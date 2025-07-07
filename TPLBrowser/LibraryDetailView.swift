
//
//  LibraryDetailView.swift
//  TPLBrowser
//
//  Created by Gemini on 2025-07-07.
//
//  This file defines the detailed view for a single library branch,
//  displaying its information, services, annual visits, and upcoming events.

import SwiftUI
import MapKit

struct LibraryDetailView: View {
    let library: Library // The library object passed to this view.

    // State variables to hold all visits and events data.
    // These are loaded once when the view appears.
    @State private var allVisits: [Visits] = []
    @State private var allEvents: [Event] = []

    // Computed property to filter visits relevant to the current library.
    // It matches the library's branchCode with the visit record's branchCode.
    var relevantVisits: [Visits] {
        allVisits.filter { $0.branchCode == library.branchCode }
            .sorted { $0.year > $1.year } // Sort by year, newest first
    }

    // Computed property to filter events relevant to the current library.
    // It matches the library's branchName with the event's library name.
    var relevantEvents: [Event] {
        allEvents.filter { $0.library == library.branchName }
            .sorted { $0.startdate < $1.startdate } // Sort by start date, earliest first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Library Icon
                Image(systemName: "building.columns.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 10)

                // Library Branch Name
                Text(library.branchName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Divider() // Visual separator

                // Basic Library Information (Address, Website, Phone)
                Group {
                    DetailRow(title: "Address", content: library.address)

                    // Display website as a clickable link if available
                    if let url = URL(string: library.website) {
                        Link(destination: url) {
                            DetailRow(title: "Website", content: library.website)
                                .foregroundColor(.blue)
                        }
                    }

                    DetailRow(title: "Phone", content: library.telephone)
                }
                .padding(.horizontal)

                // Neighborhood Information (if available)
                if let nbhdName = library.nbhdName {
                    DetailRow(title: "Neighborhood", content: nbhdName)
                        .padding(.horizontal)
                }

                // Get Directions Button
                Button(action: {
                    // Open Apple Maps with directions to the library's coordinates.
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: library.coordinate))
                    mapItem.name = library.branchName
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                }) {
                    Label("Get Directions", systemImage: "map.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Divider() // Visual separator

                // Library Services Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Services")
                        .font(.headline)
                        .padding(.horizontal)

                    // Display services using a grid for better layout
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        // Each ServiceBadge represents a specific service with an icon and text.
                        if library.kidsStop == 1 { ServiceBadge(icon: "figure.and.child.holdinghands", text: "KidsStop", color: .blue) }
                        if library.leadingReading == 1 { ServiceBadge(icon: "text.book.closed", text: "Leading Reading", color: .orange) }
                        if library.clc == 1 { ServiceBadge(icon: "laptopcomputer", text: "CLC", color: .green) }
                        if library.dih == 1 { ServiceBadge(icon: "lightbulb", text: "DIH", color: .yellow) }
                        if library.teenCouncil == 1 { ServiceBadge(icon: "person.3", text: "Teen Council", color: .purple) }
                        if library.youthHub == 1 { ServiceBadge(icon: "person.2.wave.2", text: "Youth Hub", color: .red) }
                        if library.adultLiteracyProgram == 1 { ServiceBadge(icon: "textformat.abc", text: "Adult Literacy", color: .indigo) }
                    }
                    .padding(.horizontal)
                }

                Divider() // Visual separator

                // Annual Visits Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Annual Visits")
                        .font(.headline)
                        .padding(.horizontal)

                    if relevantVisits.isEmpty {
                        Text("No visit data available for this branch.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        // Display visits in a list, showing year and number of visits.
                        ForEach(relevantVisits) { visit in
                            HStack {
                                Text("\(visit.year):")
                                    .font(.body)
                                Spacer()
                                Text("\(visit.visits) visits")
                                    .font(.body)
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Divider() // Visual separator

                // Upcoming Events Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Upcoming Events")
                        .font(.headline)
                        .padding(.horizontal)

                    if relevantEvents.isEmpty {
                        Text("No upcoming events for this branch.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        // Display events in a list, showing title, dates, and times.
                        ForEach(relevantEvents) { event in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Dates: \(event.startdate) to \(event.enddate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if let startTime = event.starttime, startTime != "None" {
                                    Text("Time: \(startTime)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                if let endTime = event.endtime, endTime != "None" {
                                    Text("End Time: \(endTime)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                if let location = event.location, location != "None" {
                                    Text("Location: \(location)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Text(event.description)
                                    .font(.caption)
                                    .lineLimit(3) // Limit description to 3 lines
                                    .padding(.top, 2)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.bottom, 5)
                        }
                    }
                }

                Spacer() // Pushes content to the top
            }
            .padding(.vertical) // Vertical padding for the entire scroll view content
        }
        .navigationTitle("Details") // Navigation bar title
        .navigationBarTitleDisplayMode(.inline) // Display title inline
        .onAppear { // Action performed when the view appears
            // Load all visits and events data when the view is shown.
            allVisits = DataService.loadVisits()
            allEvents = DataService.loadEvents()
        }
    }
}

// MARK: - DetailRow
// A reusable view for displaying a title and its corresponding content.
struct DetailRow: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(content)
                .font(.body)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - ServiceBadge
// A reusable view for displaying a library service with an icon and text.
struct ServiceBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(color)
                .cornerRadius(8)
            Text(text)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - LibraryDetailView_Previews
// Provides a preview for LibraryDetailView in Xcode's canvas.
struct LibraryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Loads the first library from the data for preview purposes.
            LibraryDetailView(library: DataService.loadLibraries().first!)
        }
    }
}
