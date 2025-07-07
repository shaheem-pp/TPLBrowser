//
//  DataService.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file provides static methods for loading data from various JSON files
//  into the application's data models. Data loading is performed asynchronously
//  to prevent blocking the main UI thread.

import Foundation

// MARK: - JSONFile Enum
// Defines an enum for all JSON file names used in the application.
// This improves maintainability by centralizing file names and preventing typos.
enum JSONFile: String {
    case libraryInfo = "Toronto Library Branch Info 2024"
    case visits = "Library Visits Annual by Branch"
    case events = "Toronto Library Events Feed"
}

class DataService: DataServiceProtocol {

    // MARK: - Load Libraries Asynchronously
    // Loads library branch information from "Toronto Library Branch Info 2024.json" asynchronously.
    // The completion handler is called on the main thread with the loaded libraries or an error.
    static func loadLibrariesAsync(completion: @escaping (Result<[Library], Error>) -> Void) {
        // Perform data loading on a background thread to keep the UI responsive.
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to find the JSON file in the app bundle using the defined enum.
            guard let url = Bundle.main.url(forResource: JSONFile.libraryInfo.rawValue, withExtension: "json") else {
                // If the file is not found, dispatch an error to the main thread.
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.fileNotFound(JSONFile.libraryInfo.rawValue)))
                }
                return
            }

            do {
                // Load the data from the URL.
                let data = try Data(contentsOf: url)
                // Create a JSON decoder.
                let decoder = JSONDecoder()
                // Decode the JSON data into an array of Library objects.
                let libraries = try decoder.decode([Library].self, from: data)
                // Dispatch the successful result to the main thread.
                DispatchQueue.main.async {
                    completion(.success(libraries))
                }
            } catch { // Catch any errors during data loading or decoding.
                // Dispatch the decoding error to the main thread.
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.decodingFailed(error)))
                }
            }
        }
    }

    // MARK: - Load Visits Asynchronously
    // Loads annual library visit statistics from "Library Visits Annual by Branch.json" asynchronously.
    // The completion handler is called on the main thread with the loaded visits or an error.
    static func loadVisitsAsync(completion: @escaping (Result<[Visits], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: JSONFile.visits.rawValue, withExtension: "json") else {
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.fileNotFound(JSONFile.visits.rawValue)))
                }
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let visits = try decoder.decode([Visits].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(visits))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.decodingFailed(error)))
                }
            }
        }
    }

    // MARK: - Load Events Asynchronously
    // Loads library event information from "Toronto Library Events Feed.json" asynchronously.
    // The completion handler is called on the main thread with the loaded events or an error.
    static func loadEventsAsync(completion: @escaping (Result<[Event], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: JSONFile.events.rawValue, withExtension: "json") else {
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.fileNotFound(JSONFile.events.rawValue)))
                }
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let events = try decoder.decode([Event].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(events))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DataLoadingError.decodingFailed(error)))
                }
            }
        }
    }
}

// MARK: - DataLoadingError
// Custom error type for data loading operations, providing more specific error information.
enum DataLoadingError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file '\(filename).json' not found in the app bundle."
        case .decodingFailed(let error):
            return "Failed to decode JSON data: \(error.localizedDescription)"
        }
    }
}