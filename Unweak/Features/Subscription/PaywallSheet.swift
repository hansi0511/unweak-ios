import StoreKit
import SwiftUI

/// Subscription page (SCREENS.md 7): unlock skills and unlimited custom workouts.
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

            VStack(alignment: .leading, spacing: 8) {
                Text("Unlock all skills")
                    .font(.screenTitle)
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)
                Text("The 10 workouts stay free.")
                    .font(.text(15))
                    .foregroundStyle(Theme.textSoft)
            }

            StickyFigureCanvas(figure: StickyAnimation.muscleUp.figure(at: StickyAnimation.muscleUp.endPoseProgress))
                .frame(height: 170)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 12) {
                benefit("All skills with their workouts, from easy to hard")
                benefit("Set a skill as your goal and track its stages")
                benefit("Unlimited custom workouts")
            }

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
            SecondaryButton("Manage subscription") {
                isManaging = true
            }
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
            case .failed:
                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Prices could not be loaded. Check your internet connection.")
                            .font(.text(15))
                            .foregroundStyle(Theme.textSoft)
                        Button {
                            Task { await subscription.loadProducts() }
                        } label: {
                            ChipLabel("Try again", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(PressFeedbackStyle())
                    }
                }
            case .loaded:
                if let yearly = subscription.yearly {
                    PlanOption(
                        title: "Yearly",
                        price: yearly.displayPrice,
                        detail: Text("Equals \((yearly.price / 12).formatted(yearly.priceFormatStyle)) per month"),
                        isSelected: selectedID == yearly.id
                    ) { selectedID = yearly.id }
                }
                if let monthly = subscription.monthly {
                    PlanOption(
                        title: "Monthly",
                        price: monthly.displayPrice,
                        detail: nil,
                        isSelected: selectedID == monthly.id
                    ) { selectedID = monthly.id }
                }
            }
        }

        if let issue = subscription.issue {
            Text(issue.message)
                .font(.text(13))
                .foregroundStyle(Theme.danger)
        }

        VStack(spacing: 12) {
            PrimaryButton("Start subscription", systemImage: "arrow.right") {
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
                    .font(.monoBold)
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.textSoft)
                    .frame(maxWidth: .infinity, minHeight: Theme.Layout.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedbackStyle())
            .disabled(isWorking)
        }

        Text("The subscription renews automatically unless you cancel it at least 24 hours before the end of the period in your Apple ID settings. Payment is charged to your Apple ID.")
            .font(.text(13))
            .foregroundStyle(Theme.textMuted)
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
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.subscription)
                .accessibilityHidden(true)
            Text(text)
                .font(.text(15))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Selectable subscription option: period, price and an optional detail line.
private struct PlanOption: View {
    let title: LocalizedStringKey
    let price: String
    let detail: Text?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Theme.subscription : Theme.lineStrong)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.textSemibold(17))
                        .foregroundStyle(Theme.text)
                    if let detail {
                        detail
                            .font(.text(13))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                Spacer(minLength: 0)
                Text(verbatim: price)
                    .font(.metric)
                    .foregroundStyle(Theme.text)
            }
            .padding(14)
            .frame(minHeight: 64)
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
