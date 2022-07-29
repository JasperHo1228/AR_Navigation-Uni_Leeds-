//
//  ViewController.swift
//  landmarkar
//
//  Created by Tsun Yin Ho on 10/4/2022.
//

import UIKit
import ARKit
import ARCoreLocation
import MapKit


public typealias ARpublicmethod = UIViewController & ARSCNViewDelegate& CLLocationManagerDelegate & MKMapViewDelegate

class ViewController: ARpublicmethod {

   
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var map:MKMapView!
    var route_count = 0
    var landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
    
    var locationManager = CLLocationManager()
    var userlocation:CLLocation!
    var lat:Double! = nil
    var long:Double! = nil
    
    var destination_name:String = ""
    //stored the location detail in dictionary
    typealias location_detail = (location_name_distance:UILabel, location:CLLocation)
    //distance as the key metre
    var location_dictionary = [Int : location_detail]()

    
    //show up all the thing on the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        //show the ar label
        self.view.addSubview(landmarker.view)
        //add the map in the scence
        self.view.addSubview(map)
        show_location()
        //boss delegate employee some work (p.s:this so important without this line it will keep loading)
        //ViewController = self is the delegate of map
        map.delegate = self
        locationManager.delegate = self
        map.showsUserLocation = true
        //prevent the app crash cuz the nil value
        if (self.lat == nil && self.long == nil){
            print("No location are inputed")
        }
        else{
        //output the map detail function
        Small_Map()
        }
    }
    
   override func viewDidLayoutSubviews() {
       landmarker.view.frame = self.view.frame
       landmarker.scene.size = self.view.frame.size
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
    
    // starting checking overlapping problem and stop updating the current location on the from the apple map
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.stopUpdatingLocation()
        landmarker.beginEvaluatingOverlappingLandmarks(atInterval: 0)
        landmarker.overlappingLandmarksStrategy = .showNearest
        locationManager.startUpdatingHeading()
    }
    //when move the map it will stop update
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    //release the tapping, it will stop evaluating the overlap function and start update the current location again
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.startUpdatingLocation()
        landmarker.stopEvaluatingOverlappingLandmarks()
        locationManager.startUpdatingHeading()
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}


//this part is going to display the AR Label and also the distance
//key part for input location
extension ViewController{
    
