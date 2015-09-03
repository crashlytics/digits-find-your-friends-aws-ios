# Find Your Friends using Digits and AWS (Cognito, DynamoDB)

This is a sample demonstrating [Digits](http://digits.com) "Find Your Friends" [feature] (https://docs.fabric.io/ios/digits/find-friends.html) with AWS Cognito and AWS DynamoDB as the backend. Digits is available via [Fabric] (https://fabric.io).

## Requirements

The requirements needed to use this sample code are:

1. [Xcode 7] (https://developer.apple.com/xcode/downloads/)
2. [Fabric] (https://fabric.io)
3. [Amazon Web Services] (http://aws.amazon.com/) 

## Steps to run sample code

Ensure that all AWS instances are located in US-East, so that they can make full use of Cognito and can connect to one another.

### Setup Digits

1. Sign up for [Fabric](https://fabric.io)
2. Download, install, and run the [Fabric Mac app] (https://fabric.io/downloads/xcode)
3. In Fabric.app, click "+ New App" and open DigitsFYF.xcworkspace
  * Install the Digits kit via a Podfile. When prompted, ignore the suggested pod snippets
4. In Xcode, open DigitsFYF.xcworkspace
  * Add the Run Script Build Phase from Fabric.app to the DigitsFYF target
  * Build the project
5. In Fabric.app, when prompted, ignore the suggested Swift snippets
6. In Xcode, run the project.  

The app should now appear in your Fabric dashboard.

### Setup AWS Cognito

1. Log into the Amazon Cognito console (https://console.aws.amazon.com/cognito)
2. Click on "Create new Identity pool"
3. Specify a name for the pool and your Twitter/Digits Consumer Key and Consumer Secret. You can find
them by opening the `Info.plist` file in the project and drilling down the Fabric item. 
4. Click "Allow" button when asked to create new AWS IAM roles for the Cognito identity.
5. Copy the pool id into `Constants.swift` as the value of the `CognitoIdentityPoolId` constant. 

### Setup AWS DynamoDB

1. Log into the Amazon DynamoDB console (https://console.aws.amazon.com/dynamodb)
2. Create a table
3. Copy the table name into `Constants.swift` as the value of the `AWSSampleDynamoDBTableName` constant.
4. Add the Primary Key Type as "Hash" with Hash Name as "CognitoId" and String type
5. Add a Global Secondary Index with Index Hash Name set to "DigitsId" and String type
6. Add a Global Secondary Index with Index Hash Name set to "PhoneNumber" and String type
7. After the table has been created, click "Details" and copy the Amazon Resource Name (ARN).

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