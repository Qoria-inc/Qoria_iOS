//
//  HomeViewModel.swift
//  Qoria_App
//
//  Created by Cursor AI on 11/02/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var homeData: dynamicJSON?
    @Published var items: [dynamicJSON] = []
    @Published var hasNextPage: Bool = true
    
    private let getHomeDataUseCase: GetHomeDataUseCase
    private var loadTask: Task<Void, Never>?
    private var currentPage: Int = 1
    private let pageSize: Int = 20 // Default per backend, max 100
    
    init(getHomeDataUseCase: GetHomeDataUseCase) {
        self.getHomeDataUseCase = getHomeDataUseCase
    }

    // MARK: - Lifecycle

    func loadHome() {
        self.loadTask?.cancel()
        self.loadTask = Task { await refreshFeed() }
    }

    // MARK: - Intent
    func refreshFeed() async {
        currentPage = 1
        hasNextPage = true
        await loadNextPage(replacingExistingItems: true)
    }

    func loadNextPageIfNeeded(currentIndex: Int) async {
        // Trigger when user is near the bottom (last 5 items)
        let thresholdIndex = max(items.count - 5, 0)
        guard currentIndex >= thresholdIndex else { return }
        await loadNextPage()
    }

    private func loadNextPage(replacingExistingItems: Bool = false) async {
        guard hasNextPage, !isLoading, !isLoadingMore else { return }

        if items.isEmpty || replacingExistingItems {
            isLoading = true
        } else {
            isLoadingMore = true
        }

        errorMessage = nil
        
        do {
            let json = try await getHomeDataUseCase.execute(page: currentPage, pageSize: pageSize)
            self.homeData = json

            let newItems = json["data"]["results"].array ?? []
            if replacingExistingItems || currentPage == 1 {
                self.items = newItems
            } else {
                self.items.append(contentsOf: newItems)
            }

            let pagination = json["pagination"]
            self.hasNextPage = pagination["has_next"].bool ?? false
            let currentPageFromResponse = pagination["page"].int ?? 1
            self.currentPage = currentPageFromResponse + 1

            print("Loaded home page \(currentPageFromResponse) items=\(newItems.count) hasNext=\(hasNextPage)")
        } catch is CancellationError {
            // ignore
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription
            ?? error.localizedDescription
        }

        isLoading = false
        isLoadingMore = false
    }
}
