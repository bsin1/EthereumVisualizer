//
//  GeneralHelper.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import UIKit

class GeneralHelper {
    
    static func createAlert(title: String, message: String, actions: [UIAlertAction]?) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        if(actions != nil) {
            actions!.forEach({ action in
                alert.addAction(action)
            })
        }
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    
    
    
}
