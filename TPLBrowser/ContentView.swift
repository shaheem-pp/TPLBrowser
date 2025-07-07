import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var libraries = DataService.loadLibraries()
    @State private var searchText = ""
    @StateObject private var locationManager = LocationManager()

    var filteredAndSortedLibraries: [Library] {
        var filtered = libraries.filter { searchText.isEmpty || $0.branchName.localizedCaseInsensitiveContains(searchText) }

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

    var body: some View {
        NavigationView {
            TabView {
                VStack {
                    SearchBar(text: $searchText)
                        .padding(.top)

                    List(filteredAndSortedLibraries) {
                        library in
                        NavigationLink(destination: LibraryDetailView(library: library)) {
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
                    .navigationTitle("TPL Branches")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

                MapView(libraries: libraries)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .navigationTitle("Library Map")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}