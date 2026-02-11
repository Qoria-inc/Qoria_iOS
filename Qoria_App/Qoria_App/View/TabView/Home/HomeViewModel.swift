//
//  HomeViewModel.swift
//  Qoria_App
//
//  Created by Cursor AI on 11/02/2026.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var homeData: dynamicJSON?

    // MARK: - Dependencies

    private let getHomeDataUseCase: GetHomeDataUseCase

    // MARK: - Init

    init(getHomeDataUseCase: GetHomeDataUseCase) {
        self.getHomeDataUseCase = getHomeDataUseCase
    }

    // MARK: - Lifecycle

    func onAppear() {
        Task { await loadHome() }
    }

    // MARK: - Intent

    func loadHome() async {
        isLoading = true
        errorMessage = nil

        do {
            let data = try await getHomeDataUseCase.execute()
            homeData = data
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
        }

        isLoading = false
    }
}

