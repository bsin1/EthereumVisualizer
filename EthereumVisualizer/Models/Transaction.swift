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
    
    var blockNumber: String = ""
    var tokenSymbol: String = ""
    var value: String = ""
    var contractAddress: String = ""
    var input: String = ""
    var hash: String = ""
    var to: String = ""
    var cumulativeGasUsed: String = ""
    var gasPrice: String = ""
    var confirmations: String = ""
    var transactionIndex: String = ""
    var tokenName: String = ""
    var nonce: String = ""
    var blockHash: String = ""
    var from: String = ""
    var gasUsed: String = ""
    var gas: String = ""
    var timeStamp: String = ""
    var tokenDecimal: String = ""
    
    static func createPromiseFromJson(json: JSON, key: String) -> Promise<Transaction> {
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
    
    static func createListFromJson(json: JSON, key: String) -> [Transaction] {
        //print("CREATING TRANSACTION LIST FROM JSON: \(json)")
        do {
            let transactions = try JSONDecoder().decode([Transaction].self, from: json[key].rawData())
            return transactions
        } catch {
            return []
        }
        
    }
    
    static func createPromiseListFromJson(json: JSON, key: String) -> Promise<[Transaction]> {
        //print("CREATING TRANSACTION PROMISE LIST FROM JSON: \(json)")
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
