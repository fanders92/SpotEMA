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

class KRWCameraController: UIViewController {

    //@IBOutlet weak var btnSnapPicture: KRWCameraButton!
    
    var btnSnapPicture:KRWCameraButton = KRWCameraButton()
    var dismissButton:UIButton = UIButton()
    
//    var sepGesture:UIPanGestureRecognizer?
    
    var session:AVCaptureSession?
    var device:AVCaptureDevice?
    var input:AVCaptureDeviceInput?
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    var stillImageOutput:AVCaptureStillImageOutput?
    
    var assLib:ALAssetsLibrary?
    
    var cameraView:UIView = UIView()
    
    var index:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.assLib = ALAssetsLibrary()
        self.btnSnapPicture.bounds = CGRectMake(0, 0, 75, 75)
        self.btnSnapPicture.center = CGPointMake(self.view.center.x, self.view.frame.height - 40)
        self.btnSnapPicture.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnSnapPicture.addTarget(self, action: "updateButtonStyleDown:", forControlEvents: UIControlEvents.TouchDown)
        self.dismissButton.setTitle("Done", forState: .Normal)
        self.dismissButton.bounds = CGRectMake(0,0,50,30)
        self.dismissButton.center = CGPointMake(30, 30)
        self.dismissButton.addTarget(self, action: "btnDoneClicked:", forControlEvents: .TouchUpInside)
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
            self.cameraView.addSubview(self.dismissButton)
        } else {
            println("Error: " + error.debugDescription)
        }
        if let session = self.session {
            session.startRunning()
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
    
    func btnDoneClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }


}

