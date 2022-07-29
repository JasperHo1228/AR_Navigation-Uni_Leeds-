//
//  customroute.swift
//  landmarkar
//
//  Created by Tsun Yin Ho on 14/7/2022.
//

import Foundation
import ARKit
import SCNPath
import FocusNode
import SmartHitTest
///still in testing process
extension ARSCNView: ARSmartHitTest {}
class customroute:UIViewController, ARSessionDelegate,ARSCNViewDelegate{
    
    //@IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var Savedata: UIButton!
    @IBOutlet weak var Loaddata: UIButton!
    @IBOutlet weak var label: UILabel!
    var sceneView = ARSCNView(frame: .zero)
    let focusSquare = FocusSquare()
    var hitPoints = [SCNVector3]() {
      didSet {
        self.pathNode.path = self.hitPoints
      }
    }
    var pathNode = SCNPathNode(path: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.frame = self.view.bounds
        self.sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        view.addSubview(Savedata)
        view.addSubview(Loaddata)
        view.addSubview(label)
      
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        
      
        self.focusSquare.viewDelegate = self.sceneView
        self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
        self.sceneView.scene.rootNode.addChildNode(self.pathNode)
        self.setupGestures()
    }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            resetTrackingConfiguration()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
               super.viewWillDisappear(animated)
               // Pause the view's session
               sceneView.session.pause()
           }
    
    var worldMapURL: URL = {
    do {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("worldMapURL")
    } catch {
        fatalError("Error getting world map URL from document directory.")
    }
}()
    
    @IBAction func Saveroute(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
                    guard let worldMap = worldMap else {
                        return self.setLabel(text: "Error getting current world map.")
                    }
                    
                    do {
                        try self.archive(worldMap: worldMap)
                        DispatchQueue.main.async {
                            self.setLabel(text: "World map is saved.")
                        }
                    } catch {
                        fatalError("Error saving world map: \(error.localizedDescription)")
                    }
            }
        }
    
    @IBAction func Load(_ sender: Any) {
        guard let worldMapData = retrieveWorldMapData(from: worldMapURL),
                    let worldMap = unarchive(worldMapData: worldMapData) else { return }
                resetTrackingConfiguration(with: worldMap)
    }
    
    

}

extension customroute{
    func setLabel(text: String) {
          label.text = text
      }
    
    func archive(worldMap: ARWorldMap) throws {
           let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
           try data.write(to: self.worldMapURL, options: [.atomic])
       }
   
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            
            let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
            if let worldMap = worldMap {
                configuration.initialWorldMap = worldMap
                setLabel(text: "Found saved world map.")
            } else {
                setLabel(text: "Move camera around.")
            }
     
            sceneView.debugOptions = [.showFeaturePoints]
            sceneView.session.run(configuration, options: options)
        }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
            do {
                return try Data(contentsOf: self.worldMapURL)
            } catch {
                self.setLabel(text: "Error retrieving data.")
                return nil
            }
        }
        
        func unarchive(worldMapData data: Data) -> ARWorldMap? {
            guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                else { return nil }
            return unarchievedObject
        }
   
}


extension customroute{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
      DispatchQueue.main.async {
        self.focusSquare.updateFocusNode()
      }
    }
}


extension customroute: UIGestureRecognizerDelegate{
    
    func setupGestures() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.delegate = self
            self.sceneView.addGestureRecognizer(tapGesture)
        }

        @IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard gestureRecognizer.state == .ended else {
                return
            }
            if self.focusSquare.state != .initializing {
                self.hitPoints.append(self.focusSquare.position)
            }
        }
    func renderer(
      _ renderer: SCNSceneRenderer,
      didAdd node: SCNNode, for anchor: ARAnchor
    ) {
      if let planeAnchor = anchor as? ARPlaneAnchor,
        planeAnchor.alignment == .vertical,
        let geom = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!)
      {
        geom.update(from: planeAnchor.geometry)
        geom.firstMaterial?.colorBufferWriteMask = .alpha
        node.geometry = geom
      }
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
      if let planeAnchor = anchor as? ARPlaneAnchor,
        planeAnchor.alignment == .vertical,
        let geom = node.geometry as? ARSCNPlaneGeometry
      {
        geom.update(from: planeAnchor.geometry)
      }
    }
}


