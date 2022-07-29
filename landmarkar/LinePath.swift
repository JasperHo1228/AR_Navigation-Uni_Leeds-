//
//  LinePath.swift
//  landmarkar
//
//  Created by Tsun Yin Ho on 29/5/2022.
//


import ARCL
import MapKit
import CoreLocation
import ARKit


class LinePath: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    var sceneLocationView = SceneLocationView()
    @IBOutlet weak var map:MKMapView!
    let locationManager = CLLocationManager()
    var destination_name:String = ""
    var lat:Double!=nil
    var long:Double!=nil
    var bool:Bool = false
    var currentLocation: CLLocation? {
            return sceneLocationView.sceneLocationManager.currentLocation
        }
    
    @IBOutlet weak var distancelabel: UILabel!
  
    
    var label = UILabel(frame: CGRect(x: 0, y: 100, width: 150, height: 80))
    var arpath:MKRoute? = nil
    var point:[CLLocation] = []
    let customiseBuilder: BoxBuilder = { (distance) -> SCNBox in
        let box = SCNBox(width: 4, height: 0.2, length: distance, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return box
    }
   
    var k = 0
    var i = 0
    var j = 0
    var b:Bool = true
    
        override func viewDidLoad() {
            super.viewDidLoad()
             self.sceneLocationView.run()
            view.addSubview(self.sceneLocationView)
            map.delegate = self
            view.addSubview(map)
            view.addSubview(self.distancelabel)
            //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            //sceneLocationView.addGestureRecognizer(gestureRecognizer)
            if (self.lat == nil && self.long == nil && arpath == nil){
                print("nil")
            }
            else{
                routeline()
            }
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            self.sceneLocationView.frame = view.bounds
        }
       
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            //let configuration = ARWorldTrackingConfiguration()
            //configuration.planeDetection = [.horizontal]
            //sceneLocationView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        }
        

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.sceneLocationView.pause()
        }
   
     //touch it again it will startupdating
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         locationManager.startUpdatingLocation()
         locationManager.stopUpdatingHeading()
     }
   
   //get the ar route
    func routeline(){
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        
        //searching location
        //Remove the annotation
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
                     
         //Create an annotation
         let annotation = MKPointAnnotation()
         annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.long)
         self.map.addAnnotation(annotation)
                     
         //Zooming in on annotation
         let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.lat, self.long)
         let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
         let region = MKCoordinateRegion(center: coordinate,span: span)
                     self.map.setRegion(region, animated: true)
        
        //get the direction from mapkit
        let directionRequest = MKDirections.Request()
        directionRequest.source =  MKMapItem.forCurrentLocation()
        let destinationlocation = MKPlacemark(coordinate: coordinate)
        directionRequest.destination = MKMapItem(placemark:destinationlocation)
        directionRequest.requestsAlternateRoutes = false
        directionRequest.transportType = .walking
        let directions = MKDirections(request:directionRequest)
        
        
        //calulate the route from mapkit route
        //check how the the route be calculate
        directions.calculate{ response,error in
            if error != nil {
              return print("wrong")
            }
            guard let arroute = response?.routes.first else{
                return print("error")
            }
        
            self.arpath = arroute
            //self.sceneLocationView.addRoutes(routes: [arroute])
            //show one ployline at one time
            self.map.removeOverlays(self.map.overlays)
            self.map.addOverlay(arroute.polyline)
            self.map.setVisibleMapRect(arroute.polyline.boundingMapRect, animated:true)
            
           //UI code must be executed by using DispatchQueue.main, also it can keep updating the UI
           //async use for deal with multiple tasks executed at a time, the task no need to wait for other task to be completed. === Concurrency in the queue
            DispatchQueue.main.async { [weak self] in
                self?.routeplot(route: arroute)
              }
           
       
      //this is getting each coordinate point from the route
            
        let points = arroute.polyline.points()
           //for mapkit api they don't let us to find out the location altitude
           //they just can find out the current altitude of the camera
           for i in 0 ..< arroute.polyline.pointCount - 1 {
               let pin1 = MKPointAnnotation()
               pin1.coordinate = CLLocationCoordinate2DMake(points[i+1].coordinate.latitude, points[i+1].coordinate.longitude)
               self.map.addAnnotation(pin1)
           }
}
      
    
        //Ar uilabel check point
        self.label.textAlignment = .center
        self.label.backgroundColor = .black
        
        
        //define uilabel total distance
        self.distancelabel.backgroundColor = UIColor.black
        self.distancelabel.font = self.distancelabel.font.withSize(26)
        self.distancelabel.numberOfLines = 0
        self.distancelabel.textColor = .systemYellow
        self.distancelabel.textAlignment = .center
        
    }

    
}


//deal with the small map detail
extension LinePath{
    //layout of the ployline on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)-> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .systemYellow
        render.lineWidth = 8
        return render
    }
    
    func routeplot(route: MKRoute) {
      
        guard let location = currentLocation,
              //horizontalAccuracy mean the expandsion light given from current location point
              //the is checking the uncertainty of the current location.
                location.horizontalAccuracy < 15 else {
                //run the route function again after a half second delay in the queue if horizontalAccuracy is smaller than 15
                    return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.routeplot(route: route)
                    }
            }
        self.sceneLocationView.addRoutes(routes: [route],boxBuilder: self.customiseBuilder)
    }
   
    
    func locationManager (_ manager: CLLocationManager ,didUpdateLocations locations :[CLLocation]){
        
        self.sceneLocationView.orientToTrueNorth = false
        map.setUserTrackingMode(.followWithHeading, animated: true)
        map.showsUserLocation = true
        locationManager.startUpdatingLocation()
        //locationManager.startUpdatingHeading()
       
        let userlocation = locations[0] as CLLocation
        
  
 
     
        //prevent the app crash when passing the nil value(long and lat)
        // not locaiton input the label will be showed Please enter the location!
        if (self.lat == nil && self.long == nil){
            self.distancelabel.backgroundColor = UIColor.black
            self.distancelabel.font = self.distancelabel.font.withSize(26)
            self.distancelabel.numberOfLines = 0
            self.distancelabel.textColor = .systemYellow
            self.distancelabel.textAlignment = .center
            self.distancelabel.text = "Please enter the location!"
        }
        
       // when horizontal Accuracy more than 15 the UILabel will show up this info and not show the
       // destination name and distance
        else if (currentLocation!.horizontalAccuracy>15){
            self.distancelabel.text = "horizontalAccuracy>15\n \(currentLocation!.horizontalAccuracy)"
        }
        else{
            let destination = CLLocation(coordinate: CLLocationCoordinate2D(latitude:self.lat, longitude: self.long), altitude: currentLocation!.altitude)
           let distance = destination.distance(from: userlocation)
           let destination_metre = Int(distance)
           self.distancelabel.text = "\(self.destination_name)\n Distance:\(destination_metre) m"
            
            
            if (destination_metre <= 25 && self.k < 1){
               if (self.arpath != nil){
                   self.sceneLocationView.removeAllNodes()
               }
               
               let location_info = UILabel(frame: CGRect(x: 0, y: 100, width: 280, height: 100))
               location_info.backgroundColor = .black
               location_info.textColor = .systemYellow
               location_info.textAlignment = .center
               location_info.font = location_info.font.withSize(30)
               location_info.text = "You have arrived!"
               let last_label = LocationAnnotationNode(location: destination, view: location_info)
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: last_label)
                    self.k = self.k+1
            }
        }
    }

}


