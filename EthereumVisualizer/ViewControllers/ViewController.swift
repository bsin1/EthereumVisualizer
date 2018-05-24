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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var index: Double = 0

    var blockData = [(block: Block, tokenData: [(token: Token, cost: Double, percentage: String)])] ()
    
    var infoNode: SCNNode?
    
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
        when(fulfilled: ApiClient.fetchErcTokens(),
                        ApiClient.fetchErcImages())
        .done { tokens, images in
            print("GOT RESPONSE")
            print("TOKENS SIZE: \(tokens.count)")

            DispatchQueue.main.async {
                var tokens = tokens
                for (index,token) in tokens.enumerated() {
                    print("inside loop")
                    if let imageUrl = images["\(token.symbol)"]["ImageUrl"].string {
                        tokens[index].imageUrl = "https://cryptocompare.com\(imageUrl)"
                    }
                    let color = self.generateColor()
                    print("setting color: \(color)")
                    tokens[index].color = self.generateColor()
                }
                Token.sharedTokens = tokens
                self.startBlockTimer()
            }

            
            
        }.catch { error in
            self.showAlertFromError(error: error)
        }
    }
    
    private func startBlockTimer() {
        print("startBlockTimer")
        fetchLatestBlock()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.fetchLatestBlock), userInfo: nil, repeats: true)
    }
    
    @objc private func fetchLatestBlock() {
        print("FETCH LATEST BLOCK")
        ApiClient.fetchLatestBlock()
            .done { block in
                if(self.blockData.contains(where: {$0.block.hash == block.hash})) {
                    print("BLOCK ALREADY EXISTS")
                    return
                }
                //print("GOT BLOCK: \(block)")
                guard let gasUsed = block.gasUsed,
                    let totalCost = Double(gasUsed),
                    let transactions = block.transactions else {
                    return
                }
                
                var tokenDictionary = [Token:Double]()
                transactions.forEach({ transaction in
                    if let token = Token.sharedTokens.first(where: {$0.address == transaction.to}),
                        let gas = transaction.gas,
                        let gasCost = Double(gas) {
                        if(tokenDictionary[token] == nil) {
                            tokenDictionary[token] = gasCost
                        } else {
                            tokenDictionary[token]! += gasCost
                        }
                    }
                })
                
                var tokenData = [(token: Token, cost: Double, percentage: String)]()

                let scene = self.sceneView.scene

                
                if(tokenDictionary.keys.count > 0) {
                    let maxHeight = 0.025
                    var yCoordinate = 0.0
                    for (key, value) in tokenDictionary {
                        let percentageDouble = value / totalCost
                        let percentage = "\(String(format: "%.2f", percentageDouble * 100))"
                        tokenData.append((token: key, cost: value, percentage: percentage))
                        
                        print("\(key.symbol): \(value) (\(percentage)%)")
                
                        let segmentHeight = maxHeight * percentageDouble
                        
                        yCoordinate += (segmentHeight / 2)
                        print("placing ERC box at y coordinate: \(yCoordinate)")
                        let box = SCNBox(width: 0.025, height: CGFloat(segmentHeight), length: 0.025, chamferRadius: 0)
                        let material = SCNMaterial()
                        material.diffuse.contents = key.color
                        box.materials = [material]
                        let boxNode = SCNNode(geometry: box)
                        boxNode.position = SCNVector3(self.index,yCoordinate,-0.1)
                        scene.rootNode.addChildNode(boxNode)
                        yCoordinate += (segmentHeight / 2)
                        
                    }
                    print("WHITE BLOCK HEIGHT: \(maxHeight - yCoordinate)")

                    let box = SCNBox(width: 0.025, height: CGFloat(maxHeight - yCoordinate), length: 0.025, chamferRadius: 0)
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.white
                    box.materials = [material]
                    let boxNode = SCNNode(geometry: box)
                    boxNode.name = block.hash
                    boxNode.position = SCNVector3(self.index,yCoordinate + ((maxHeight - yCoordinate) / 2),-0.1)
                    scene.rootNode.addChildNode(boxNode)
                    
                } else {
                    let box = SCNBox(width: 0.025, height: 0.025, length: 0.025, chamferRadius: 0)
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.white
                    box.materials = [material]
                    let boxNode = SCNNode(geometry: box)
                    boxNode.name = block.hash
                    boxNode.position = SCNVector3(self.index,0.025/2,-0.1)
                    scene.rootNode.addChildNode(boxNode)
                }
                
                self.index += 0.05
                self.sceneView.scene = scene

                
                print("TOTAL COST: \(totalCost)")
                
                self.blockData.append((block: block, tokenData: tokenData))
                
                


            }.catch { error in
                print("GOT ERROR DURING FETCH LATEST TRANSACTIONS: \(error)")
                
        }
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
