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
    let startdateString: String // The start date of the event as a String (e.g., "2025-09-05").
    let enddateString: String   // The end date of the event as a String (e.g., "2025-12-19").
    let starttimeString: String? // The start time of the event as a String (optional, can be "None").
    let endtimeString: String?   // The end time of the event as a String (optional, can be "None").
    let library: String // The name of the library hosting the event.
                        // This can be used to link events to specific library branches.
    let location: String? // The specific location within the library (optional, can be "None").
    let description: String // A detailed description of the event.

    // MARK: - CodingKeys
    // Custom keys to map JSON field names to Swift property names.
    // This is necessary because JSON keys start with lowercase letters or underscores.
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case startdateString = "startdate"
        case enddateString = "enddate"
        case starttimeString = "starttime"
        case endtimeString = "endtime"
        case library, location, description
    }

    // MARK: - Date Formatters
    // Static date formatter for parsing date strings.
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // Static date formatter for parsing time strings.
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: - Computed Date Properties
    // Converts the startdateString to a Date object.
    var startdate: Date? {
        Event.dateFormatter.date(from: startdateString)
    }

    // Converts the enddateString to a Date object.
    var enddate: Date? {
        Event.dateFormatter.date(from: enddateString)
    }

    // Converts the starttimeString to a Date object.
    var starttime: Date? {
        guard let timeString = starttimeString, timeString != "None" else { return nil }
        return Event.timeFormatter.date(from: timeString)
    }

    // Converts the endtimeString to a Date object.
    var endtime: Date? {
        guard let timeString = endtimeString, timeString != "None" else { return nil }
        return Event.timeFormatter.date(from: timeString)
    }

    // MARK: - Display Strings
    // Formatted string for displaying the start date.
    var formattedStartDate: String {
        startdate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
    }

    // Formatted string for displaying the end date.
    var formattedEndDate: String {
        enddate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"
    }

    // Formatted string for displaying the start time.
    var formattedStartTime: String {
        starttime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
    }

    // Formatted string for displaying the end time.
    var formattedEndTime: String {
        endtime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
    }
}