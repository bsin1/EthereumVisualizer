//
//  Token.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PromiseKit

struct Token: Hashable, Codable {
    var hashValue: Int = 0
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        return lhs.symbol == rhs.symbol
    }
    
    static var sharedTokens = [Token]()
    
    var address: String = ""
    var name: String = ""
    var decimals: String = ""
    var symbol: String = ""
    var price: PriceData = PriceData()
    var imageUrl: String = ""
    var color: UIColor = UIColor.black
    
    private enum CodingKeys: String, CodingKey {
        case address
        case name
        case symbol
        case price
    }
    
    init(symbol: String,
         address: String,
         color: UIColor) {
        self.symbol = symbol
        self.address = address
        self.color = color
    }
    
    static func createListFromJson(json: JSON, key: String? = nil) -> Promise<[Token]> {
        print("CREATING TOKEN LIST FROM JSON: \(json)")
        return Promise { seal in
            do {
                var tokens = try JSONDecoder().decode([Token].self, from: key != nil ? json[key!].rawData() : json.rawData())
                
                if let jsonArray = json.array {
                    for (index, _) in tokens.enumerated() {
                        if let decimalsString = jsonArray[index]["decimals"].string {
                            tokens[index].decimals = decimalsString
                        } else if let decimalsInt = jsonArray[index]["decimals"].int {
                            tokens[index].decimals = String(decimalsInt)
                        }
                    }
                }
                
                seal.fulfill(tokens)
            } catch {
                print("error during decode token list: \(error)")
                seal.reject(error.localizedDescription)
            }
        }
    }
    
    
}
