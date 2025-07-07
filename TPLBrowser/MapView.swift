import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    let libraries: [Library]
    @State private var position: MapCameraPosition
    @StateObject private var locationManager = LocationManager()
    @State private var nearestLibrary: Library? = nil
    @State private var distanceToNearestLibrary: String? = nil

    init(libraries: [Library]) {
        self.libraries = libraries
        _position = State(initialValue: MapView.initialCameraPosition(for: libraries))
    }

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(libraries) { library in
                Annotation(library.branchName, coordinate: library.coordinate) {
                    NavigationLink(destination: LibraryDetailView(library: library)) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .offset(y: 5)
                            Text(library.branchName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(5)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
            }
            UserAnnotation()
        }
        .navigationTitle("Library Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                        zoomToUserLocationAndFindNearestLibrary()
                    } else {
                        showingLocationAlert = true
                    }
                }) {
                    Label("My Location", systemImage: "location.fill")
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .overlay(alignment: .bottom) {
            if let distance = distanceToNearestLibrary {
                Text("Nearest Library: \(nearestLibrary?.branchName ?? "") (\(distance))")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.bottom)
            }
        }
        .alert("Location Access Denied", isPresented: $showingLocationAlert) {
            Button("OK") { }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable location services in Settings to use this feature.")
        }
    }

    static func initialCameraPosition(for libraries: [Library]) -> MapCameraPosition {
        guard !libraries.isEmpty else {
            return .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 43.7, longitude: -79.4),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }

        var minLat = 90.0
        var maxLat = -90.0
        var minLong = 180.0
        var maxLong = -180.0

        for library in libraries {
            minLat = min(minLat, library.coordinate.latitude)
            maxLat = max(maxLat, library.coordinate.latitude)
            minLong = min(minLong, library.coordinate.longitude)
            maxLong = max(maxLong, library.coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLong + maxLong) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2,
            longitudeDelta: (maxLong - minLong) * 1.2
        )

        return .region(MKCoordinateRegion(center: center, span: span))
    }

    private func zoomToUserLocationAndFindNearestLibrary() {
        guard let userLocation = locationManager.lastKnownLocation else {
            print("User location not available.")
            return
        }

        position = .region(MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))

        findNearestLibrary(to: userLocation)
    }

    private func findNearestLibrary(to userLocation: CLLocation) {
        var nearest: Library? = nil
        var shortestDistance: CLLocationDistance = .greatestFiniteMagnitude

        for library in libraries {
            let libraryLocation = CLLocation(latitude: library.coordinate.latitude, longitude: library.coordinate.longitude)
            let distance = userLocation.distance(from: libraryLocation)

            if distance < shortestDistance {
                shortestDistance = distance
                nearest = library
            }
        }

        if let nearest = nearest {
            self.nearestLibrary = nearest
            self.distanceToNearestLibrary = String(format: "%.2f km", shortestDistance / 1000)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation? = nil
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
        manager.stopUpdatingLocation() // Stop updating after getting a location
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide sample libraries for the preview
        let sampleLibraries: [Library] = [
            Library(id: 1, branchCode: "AB", branchName: "Albion", address: "1515 Albion Road", postalCode: "M9V 1B2", website: "https://www.tpl.ca/albion", telephone: "416-394-5170", squareFootage: "29000", publicParking: "59", kidsStop: 1, leadingReading: 1, clc: 1, dih: 1, teenCouncil: 1, youthHub: 1, adultLiteracyProgram: 1, workstations: 38, serviceTier: "DL", lat: "43.739826", long: "-79.584096", nbhdNo: 2, nbhdName: "Mount Olive-Silverstone-Jamestown", tplnia: 1, wardNo: 1, wardName: "Etobicoke North", presentSiteYear: 2017),
            Library(id: 2, branchCode: "ACD", branchName: "Albert Campbell", address: "496 Birchmount Road", postalCode: "M1K 1N8", website: "https://www.tpl.ca/albertcampbell", telephone: "416-396-8890", squareFootage: "28957", publicParking: "45", kidsStop: 0, leadingReading: 1, clc: 1, dih: 1, teenCouncil: 1, youthHub: 1, adultLiteracyProgram: 0, workstations: 36, serviceTier: "DL", lat: "43.708019", long: "-79.269252", nbhdNo: 120, nbhdName: "Clairlea-Birchmount", tplnia: 1, wardNo: 20, wardName: "Scarborough Southwest", presentSiteYear: 1971)
        ]
        MapView(libraries: sampleLibraries)
    }
}