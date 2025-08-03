//
//  RatesData.swift
//  ByteCoin
//
//  Created by Aliaksandr Zuyeu on 3.08.25.
//  Copyright © 2025 The App Brewery. All rights reserved.
//
import Foundation

// MARK: - RatesData
struct RatesData: Codable {
    let rates: [String: [CurrencyRates]]
}
// MARK: - CurrencyRates
struct CurrencyRates: Codable {
    let changer: Int
    let rate: String
}
