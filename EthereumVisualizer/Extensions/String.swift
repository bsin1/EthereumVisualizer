//
//  String.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
extension String: LocalizedError {
    
    //pass strings as an error.  Access message via error.localizedDescription
    public var errorDescription: String? { return self }
}
