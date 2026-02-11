//
//  HomeRepositoryImpl.swift
//  Qoria_App
//
//  Concrete implementation of HomeRepository that
//  uses the existing NetworkCall / NetworkManager stack.
//

import Foundation

final class HomeRepositoryImpl: HomeRepository {

    // MARK: - Dependencies

    private let networkCall: NetworkCall

    // Example of a potentially expensive resource that should be lazy.
    lazy var debugParser: dynamicJSON = {
        dynamicJSON(["source": "HomeRepositoryImpl"])
    }()

    // MARK: - Init

    init(networkCall: NetworkCall = .shared) {
        self.networkCall = networkCall
    }

    // MARK: - HomeRepository

    func fetchHomeData() async throws -> dynamicJSON {
        // For now, reuse the test todo endpoint as a placeholder.
        // Replace with a dedicated Home feed endpoint when available.
        let json = try await networkCall.getTestTodo()
        return json
    }
}

