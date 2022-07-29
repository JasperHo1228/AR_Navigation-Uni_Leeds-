//
//  MapViewController.swift
//  landmarkar
//
//  Created by Tsun Yin Ho on 26/5/2022.
//

import CoreLocation
import MapKit


class MapViewController: ARpublicmethod, UISearchControllerDelegate{
   
    
    @IBOutlet weak var ARMode: UIButton!
    @IBOutlet weak var Route: UIButton!
    @IBOutlet var map:MKMapView!

    @IBOutlet weak var customise: UIButton!
    
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var location_name:String = ""
    var selectedPin:MKPlacemark? = nil
    
    //concept of global variable
    var longtitude:Double! = nil
    var latitude:Double! = nil
    var route: MKRoute? = nil
    let touch_annotation = MKPointAnnotation()
    
    @IBAction func ARPath(_ sender: Any) {
    }
    
    //@IBAction func linkmap need to be empty otherwise it will-
    //push two controller view out!!!!!
    @IBAction func linkmap(_ sender: Any) {
    }
    
    @IBAction func customar(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        view.addSubview(ARMode)
        view.addSubview(Route)
        view.addSubview(customise)
        map.isRotateEnabled = true
        
        locationManager.delegate = self
        map.showsUserLocation = true
        map.delegate = self
        map.showsCompass = true
        map.showsScale = true
        map.showsBuildings = true
        
        
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation  = true
        definesPresentationContext = true
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Searching"
        navigationItem.titleView = resultSearchController?.searchBar
        
        locationSearchTable.map = map
        locationSearchTable.mapSearching = self
        
        let presslong = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.touchaddPin))
        self.map.addGestureRecognizer(presslong)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

   
    func locationManager (_ manager: CLLocationManager ,didUpdateLocations locations :[CLLocation]){
        map.setUserTrackingMode(.followWithHeading, animated: true)
        map.showsUserLocation = true
    }
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         locationManager.stopUpdatingLocation()
     }
    
     //when move the map it will stop update
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         locationManager.stopUpdatingLocation()
     }
    
     //touch it again it will startupdating
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         locationManager.startUpdatingLocation()
         locationManager.startUpdatingHeading()
     }
  
    
    @IBAction func touchaddPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let touch_long = gestureRecognizer.location(in: self.map)
        let location_postion = map.convert(touch_long, toCoordinateFrom: self.map)
        self.touch_annotation.coordinate =   CLLocationCoordinate2DMake(location_postion.latitude,location_postion.longitude)
        touch_annotation.title = "Pin"
        map.addAnnotation(self.touch_annotation)
       
        latitude = location_postion.latitude
        longtitude = location_postion.longitude
        location_name = "Distance:"
       
        let directionRequest = MKDirections.Request()
        let currentlocation = MKMapItem.forCurrentLocation()
        directionRequest.source = currentlocation
      
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude!, self.longtitude!)
        let destinationlocation = MKPlacemark(coordinate: coordinate)
        directionRequest.destination = MKMapItem(placemark:destinationlocation)
        directionRequest.transportType = .walking
        directionRequest.requestsAlternateRoutes = false
        let directions = MKDirections(request:directionRequest)
                
        directions.calculate(completionHandler: { response,error in
                    guard response != nil else{
                        if error != nil{
                            print("wrong")
                        }
                        return
                    }
                    //get the route
            self.route = response!.routes[0]
            print(response!.routes[0].distance,"Metres")
                    //self.lineroutes = response!.routes
                    //just show one route only
            self.map.removeOverlays(self.map.overlays)
            self.map.addOverlay(self.route!.polyline)
            self.map.setVisibleMapRect(self.route!.polyline.boundingMapRect, animated: true)
                })
    }
}




public protocol MapSearch {
    
    func location_info(placemark:MKPlacemark)
}

extension MapViewController: MapSearch {
    func location_info(placemark:MKPlacemark){
        selectedPin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        //dropping the destination pin on apple map
        //coordinate in swift contain the information of latitude and longtitude
        annotation.coordinate = placemark.coordinate
        //show up the location name on pin
        annotation.title = placemark.name
        
       
        location_name = placemark.name!
        if(placemark.name == "Leeds University Union"){
            latitude = 53.80677
            longtitude = -1.55644
        }
        
       else{
        latitude = placemark.coordinate.latitude
        longtitude = placemark.coordinate.longitude
        }
        
        map.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
        
   
        //asking for a route
        let directionRequest = MKDirections.Request()
        //get the users current location
        let currentlocation = MKMapItem.forCurrentLocation()
        //this can be understand as a starting point on the map by using source it can be
        directionRequest.source = currentlocation
        //define destination coordinate
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude!, self.longtitude!)
        let destinationlocation = MKPlacemark(coordinate: coordinate)
        //get the detination point on map by using mkmapitem
        directionRequest.destination = MKMapItem(placemark:destinationlocation)
        directionRequest.transportType = .walking
        directionRequest.requestsAlternateRoutes = false
        //by giving two point from the above request a route
        let directions = MKDirections(request:directionRequest)
        
        //calculate the route
        directions.calculate(completionHandler: { response,error in
                    guard response != nil else{
                        if error != nil{
                            print("wrong")
                        }
                        return
                    }
                    //get the route
            self.route = response!.routes[0]
            print(response!.routes[0].distance,"Metres")
           
            self.map.removeOverlays(self.map.overlays)
            //show the route
            self.map.addOverlay(self.route!.polyline)
            self.map.setVisibleMapRect(self.route!.polyline.boundingMapRect, animated: true)
                })
    }
}


extension MapViewController{
    //customise the route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)->MKOverlayRenderer{
        let render = MKPolylineRenderer(overlay: overlay as!MKPolyline)
        render.strokeColor = .systemYellow
        render.lineWidth = 8
        return render
    }
    
    //send the location data and route to ViewController and LinePath
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "mapping"){
                    let mapvc = segue.destination as! ViewController
                     mapvc.lat = self.latitude
                     mapvc.long = self.longtitude
                     mapvc.destination_name = self.location_name
            }
        else if (segue.identifier == "ARroute"){
            let aroute = segue.destination as! LinePath
            aroute.lat = self.latitude
            aroute.long = self.longtitude
            aroute.destination_name = self.location_name
        }
    }

}





