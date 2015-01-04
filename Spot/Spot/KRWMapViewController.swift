//
//  ViewController.swift
//  Spot
//
//  Created by Kw on 01/12/14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class KRWMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var toolbar = UIToolbar()
    
    let locationManager = CLLocationManager()
    var locationStatus : NSString = "Not Started"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.hidesBarsOnTap = true
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggle:"))
        
        self.mapView.addSubview(self.toolbar)
        
        if (CLLocationManager.locationServicesEnabled()) {
            // Set current ViewController to the delegate
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            mapView.delegate = self
            mapView.showsUserLocation = true
        } else {
            println("Location services are not enabled");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CoreLocation Delegate Methods
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        //removeLoadingView() // ToDo find out what that means ????
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        //Coordinations od the current position (gps)
        var coord = locationObj.coordinate
        
        // Calculate the center
        //let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        // Calculate the region which is shown by themap
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        // Set the Maps view to the region
        //self.mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            // status of authorization
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    
    
//    func toggle(sender: AnyObject) {
//        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true) //or animated: false
//    }
//    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    

    @IBAction func callEmergencyContact(sender: AnyObject) {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var err = NSErrorPointer()
        var request = NSFetchRequest(entityName: "Number")
        request.returnsObjectsAsFaults = false
        var results:NSArray = context.executeFetchRequest(request, error: err)!
        if results.count > 0 {
            let loadObject:NSManagedObject = results[0] as NSManagedObject
            if let url = NSURL(string:loadObject.valueForKey("number") as String){
                if UIApplication.sharedApplication().canOpenURL(url){
                    println(url)
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }else if results.count == 0 {
            // No number saved ... save now?
        }
        println(results.count.description)
        
    }
    
    func getDestination() -> MKPlacemark? {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        var err = NSErrorPointer()
        var request = NSFetchRequest(entityName: "Destination")
        request.returnsObjectsAsFaults = false
        var results:NSArray = context.executeFetchRequest(request, error: err)!
        if results.count > 0 {
            let loadObject:NSManagedObject = results[0] as NSManagedObject
            var long:Double = loadObject.valueForKey("longitude") as Double
            var lat:Double = loadObject.valueForKey("latitude") as Double
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long), completionHandler: {(places: [AnyObject]!, error:NSError!) -> Void in
                for place in places {
                    println("################")
                    println(place.name)
                    println("################")
                }
            })
            
            return MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), addressDictionary: nil)
        }else if results.count == 0 {
            // No Destination saved ... save now?
        }
        return nil
    }
    
    @IBAction func bringMeHome(sender: AnyObject) {
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        var destination: MKMapItem = MKMapItem(placemark: getDestination())
        request.setDestination(destination)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler({(response:
            MKDirectionsResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error
            } else {
                self.showRoute(response)
            }
            
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes as [MKRoute] {
            
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                println(step.instructions as String)
            }
        }
        let userLocation = self.mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location.coordinate, 2000, 2000)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

}

