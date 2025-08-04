//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

struct CoinManager {
    enum APIEndpoint {
        case currencies
        case exchangeRates(fromId: Int, toId: Int)
        
        static var apiKey: String {
            return "991d15b2a1a0f99a72d909a1622aa6eb"
        }
        static var baseURL: String {
            return "https://bestchange.app/v2/"
        }
        
        func path() -> String {
            switch self {
            case .currencies:
                return APIEndpoint.baseURL + APIEndpoint.apiKey +  "/currencies/en"
            case .exchangeRates(let fromId, let toId):
                return APIEndpoint.baseURL + APIEndpoint.apiKey + "/rates/\(fromId)-\(toId)"
            }
        }
    }
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func fetchCurrencyIDs(fromCode: String, toCode: String, completion: @escaping (_ fromID: Int, _ toID: Int) -> Void) {
        let url = URL(string: APIEndpoint.currencies.path())!
        //        let url = URL(string: "https://bestchange.app/v2/991d15b2a1a0f99a72d909a1622aa6eb/currencies/en")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Ошибка загрузки валют: \(error?.localizedDescription ?? "нет данных")")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(CoinData.self, from: data)
                guard
                    let from = decoded.currencies
                        .filter({ $0.code.hasSuffix(fromCode)
                        })
                        .sortedByPriority(forCode: fromCode)
                        .first,
                    let to = decoded.currencies
                        .filter({ $0.code.hasSuffix(toCode)
                        })
                        .sortedByPriority(forCode: toCode)
                        .first
                else {
                    print("Не найдены валюты с кодами \(fromCode), \(toCode)")
                    return
                }
                completion(from.id, to.id)
                
            } catch {
                print("Ошибка парсинга JSON: \(error)")
            }
        }.resume()
    }
    
    func fetchRates(fromID: Int, toID: Int) {
        let pair = "\(fromID)-\(toID)"
        let url = URL(string: APIEndpoint.exchangeRates(fromId: fromID, toId: toID).path())!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Ошибка загрузки курсов: \(error?.localizedDescription ?? "нет данных")")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(RatesData.self, from: data)
                
                if let rates = decoded.rates[pair] {
                    let rate = rates
                        .sorted { $0.rate < $1.rate }
                        .first?.rate
                    let coin = CoinModel(rate: rate ?? "0")
                    self.delegate?.didUpdateCoinRate(self, coin: coin)
                } else {
                    print("Курс не найден по ключу \(pair)")
                }
                
            } catch {
                print("Ошибка декодирования курсов: \(error)")
            }
        }.resume()
    }
    
    func sortedWithPriority() {
        
    }
    
    func getCoinPrice(from fromCode: String, to toCode: String = "BTC") {
        fetchCurrencyIDs(fromCode: fromCode, toCode: toCode) { fromID, toID in
            fetchRates(fromID: fromID, toID: toID)
        }
        
    }
    
}



protocol CoinManagerDelegate {
    func didUpdateCoinRate(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

extension Array where Element == Currency {
    func sortedByPriority(forCode: String) -> [Currency] {
        return self.sorted { lhs, rhs in
            func priority(for value: String) -> Int {
                if value == forCode { return 0 }
                else if value == "CARD\(forCode)" { return 1 }
                else if value == "CASH\(forCode)" { return 2 }
                else { return 3 }
            }

            let p1 = priority(for: lhs.code)
            let p2 = priority(for: rhs.code)

            return p1 == p2 ? lhs.code < rhs.code : p1 < p2
        }
    }
}

