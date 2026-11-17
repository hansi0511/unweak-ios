import AVFoundation
import CoreVideo
import SwiftUI

/// Turns a share card with the moving Sticky Man into a short MP4 loop
/// (H.264, 1080 px wide, 30 frames per second, no sound), rendered on the device.
@MainActor
enum ShareVideoRenderer {
    nonisolated static let framesPerSecond = 30
    /// The video is at least this long; whole animation loops are repeated to reach it.
    nonisolated static let minimumSeconds = 6.0

    enum RenderError: Error {
        case writerSetup
        case pixelBuffer
        case writing
    }

    /// Number of frames and loops for an animation of the given length.
    nonisolated static func plan(animationDuration: TimeInterval) -> (frames: Int, loops: Int) {
        let loops = max(1, Int((minimumSeconds / animationDuration).rounded(.up)))
        let frames = Int((animationDuration * Double(loops) * Double(framesPerSecond)).rounded())
        return (frames, loops)
    }

    /// Animation progress (0..<1) of frame `index`.
    nonisolated static func progress(ofFrame index: Int, animationDuration: TimeInterval) -> Double {
        let seconds = Double(index) / Double(framesPerSecond)
        return seconds.truncatingRemainder(dividingBy: animationDuration) / animationDuration
    }

    /// Renders the video into a temporary file and returns its URL.
    /// - Parameter onProgress: Called with 0...1 while frames are written.
    static func render(
        content: ShareContent,
        format: ShareFormat,
        accent: Accent,
        locale: Locale,
        onProgress: (Double) -> Void
    ) async throws -> URL {
        let width = Int(format.size.width * ShareFormat.renderScale)
        let height = Int(format.size.height * ShareFormat.renderScale)
        let url = FileManager.default.temporaryDirectory
            .appending(path: "Unweak-\(format.rawValue)-\(UUID().uuidString.prefix(8)).mp4")

        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            ],
        ])
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
        ])
        guard writer.canAdd(input) else { throw RenderError.writerSetup }
        writer.add(input)
        guard writer.startWriting() else { throw RenderError.writerSetup }
        writer.startSession(atSourceTime: .zero)

        let duration = content.animation.duration
        let (frames, _) = plan(animationDuration: duration)
        let date = Date.now

        for index in 0..<frames {
            // Stops when the user switches format or closes the sheet.
            if Task.isCancelled {
                writer.cancelWriting()
                throw CancellationError()
            }
            let card = ShareCardView(
                content: content,
                format: format,
                date: date,
                progress: progress(ofFrame: index, animationDuration: duration)
            )
            .environment(\.accent, accent)
            .environment(\.locale, locale)
            let renderer = ImageRenderer(content: card)
            renderer.scale = ShareFormat.renderScale
            guard let image = renderer.cgImage,
                  let buffer = pixelBuffer(from: image, pool: adaptor.pixelBufferPool, width: width, height: height)
            else { throw RenderError.pixelBuffer }

            while !input.isReadyForMoreMediaData {
                try await Task.sleep(for: .milliseconds(5))
            }
            let time = CMTime(value: CMTimeValue(index), timescale: CMTimeScale(framesPerSecond))
            guard adaptor.append(buffer, withPresentationTime: time) else { throw RenderError.writing }

            onProgress(Double(index + 1) / Double(frames))
            // Keep the interface responsive between frames.
            await Task.yield()
        }

        input.markAsFinished()
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            writer.finishWriting {
                continuation.resume()
            }
        }
        guard writer.status == .completed else { throw RenderError.writing }
        return url
    }

    private static func pixelBuffer(from image: CGImage, pool: CVPixelBufferPool?, width: Int, height: Int) -> CVPixelBuffer? {
        var buffer: CVPixelBuffer?
        if let pool {
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
        } else {
            let attributes = [
                kCVPixelBufferCGImageCompatibilityKey: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            ] as CFDictionary
            CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA, attributes, &buffer)
        }
        guard let buffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return buffer
    }
}
