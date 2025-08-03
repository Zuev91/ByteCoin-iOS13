// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let coinData = try? JSONDecoder().decode(CoinData.self, from: jsonData)

import Foundation

// MARK: - CoinData
struct CoinData: Codable {
    let currencies: [Currency]
}

// MARK: - Currency
struct Currency: Codable {
    let id: Int
    let code: String
}

//struct Rates: Codable {
//    let rates: [String: [CurrencyRates]]
//}
//// MARK: - CurrencyRates
//struct CurrencyRates: Codable {
//    let changer: Int
//    let rate: String
//}

