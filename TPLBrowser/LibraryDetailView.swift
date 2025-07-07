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

// MARK: - LibraryDetailView
struct LibraryDetailView: View {
    let library: Library // The library object passed to this view.
    var dataService: DataServiceProtocol.Type = DataService.self // Injected DataService dependency

    // MARK: - State Properties
    // State variables to hold all visits and events data.
    // These are populated asynchronously when the view appears.
    @State private var allVisits: [Visits] = []
    @State private var allEvents: [Event] = []
    // State properties to control the visibility of loading indicators for visits and events.
    @State private var isLoadingVisits = true
    @State private var isLoadingEvents = true
    // State properties to store any errors during data loading for visits and events.
    @State private var showingVisitsErrorAlert = false
    @State private var visitsErrorMessage: String = ""
    @State private var showingEventsErrorAlert = false
    @State private var eventsErrorMessage: String = ""

    // MARK: - Computed Properties
    // Filters visits relevant to the current library and sorts them by year.
    var relevantVisits: [Visits] {
        allVisits.filter { $0.branchCode == library.branchCode }
            .sorted { $0.year > $1.year } // Sort by year, newest first
    }

    // Filters events relevant to the current library and sorts them by start date.
    var relevantEvents: [Event] {
        allEvents.filter { $0.library == library.branchName }
            .sorted { $0.startdate ?? Date.distantFuture < $1.startdate ?? Date.distantFuture } // Sort by start date, earliest first
    }

    // MARK: - Body
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
                        .accessibilityElement(children: .combine) // Combine title and content for accessibility
                        .accessibilityLabel("Address: \(library.address)")

                    // Display website as a clickable link if available
                    if let url = URL(string: library.website) {
                        Link(destination: url) {
                            DetailRow(title: "Website", content: library.website)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Website: \(library.website)")
                    }

                    DetailRow(title: "Phone", content: library.telephone)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Phone: \(library.telephone)")
                }
                .padding(.horizontal)

