
//
//  TPLBrowserTests.swift
//  TPLBrowserTests
//
//  Created by Gemini on 2025-07-07.
//

import XCTest
@testable import TPLBrowser // Import your app module

class TPLBrowserTests: XCTestCase {

    // Test loading libraries asynchronously
    func testLoadLibrariesAsync() throws {
        let expectation = self.expectation(description: "Libraries loaded")

        DataService.loadLibrariesAsync { result in
            switch result {
            case .success(let libraries):
                XCTAssertFalse(libraries.isEmpty, "Libraries should not be empty")
                // You can add more specific assertions here, e.g., check a known library's name
                XCTAssertTrue(libraries.contains(where: { $0.branchName == "Albion" }), "Albion library should be present")
            case .failure(let error):
                XCTFail("Error loading libraries: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // Test loading visits asynchronously
    func testLoadVisitsAsync() throws {
        let expectation = self.expectation(description: "Visits loaded")

        DataService.loadVisitsAsync { result in
            switch result {
            case .success(let visits):
                XCTAssertFalse(visits.isEmpty, "Visits should not be empty")
                XCTAssertTrue(visits.contains(where: { $0.branchCode == "AB" }), "Visits for branch AB should be present")
            case .failure(let error):
                XCTFail("Error loading visits: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // Test loading events asynchronously
    func testLoadEventsAsync() throws {
        let expectation = self.expectation(description: "Events loaded")

        DataService.loadEventsAsync { result in
            switch result {
            case .success(let events):
                XCTAssertFalse(events.isEmpty, "Events should not be empty")
                XCTAssertTrue(events.contains(where: { $0.title.contains("Tea & Entertainment") }), "Tea & Entertainment event should be present")
            case .failure(let error):
                XCTFail("Error loading events: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
