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

1. Log into the [Cognito console] (https://console.aws.amazon.com/cognito).
2. Create a new Identity Pool named `DigitsSample` and set the Twitter (Digits) API credentials. You can find the Consumer Key and Consumer Secret by opening the `Info.plist` file in the project and drilling down the `Fabric` item. 
<img src="/screenshots/cognito.png" width="600">
<img src="/screenshots/plist.png" width="600">
3. Allow AWS to create IAM roles for the new identity.
4. Set the pool id as the value of `CognitoIdentityPoolId` in `Constants.swift`. 

### Setup DynamoDB

1. Log into the [DynamoDB console] (https://console.aws.amazon.com/dynamodb).
2. Create a new table `Users`.
3. Add a Primary Key hash named `CognitoId` (Type String).
4. Add a Global Secondary Index named `DigitsId` (Type String).
5. Add a Global Secondary Index named `PhoneNumber` (Type String).
6. After the table has been created, copy its Amazon Resource Name (ARN) somewhere. 
<img src="/screenshots/arn.png" width="600">

### Setup AWS Identity and Access Management

1. Log into the [IAM console] (https://console.aws.amazon.com/iam).
2. In the "Roles" tab, select `Cognito_DigitsSampleAuth_Role` and change its only policy to the following:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "YOUR_TABLE'S_ARN",
                "YOUR_TABLES'S_ARN/index/DigitsId-index"
            ]
        }
    ]
}
``` 

Note that that you need to put your table's ARN in the policy. 

## Project

Here's an easy way to see the sample in action:

1. Run the app on the iPhone 5 simulator. 
  * Use your phone number to login and accept the prompt to upload the simulator's contacts to Digits. 
2. Launch the iPhone 6 simulator. 
  * Add yourself as a contact with the number you've used in Step 1. 
3. Run the app on the iPhone 6 simulator.
  * Use another phone number to login and accept the prompt to upload the simulator's contacts to Digits.
  * The app will display confirm that the person from Step 2 is an existing user. 

If you don't have a second phone number, you can use something like Google Voice. 

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
