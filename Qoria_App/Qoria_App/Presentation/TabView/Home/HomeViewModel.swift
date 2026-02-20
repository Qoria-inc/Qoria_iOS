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
        items = []
        await loadNextPage()
    }

    func loadNextPageIfNeeded(currentIndex: Int) async {
        // Trigger when user is near the bottom (last 5 items)
        let thresholdIndex = max(items.count - 5, 0)
        guard currentIndex >= thresholdIndex else { return }
        await loadNextPage()
    }

    private func loadNextPage() async {
        guard hasNextPage, !isLoadingMore else { return }

        if items.isEmpty {
            isLoading = true
        } else {
            isLoadingMore = true
        }

        errorMessage = nil
        
        do {
            let json = try await getHomeDataUseCase.execute(page: currentPage, pageSize: pageSize)
            self.homeData = json

            let newItems = json["data"]["results"].array ?? []
            if currentPage == 1 {
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
    
    // MARK:- Temporary login solution since we don't have any login screen yet. #DevNote.
    func performHardcodedLogin() async {
        do {
            let json = try await NetworkCall.shared.loginWithEmail()
            
            let data = json["data"]
            let accessToken = data["access"].string ?? data["access_token"].string
            let refreshToken = data["refresh"].string ?? data["refresh_token"].string
            
            AuthTokenStore.shared.accessToken = accessToken
            AuthTokenStore.shared.refreshToken = refreshToken
            
            if let access = accessToken, let refresh = refreshToken {
                print("LoginWithEmail success. Access token prefix: \(access.prefix(10)), Refresh token prefix: \(refresh.prefix(10))")
            } else {
                print("LoginWithEmail success but tokens missing or malformed. Full JSON: \(json)")
            }
            
            // Optionally inspect user:
            // let user = data["user"]
            // let email = user["email"].string
        } catch {
            // TODO: you can set an errorMessage property if you want
            print("Login failed: \(error)")
        }
    }
}
