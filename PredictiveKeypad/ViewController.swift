//
//  ViewController.swift
//  PredictiveKeypad
//
//  Created by Satish Kumar R Kancherla on 2/25/16.
//  Copyright © 2016 Satish Kumar R Kancherla. All rights reserved.
//

import UIKit
import AddressBook
import Contacts

class ViewController: UIViewController {
    
    lazy var contactStore:CNContactStore = CNContactStore()
    var accessGranted = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
    
        self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
            self.accessGranted = access
            if !access {
                if authorizationStatus == CNAuthorizationStatus.Denied {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        self.showMessage(message)
                    })
                }
            }

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Birthdays", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }


    @IBAction func onEnteringNumber(sender: UITextField) {
            if accessGranted {
                let predicate = CNContact.predicateForContactsMatchingName(sender.text!)
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey]
                var contacts = [CNContact]()
                var message: String!
                do {
                    contacts = try self.contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
                    
                    if contacts.count == 0 {
                        message = "No contacts were found matching the given name."
                    }
                }
                catch {
                    message = "Unable to fetch contacts."
                }
                
                
                if message != nil {
                    self.showMessage(message)
                }
                else {
                    
                }
            }
        
        
    }
}

