//
//  ViewController.swift
//  CameraClone2
//
//  Created by Kw on 23/11/14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CoreData
import CoreLocation

class KRWCameraController: UIViewController, CLLocationManagerDelegate {

    //@IBOutlet weak var btnSnapPicture: KRWCameraButton!
    
    var btnSnapPicture:KRWCameraButton = KRWCameraButton()
    
//    var sepGesture:UIPanGestureRecognizer?
    
    var session:AVCaptureSession?
    var device:AVCaptureDevice?
    var input:AVCaptureDeviceInput?
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    var stillImageOutput:AVCaptureStillImageOutput?
    
    var assLib:ALAssetsLibrary?
    
    var cameraView:UIView = UIView()
    
    var index:Int = 0
    
    
    let locationManager = CLLocationManager()
    var locationStatus : NSString = "Not Started"
    
    var currentCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnTap = true
        
        self.view.backgroundColor = UIColor.blackColor()
        self.assLib = ALAssetsLibrary()
        self.btnSnapPicture.bounds = CGRectMake(0, 0, 75, 75)
        self.btnSnapPicture.center = CGPointMake(self.view.center.x, self.view.frame.height - 40)
        self.btnSnapPicture.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnSnapPicture.addTarget(self, action: "updateButtonStyleDown:", forControlEvents: UIControlEvents.TouchDown)
        self.cameraView.userInteractionEnabled = true
        self.cameraView.bounds = self.view.bounds
        self.cameraView.center = self.view.center
        self.view.addSubview(self.cameraView)
        //self.view.bringSubviewToFront(cV)
        self.session = AVCaptureSession()
        self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSErrorPointer = nil
        self.input = AVCaptureDeviceInput.deviceInputWithDevice(self.device, error: error) as? AVCaptureDeviceInput
        self.stillImageOutput = AVCaptureStillImageOutput()
//        self.sepGesture  = UIPanGestureRecognizer(target: self, action: "recognizedGesture:")
//        if var sepGest = self.sepGesture {
//            self.view.addGestureRecognizer(sepGest)
//            println("setup recog")
//        }
        if (self.input != nil) {
            self.session?.addInput(self.input)
            self.session?.addOutput(stillImageOutput)
            self.previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(self.session) as? AVCaptureVideoPreviewLayer
            self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer?.bounds = self.cameraView.bounds
            self.previewLayer?.position = CGPointMake(CGRectGetMidX(self.cameraView.bounds), CGRectGetMidY(self.cameraView.bounds))
            self.cameraView.layer.addSublayer(self.previewLayer)
            self.cameraView.addSubview(self.btnSnapPicture)
        } else {
            println("Error: " + error.debugDescription)
        }
        if let session = self.session {
            session.startRunning()
        }
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
    
    override func viewDidAppear(animated: Bool) {
        if let session = self.session {
            if session.running == false {
                session.startRunning()
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let session = self.session {
            session.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func updateButtonStyleDown(sender: KRWCameraButton) {
        sender.setNeedsDisplay()
        
    }
    
    func takePhoto(sender: KRWCameraButton) {
        sender.setNeedsDisplay()
        if let stillOutput = self.stillImageOutput {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var videoConnection : AVCaptureConnection?
                for connecton in stillOutput.connections {
                    for port in connecton.inputPorts!{
                        if port.mediaType == AVMediaTypeVideo {
                            videoConnection = connecton as? AVCaptureConnection
                            break
                        }
                    }
                    
                    if videoConnection != nil {
                        break
                    }
                }
                if videoConnection != nil {
                    stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection){
                        (imageSampleBuffer : CMSampleBuffer!, _) in
                        
                        let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        var pickedImage: UIImage = UIImage(data: imageDataJpeg)!
                        
                        let imageData = UIImagePNGRepresentation(pickedImage)
                        UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
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
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    func getImageAtIndex(index: Int, img: UIImage) {
        var url:NSURL = NSURL()
        var img:UIImage?
        self.assLib?.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock:  {
            (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                group.enumerateAssetsAtIndexes(NSIndexSet(index: group!.numberOfAssets()-index), options: nil, usingBlock: {
                    (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if (result != nil) {
                        var assRep: ALAssetRepresentation = result.defaultRepresentation()
                        url = assRep.url()
                    }
                })
            }else if group == nil {
                
                self.assLib?.assetForURL(url, resultBlock: {
                    (asset: ALAsset!) in
                    if asset != nil {
                        var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                        var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                        if var image = UIImage(CGImage: iref) {
                            img = image
                        }
                    }
                    }, failureBlock: {
                        (error: NSError!) in
                })
            }
            }, failureBlock: {
                (error: NSError!) in
        })
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
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

