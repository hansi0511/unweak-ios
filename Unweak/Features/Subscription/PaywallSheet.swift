import StoreKit
import SwiftUI

/// Subscription page (Design V2, `V2-Abo`): unlock skills and unlimited custom workouts.
/// Shows the active state with "Manage subscription" once Pro is active.
struct PaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionStore.self) private var subscription
    @State private var selectedID = ProductID.yearly
    @State private var isWorking = false
    @State private var isManaging = false

    var body: some View {
        ScreenContainer {
            HStack {
                IconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                    dismiss()
                }
                Spacer()
                Badge(kind: .subscription)
            }

            StickyFigureCanvas(figure: StickyAnimation.muscleUp.figure(at: StickyAnimation.muscleUp.endPoseProgress))
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Unlock all skills")
                    .font(.grotesk(32))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Text("10 workouts always stay free.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
            }

            VStack(alignment: .leading, spacing: 14) {
                benefit("All 6 skills")
                benefit("Goals with 5 stages")
                benefit("Unlimited custom workouts")
            }
            .padding(.horizontal, 8)

            if subscription.isPro {
                activeSection
            } else {
                offerSection
            }
        }
        .presentationBackground(Theme.background)
        .manageSubscriptionsSheet(isPresented: $isManaging)
        .onChange(of: subscription.isPro) { _, isPro in
            if isPro { dismiss() }
        }
        .task {
            // Try again each time the page opens, e.g. after the connection is back.
            if subscription.loadState != .loaded {
                await subscription.loadProducts()
            }
        }
    }

    // MARK: Sections

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Card {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Theme.subscription)
                        .accessibilityHidden(true)
                    Text("Pro is active. Thank you!")
                        .font(.textSemibold(15))
                        .foregroundStyle(Theme.text)
                }
            }
            Button {
                isManaging = true
            } label: {
                Text("Manage subscription")
                    .font(.text(15))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                    .overlay(Rectangle().strokeBorder(Theme.lineStrong, lineWidth: 1))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
        }
    }

    @ViewBuilder
    private var offerSection: some View {
        VStack(spacing: 10) {
            switch subscription.loadState {
            case .loading:
                ProgressView()
                    .tint(Theme.text)
                    .frame(maxWidth: .infinity, minHeight: 120)
            case .failed, .noProducts:
                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        if subscription.loadState == .failed {
                            Text("Prices could not be loaded. Check your internet connection.")
                                .font(.text(15))
                                .foregroundStyle(Theme.textSoft)
                        } else {
                            Text("The subscriptions are not available right now. Please try again later.")
                                .font(.text(15))
                                .foregroundStyle(Theme.textSoft)
                            #if DEBUG
                            // Developer hint, not shown in App Store builds.
                            Text(verbatim: "DEBUG: The App Store returned no products for \(ProductID.all.sorted().joined(separator: ", ")). In the simulator, check Edit Scheme → Run → Options → StoreKit Configuration = Unweak.storekit, and open Unweak.storekit in Xcode to see whether it loads.")
                                .font(.text(12))
                                .foregroundStyle(Theme.subscription)
                            #endif
                        }
                        Button {
                            Task { await subscription.loadProducts() }
                        } label: {
                            Label("Try again", systemImage: "arrow.clockwise")
                                .font(.text(15))
                                .foregroundStyle(Theme.text)
                                .frame(minHeight: Theme.Layout.minTouchTarget)
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            case .loaded:
                HStack(spacing: 10) {
                    if let yearly = subscription.yearly {
                        PlanOption(
                            title: "Year",
                            price: yearly.displayPrice,
                            detail: Text("\((yearly.price / 12).formatted(yearly.priceFormatStyle)) per month"),
                            isSelected: selectedID == yearly.id
                        ) { selectedID = yearly.id }
                    }
                    if let monthly = subscription.monthly {
                        PlanOption(
                            title: "Month",
                            price: monthly.displayPrice,
                            detail: Text("monthly"),
                            isSelected: selectedID == monthly.id
                        ) { selectedID = monthly.id }
                    }
                }
            }
        }

        if let issue = subscription.issue {
            Text(issue.message)
                .font(.text(13))
                .foregroundStyle(Theme.danger)
        }

        VStack(spacing: 12) {
            PrimaryButton("Start Pro") {
                startPurchase()
            }
            .disabled(isWorking || selectedProduct == nil)

            Button {
                Task {
                    isWorking = true
                    await subscription.restore()
                    isWorking = false
                }
            } label: {
                Text("Restore purchases")
                    .font(.text(14))
                    .foregroundStyle(Theme.textSoft)
                    .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .disabled(isWorking)
        }

        VStack(spacing: 6) {
            Text("Cancel anytime")
                .font(.text(13))
                .foregroundStyle(Theme.textSoft)
            // Required by the App Store on subscription pages.
            Text("The subscription renews automatically unless you cancel it at least 24 hours before the end of the period in your Apple ID settings. Payment is charged to your Apple ID.")
                .font(.text(11))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var selectedProduct: Product? {
        subscription.products.first { $0.id == selectedID }
    }

    private func startPurchase() {
        guard let product = selectedProduct else { return }
        Task {
            isWorking = true
            defer { isWorking = false }
            do {
                // `Product` is Sendable, so this call is safe under strict concurrency
                // (SwiftUI's PurchaseAction is not).
                let result = try await product.purchase()
                _ = await subscription.handle(result)
            } catch {
                subscription.purchaseFailed()
            }
        }
    }

    private func benefit(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.subscription)
                .accessibilityHidden(true)
            Text(text)
                .font(.text(17))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Selectable subscription option as a tile: period, price and a note below.
private struct PlanOption: View {
    let title: LocalizedStringKey
    let price: String
    let detail: Text?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.text(14))
                    .foregroundStyle(Theme.textSoft)
                Text(verbatim: price)
                    .font(.grotesk(22))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let detail {
                    detail
                        .font(.text(13))
                        .foregroundStyle(Theme.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
            .background(isSelected ? Theme.surfaceSelected : Theme.surface)
            .overlay(Rectangle().strokeBorder(isSelected ? Theme.subscription : Theme.line, lineWidth: isSelected ? 2 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview("Free") {
    PaywallSheet()
        .previewEnvironment()
}

#Preview("Pro, German") {
    PaywallSheet()
        .environment(SubscriptionStore.preview(isPro: true))
        .previewEnvironment()
        .environment(\.locale, Locale(identifier: "de"))
}
