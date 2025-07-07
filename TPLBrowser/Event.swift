
//
//  Event.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file defines the data structure for library events.
//  It corresponds to the "Toronto Library Events Feed.json" file.

import Foundation

// MARK: - Event
// This struct represents a single library event.
struct Event: Codable, Identifiable {
    let id: Int         // Unique identifier for the event.
    let title: String   // The title of the event.
    let startdate: String // The start date of the event (e.g., "2025-09-05").
    let enddate: String   // The end date of the event (e.g., "2025-12-19").
    let starttime: String? // The start time of the event (optional, can be "None").
    let endtime: String?   // The end time of the event (optional, can be "None").
    let library: String // The name of the library hosting the event.
                        // This can be used to link events to specific library branches.
    let location: String? // The specific location within the library (optional, can be "None").
    let description: String // A detailed description of the event.

    // MARK: - CodingKeys
    // Custom keys to map JSON field names to Swift property names.
    // This is necessary because JSON keys start with lowercase letters or underscores.
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, startdate, enddate, starttime, endtime, library, location, description
    }
}
