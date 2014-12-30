//
//  SoberViewController.swift
//  Spot
//
//  Created by Florian Anders on 12.12.14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit
import AddressBookUI
import CoreData

class SoberViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate {
    
    lazy var charSet = NSCharacterSet(charactersInString: "()- ")
    
    var phoneNumber = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func setEmergencyContact(sender: UIButton) {
        let abController = ABPeoplePickerNavigationController()
        abController.peoplePickerDelegate = self
        abController.displayedProperties = [NSNumber(int: kABPersonPhoneProperty)]
        self.presentViewController(abController, animated: true, completion: nil)
    }

    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier){
        
        phoneNumber = cleanPhoneNumber(getPhoneNumberOfSelectedPerson(person, identifier: identifier) as String)
    }
    
    @IBAction func callPhoneNumber(sender: UIButton) {
        println(phoneNumber)
        if let url = NSURL(string:phoneNumber){
            if UIApplication.sharedApplication().canOpenURL(url){
                println(url)
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func getPhoneNumberOfSelectedPerson(person: ABRecord, identifier: ABMultiValueIdentifier) -> String {
        let phones: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue()
        let index = ABMultiValueGetIndexForIdentifier(phones, identifier)
        if let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeUnretainedValue() as? String {
            return phoneNumber
        }
        return ""
    }
    
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
        println(err.debugDescription)
        return phoneNumber
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

}
