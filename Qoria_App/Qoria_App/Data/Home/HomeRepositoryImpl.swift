//
//  HomeRepositoryImpl.swift
//  Qoria_App
//
//  Concrete implementation of HomeRepository that
//  uses the existing NetworkCall / NetworkManager stack.
//

final class HomeRepositoryImpl: HomeRepository {

    private let networkCall: NetworkCalling

    init(networkCall: NetworkCalling = NetworkCall.shared) {
        self.networkCall = networkCall
    }

    func fetchHomeData() async throws -> dynamicJSON {
        try await networkCall.getTestTodo()
    }
}
