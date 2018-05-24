//
//  Transaction.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

struct Transaction: Codable {
    
    var blockHash: String? = ""
    var blockNumber: String? = ""
    var from: String? = ""
    var gas: String? = ""
    var gasPrice: String? = ""
    var hash: String? = ""
    var input: String? = ""
    var nonce: String? = ""
    var to: String? = ""
    var transactionIndex: String? = ""
    var value: String? = ""
    var v: String? = ""
    var r: String? = ""
    var s: String? = ""
    
    static func createFromJson(json: JSON, key: String) -> Promise<Transaction> {
        //print("CREATING TRANSACTION FROM JSON: \(json)")
        return Promise { seal in
            do {
                let transaction = try JSONDecoder().decode(Transaction.self, from: json[key].rawData())
                print("created transaction")
                seal.fulfill(transaction)
            } catch {
                print("error during decode transaction: \(error.localizedDescription)")
                seal.reject(error.localizedDescription)
            }
            
            
        }
        
    }
    
    static func createListFromJson(json: JSON, key: String) -> Promise<[Transaction]> {
        print("CREATING TRANSACTION LIST FROM JSON: \(json)")
        return Promise { seal in
            do {
                let transactions = try JSONDecoder().decode([Transaction].self, from: json[key].rawData())
                seal.fulfill(transactions)
            } catch {
                print("error during decode transaction list: \(error.localizedDescription)")
                seal.reject(error.localizedDescription)
            }
        }
    }
    
}
