//
//  AppDelegate.swift
//  DigitsFYF
//
//  Created by Valentin Polouchkine  on 8/22/15.
//  Copyright (c) 2015 Fabric. All rights reserved.
//

import UIKit
import Fabric
import DigitsKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Digits.self()])
        return true
    }
}