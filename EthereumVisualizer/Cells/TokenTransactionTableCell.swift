//
//  TokenTransactionTableCell.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import UIKit
import Kingfisher

class TokenTransactionTableCell: UITableViewCell {

    @IBOutlet weak var mIcon: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mCost: UILabel!
    @IBOutlet weak var mPercentage: UILabel!
    
    
    func configure(data: (token: Token, cost: Double, percentage: String)) {
        if let url = URL(string: data.token.imageUrl) {
            mIcon.kf.setImage(with: url)
        }
        mName.text = data.token.symbol
        mCost.text = "\(data.cost)"
        mPercentage.text = "\(data.percentage)%"
        mName.textColor = data.token.color
        mCost.textColor = data.token.color
        mPercentage.textColor = data.token.color

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
