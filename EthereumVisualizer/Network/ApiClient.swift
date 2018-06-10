//
//  ApiClient.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//


import Foundation
import PromiseKit
import SwiftyJSON

class ApiClient {
    
    private static func createJson(data: Any) -> Promise<JSON> {
        
        return Promise { seal in
            
            let json = JSON(data)
            print("GOT JSON: \(json)")
            guard let success = json["success"].int,
                success == 1 else {
                    if let message = json["message"].string {
                        throw message
                    }
                    throw "Failure creating JSON"
            }
            
            seal.fulfill(json["data"])
        }
        
    }
    
    static func fetchBlockcypherData() -> Promise<JSON> {
        let url = "https://api.blockcypher.com/v1/eth/main"
        return performRequest(url: url,
                       parameters: ["token":"fe57007173614cefbcb309d5b4d23a4e"],
                       method: .get)
        .then { json -> Promise<JSON> in
            guard let latestUrl = json["latest_url"].string else {
                print("REJECTING: \(json)")
                return Promise { $0.reject("Unable to parse latest_url")}
            }
            return performRequest(url: latestUrl, parameters: ["token":"fe57007173614cefbcb309d5b4d23a4e"], method: .get)
        }
    }
    
    static func fetchErcTokens() -> Promise<[Token]> {
        
        let url = "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json"
        return performRequest(url: url,
                              parameters: [:],
                              method: .get)
        .then { json in
            Token.createListFromJson(json: json)
        }
    }
    
    static func fetchErcImages() -> Promise<JSON> {
        
        let url = "https://www.cryptocompare.com/api/data/coinlist/"
        return performRequest(url: url,
                              parameters: [:],
                              method: .get)
        .then { json in
            return Promise { seal in
                seal.fulfill(json["Data"])
                
            }
        }
        
    }
    
    static func fetchTokenTransactions(cypherData: JSON, topTokens: [Token]) -> Promise<[Transaction]> {
        
        let topTokens = topTokens.filter({$0.symbol != "ETH"})
        var promises = [Promise<JSON>]()
        topTokens.forEach({promises.append(fetchTokenContractData(symbol: $0.symbol, contractAddress: $0.address, blockHeight: cypherData["height"].int!))})
        print("total promises size: \(promises.count)")
        let chunked = promises.chunked(into: 4)
        var transactions = [Transaction]()
        let delay = 1.0
        
        return when(fulfilled: chunked[0])
        .then { results -> Guarantee<Void> in
            print("GOT RESULTS 0: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[1])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 1: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[2])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 2: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[3])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 3: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[4])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 4: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[5])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 5: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[6])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 6: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[7])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 7: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[8])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 8: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            when(fulfilled: chunked[9])
        }.then { results -> Guarantee<Void> in
            print("GOT RESULTS 9: \(results)")
            let filteredResults = results.filter({$0["status"].string! == "1"})
            filteredResults.forEach({ json in
                transactions.append(contentsOf: Transaction.createListFromJson(json: json, key: "result"))
            })
            return after(seconds: delay)
        }.then {
            return Promise{$0.fulfill(transactions)}
        }
        
    }
    
//    static func returnObjectAfterWait(object:Any, waitTime:TimeInterval) -> Promise<Any>{
//        return Promise<Any> { (seal: Resolver<Any>) in
//            after(seconds: waitTime).then { _ in
//                seal.fulfill(object)
//            }
//        }
//    }
    
    static func fetchTopErcTokens() -> Promise<[Token]> {
        let url = "https://api.ethplorer.io/getTop?criteria=trade&apiKey=freekey"
        return performRequest(url: url, parameters: [:], method: .get)
        .then { json in
            Token.createListFromJson(json: json, key: "tokens")
        }
    }
    
    static func fetchTokenContractData(symbol: String,
                                       contractAddress: String,
                                       blockHeight: Int) -> Promise<JSON> {
        //print("FETCHING DATA FOR: \(symbol)")
        let url = "https://api.etherscan.io/api"
        return performRequest(url: url,
                              parameters: ["module":"account",
                                           "action":"tokentx",
                                           "contractaddress":contractAddress,
                                           "startBlock":blockHeight,
                                           "endblock":blockHeight,
                                           "sort":"asc"],
                              method: .get)
    }
    
    
    private static func performRequest(url: String,
                                       parameters: Parameters,
                                       method: HTTPMethod) -> Promise<JSON> {
        
        
        return Alamofire
            .request(
                url,
                method: method,
                parameters: parameters,
                headers: [:])
            .responseJSON()
            .then { response  in
                return Promise { seal in
                    //print("GOT RESPONSE: \(response.json)")
                    seal.fulfill(JSON(response.json))
                }
        }
    }
    

    
}
