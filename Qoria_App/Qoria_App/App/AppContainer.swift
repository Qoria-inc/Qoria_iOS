//
//  AppContainer.swift
//  Qoria_App
//
//  Created by Fahim Rahman on 11/02/2026.
//

final class AppContainer {
    static let shared = AppContainer()
    private init() {}

    private lazy var homeRepo: HomeRepository = HomeRepositoryImpl()
    private lazy var homeUseCase = GetHomeDataUseCase(repository: homeRepo)

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(getHomeDataUseCase: homeUseCase)
    }
}
