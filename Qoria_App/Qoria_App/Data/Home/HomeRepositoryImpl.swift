//
//  HomeRepositoryImpl.swift
//  Qoria_App
//
//  Concrete implementation of HomeRepository that
//  uses the existing NetworkCall / NetworkManager stack.
//

import Alamofire
final class HomeRepositoryImpl: HomeRepository {

    private let networkCall: NetworkCalling

    init(networkCall: NetworkCalling = NetworkCall.shared) {
        self.networkCall = networkCall
    }

    func fetchHomeData(page: Int, pageSize: Int) async throws -> dynamicJSON {
        let json = try await NetworkManager.shared.requestJSON(
            url: AppUrl.shared.homeFeedURL(),
            method: .get,
            parameters: [
                "page": page,
                "page_size": pageSize
            ]
        )
        return json
    }
}
