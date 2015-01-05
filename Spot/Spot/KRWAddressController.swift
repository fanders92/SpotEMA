//
//  KRWAddressControllerTableViewController.swift
//  Spot
//
//  Created by Kw on 02/01/15.
//  Copyright (c) 2015 K.Wachendorff. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import AddressBookUI

class KRWAddressController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    var searchController: UISearchController?
    var searchResultsController: UITableViewController?
    
    var searchObject:MKLocalSearch?
    
    let identifier = "Cell"
    
    let locationManager = CLLocationManager()
    var locationStatus : NSString = "Not Started"
    
    var currentCoordinates: CLLocationCoordinate2D?
    
    // Filtered results are stored here.
    var results: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // A table for search results and its controller.
        let resultsTableView = UITableView(frame: self.tableView.frame)
        self.searchResultsController = UITableViewController()
        self.searchResultsController?.tableView = resultsTableView
        self.searchResultsController?.tableView.dataSource = self
        self.searchResultsController?.tableView.delegate = self
        
        // Register cell class for the identifier.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.identifier)
        self.searchResultsController?.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.identifier)
        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController!)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit() // bar size
        self.tableView.tableHeaderView = self.searchController?.searchBar
        
        self.definesPresentationContext = true
        
        
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchResultsController?.tableView {
            if let results = self.results {
                return results.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifier) as UITableViewCell
        let mapItem: MKMapItem = self.results!.objectAtIndex(indexPath.row) as MKMapItem
        var text: String = ""
        var name: String = ""
        if tableView == self.searchResultsController?.tableView {
            if let results = self.results {
                text = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, false)
            }
        }
        
        //cell.txtStreet.text = text
        //cell.txtName.text = name
        cell.textLabel?.text = text
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.searchResultsController?.tableView {
            // Remove search bar & hide it.
            self.searchController?.active = false
            self.hideSearchBar()
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            
            var request = NSFetchRequest(entityName: "Destination")
            request.returnsObjectsAsFaults = false
            var err = NSErrorPointer()
            
            let destination = ((self.results!.objectAtIndex(indexPath.row))as MKMapItem).placemark.location.coordinate
            
            var results:NSArray = context.executeFetchRequest(request, error: err)!
            if results.count > 0 {
                let loadObject:NSManagedObject = results[0] as NSManagedObject
                loadObject.setValue(destination.latitude, forKey: "latitude")
                loadObject.setValue(destination.longitude, forKey: "longitude")
                println("Destination saved.")
                context.save(nil)
            } else if results.count == 0 {
                var newObject:NSManagedObject  = NSEntityDescription.insertNewObjectForEntityForName("Destination", inManagedObjectContext: context) as NSManagedObject
                newObject.setValue(destination.latitude, forKey: "latitude")
                newObject.setValue(destination.longitude, forKey: "longitude")
                newObject.setPrimitiveValue(0, forKey: "id")
                context.save(nil)
                println("New Destination saved.")
            }
        }
    }
    
    func hideSearchBar() {
        let yOffset = self.navigationController!.navigationBar.bounds.height + UIApplication.sharedApplication().statusBarFrame.height
        self.tableView.contentOffset = CGPointMake(0, self.searchController!.searchBar.bounds.height - yOffset)
    }
    
    // UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if self.searchController?.searchBar.text.lengthOfBytesUsingEncoding(NSUTF32StringEncoding) > 0 {
            if self.searchObject?.searching != nil {
                self.searchObject?.cancel()
            }
            let searchRequest = MKLocalSearchRequest()
            if let userLocation = self.currentCoordinates {
                var region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.112872, longitudeDelta: 0.109863))
                searchRequest.region = region
            }
            
            let searchBarText = self.searchController!.searchBar.text
            searchRequest.naturalLanguageQuery = searchBarText
            
            let searchCompletionHandler:MKLocalSearchCompletionHandler = {(response: MKLocalSearchResponse!, error: NSError!) -> Void in
                if error != nil {
                    let alert = UIAlertController(title: "Error!", message: "Could not find places.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    self.results = response.mapItems
//                    response.boundingRegion
                    // Reload a table with results.
                    self.searchResultsController?.tableView.reloadData()
                }
            }
            
            if self.searchObject != nil {
                self.searchObject = nil
            }
            
            self.searchObject = MKLocalSearch(request: searchRequest)
            searchObject?.startWithCompletionHandler(searchCompletionHandler)
        }
    }
    
    //UISearchController
    
    func didDismissSearchController(searchController: UISearchController) {
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.hideSearchBar()
            }, completion: { value in
                if value {
                    self.navigationController?.popViewControllerAnimated(true)
                }
        })
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

}
