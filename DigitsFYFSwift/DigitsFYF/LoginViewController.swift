//
//  ViewController.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/22/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import UIKit
import DigitsKit

class LoginViewController: UIViewController {
    let cognito : AWSCognitoCredentialsProvider
    let dynamo : AWSDynamoDBObjectMapper
    
    required init(coder aDecoder: NSCoder) {
        cognito = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: Constants.CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: cognito)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        dynamo = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticateButton = DGTAuthenticateButton(authenticationCompletion: {
            (session: DGTSession!, error: NSError!) in
            
            if (session != nil) {
                self.saveToCognito({ (success) -> Void in
                    if (success) {
                        self.saveToDynamoDB({ (success) -> Void in
                            if (success) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    let contactsVC = self.storyboard!.instantiateViewControllerWithIdentifier("contacts") as! ContactsViewController
                                    self.navigationController!.pushViewController(contactsVC, animated: true)
                                }
                            }
                        })
                    }
                })
            }
            
            if (error != nil) {
                print(error.localizedDescription)
            }
        })
        
        authenticateButton.center = self.view.center
        self.view.addSubview(authenticateButton)
    }
    
    func saveToCognito(completion: (success: Bool) -> Void) {
        let digitsSession = Digits.sharedInstance().session()
        
        self.cognito.logins = [ "www.digits.com" : digitsSession.authToken + ";" + digitsSession.authTokenSecret ]
        
        self.cognito.refresh().continueWithBlock { (task) -> AnyObject! in
            if (task.result != nil) {
                print("You have been successfully stored in Cognito")
                completion(success: true)
            }
            
            if (task.error != nil) {
                print(task.error.localizedDescription)
                completion(success: false)
            }
            
            if (task.exception != nil) {
                print(task.exception.description)
                completion(success: false)
            }
            
            return nil
        }
    }
    
    func saveToDynamoDB(completion: (success: Bool) -> Void) {
        let digitsSession = Digits.sharedInstance().session()
        
        let user = User()
        
        user.cognitoId = self.cognito.identityId
        user.digitsId = digitsSession.userID
        user.phoneNumber = digitsSession.phoneNumber
            
        self.dynamo.save(user).continueWithBlock({ (task) -> AnyObject! in
            if (task.result != nil) {
                print("You have been successfully stored in DynamoDB")
                completion(success: true)
            }
                
            if (task.error != nil) {
                print(task.error.localizedDescription)
                completion(success: false)
            }
            
            if (task.exception != nil) {
                print(task.exception.description)
                completion(success: false)
            }
            
            return nil
        })
    }
}