//
//  ViewController.swift
//  add_object
//
//  Created by Tsun Yin Ho on 24/5/2022.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()()
        
        // Add the box anchor to the scene
        arView.scene.addAnchors(boxAnchor
    }
}
