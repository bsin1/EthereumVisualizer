//
//  SetOceanView.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SetOceanView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var circularSegments: Bool = false {
        didSet {
            if(frame.width != frame.height) {
                circularSegments = false
            }
            
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var showShadow: Bool = false
    
    @IBInspectable var shadowRadius: CGFloat = 6
    @IBInspectable var shadowColor: UIColor = .black
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        clipsToBounds = true
        if(circularSegments) {
            layer.cornerRadius = self.frame.width / 2
        }
        if(showShadow) {
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor.cgColor
            self.layer.shadowOpacity = 0.75
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
}
