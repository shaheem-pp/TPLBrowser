//
//  DataService.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file provides static methods for loading data from various JSON files
//  into the application's data models.

import Foundation

class DataService {

    // MARK: - Load Libraries
    // Loads library branch information from "Toronto Library Branch Info 2024.json".
    // Returns an array of Library objects.
    static func loadLibraries() -> [Library] {
        // Attempt to find the JSON file in the app bundle.
        if let url = Bundle.main.url(forResource: "Toronto Library Branch Info 2024", withExtension: "json") {
            do {
                // Load the data from the URL.
                let data = try Data(contentsOf: url)
                // Create a JSON decoder.
                let decoder = JSONDecoder()
                // Decode the JSON data into an array of Library objects.
                let libraries = try decoder.decode([Library].self, from: data)
                return libraries
            } catch { // Catch any errors during data loading or decoding.
                print("Error decoding Library JSON: \(error)")
            }
        }
        // Return an empty array if the file is not found or decoding fails.
        return []
    }

    // MARK: - Load Visits
    // Loads annual library visit statistics from "Library Visits Annual by Branch.json".
    // Returns an array of Visits objects.
    static func loadVisits() -> [Visits] {
        // Attempt to find the JSON file in the app bundle.
        if let url = Bundle.main.url(forResource: "Library Visits Annual by Branch", withExtension: "json") {
            do {
                // Load the data from the URL.
                let data = try Data(contentsOf: url)
                // Create a JSON decoder.
                let decoder = JSONDecoder()
                // Decode the JSON data into an array of Visits objects.
                let visits = try decoder.decode([Visits].self, from: data)
                return visits
            } catch { // Catch any errors during data loading or decoding.
                print("Error decoding Visits JSON: \(error)")
            }
        }
        // Return an empty array if the file is not found or decoding fails.
        return []
    }

    // MARK: - Load Events
    // Loads library event information from "Toronto Library Events Feed.json".
    // Returns an array of Event objects.
    static func loadEvents() -> [Event] {
        // Attempt to find the JSON file in the app bundle.
        if let url = Bundle.main.url(forResource: "Toronto Library Events Feed", withExtension: "json") {
            do {
                // Load the data from the URL.
                let data = try Data(contentsOf: url)
                // Create a JSON decoder.
                let decoder = JSONDecoder()
                // Decode the JSON data into an array of Event objects.
                let events = try decoder.decode([Event].self, from: data)
                return events
            } catch { // Catch any errors during data loading or decoding.
                print("Error decoding Events JSON: \(error)")
            }
        }
        // Return an empty array if the file is not found or decoding fails.
        return []
    }
}