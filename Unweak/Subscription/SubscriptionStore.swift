import Foundation
import Observation
import StoreKit
import SwiftUI

/// Something that went wrong while buying or restoring, shown on the subscription page.
enum PurchaseIssue: Equatable, Sendable {
    case unverified
    case pending
    case failed
    case restoreFailed
    case nothingToRestore

    var message: LocalizedStringKey {
        switch self {
        case .unverified: "The purchase could not be verified."
        case .pending: "The purchase is waiting for approval."
        case .failed: "The purchase did not work. Please try again."
        case .restoreFailed: "Purchases could not be restored. Please try again."
        case .nothingToRestore: "No active subscription was found for this Apple ID."
        }
    }
}

/// Pro subscription via StoreKit 2: products, current entitlement, purchase results,
/// restore. Listens to transaction updates (renewals, refunds, purchases on other devices).
@MainActor
@Observable
final class SubscriptionStore {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    private(set) var isPro = false
    /// Yearly first, then monthly.
    private(set) var products: [Product] = []
    private(set) var loadState: LoadState = .loading
    /// Set when the last purchase or restore did not work.
    private(set) var issue: PurchaseIssue?

    var access: Access { Access(isPro: isPro) }

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    /// - Parameter connect: `false` keeps StoreKit untouched (previews, tests).
    init(connect: Bool = true) {
        guard connect else {
            loadState = .loaded
            return
        }
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlement()
            }
        }
        Task {
            await refreshEntitlement()
            await loadProducts()
        }
    }

    /// Store with a fixed state, for Xcode Previews.
    static func preview(isPro: Bool) -> SubscriptionStore {
        let store = SubscriptionStore(connect: false)
        store.isPro = isPro
        return store
    }

    var yearly: Product? { products.first { $0.id == ProductID.yearly } }
    var monthly: Product? { products.first { $0.id == ProductID.monthly } }

    func loadProducts() async {
        loadState = .loading
        do {
            let loaded = try await Product.products(for: ProductID.all)
            products = loaded.sorted { $0.price > $1.price }
            loadState = loaded.isEmpty ? .failed : .loaded
        } catch {
            loadState = .failed
        }
    }

    /// Checks the current entitlements for an active Pro subscription.
    func refreshEntitlement() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               ProductID.all.contains(transaction.productID),
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPro = active
    }

    /// Handles the result of `PurchaseAction` (SwiftUI `@Environment(\.purchase)`).
    /// Returns `true` when Pro is now active.
    func handle(_ result: Product.PurchaseResult) async -> Bool {
        issue = nil
        switch result {
        case .success(.verified(let transaction)):
            await transaction.finish()
            await refreshEntitlement()
            return isPro
        case .success(.unverified):
            issue = .unverified
            return false
        case .pending:
            issue = .pending
            return false
        case .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func purchaseFailed() {
        issue = .failed
    }

    /// Asks the App Store for earlier purchases of this Apple ID.
    func restore() async {
        issue = nil
        do {
            try await AppStore.sync()
        } catch {
            issue = .restoreFailed
        }
        await refreshEntitlement()
        if !isPro, issue == nil {
            issue = .nothingToRestore
        }
    }
}
