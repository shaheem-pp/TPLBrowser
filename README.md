# TPLBrowser

TPLBrowser is a SwiftUI application that allows users to browse and search for Toronto Public Library (TPL) branches. It provides a user-friendly interface to view library locations on a map, search for specific branches, and see detailed information about each branch.

## Features

*   **List View:** Displays a comprehensive list of all TPL branches, sorted by distance from the user's current location.
*   **Search:** Allows users to search for libraries by name.
*   **Map View:** Shows the geographical location of all library branches on an interactive map.
*   **Library Details:** Provides detailed information for each library, including address, website, and more.
*   **Distance Calculation:** Shows the distance to each library from the user's current location.
*   **Pull-to-Refresh:** Easily refresh the library list.
*   **User Location:** Shows the user's current location on the map.

## Data

The application fetches real-time data from the City of Toronto's Open Data Portal, ensuring the information is always up-to-date. The following datasets are used:

*   [Library Branch General Information](https://open.toronto.ca/dataset/library-branch-general-information/)
*   [Library Events Feed](https://www.torontopubliclibrary.ca/data/library-events-feed.json) (Future)
*   [Library Visits Annual by Branch](https://www.torontopubliclibrary.ca/data/library-visits-annual-by-branch.json) (Future)

## Technology Stack

*   **UI:** SwiftUI
*   **Location:** CoreLocation
*   **Mapping:** MapKit
*   **Networking:** URLSession

## Future Enhancements

*   **Event Information:** Display upcoming events for each library branch.
*   **Visit Statistics:** Show annual visit statistics for each branch.
*   **Offline Support:** Cache data for offline access.
*   **Accessibility:** Improve accessibility for users with disabilities.

## Getting Started

To run the application:

1.  Clone the repository.
2.  Open `TPLBrowser.xcodeproj` in Xcode.
3.  Build and run the project on the desired simulator or device.

---

*This project is not affiliated with the Toronto Public Library.*