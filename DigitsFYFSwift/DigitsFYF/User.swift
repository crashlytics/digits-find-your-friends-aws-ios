//
//  User.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/24/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import Foundation

class User : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var CognitoId : String? { didSet { print("Your CognitoId: " + CognitoId!) } }
    var DigitsId : String? { didSet { print("Your DigitsId: " + DigitsId!) } }
    var PhoneNumber : String? { didSet { print("Your phone number: " + PhoneNumber!) } }
    
    static func dynamoDBTableName() -> String {
        return AWSSampleDynamoDBTableName
    }
    
    static func hashKeyAttribute() -> String {
        return "CognitoId"
    }
    
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}