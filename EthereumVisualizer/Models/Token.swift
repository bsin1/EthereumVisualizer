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
    
    var symbol: String = ""
    var address: String = ""
    var imageUrl: String = ""
    var color: UIColor = UIColor.black
    
    private enum CodingKeys: String, CodingKey {
        case symbol
        case address
    }
    
    init(symbol: String,
         address: String,
         color: UIColor) {
        self.symbol = symbol
        self.address = address
    }
    
    static func createListFromJson(json: JSON) -> Promise<[Token]> {
        //print("CREATING TOKEN LIST FROM JSON: \(json)")
        return Promise { seal in
            do {
                let tokens = try JSONDecoder().decode([Token].self, from: json.rawData())
                seal.fulfill(tokens)
            } catch {
                print("error during decode token list: \(error.localizedDescription)")
                seal.reject(error.localizedDescription)
            }
        }
    }
    
    
}
