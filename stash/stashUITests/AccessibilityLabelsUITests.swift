//
//  AccessibilityLabelsUITests.swift
//  stashUITests
//
//  Icon-only controls carry no text, so VoiceOver announces nothing but
//  "button" unless they are labelled. These read the accessibility tree to
//  prove the labels are actually there.
//

import XCTest

final class AccessibilityLabelsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// The onboarding app bar's back arrow — reachable from a fresh install.
    @MainActor
    func testTheOnboardingBackArrowIsLabelled() throws {
        let app = XCUIApplication()
        app.launch()

        let cont = app.buttons["Continue"]
        guard cont.waitForExistence(timeout: 10) else {
            throw XCTSkip("Not on the first onboarding step — the app already has data.")
        }
        cont.tap()

        let back = app.buttons["Back"]
        XCTAssertTrue(back.waitForExistence(timeout: 5),
                      "The back arrow shows only an icon, so it needs a spoken label")
    }
}
