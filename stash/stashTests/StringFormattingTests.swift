//
//  StringFormattingTests.swift
//  stashTests
//
//  Unit tests for live number-input formatting.
//

import XCTest
@testable import stash

final class StringFormattingTests: XCTestCase {

    func testGroupsThousands() {
        XCTAssertEqual("85000".groupedThousandsInput, "85.000")
        XCTAssertEqual("1000000".groupedThousandsInput, "1.000.000")
    }

    func testKeepsShortNumbersUngrouped() {
        XCTAssertEqual("0".groupedThousandsInput, "")
        XCTAssertEqual("5".groupedThousandsInput, "5")
        XCTAssertEqual("999".groupedThousandsInput, "999")
    }

    func testDropsLeadingZeros() {
        XCTAssertEqual("085000".groupedThousandsInput, "85.000")
        XCTAssertEqual("007".groupedThousandsInput, "7")
    }

    func testStripsNonDigits() {
        XCTAssertEqual("85.000".groupedThousandsInput, "85.000")
        XCTAssertEqual("1a2b3".groupedThousandsInput, "123")
    }
}
