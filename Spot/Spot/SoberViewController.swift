//
//  SoberViewController.swift
//  Spot
//
//  Created by Florian Anders on 12.12.14.
//  Copyright (c) 2014 K.Wachendorff. All rights reserved.
//

import UIKit
import AddressBookUI

class SoberViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var phoneNumberLabel: UILabel!

    let charSet = NSCharacterSet(charactersInString: "() -")
    
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
//        if (property == kABPersonPhoneProperty) {
//            let multiPhones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue()
//            for i in 0..<ABMultiValueGetCount(multiPhones) {
//                if identifier == ABMultiValueGetIdentifierAtIndex(multiPhones, i) {
//                    let phoneNumberRef: AnyObject = ABMultiValueCopyValueAtIndex(multiPhones, i).takeUnretainedValue()
//                    if let phoneNumber = phoneNumberRef as? String {
//                        println(phoneNumber)
//                    }
//                }
//            }
//        }
        phoneNumberLabel.text = getPhoneNumberOfSelectedPerson(person, identifier: identifier)
        //println(getPhoneNumberOfSelectedPerson(person, identifier: identifier))
        cleanPhoneNumber(getPhoneNumberOfSelectedPerson(person, identifier: identifier) as String)
    }
    
    func getPhoneNumberOfSelectedPerson(person: ABRecord, identifier: ABMultiValueIdentifier) -> String {
        let phones: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue()
        let index = ABMultiValueGetIndexForIdentifier(phones, identifier)
        if let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeUnretainedValue() as? String {
            return phoneNumber
        }
        return ""
    }
    
    func cleanPhoneNumber(var phoneNumber: String){
       (phoneNumber.componentsSeparatedByCharactersInSet(charSet) as NSArray).componentsJoinedByString("")
        phoneNumber = "tel://" + phoneNumber
        println(phoneNumber)
    }

}
