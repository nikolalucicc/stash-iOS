//
//  stashUITestsLaunchTests.swift
//  stashUITests
//
//  Created by Nikola on 16. 5. 2026..
//

import XCTest

final class StashUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here after app launch but before taking a screenshot,
        // such as logging in or navigating to the desired screen.

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
