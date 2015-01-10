//
//  CameraTestViewController.swift
//  Spot
//
//  Created by Florian Anders on 10.01.15.
//  Copyright (c) 2015 K.Wachendorff & F.Anders. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation
import CoreData

class CameraViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var locationStatus : NSString = "Not Started"
    
    var currentCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.mediaTypes = [kUTTypeImage]    //
        self.sourceType = .Camera   //Set the interface, which will be displayed
        if (CLLocationManager.locationServicesEnabled()) {
            // Set current ViewController to the delegate
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
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
        self.currentCoordinates = locationObj.coordinate
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

    //Save image, get and save location
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage] as UIImage?, nil, nil, nil)   //Speichern des Bildes
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Destination")
        request.returnsObjectsAsFaults = false
        var err = NSErrorPointer()
        
        var results:NSArray = context.executeFetchRequest(request, error: err)!
        if results.count > 0 {
            let loadObject:NSManagedObject = results[0] as NSManagedObject
            loadObject.setValue(self.currentCoordinates?.latitude, forKey: "latitude")
            loadObject.setValue(self.currentCoordinates?.longitude, forKey: "longitude")
            println("Destination saved.")
            context.save(nil)
        } else if results.count == 0 {
            var newObject:NSManagedObject  = NSEntityDescription.insertNewObjectForEntityForName("Destination", inManagedObjectContext: context) as NSManagedObject
            newObject.setValue(self.currentCoordinates?.latitude, forKey: "latitude")
            newObject.setValue(self.currentCoordinates?.longitude, forKey: "longitude")
            newObject.setPrimitiveValue(0, forKey: "id")
            context.save(nil)
            println("New Destination saved.")
        }

        picker.dismissViewControllerAnimated(true, completion: nil) //Leave camera
    }

    


}
