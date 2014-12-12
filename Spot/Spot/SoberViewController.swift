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
        println(identifier)
    }


    

}
