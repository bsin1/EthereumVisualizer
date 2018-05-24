//
//  Block.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

struct Block: Codable {
    
    var hash: String? = ""
    var gasUsed: String? = ""
    var transactions: [Transaction]? = [Transaction]()
    
    static func createFromJson(json: JSON, key: String) -> Promise<Block> {
        //print("CREATING BLOCK FROM JSON: \(json)")
        return Promise { seal in
            do {
                let block = try JSONDecoder().decode(Block.self, from: json[key].rawData())
                print("created block with hash: \(block.hash)")
                seal.fulfill(block)
            } catch {
                print("error during decode block: \(error.localizedDescription)")
                seal.reject(error.localizedDescription)
            }
            
            
        }
        
    }
    
}
