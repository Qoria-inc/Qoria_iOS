//
//  GetHomeDataUseCase.swift
//  Qoria_App
//
//  Simple use case that delegates to HomeRepository.
//

import Foundation

struct GetHomeDataUseCase {

    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func execute(page: Int, pageSize: Int = 20) async throws -> dynamicJSON {
        try await repository.fetchHomeData(page: page, pageSize: pageSize)
    }
}