                // Neighborhood Information (if available)
                if let nbhdName = library.nbhdName {
                    DetailRow(title: "Neighborhood", content: nbhdName)
                        .padding(.horizontal)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Neighborhood: \(nbhdName)")
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
                .accessibilityLabel("Get Directions to \(library.branchName)")

                Divider() // Visual separator

                // Library Services Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Services")
                        .font(.headline)
                        .padding(.horizontal)
                        .accessibilityAddTraits(.isHeader) // Mark as a header for accessibility

                    // Define all possible services with their properties.
                    let services: [(condition: Int?, icon: String, text: String, color: Color)] = [
                        (library.kidsStop, "figure.and.child.holdinghands", "KidsStop", .blue),
                        (library.leadingReading, "text.book.closed", "Leading Reading", .orange),
                        (library.clc, "laptopcomputer", "CLC", .green),
                        (library.dih, "lightbulb", "DIH", .yellow),
                        (library.teenCouncil, "person.3", "Teen Council", .purple),
                        (library.youthHub, "person.2.wave.2", "Youth Hub", .red),
                        (library.adultLiteracyProgram, "textformat.abc", "Adult Literacy", .indigo)
                    ]

                    // Display services using a grid for better layout.
                    // Only display services where the condition is 1 (true).
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(services.filter { $0.condition == 1 }, id: \.text) { service in
                            ServiceBadge(icon: service.icon, text: service.text, color: service.color)
                                .accessibilityLabel("\(service.text) service available")
                        }
                    }
                    .padding(.horizontal)
                }

                Divider() // Visual separator

                // Annual Visits Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Annual Visits")
                        .font(.headline)
                        .padding(.horizontal)
                        .accessibilityAddTraits(.isHeader)

                    if isLoadingVisits { // Show loading indicator for visits
                        ProgressView("Loading Visits...")
                            .padding(.horizontal)
                    } else if relevantVisits.isEmpty { // Show message if no visits found
                        ContentUnavailableView("No Visit Data", systemImage: "chart.bar.fill", description: Text("No annual visit data available for this branch."))
                            .padding(.horizontal)
                    } else { // Display visits if loaded
                        ForEach(relevantVisits) { visit in
                            HStack {
                                Text("\(visit.year):")
                                    .font(.body)
                                Spacer()
                                Text("\(visit.visits) visits")
                                    .font(.body)
                            }
                            .padding(.horizontal)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Year \(visit.year): \(visit.visits) visits")
                        }
                    }
                }

                Divider() // Visual separator

                // Upcoming Events Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Upcoming Events")
                        .font(.headline)
                        .padding(.horizontal)
                        .accessibilityAddTraits(.isHeader)

                    if isLoadingEvents { // Show loading indicator for events
                        ProgressView("Loading Events...")
                            .padding(.horizontal)
                    } else if relevantEvents.isEmpty { // Show message if no events found
                        ContentUnavailableView("No Upcoming Events", systemImage: "calendar", description: Text("No upcoming events scheduled for this branch."))
                            .padding(.horizontal)
                    } else {
                        // Display events in a list, showing title, dates, and times.
                        ForEach(relevantEvents) { event in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel(event.title)
                                Text("Dates: \(event.formattedStartDate) to \(event.formattedEndDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .accessibilityLabel("Dates: from \(event.formattedStartDate) to \(event.formattedEndDate)")
                                if event.starttime != nil {
                                    Text("Time: \(event.formattedStartTime)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .accessibilityLabel("Start time: \(event.formattedStartTime)")
                                }
                                if event.endtime != nil {
                                    Text("End Time: \(event.formattedEndTime)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .accessibilityLabel("End time: \(event.formattedEndTime)")
                                }
                                if let location = event.location, location != "None" {
                                    Text("Location: \(location)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .accessibilityLabel("Location: \(location)")
                                }
                                ExpandableText(event.description, lineLimit: 3)
                                    .font(.caption)
                                    .padding(.top, 2)
                                    .accessibilityLabel(event.description)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.bottom, 5)
                            .accessibilityElement(children: .contain) // Make the whole event item accessible
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
            // Load visits asynchronously.
            dataService.loadVisitsAsync { result in
                isLoadingVisits = false // Hide loading indicator once loading is complete.
                switch result {
                case .success(let loadedVisits):
                    self.allVisits = loadedVisits
                case .failure(let error):
                    self.visitsErrorMessage = error.localizedDescription
                    self.showingVisitsErrorAlert = true
                }
            }

            // Load events asynchronously.
            dataService.loadEventsAsync { result in
                isLoadingEvents = false // Hide loading indicator once loading is complete.
                switch result {
                case .success(let loadedEvents):
                    self.allEvents = loadedEvents
                case .failure(let error):
                    self.eventsErrorMessage = error.localizedDescription
                    self.showingEventsErrorAlert = true
                }
            }
        }
        // MARK: - Error Alerts
        // Alert for visits loading errors.
        .alert("Visits Loading Error", isPresented: $showingVisitsErrorAlert) {
            Button("OK") { }
        } message: {
            Text(visitsErrorMessage)
        }
        // Alert for events loading errors.
        .alert("Events Loading Error", isPresented: $showingEventsErrorAlert) {
            Button("OK") { }
        } message: {
            Text(eventsErrorMessage)
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
            // Provide a sample library for the preview
            let sampleLibrary = Library(id: 1, branchCode: "AB", branchName: "Albion", address: "1515 Albion Road", postalCode: "M9V 1B2", website: "https://www.tpl.ca/albion", telephone: "416-394-5170", squareFootage: "29000", publicParking: "59", kidsStop: 1, leadingReading: 1, clc: 1, dih: 1, teenCouncil: 1, youthHub: 1, adultLiteracyProgram: 1, workstations: 38, serviceTier: "DL", lat: "43.739826", long: "-79.584096", nbhdNo: 2, nbhdName: "Mount Olive-Silverstone-Jamestown", tplnia: 1, wardNo: 1, wardName: "Etobicoke North", presentSiteYear: 2017)
            LibraryDetailView(library: sampleLibrary)
        }
    }
}