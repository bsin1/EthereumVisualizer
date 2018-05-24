//
//  DataViewController.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var mHash: UILabel!
    
    @IBOutlet weak var mTableView: UITableView!
    var hashString: String = "NONE FOUND"
    var dataList = [(token: Token, cost: Double, percentage: String)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mHash.text = hashString
        mTableView.delegate = self
        mTableView.dataSource = self
        // Do any additional setup after loading the view.
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Token") as! TokenTransactionTableCell
        cell.configure(data: dataList[indexPath.row])
        return cell
    }


}
