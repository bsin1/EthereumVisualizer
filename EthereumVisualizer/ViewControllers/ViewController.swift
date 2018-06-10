//
//  ViewController.swift
//  EthereumVisualizer
//
//  Created by Balin Sinnott on 5/22/18.
//  Copyright © 2018 SetOcean. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PromiseKit
import SwiftyJSON

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var index: Double = 0

    var blockData = [(block: Block, tokenData: [(token: Token, cost: Double, percentage: String)])] ()
    
    var infoNode: SCNNode?
    
    var lastHash: String = ""
    var totalCost: Double = 1
    
    
    var visibleVC = DataViewController()
    var visiblePlane = SCNPlane()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        fetchTokens()
        //fetchLatestBlock()
        


    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        print("tapped")
        let touchLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        if !hitResults.isEmpty {
            print("NODE TOUCHED")
            guard let hitResult = hitResults.first else {
                print("hit result failed")
                return
            }
            let node = hitResult.node
            guard let hash = node.name else {
                print("unable to get hash from node name")
                return
            }
            
            if(infoNode != nil) {
                infoNode!.removeFromParentNode()
                infoNode = nil
            } else {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "Data") as? DataViewController {
                    visibleVC = vc
                    visiblePlane = SCNPlane(width: 0.05, height: 0.05)
                    visibleVC.hashString = hash
                    
                    if let data = blockData.first(where: {$0.block.hash == hash}) {
                        visibleVC.dataList = data.tokenData
                    }
                    
                    
                    print("adding view")
                    visiblePlane.firstMaterial?.diffuse.contents = visibleVC.view
                    infoNode = SCNNode(geometry: visiblePlane)
                    infoNode!.position = SCNVector3(node.position.x, 0.05, -0.1)
                    self.sceneView.scene.rootNode.addChildNode(self.infoNode!)

                } else {
                    print("unable to create vc")
                }
                
            }
            
            // this means the node has been touched
        } else {
            print("NOTHING TOUCHED")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func generateColor() -> UIColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        print("red: \(red)")
        print("green: \(green)")
        print("blue: \(blue)")
        
        print("val: \(red/255)")
        print("cgfloat: \(CGFloat(red/255))")

        
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
    }
    
    private func fetchTokens() {
        print("FETCH TOKENS")
        when(fulfilled: ApiClient.fetchTopErcTokens(),
                        ApiClient.fetchErcImages())
        .done { tokens, images in
            print("GOT RESPONSE")
            print("TOKENS SIZE: \(tokens.count)")
            
            var topTokens = tokens
            
            DispatchQueue.main.async {
                for (index,token) in topTokens.enumerated() {
                    print("inside loop")
                    if let imageUrl = images["\(token.symbol)"]["ImageUrl"].string {
                        topTokens[index].imageUrl = "https://cryptocompare.com\(imageUrl)"
                    }
                    let color = self.generateColor()
                    print("setting color: \(color)")
                    topTokens[index].color = self.generateColor()
                }
                Token.sharedTokens = topTokens
                self.startBlockTimer()
            }
            
        }.catch { error in
            self.showAlertFromError(error: error)
        }
    }
    
    private func startBlockTimer() {
        print("startBlockTimer")
        fetchErcTransactions()
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.fetchErcTransactions), userInfo: nil, repeats: true)
    }
    
    
    
    
    @objc private func fetchErcTransactions() {
        print("fetchErcTransactions")
        ApiClient.fetchBlockcypherData()
        .then { cypherData -> Promise<[Transaction]> in
            
            guard let hash = cypherData["hash"].string,
                let blockNumber = cypherData["height"].int,
                let totalCost = cypherData["total"].double else {
                    throw "Unable to get hash, blockNumber or totalCost from blockcypher json"
            }
            
            print("FOUND DATA FOR BLOCK HASH: \(hash)")
            print("FOUND DATA FOR BLOCK HASH NUMBER: \(blockNumber)")
            
            guard hash != self.lastHash else {
                throw "Block HASH already found"
            }
            
            print("SAVING LAST BLOCK HASH: \(hash)")
            
            self.lastHash = hash
            if let ethToken = Token.sharedTokens.first(where: {$0.symbol == "ETH"}),
                let price = Double(ethToken.price.rate) {
                
                self.totalCost = (totalCost / pow(10, 18)) * price
                print("UPDATED TOTAL COST: \(self.totalCost)")
            } else {
                print("UNABLE TO GET PRICE ETH")
            }
            
            return ApiClient.fetchTokenTransactions(cypherData: cypherData, topTokens: Token.sharedTokens)
        }.done { transactions in
            self.buildArView(transactions: transactions)
        }.catch { error in
            print("GOT ERROR: \(error)")
            self.showAlertFromError(error: error)
        }
    }
    
    private func buildArView(transactions: [Transaction]) {
        
        print("Building AR View for transactions: \(transactions)")
        var tokenDictionary = [String:Double]()
        transactions.forEach({ transaction in
            if let value = Double(transaction.value),
                let decimal = Double(transaction.tokenDecimal),
                let token = Token.sharedTokens.first(where: {$0.symbol == transaction.tokenSymbol}),
                let price = Double(token.price.rate) {
                    if(tokenDictionary[transaction.contractAddress] == nil) {
                        tokenDictionary[transaction.contractAddress] = (value / pow(10,decimal)) * price
                    } else {
                        tokenDictionary[transaction.contractAddress]! += (value / pow(10,decimal)) * price
                    }
            }
        })

        var tokenData = [(token: Token, cost: Double, percentage: String)]()

        let scene = self.sceneView.scene
        let maxHeight = 5.0
        var yCoordinate = 0.0
        let zCoordinate = -20.0

        if(tokenDictionary.keys.count > 0) {
            
            
            for (key, value) in tokenDictionary {
                let percentageDouble = value / totalCost
                
                print("value: \(value)")
                print("totalCost: \(totalCost)")
                
                print("percentage double: \(percentageDouble)")
                //let percentage = "\(String(format: "%.2f", percentageDouble * 100))"
                
                
                
                //tokenData.append((token: key, cost: value, percentage: percentage))
                //print("\(key.symbol): \(value) (\(percentage)%)")

                let segmentHeight = maxHeight * percentageDouble
                
                print("segment height: \(segmentHeight)")
                
                yCoordinate += (segmentHeight / 2)
                print("placing ERC box at y coordinate: \(yCoordinate)")
                let box = SCNBox(width: CGFloat(maxHeight), height: CGFloat(segmentHeight), length: CGFloat(maxHeight), chamferRadius: 0)
                let material = SCNMaterial()
                if let token = Token.sharedTokens.first(where: {$0.address == key}) {
                    material.diffuse.contents = token.color
                } else {
                    material.diffuse.contents = generateColor()
                }
                box.materials = [material]
                let boxNode = SCNNode(geometry: box)
                boxNode.position = SCNVector3(self.index,yCoordinate,zCoordinate)
                scene.rootNode.addChildNode(boxNode)
                yCoordinate += (segmentHeight / 2)

            }
            print("WHITE BLOCK HEIGHT: \(maxHeight - yCoordinate)")

            let box = SCNBox(width: CGFloat(maxHeight), height: CGFloat(maxHeight - yCoordinate), length: CGFloat(maxHeight), chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white
            box.materials = [material]
            let boxNode = SCNNode(geometry: box)
            boxNode.name = lastHash
            boxNode.position = SCNVector3(self.index,yCoordinate + ((maxHeight - yCoordinate) / 2),zCoordinate)
            scene.rootNode.addChildNode(boxNode)

        } else {
            let box = SCNBox(width: CGFloat(maxHeight), height: CGFloat(maxHeight), length: CGFloat(maxHeight), chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white
            box.materials = [material]
            let boxNode = SCNNode(geometry: box)
            boxNode.name = lastHash
            boxNode.position = SCNVector3(self.index,maxHeight/2,zCoordinate)
            scene.rootNode.addChildNode(boxNode)
        }

        self.index += 6
        self.sceneView.scene = scene

        //self.blockData.append((block: block, tokenData: tokenData))
        
        
    }
    
    
    @IBAction func reset(_ sender: Any) {
        self.sceneView.scene.rootNode.childNodes.forEach({$0.removeFromParentNode()})
        infoNode = nil
        index = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
