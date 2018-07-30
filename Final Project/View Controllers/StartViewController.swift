//
//  StartViewController.swift
//  Final Project
//
//  Created by Tony Buckner on 7/9/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class StartViewController: UIViewController {
    
    //object variables
    @IBOutlet weak var textOne: UILabel!
    @IBOutlet weak var textTwo: UITextView!
    @IBOutlet weak var goButton: UIButton!
    
    //location variable
    let locationManager = CLLocationManager()
    
    //data controller code and fetch requests
    var dataController:DataController!
    
    //fetched results variable and function
    var fetchedResultsController:NSFetchedResultsController<MetaData>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<MetaData> = MetaData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //fetchedResultsController.delegate = self
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    //------------------------------------------------
    
    //code for activity indicator
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.blue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        setupFetchedResultsController()
        
    }
    
    fileprivate func reEnableView() {
        //Add code here:
        
        self.goButton.isEnabled = true
        
        //fade back in
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.textOne.alpha = 1
            self.textTwo.alpha = 1
            self.goButton.alpha = 1
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reEnableView()
        
        setupFetchedResultsController()
        
    }
    
    @IBAction func startApp(_ sender: Any) {
        
        //grab user location and save to singeton to be passed to next view
        print(locationManager.location?.coordinate as Any)
        let realLocation = locationManager.location?.coordinate
        SavedRealLocation.sharedInstance.location.latitude = (realLocation?.latitude)!
        SavedRealLocation.sharedInstance.location.longitude = (realLocation?.longitude)!
        
        //disable "GO!" button
        self.goButton.isEnabled = false
        
        //fade out background while loading
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.textOne.alpha = 0.1
            self.textTwo.alpha = 0.1
            self.goButton.alpha = 0.1
        }, completion: nil)
        
        activityIndicator.startAnimating()
        
        ZomatoAPIFunctions.init().getListWithMethodParameters(lat: (realLocation?.latitude)!, lon: (realLocation?.longitude)!) { (good, errorCode) in
            
            performUIUpdatesOnMain {
                if good{
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "StartApp", sender: nil)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.alerts(type: errorCode)
                    //self.performSegue(withIdentifier: "StartApp", sender: nil)
                    self.reEnableView()
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    //send info over to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        MetaDataSingleton.sharedInstance.metaData = fetchedResultsController.fetchedObjects!
        
        if let mvc = segue.destination as? MainViewController {
            
            mvc.metaData = fetchedResultsController.fetchedObjects
            mvc.dataController = dataController
            
        }
        
        //go to favorites VC
        if let fvc = segue.destination as? FavoritesViewController {
            
            fvc.metaData = fetchedResultsController.fetchedObjects
            fvc.dataController = dataController
            
        }
    }
    
}
