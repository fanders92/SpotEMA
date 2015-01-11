//
//  SoberViewController.swift
//  Spot
//
//  Created by Florian Anders on 12.12.14.
//  Copyright (c) 2015 K.Wachendorff & F.Anders. All rights reserved.
//

import UIKit
import AddressBookUI
import CoreData
import MobileCoreServices

class SpotViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var charSet = NSCharacterSet(charactersInString: "()- ")
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hidesBarsOnTap = false
        self.backgroundImage.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)   //Hintergrundfarbe festlegen
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hidesBarsOnTap = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setHomeAdress(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Choose", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraOption = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("camera", sender: self)
        }
        let addressOption = UIAlertAction(title: "Manual", style: UIAlertActionStyle.Default) { (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("manual", sender: self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, nil)
        optionMenu.addAction(cameraOption)
        optionMenu.addAction(addressOption)
        optionMenu.addAction(cancel)
        self.presentViewController(optionMenu, animated: true) { () -> Void in
            println("OptionMenu")
        }
        
    }

    //Funktion zum Anzeigen der Kontakte
    @IBAction func setEmergencyContact(sender: KRWContactButton) {
        let abController = ABPeoplePickerNavigationController()
        abController.peoplePickerDelegate = self
        abController.displayedProperties = [NSNumber(int: kABPersonPhoneProperty)]
        self.presentViewController(abController, animated: true, completion: nil)
    }

    //Wird ausgeführt wenn Nutzer Telefonnummer ausgewählt hat
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier){
         let phoneNumber = cleanPhoneNumber(getPhoneNumberOfSelectedPerson(person, identifier: identifier))
    }
    
    //Feststellen der Telefonnummer
    func getPhoneNumberOfSelectedPerson(person: ABRecord, identifier: ABMultiValueIdentifier) -> String {
        let phones: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue()
        let index = ABMultiValueGetIndexForIdentifier(phones, identifier)
        if let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeUnretainedValue() as? String {
            return phoneNumber
        }
        return ""
    }
    
    //Telefonnummer säubern und persistent Speichern
    func cleanPhoneNumber(var phoneNumber: String) -> String{
       (phoneNumber.componentsSeparatedByCharactersInSet(charSet) as NSArray).componentsJoinedByString("")
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("+", withString: "00")
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        phoneNumber = "tel://" + phoneNumber
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Number")
        request.returnsObjectsAsFaults = false
        var err = NSErrorPointer()
        
        var results:NSArray = context.executeFetchRequest(request, error: err)!
        if results.count > 0 {
            let loadObject:NSManagedObject = results[0] as NSManagedObject
            loadObject.setValue(phoneNumber as String, forKey: "number")
            println("Number saved.")
            context.save(nil)
        } else if results.count == 0 {
            var newObject:NSManagedObject  = NSEntityDescription.insertNewObjectForEntityForName("Number", inManagedObjectContext: context) as NSManagedObject
            newObject.setValue(phoneNumber as String, forKey: "number")
            newObject.setPrimitiveValue(0, forKey: "id")
            context.save(nil)
            println("New Number saved.")
        }
        return phoneNumber
    }
    
    @IBAction func updateButtonStyleDown(sender: UIButton) {
        sender.setNeedsDisplay()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
