//
//  AppDelegate.swift
//  StepCountApp
//
//  Created by MAC105 on 24/08/21.
//

import UIKit
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        LocationService.sharedInstance.locationManager.startUpdatingLocation()
        return true
    }
}