    func show_location(){
        self.userlocation = locationManager.location
        
    //1) maybe try to find how to group up all the related variable
    //2) set up the distance if small than 170m then display those 10 location
    //3) dictionary key: distance, value(uilabel, location)
    
   
        
    let Parkinaon_label = UILabel(frame: CGRect(x: 0 , y: 0, width: 250, height: 110))
        Parkinaon_label.backgroundColor = UIColor.black
        Parkinaon_label.font = Parkinaon_label.font.withSize(30)
        Parkinaon_label.numberOfLines = 0
    let Parkinson_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80801, longitude: -1.55240), altitude: 82, horizontalAccuracy:15, verticalAccuracy:15, timestamp: Date())
    let distance_parkinson = Parkinson_location.distance(from: self.userlocation) //by using haversine formula
    let distance_parkinson_metre = Int(distance_parkinson)
    Parkinaon_label.textColor = .systemYellow
    Parkinaon_label.textAlignment = .center
    Parkinaon_label.text = "Parkinson Building\n Distance: \(distance_parkinson_metre)m";
        location_dictionary[distance_parkinson_metre] = location_detail(location_name_distance:Parkinaon_label,location:Parkinson_location)
      
        
    //Bp distance :53.80778,-1.54977
    let BP_label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 125))
        BP_label.backgroundColor = UIColor.black
        BP_label.font = BP_label.font.withSize(30)
        BP_label.numberOfLines = 0
    let BP_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.80778, longitude: -1.54977), altitude: 80, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let distance_BP = BP_location.distance(from: self.userlocation) //by using haversine formula
    let distance_BP_metre = Int(distance_BP)
    BP_label.textColor = .systemYellow
    BP_label.textAlignment = .center
    BP_label.text = "Blenhiem Point\n Distance: \(distance_BP_metre) m";
        location_dictionary[distance_BP_metre] = location_detail(location_name_distance:BP_label,location:BP_location)
      
       
    // Brag distance  53.80888° N, 1.55399° W
    let Bragg_label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 110))
        Bragg_label.backgroundColor = UIColor.black
        Bragg_label.font = Bragg_label.font.withSize(30)
        Bragg_label.numberOfLines = 0
    let Bragg_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.80888, longitude: -1.55399), altitude: 89, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let distance_Brag = Bragg_location.distance(from: self.userlocation)
    let distance_Bragg_metre = Int(distance_Brag)
    Bragg_label.textColor = .systemYellow
    Bragg_label.textAlignment = .center
    Bragg_label.text = "Bragg Building\n Distance: \(distance_Bragg_metre) m";
    location_dictionary[distance_Bragg_metre] = location_detail(location_name_distance:Bragg_label,location:Bragg_location)
    
    //Laidlaw distance 53.80678° N, 1.55188° W 53.80679° N, 1.55188° W
    let Laidlaw_label = UILabel(frame: CGRect(x: 0, y: 0, width: 230, height: 110))
        Laidlaw_label.backgroundColor = UIColor.black
        Laidlaw_label.font = Laidlaw_label.font.withSize(30)
        Laidlaw_label.numberOfLines = 0
    let Laidlaw_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:  53.80679, longitude: -1.55188), altitude: 78, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
    let distance_Laidlaw = Laidlaw_location.distance(from: self.userlocation)
    let distance_Laidlaw_metre = Int(distance_Laidlaw)
    Laidlaw_label.textAlignment = .center
    Laidlaw_label.textColor = .systemYellow
    Laidlaw_label.text = "Laidlaw Library\n Distance: \(distance_Laidlaw_metre) m";
    location_dictionary[distance_Laidlaw_metre] = location_detail(location_name_distance:Laidlaw_label,location:Laidlaw_location)

    //Business school: 53.80781° N, 1.56047° W
    let Business_label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        Business_label.backgroundColor = UIColor.black
        Business_label.font = Business_label.font.withSize(30)
        Business_label.numberOfLines = 0
    let Business_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80781, longitude:-1.56047), altitude: 83, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
    let distance_Business =  Business_location.distance(from: self.userlocation)
    let distance_Business_metre = Int(distance_Business)
    Business_label.textColor = .systemYellow
    Business_label.textAlignment = .center
    Business_label.text = "Business School\n Distance: \(distance_Business_metre) m";
    location_dictionary[distance_Business_metre] = location_detail(location_name_distance:Business_label,location:Business_location)
        
        //Marjorie and Arnold Ziff Building:53.80663° N, 1.55387° W
    let marjorie_label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        marjorie_label.backgroundColor = UIColor.black
        marjorie_label.font = marjorie_label.font.withSize(30)
        marjorie_label.numberOfLines = 0
    let marjorie_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.80663, longitude: -1.55387), altitude: 81, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let distance_marjorie = marjorie_location.distance(from: self.userlocation)
        let distance_marjorie_metre = Int(distance_marjorie)
        marjorie_label.textColor = .systemYellow
        marjorie_label.textAlignment = .center
        marjorie_label.text = "Marjorie and Arnold Ziff Building\n Distance:\(distance_marjorie_metre) m";
        location_dictionary[distance_marjorie_metre] = location_detail(location_name_distance:marjorie_label,location:marjorie_location)
        
    // nexus 53.80549° N, 1.55032° W
    let nexus_label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        nexus_label.backgroundColor = UIColor.black
        nexus_label.font = nexus_label.font.withSize(30)
        nexus_label.numberOfLines = 0
        let nexus_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80549, longitude: -1.55032), altitude: 70, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
            let distance_nexus = nexus_location.distance(from: self.userlocation)
            let distance_nexus_metre = Int(distance_nexus)
            nexus_label.textColor = .systemYellow
            nexus_label.textAlignment = .center
            nexus_label.text = "Nexus\n Distance:\(distance_nexus_metre) m";
            location_dictionary[distance_nexus_metre] = location_detail(location_name_distance:nexus_label,location:nexus_location)
    
        //EC_Stoner 53.80538° N, 1.55174° W
        let EC_Stoner_label = UILabel(frame: CGRect(x: 0, y: 100, width: 250, height: 150))
        EC_Stoner_label.backgroundColor = UIColor.black
        EC_Stoner_label.font = EC_Stoner_label.font.withSize(30)
        EC_Stoner_label.numberOfLines = 0
            let EC_Stoner_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.80538, longitude: -1.55174), altitude: 83, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_EC_Stoner = EC_Stoner_location.distance(from: self.userlocation)
                let distance_EC_Stoner_metre = Int(distance_EC_Stoner)
                EC_Stoner_label.textColor = .systemYellow
                EC_Stoner_label.textAlignment = .center
                EC_Stoner_label.text = "EC Stoner Building\n Distance:\(distance_EC_Stoner_metre) m";
                location_dictionary[distance_EC_Stoner_metre] = location_detail(location_name_distance:EC_Stoner_label,location:EC_Stoner_location)
        
        
        //ARABIC, ISLAMIC AND MIDDLE EASTERN STUDIES
        //School of Languages, Cultures and Societies: Michael Sadler Building 53.80709° N, 1.55341° W
        let Michael_Sadler_label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 130))
        Michael_Sadler_label.backgroundColor = UIColor.black
        Michael_Sadler_label.font = Michael_Sadler_label.font.withSize(30)
        Michael_Sadler_label.numberOfLines = 0
            let Michael_Sadler_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80709, longitude: -1.55341), altitude: 81, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Michael_Sadler = Michael_Sadler_location.distance(from: self.userlocation)
                let distance_Michael_Sadler_metre = Int(distance_Michael_Sadler)
                Michael_Sadler_label.textColor = .systemYellow
                Michael_Sadler_label.textAlignment = .center
                Michael_Sadler_label.text = "Michael Sadler Building\n Distance:\(distance_Michael_Sadler_metre) m";
                location_dictionary[distance_Michael_Sadler_metre] = location_detail(location_name_distance:Michael_Sadler_label,location:Michael_Sadler_location)
      
        //ASTBURY BUILDING Biological Sciences  53.80390° N, 1.55545° W
        let Astbury_label = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 150))
        Astbury_label.backgroundColor = UIColor.black
        Astbury_label.font = Astbury_label.font.withSize(30)
        Astbury_label.numberOfLines = 0
            let Astbury_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:  53.80390, longitude: -1.55545), altitude: 68, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Astbury = Astbury_location.distance(from: self.userlocation)
                let distance_Astbury_metre = Int(distance_Astbury)
                Astbury_label.textColor = .systemYellow
                Astbury_label.textAlignment = .center
                Astbury_label.text = "Astbury Building\n Distance:\(distance_Astbury_metre) m";
                location_dictionary[distance_Astbury_metre] = location_detail(location_name_distance:Astbury_label,location:Astbury_location)
        
       // Baines Wing 53.80743° N, 1.55334° W
        let Baines_wing_label = UILabel(frame: CGRect(x: 0, y: 100, width: 250, height: 150))
        Baines_wing_label.backgroundColor = UIColor.black
        Baines_wing_label.font = Baines_wing_label.font.withSize(30)
        Baines_wing_label.numberOfLines = 0
            let Baines_wing_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80743, longitude:-1.55334), altitude:82 , horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Baines_wing = Baines_wing_location.distance(from: self.userlocation)
                let distance_Baines_wing_metre = Int(distance_Baines_wing)
        Baines_wing_label.textColor = .systemYellow
        Baines_wing_label.textAlignment = .center
        Baines_wing_label.text = "Baines Wing\n Distance:\(distance_Baines_wing_metre) m";
                location_dictionary[distance_Baines_wing_metre] = location_detail(location_name_distance:Baines_wing_label,location:Baines_wing_location)
        
        //Beech Grove House 53.80718° N, 1.55574° W
        let Beech_Grove_House_label = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 150))
        Beech_Grove_House_label.backgroundColor = UIColor.black
        Beech_Grove_House_label.font = Beech_Grove_House_label.font.withSize(30)
        Beech_Grove_House_label.numberOfLines = 0
            let Beech_Grove_House_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.80718, longitude:-1.55574), altitude: 89, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Beech_Grove_House = Beech_Grove_House_location.distance(from: self.userlocation)
                let distance_Beech_Grove_House_metre = Int(distance_Beech_Grove_House)
        Beech_Grove_House_label.textColor = .systemYellow
        Beech_Grove_House_label.textAlignment = .center
        Beech_Grove_House_label.text = "Beech Grove House\n Distance:\(distance_Beech_Grove_House_metre) m";
                location_dictionary[distance_Beech_Grove_House_metre] = location_detail(location_name_distance:Beech_Grove_House_label,location:Beech_Grove_House_location)
        
        //Beech Grove terrace 53.80714° N, 1.55480° W
        let Beech_Grove_Terrace_label = UILabel(frame: CGRect(x: 0, y: 82, width: 250, height: 150))
        Beech_Grove_Terrace_label.backgroundColor = UIColor.black
        Beech_Grove_Terrace_label.font = Beech_Grove_Terrace_label.font.withSize(30)
        Beech_Grove_Terrace_label.numberOfLines = 0
            let Beech_Grove_Terrace_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80714, longitude: -1.55480), altitude: 82, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Beech_Grove_Terrace = Beech_Grove_Terrace_location.distance(from: self.userlocation)
                let distance_Beech_Grove_Terrace_metre = Int(distance_Beech_Grove_Terrace)
        Beech_Grove_Terrace_label.textColor = .systemYellow
        Beech_Grove_Terrace_label.textAlignment = .center
        Beech_Grove_Terrace_label.text = "Beech Grove Terrace\n Distance:\(distance_Beech_Grove_Terrace_metre) m";
                location_dictionary[distance_Beech_Grove_Terrace_metre] = location_detail(location_name_distance:Beech_Grove_Terrace_label,location:Beech_Grove_Terrace_location)
        
         
        
        //L C Mail Building 53.80388° N, 1.55441° W
        let LC_Mail_Building_label = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 150))
        LC_Mail_Building_label.backgroundColor = UIColor.black
        LC_Mail_Building_label.font = LC_Mail_Building_label.font.withSize(30)
        LC_Mail_Building_label.numberOfLines = 0
            let LC_Mail_Building_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80388, longitude: -1.55441), altitude: 68, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_LC_Mail_Building = LC_Mail_Building_location.distance(from: self.userlocation)
                let distance_LC_Mail_Building_metre = Int(distance_LC_Mail_Building)
        LC_Mail_Building_label.textColor = .systemYellow
        LC_Mail_Building_label.textAlignment = .center
        LC_Mail_Building_label.text = "L C Maill Building\n Distance:\(distance_LC_Mail_Building_metre) m";
                location_dictionary[distance_LC_Mail_Building_metre] = location_detail(location_name_distance:LC_Mail_Building_label,location:LC_Mail_Building_location)
         
        //53.80721,-1.52165 St James's University Hospital
        let St_James_Hospital_label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        St_James_Hospital_label.backgroundColor = UIColor.black
        St_James_Hospital_label.font = St_James_Hospital_label.font.withSize(30)
        St_James_Hospital_label.numberOfLines = 0
            let St_James_Hospital_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80721, longitude: -1.52165), altitude: 66, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_St_James_Hospital = St_James_Hospital_location.distance(from: self.userlocation)
                let distance_St_James_Hospital_metre = Int(distance_St_James_Hospital)
        St_James_Hospital_label.textColor = .systemYellow
        St_James_Hospital_label.textAlignment = .center
        St_James_Hospital_label.text = "St James's University Hospital\n Distance:\(distance_St_James_Hospital_metre) m";
                location_dictionary[distance_St_James_Hospital_metre] = location_detail(location_name_distance:St_James_Hospital_label,location:St_James_Hospital_location)

    
        //53.80574° N, 1.55565° W Bio_Teaching_Laboratories
        let Bio_Teaching_Laboratories_label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        Bio_Teaching_Laboratories_label.backgroundColor = UIColor.black
        Bio_Teaching_Laboratories_label.font = Bio_Teaching_Laboratories_label.font.withSize(30)
        Bio_Teaching_Laboratories_label.numberOfLines = 0
            let Bio_Teaching_Laboratories_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80574, longitude: -1.55565), altitude: 77, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Bio_Teaching_Laboratories = Bio_Teaching_Laboratories_location.distance(from: self.userlocation)
                let distance_Bio_Teaching_Laboratories_metre = Int(distance_Bio_Teaching_Laboratories)
        Bio_Teaching_Laboratories_label.textColor = .systemYellow
        Bio_Teaching_Laboratories_label.textAlignment = .center
        Bio_Teaching_Laboratories_label.text = "Biological Sciences Teaching Laboratories\n Distance:\(distance_Bio_Teaching_Laboratories_metre) m";
                location_dictionary[distance_Bio_Teaching_Laboratories_metre] = location_detail(location_name_distance:Bio_Teaching_Laboratories_label,location:Bio_Teaching_Laboratories_location)
        
        //53.80427° N, 1.55295° W The Edge
        let The_Edge_label = UILabel(frame: CGRect(x: 0, y: 0, width: 230, height: 120))
        The_Edge_label.backgroundColor = UIColor.black
        The_Edge_label.font = The_Edge_label.font.withSize(30)
        The_Edge_label.numberOfLines = 0
            let The_Edge_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80427, longitude: -1.55295), altitude: 68, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_The_Edge = The_Edge_location.distance(from: self.userlocation)
                let distance_The_Edge_metre = Int(distance_The_Edge)
        The_Edge_label.textColor = .systemYellow
        The_Edge_label.textAlignment = .center
        The_Edge_label.text = "The Edge\n Distance:\(distance_The_Edge_metre) m";
                location_dictionary[distance_The_Edge_metre] = location_detail(location_name_distance:The_Edge_label,location:The_Edge_location)
        
        //landmarker.addLandmark(view: Beech_Grove_Terrace_label , at:Beech_Grove_Terrace_location , completion: nil)
        
        let LUU_label = UILabel(frame: CGRect(x: 0, y: 0, width: 230, height: 120))
        LUU_label.backgroundColor = UIColor.black
        LUU_label.font = LUU_label.font.withSize(30)
        LUU_label.numberOfLines = 0
            let LUU_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80677, longitude: -1.55644), altitude: 80, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_LUU = LUU_location.distance(from: self.userlocation)
                let distance_LUU_metre = Int(distance_LUU)
        LUU_label.textColor = .systemYellow
        LUU_label.textAlignment = .center
        LUU_label.text = "Leeds University Union\n Distance:\(distance_LUU_metre) m";
                location_dictionary[distance_LUU_metre] = location_detail(location_name_distance:LUU_label,location:LUU_location)
       // landmarker.addLandmark(view: LUU_label , at:LUU_location , completion: nil)
        
        let Cloth_building_label = UILabel(frame: CGRect(x: 0, y: 0, width: 230, height: 120))
        Cloth_building_label.backgroundColor = UIColor.black
        Cloth_building_label.font = Cloth_building_label.font.withSize(30)
        Cloth_building_label.numberOfLines = 0
            let Cloth_building_location = CLLocation(coordinate: CLLocationCoordinate2D(latitude:53.80815, longitude: -1.55475), altitude: 80, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
                let distance_Cloth_building = Cloth_building_location.distance(from: self.userlocation)
                let distance_Cloth_building_metre = Int(distance_Cloth_building)
        Cloth_building_label.textColor = .systemYellow
        Cloth_building_label.textAlignment = .center
        Cloth_building_label.text = "Clothworkers' Building North\n Distance:\(distance_Cloth_building_metre) m";
                location_dictionary[distance_Cloth_building_metre] = location_detail(location_name_distance:Cloth_building_label,location:Cloth_building_location)
       
        //sorted the distance in dictionary and get top 5 location
        let sorted_distance = location_dictionary.keys.sorted()[...4]
        //let intersecting: [[SKNode]]
        for key in sorted_distance{
            //set up the distance threshold
            if(key <= 170){
                landmarker.addLandmark(view:location_dictionary[key]!.location_name_distance , at:location_dictionary[key]!.location, completion: nil)
                
            }
        }
    }
}

extension ViewController{
    
    //update current location key part
    func locationManager (_ manager: CLLocationManager ,didUpdateLocations locations :[CLLocation]){
        //current location
        
        map.setUserTrackingMode(.followWithHeading, animated: true)
        map.showsUserLocation = true
    }
}

//this part is show up the small map detail
extension ViewController{
    
    func Small_Map(){
        //activity Incidator pin logo
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //after find out the pin need to animate otherwise the loading sign will
        //keep on loading
        activityIndicator.stopAnimating()
        //searching location
        //Remove the annotation
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
                     
         //Create an annotation
         let annotation = MKPointAnnotation()
         annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.long)
         annotation.title = destination_name
         self.map.addAnnotation(annotation)
                     
         //Zooming in on annotation
         let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.lat, self.long)
         let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
         let region = MKCoordinateRegion(center: coordinate,span: span)
                     self.map.setRegion(region, animated: true)
        
                }

}


