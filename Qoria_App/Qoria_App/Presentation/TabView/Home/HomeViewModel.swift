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
    @Published var errorMessage: String?
    @Published var homeData: dynamicJSON?
    
    private let getHomeDataUseCase: GetHomeDataUseCase
    private var loadTask: Task<Void, Never>?
    
    init(getHomeDataUseCase: GetHomeDataUseCase) {
        self.getHomeDataUseCase = getHomeDataUseCase
    }

    // MARK: - Lifecycle

    func loadHome() {
        self.loadTask?.cancel()
        self.loadTask = Task { await loadHome() }
    }

    // MARK: - Intent

    func loadHome() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            self.homeData = try await getHomeDataUseCase.execute()
        } catch is CancellationError {
            // ignore
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription
            ?? error.localizedDescription
        }
    }
}
