import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    // MARK: - Properties
    // Injected DataService dependency. Defaults to the concrete DataService class.
    var dataService: DataServiceProtocol.Type = DataService.self

    // MARK: - State Properties
    // @State property to hold the list of libraries. It's initially empty and populated asynchronously.
    @State private var libraries: [Library] = []
    // @State property for the search text entered by the user.
    @State private var searchText = ""
    // @StateObject for the LocationManager to observe user's location changes.
    @StateObject private var locationManager = LocationManager()
    // @State property to control the visibility of a loading indicator.
    @State private var isLoading = true
    // @State property to store any error that occurs during data loading.
    @State private var showingErrorAlert = false
    @State private var errorMessage: String = ""

    // MARK: - Computed Properties
    // Filters and sorts the libraries based on search text and user's distance.
    var filteredAndSortedLibraries: [Library] {
        // Filter libraries based on the search text.
        var filtered = libraries.filter { searchText.isEmpty || $0.branchName.localizedCaseInsensitiveContains(searchText) }

        // If user location is available, sort the filtered libraries by distance.
        if let userLocation = locationManager.lastKnownLocation {
            filtered.sort { (library1, library2) -> Bool in
                let loc1 = CLLocation(latitude: library1.coordinate.latitude, longitude: library1.coordinate.longitude)
                let loc2 = CLLocation(latitude: library2.coordinate.latitude, longitude: library2.coordinate.longitude)
                let dist1 = userLocation.distance(from: loc1)
                let dist2 = userLocation.distance(from: loc2)
                return dist1 < dist2
            }
        }
        return filtered
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            // Display a loading indicator if data is still being loaded.
            if isLoading {
                ProgressView("Loading Libraries...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else { // Once data is loaded, display the TabView.
                TabView {
                    // MARK: - List View Tab
                    VStack {
                        SearchBar(text: $searchText)
                            .padding(.top)

                        if filteredAndSortedLibraries.isEmpty && !searchText.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        } else if filteredAndSortedLibraries.isEmpty && searchText.isEmpty {
                            ContentUnavailableView("No Libraries Available", systemImage: "building.columns", description: Text("Could not load library data. Please try again later."))
                        } else {
                            List(filteredAndSortedLibraries) {
                                library in
                                NavigationLink(destination: LibraryDetailView(library: library, dataService: dataService)) {
                                    HStack(alignment: .top, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(library.branchName)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                                .lineLimit(2) // Allow branch name to wrap
                                            Text(library.address)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2) // Allow address to wrap
                                        }
                                        Spacer()
                                        // Display distance if user location is available.
                                        if let userLocation = locationManager.lastKnownLocation {
                                            let libraryLocation = CLLocation(latitude: library.coordinate.latitude, longitude: library.coordinate.longitude)
                                            let distance = userLocation.distance(from: libraryLocation)
                                            Text(String(format: "%.2f km", distance / 1000))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .fixedSize() // Prevent distance text from wrapping
                                        }
                                    }
                                    .padding(.vertical, 8) // Add more vertical padding for consistent spacing
                                }
                            }
                            .listStyle(PlainListStyle()) // Use PlainListStyle for cleaner look
                        }
                    }
                    .navigationTitle("TPL Branches") // Apply navigation title to the VStack content
                    .navigationBarTitleDisplayMode(.inline) // Apply display mode to the VStack content
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }

                    // MARK: - Map View Tab
                    MapView(libraries: libraries) // Pass the loaded libraries to the MapView
                        .navigationTitle("Library Map") // Apply navigation title to the MapView
                        .navigationBarTitleDisplayMode(.inline) // Apply display mode to the MapView
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }
                }
            }
        }
        // MARK: - View Lifecycle
        .onAppear {
            // Request location access when the view appears.
            locationManager.requestLocation()
            // Load libraries asynchronously when the view appears.
            dataService.loadLibrariesAsync { result in
                isLoading = false // Hide loading indicator once loading is complete.
                switch result {
                case .success(let loadedLibraries):
                    self.libraries = loadedLibraries
                case .failure(let error):
                    // Show an alert if there's an error loading data.
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            }
        }
        // MARK: - Error Alert
        // Display an alert if an error occurred during data loading.
        .alert(isPresented: $showingErrorAlert) {
            Alert(
                title: Text("Loading Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}