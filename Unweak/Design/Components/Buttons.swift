import SwiftUI

/// Main call to action: 60 pt high, accent surface, glow.
struct PrimaryButton: View {
    @Environment(\.accent) private var accent
    @Environment(\.isEnabled) private var isEnabled

    private let title: LocalizedStringKey
    private let systemImage: String?
    private let action: () -> Void

    init(_ title: LocalizedStringKey, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.buttonTitle)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .bold))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(Theme.onAccent)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: Theme.Layout.primaryButtonHeight)
            .background(isEnabled ? accent.color : accent.color.opacity(0.35))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .glow(isEnabled ? accent.color : .clear, radius: Theme.Glow.medium)
    }
}

/// Secondary action: dashed accent outline with a monospaced uppercase title.
struct SecondaryButton: View {
    @Environment(\.accent) private var accent

    private let title: LocalizedStringKey
    private let systemImage: String?
    private let action: () -> Void

    init(_ title: LocalizedStringKey, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .bold))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.monoBold)
                    .tracking(1.2)
                    .textCase(.uppercase)
            }
            .foregroundStyle(accent.color)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 52)
            .overlay(
                Rectangle().strokeBorder(accent.color, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
    }
}

/// Square 44 pt icon button with a strong line border, e.g. the settings or plus button in headers.
struct IconButton: View {
    private let systemImage: String
    private let label: LocalizedStringKey
    private let action: () -> Void

    init(systemImage: String, accessibilityLabel: LocalizedStringKey, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            IconButtonLabel(systemImage: systemImage)
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityLabel(label)
    }
}

/// The visual of `IconButton`, reusable as a `NavigationLink` label.
struct IconButtonLabel: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Theme.text)
            .frame(width: Theme.Layout.minTouchTarget, height: Theme.Layout.minTouchTarget)
            .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
            .contentShape(Rectangle())
    }
}

/// Back button for the top left of every pushed screen.
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IconButton(systemImage: "chevron.left", accessibilityLabel: "Back") {
            dismiss()
        }
    }
}

/// Dims the label slightly while pressed.
struct PressFeedbackStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview("All accents") {
    AccentPreview { _ in
        VStack(spacing: 12) {
            PrimaryButton("Start workout", systemImage: "play.fill") {}
            SecondaryButton("Create custom workout", systemImage: "plus") {}
            HStack {
                BackButton()
                IconButton(systemImage: "slider.horizontal.3", accessibilityLabel: "Settings") {}
                Spacer()
            }
        }
    }
}

#Preview("German") {
    VStack(spacing: 12) {
        PrimaryButton("Start workout", systemImage: "play.fill") {}
        SecondaryButton("Create custom workout", systemImage: "plus") {}
    }
    .padding(Theme.Layout.screenEdge)
    .frame(maxHeight: .infinity)
    .background(Theme.background)
    .environment(\.locale, Locale(identifier: "de"))
}
