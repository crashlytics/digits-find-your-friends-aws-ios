# Find Your Friends using Digits and AWS

This is a sample demonstrating [Digits](http://digits.com) "Find Your Friends" [feature] (https://docs.fabric.io/ios/digits/find-friends.html) with AWS Cognito and AWS DynamoDB as the backend. Digits is available via [Fabric] (https://fabric.io).

## Requirements

1. [Xcode 7] (https://developer.apple.com/xcode/downloads/)
2. [Fabric] (https://fabric.io)
3. [Amazon Web Services] (http://aws.amazon.com/) 

Ensure that all AWS instances are located in US-East, so that they can make full use of Cognito and can connect to one another.

### Setup Digits

1. Sign up for [Fabric](https://fabric.io).
2. Download, install, and run the [Fabric Mac app] (https://fabric.io/downloads/xcode).
3. In Fabric.app, click "+ New App" and open `DigitsFYF.xcworkspace`.
  * Install the Digits kit via a Podfile. When prompted, ignore the suggested pod snippets.
4. In Xcode, open `DigitsFYF.xcworkspace`.
  * Add the Run Script Build Phase from Fabric.app to the DigitsFYF target.
  * Build the project.
5. In Fabric.app, when prompted, ignore the suggested Swift snippets.
6. In Xcode, run the project.  

### Setup Cognito

1. Log into the [Cognito console] (https://console.aws.amazon.com/cognito)
2. Create a new Identity Pool and set the Twitter (Digits) API credentials. You can find the Consumer Key and Consumer Secret by opening the `Info.plist` file in the project and drilling down the `Fabric` item. 

<img src="/screenshots/cognito.png" width="600">

<img src="/screenshots/plist.png" width="600">

3. Allow AWS to create IAM roles for the new identity.
4. Set the pool id as the value of `CognitoIdentityPoolId` in `Constants.swift`. 

### Setup DynamoDB

1. Log into the [DynamoDB console] (https://console.aws.amazon.com/dynamodb)
2. Create a new table `Users`.
3. Add a Primary Key Type hash named `CognitoId` (String).
4. Add a Global Secondary Index named `DigitsId` (String).
5. Add a Global Secondary Index named `PhoneNumber` (String).
6. After the table has been created, copy its Amazon Resource Name (ARN) in the "Details" tab.

<img src="/screenshots/arn.png" width="600">

### Setup AWS Identity and Access Management

1. Log into the Amazon IAM console (https://console.aws.amazon.com/iam/)
2. Click "Roles" and select `Cognito_FOOAuth_Role`, where FOO is the name of Identity Pool you created earlier.
3. There should be a single Inline Policy, click "Edit Policy"
4. Replace the policy by one that allows access to the DynamoDB table you've created earlier:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "YOUR_TABLE_ARN",
                "YOUR_TABLE_ARN/DigitsId-index"
            ]
        }
    ]
}
``` 

## Project

The sample demonstrates the following flow:

1. User A logins into the app using phone number X.
2. User B has User A and phone number X in the his/her's Contacts. 
3. User B logins into the app using phone number Y.
4. User B is alerted that User A is already using the app. The app 
displays User A's name as set by User B in his/her's Contacts. 


## Additional reading

The following documents serve as additional information on the Amazon platform and Fabric Digits.

- [Amazon Cognito](http://aws.amazon.com/cognito/)
- [Announcing Twitter and Digits Support for Amazon Cognito](http://mobile.awsblog.com/post/Tx398OODXZXXAMZ/Announcing-Twitter-and-Digits-Support-for-Amazon-Cognito)
- [Fabric Digits](http://get.digits.com/)

## Compatibility

This project was written in Swift 2 on Xcode 7b6.

## License

Copyright 2015 Twitter, Inc.

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
