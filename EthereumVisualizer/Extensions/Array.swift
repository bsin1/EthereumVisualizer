//
//  Array.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 6/9/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
