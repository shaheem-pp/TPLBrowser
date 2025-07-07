
//
//  Visits.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file defines the data structure for library visit statistics.
//  It corresponds to the "Library Visits Annual by Branch.json" file.

import Foundation

// MARK: - Visits
// This struct represents a single record of annual visits for a library branch.
struct Visits: Codable, Identifiable {
    let id: Int          // Unique identifier for the visit record.
    let year: Int        // The year for which the visit data is recorded.
    let branchCode: String // The unique code for the library branch (e.g., "AB", "ACD").
                         // This can be used to link visit data to specific library branches.
    let visits: String   // The number of visits for the year, stored as a String.
                         // Note: While "Visits" is a number, it's parsed as a String
                         // to handle potential non-numeric values or large numbers
                         // that might exceed Int limits without careful handling.

    // MARK: - CodingKeys
    // Custom keys to map JSON field names to Swift property names.
    // This is necessary because JSON keys start with uppercase letters or underscores.
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case year = "Year"
        case branchCode = "BranchCode"
        case visits = "Visits"
    }
}
