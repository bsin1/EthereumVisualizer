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
    
    private static func fetchLatestBlockNumber() -> Promise<String> {
        
        let url = "https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=WPIM39V2XK35DAQWYGT578ZXYQIDHN46US"
        return performRequest(url: url,
                              parameters: [:],
                              method: .get)
            .then { json in
                return Promise { seal in
                    if let blockNumber = json["result"].string {
                        seal.fulfill(blockNumber)
                    } else {
                        seal.reject("unable to get block number")
                    }
                }
        }
    }
    
    static func fetchLatestBlock() -> Promise<Block> {
        
        return fetchLatestBlockNumber()
            .then { blockNumber in
                fetchLatestBlockByNumber(blockNumber: blockNumber)
            }
    }
    
    private static func fetchLatestBlockByNumber(blockNumber: String) -> Promise<Block> {
        
        let url = "https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=\(blockNumber)&boolean=true&apikey=WPIM39V2XK35DAQWYGT578ZXYQIDHN46US"
        
        return performRequest(url: url,
                              parameters: [:],
                              method: .get)
        .then { json in
            Block.createFromJson(json: json, key: "result")
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
    
    
    private static func performRequest(url: String,
                                       parameters: Parameters,
                                       method: HTTPMethod) -> Promise<JSON> {
        
        
        return Alamofire
            .request(
                url,
                method: method,
                parameters: parameters,
                encoding: URLEncoding.httpBody,
                headers: [:])
            .responseJSON()
            .then { response  in
                return Promise { seal in
                    seal.fulfill(JSON(response.json))
                }
        }
    }
    

    
}
