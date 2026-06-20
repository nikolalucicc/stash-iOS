//
//  OnboardingFourthStepVMTests.swift
//  stashTests
//
//  Unit tests for OnboardingFourthStepVM and the Currency model.
//

import XCTest
@testable import stash

@MainActor
final class OnboardingFourthStepVMTests: XCTestCase {

    func testDefaultCurrencyIsRSD() {
        let vm = OnboardingFourthStepVM()
        XCTAssertEqual(vm.selectedCurrency, .rsd)
    }

    func testCurrencyHasThreeCases() {
        XCTAssertEqual(Currency.allCases.count, 3)
    }

    func testCurrencyCodes() {
        XCTAssertEqual(Currency.rsd.code, "RSD")
        XCTAssertEqual(Currency.eur.code, "EUR")
        XCTAssertEqual(Currency.usd.code, "USD")
    }

    func testCurrencyFlags() {
        XCTAssertEqual(Currency.rsd.flag, "🇷🇸")
        XCTAssertEqual(Currency.eur.flag, "🇪🇺")
        XCTAssertEqual(Currency.usd.flag, "🇺🇸")
    }

    func testCurrencyRawValueRoundTrip() {
        for currency in Currency.allCases {
            XCTAssertEqual(Currency(rawValue: currency.rawValue), currency)
        }
    }
}
