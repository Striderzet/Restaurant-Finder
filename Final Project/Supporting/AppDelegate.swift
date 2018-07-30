//
//  AppDelegate.swift
//  Final Project
//
//  Created by Tony Buckner on 7/4/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //this is how the data model gets connected to the project
    let dataController = DataController(modelName: "FinalProject")
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //navigation controller variable to communicate for data store
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mainViewController = navigationController.topViewController as! StartViewController
        mainViewController.dataController = dataController
        
        return true
    }

}

