//
//  Alerts.swift
//  On The Map
//
//  Created by Tony Buckner on 4/19/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    //alerts function
    func alerts(type: String){
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if type == "net" {
            alert.title = "CONNECTION FAILURE"
            alert.message = "No Internet connection. Make sure your device is connected to a network and try again."
        } else if type == "log" {
            alert.title = "LOGIN FAILURE"
            alert.message = "Please enter a valid email and password and try again."
        } else if type == "nil" {
            alert.title = "DATA FAILURE"
            alert.message = "The login attempt returned no data. Please call Customer Support."
        } else if type == "info" {
            alert.title = "INFO FAILURE"
            alert.message = "The requested iformation was not able to be retrieved. Please call Customer Support."
        } else if type == "con" {
            alert.title = "CONNECTION FAILURE"
            alert.message = "The application had difficulty connecting to the server. Please call Customer Support."
        } else if type == "geo" {
            alert.title = "LOCATION FAILURE"
            alert.message = "The application had difficulty finding your location."
        } else {
            alert.title = "ERROR"
            alert.message = "Error..."
        }
        
        //error popup
        present(alert, animated: true)
        
    }
    
    //alert when incomplete info tried to be submitted
    func submitInfoAlert(){
        let alert = UIAlertController(title: "INCOMPLETE DATA", message: "Please enter all fields before attempting to submit.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
