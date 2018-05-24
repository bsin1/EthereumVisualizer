//
//  UIViewController.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    
    func showAlertFromError(error: Error) {
        let alert = GeneralHelper.createAlert(title: "Sorry!",
                                              message: error.localizedDescription,
                                              actions: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
