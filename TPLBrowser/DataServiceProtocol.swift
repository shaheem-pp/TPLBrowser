
//
//  DataServiceProtocol.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file defines the protocol for the DataService, enabling dependency injection
//  and making the data loading logic more testable and flexible.

import Foundation

// MARK: - DataServiceProtocol
// Defines the contract for any data service that provides library, visits, and event data.
protocol DataServiceProtocol {
    static func loadLibrariesAsync(completion: @escaping (Result<[Library], Error>) -> Void)
    static func loadVisitsAsync(completion: @escaping (Result<[Visits], Error>) -> Void)
    static func loadEventsAsync(completion: @escaping (Result<[Event], Error>) -> Void)
}
