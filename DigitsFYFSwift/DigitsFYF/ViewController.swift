//
//  ViewController.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/22/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import UIKit
import DigitsKit

class ViewController: UIViewController {
    // These don't have to be optional since you initialize them all in init
    let credentialProvider : AWSCognitoCredentialsProvider?
    let configuration : AWSServiceConfiguration?
    let dbMapper : AWSDynamoDBObjectMapper?
    
    required init(coder aDecoder: NSCoder) {
        // Setup AWS Cognito and DynamoDB
        credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: CognitoIdentityPoolId)
        configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        dbMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticateButton = DGTAuthenticateButton(authenticationCompletion: {
            (session: DGTSession!, error: NSError!) in
            
            if (session != nil) {
                self.saveToCognito()
                self.saveToDynamoDB()
            }
            
            if (error != nil) {
                print(error.localizedDescription)
            }
        })
        
        authenticateButton.center = self.view.center
        self.view.addSubview(authenticateButton)
    }
    
    func saveToCognito() {
        let digitsSession = Digits.sharedInstance().session()
        
        self.credentialProvider!.logins = [ "www.digits.com" : digitsSession.authToken + ";" + digitsSession.authTokenSecret ]
    }
    
    func saveToDynamoDB() {
        let digitsSession = Digits.sharedInstance().session()
        
        // If `saveToDynamoDB` is dependent on `saveToCognito` continuing, consider having save to cognito take a completion block and having it refresh and call that completion block itself.
        self.credentialProvider!.refresh().continueWithBlock { (task) -> AnyObject! in
            let user = User()
            // Perhaps add an init method to User that takes all these instead of setting them like this?
            user.CognitoId = self.credentialProvider!.identityId
            user.DigitsId = digitsSession.userID
            user.PhoneNumber = digitsSession.phoneNumber
            
            self.dbMapper!.save(user).continueWithBlock({ (task) -> AnyObject! in
                if (task.result != nil) {
                    print("You have been successfully stored in DynamoDB")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let contactsVC = self.storyboard!.instantiateViewControllerWithIdentifier("contacts") as! ContactsViewController
                        self.navigationController!.pushViewController(contactsVC, animated: true)
                    }
                }
                
                if (task.error != nil) {
                    print(task.error)
                }
                
                if (task.exception != nil) {
                    print(task.exception)
                }
                
                return nil
            })
            
            return nil
        }
    }
}