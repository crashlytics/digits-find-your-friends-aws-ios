//
//  ContactsViewController.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/22/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import UIKit
import DigitsKit
import Contacts

class ContactsViewController: UIViewController {
    @IBOutlet weak var lblFriendName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let digitsSession = Digits.sharedInstance().session()
        let contacts = DGTContacts(userSession: digitsSession)
        
        contacts.startContactsUploadWithCompletion { result, error in
            if (result != nil) {
                print("Your " + String(result.numberOfUploadedContacts) + " contacts have been successfully stored in Digits")
                
                contacts.lookupContactMatchesWithCursor(nil) { matches, nextCursor, error in
                    if (matches != nil) {
                        if (matches.count > 0) {
                            // Grabbing a single match for demo purposes
                            let match = matches[0] as! DGTUser
                            self.queryDynamoDB(match.userID)
                        }
                        else
                        {
                            print("No friends found")
                            dispatch_async(dispatch_get_main_queue()) {
                                self.lblFriendName.text = "Looks like you're the first among your friends to use this app."
                            }
                        }
                    }
                }
            }
            
            if (error != nil) {
                print(error.description)
            }
        }
    }
    
    func queryDynamoDB(digitsId : String) {
        let dynamo = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.hashKeyValues = digitsId
        queryExpression.hashKeyAttribute = "digitsId"
        queryExpression.indexName = "digitsId-index"
        
        dynamo.query(User.self, expression: queryExpression).continueWithBlock { (task) -> AnyObject! in
            if (task.result != nil)
            {
                let users = task.result.items as! [User]
                
                if (users.count > 0) {
                    let user = users[0]
                    
                    if let phoneNumber = user.phoneNumber {
                        let localContactName = self.getLocalContactName(phoneNumber)
                        
                        print("Friend's phone number: " + phoneNumber)
                        print("Friend's name: " + localContactName)
                        
                        if (localContactName != "") {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.lblFriendName.text = localContactName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + " is already using this app!"
                            }
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.lblFriendName.text = "Looks like someone you know is using this app."
                            }
                        }
                        
                    }
                }
            }
            
            if (task.error != nil) {
                print(task.error)
            }
            
            if (task.exception != nil) {
                print(task.exception)
            }
            
            return nil
        }
        
    }
    
    // Find a local contact's name by phone number
    func getLocalContactName(phoneNumber: String) -> String {
        var name = ""
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
        
        do {
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                for labeledLocalPhoneNumber in contact.phoneNumbers {
                    let localPhoneNumber = labeledLocalPhoneNumber.value as! CNPhoneNumber
                    
                    // The first character is a space, while the last is a non-breaking space (⌥ + Space)
                    if (phoneNumber.rangeOfString(localPhoneNumber.stringValue.stringByRemovingOccurrencesOfCharacters(" )(- ")) != nil) {
                        name = contact.givenName + " " + contact.familyName
                    }
                }
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return name
    }
}