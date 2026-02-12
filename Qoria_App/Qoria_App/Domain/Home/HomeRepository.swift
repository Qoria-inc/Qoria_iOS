//
//  HomeRepository.swift
//  Qoria_App
//
//  Defines the abstract contract for fetching
//  Home screen data, independent from networking.
//

import Foundation

protocol HomeRepository {
    func fetchHomeData() async throws -> dynamicJSON
}
