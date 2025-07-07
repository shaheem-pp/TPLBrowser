import SwiftUI
import MapKit

struct LibraryDetailView: View {
    let library: Library

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "building.columns.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 10)

                Text(library.branchName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Divider()

                Group {
                    DetailRow(title: "Address", content: library.address)

                    if let url = URL(string: library.website) {
                        Link(destination: url) {
                            DetailRow(title: "Website", content: library.website)
                                .foregroundColor(.blue)
                        }
                    }

                    DetailRow(title: "Phone", content: library.telephone)
                }
                .padding(.horizontal)

                if let nbhdName = library.nbhdName {
                    DetailRow(title: "Neighborhood", content: nbhdName)
                        .padding(.horizontal)
                }

                Button(action: {
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

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Services")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
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

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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

struct LibraryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LibraryDetailView(library: DataService.loadLibraries().first!)
        }
    }
}