//
//  User.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/24/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import Foundation

class User : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var cognitoId : String?
    var digitsId : String?
    var phoneNumber : String?
    
    static func dynamoDBTableName() -> String {
        return "users"
    }
    
    static func hashKeyAttribute() -> String {
        return "cognitoId"
    }
    
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
}