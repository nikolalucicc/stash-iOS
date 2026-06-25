//
//  ExchangeRateService.swift
//  stash
//
//  Fetches live exchange rates. Uses open.er-api.com (no API key, supports
//  RSD/EUR/USD). No personal data is sent — only the base currency code.
//

import Foundation

enum ExchangeRateError: Error {
    case network
    case missingRate
}

enum ExchangeRateService {

    /// The multiplier to convert an amount from `from` into `to`.
    static func rate(from: Currency, to target: Currency) async throws -> Double {
        if from == target { return 1 }

        guard let url = URL(string: "https://open.er-api.com/v6/latest/\(from.code)") else {
            throw ExchangeRateError.network
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ExchangeRateError.network
        }

        let payload = try JSONDecoder().decode(RatesPayload.self, from: data)
        guard payload.result == "success", let rate = payload.rates[target.code] else {
            throw ExchangeRateError.missingRate
        }
        return rate
    }

    private struct RatesPayload: Decodable {
        let result: String
        let rates: [String: Double]
    }
}
