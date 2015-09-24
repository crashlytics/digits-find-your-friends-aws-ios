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
    
    // Doesn't have to be optional since it's being init'd in init
    let db : AWSDynamoDB?
    
    required init(coder aDecoder: NSCoder) {
        db = AWSDynamoDB.defaultDynamoDB()
        
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let digitsSession = Digits.sharedInstance().session()
        let contacts = DGTContacts(userSession: digitsSession)
        
        // Lots of indentation here. Maybe split up into separate methods
        contacts.startContactsUploadWithCompletion { result, error in
            if (result != nil) {
                // might want to inspect `numberOfUploadedContacts` for the number that were successfully uploaded. We hope it's all of them, but these two values can sometimes be different (like for really really large address books and rate limits are hit uploading some of the batches since we split them up and upload in batches)
                print("Your " + String(result.totalContacts) + " contacts have been successfully stored in Digits")
            }
            if (error != nil) {
                print(error.localizedDescription)
            }
            
            contacts.lookupContactMatchesWithCursor(nil) { matches, nextCursor, error in
                if (matches != nil) {
                    // Do you want this to happen once for every matched user? Looks like it would issue a lot of separate queries to AWS and each match would override the prior in the label text.
                    for item in matches as! [DGTUser] {
                        print("Friend's DigitsId: " + item.userID)

                        // Need to use the low level client because querying a global secondary index is 
                        // not supported. See https://github.com/aws/aws-sdk-ios/issues/162
                        let queryInput = AWSDynamoDBQueryInput()
                        
                        queryInput.tableName = "Users"
                        queryInput.indexName = "DigitsId-index"
                        
                        let hashValue = AWSDynamoDBAttributeValue()
                        hashValue.S = item.userID

                        queryInput.expressionAttributeValues = [":hashval" : hashValue]
                        queryInput.keyConditionExpression = "DigitsId = :hashval"
                        
                        // Grabbing a single friend
                        queryInput.limit = 1

                        self.db!.query(queryInput).continueWithBlock { (task) -> AnyObject! in
                            if (task.result != nil)
                            {
                                let result = task.result as! AWSDynamoDBQueryOutput
                                
                                if (result.count.integerValue > 0) {
                                    let items = result.items as NSArray
                                    let firstItem = items[0] as! Dictionary<String, AWSDynamoDBAttributeValue>
                                    
                                    let friendPhoneNumber = firstItem["PhoneNumber"]!.S
                                    print("Friend's phone number: " + friendPhoneNumber)
                                    
                                    let friendName = self.getFriendName(friendPhoneNumber)
                                    print("Friend's name: " + friendName)
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        if (friendName != "") {
                                            self.lblFriendName.text = "Looks like your friend " + friendName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + " is already using this app!"
                                        }
                                        else
                                        {
                                            self.lblFriendName.text = "Looks like someone you know is already using this app, but we couldn't find him/her in your contacts."
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
                }
                else
                {
                    self.lblFriendName.text = "Looks like you're the first user among your friends."
                }
            }
        }
    }
    
    func getFriendName(friendPhoneNumber: String) -> String {
        var name = ""
        
        // Nice!
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
        
        do {
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                for labeledLocalPhoneNumber in contact.phoneNumbers {
                    let localPhoneNumber = labeledLocalPhoneNumber.value as! CNPhoneNumber
                    
                    // The first character is a space, while the last is a non-breaking space (⌥ + Space)
                    if (friendPhoneNumber.rangeOfString(localPhoneNumber.stringValue.stringByRemovingOccurrencesOfCharacters(" )(- ")) != nil) {
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