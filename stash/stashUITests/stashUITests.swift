//
//  stashUITests.swift
//  stashUITests
//
//  Created by Nikola on 16. 5. 2026..
//

import XCTest

final class StashUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Set the initial state (e.g. interface orientation) required before tests run.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. Called after each test method.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
