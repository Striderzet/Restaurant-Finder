//
//  ViewController.swift
//  Final Project
//
//  Created by Tony Buckner on 7/4/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData
import CoreLocation

class MainViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    //loaded back flag to reload data
    var loadedBack = false
    
    //local cache array
    var seletecedInformationCache = [objectInfo]()
    
    //coodinate variable
    var centerCoordinate = MKPointAnnotation()
    
    //seletced indexpath row
    var row = Int()
    
    //metadata var (all objects)
    var metaData: [MetaData]!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set object delegates
        tableView.delegate = self
        mapView.delegate = self
        
        //drop pin in location user is in
        centerCoordinate.coordinate.latitude = SavedRealLocation.sharedInstance.location.latitude
        centerCoordinate.coordinate.longitude = SavedRealLocation.sharedInstance.location.longitude
        centerCoordinate.title = "YOU ARE HERE"
        centerCoordinate.subtitle = "0.0 km"
        mapView.addAnnotation(centerCoordinate)
        
        //zoom into location
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: SavedRealLocation.sharedInstance.location.latitude, longitude: SavedRealLocation.sharedInstance.location.longitude), span: span)
        mapView.setRegion(region, animated: true)
        
        //this will add the pins from the initial list in the view load phase instead of the row info population phase. This way, the pins will not keep dropping while the user scrolls
        
        
        for objectHold in SelectedObjectInformation.sharedInstance.info {
            
            let restaurantCoordinate = MKPointAnnotation()
            
            let convertedDistance = Double(getDistanceFromLocation(lat1: SavedRealLocation.sharedInstance.location.latitude, long1: SavedRealLocation.sharedInstance.location.longitude, lat2: objectHold.distance.latitude, long2: objectHold.distance.longitude)) / 1000
            
            restaurantCoordinate.subtitle = String(convertedDistance).padding(toLength: 4, withPad: "", startingAt: 0) + " km"
            restaurantCoordinate.coordinate.latitude = objectHold.distance.latitude
            restaurantCoordinate.coordinate.longitude = objectHold.distance.longitude
            restaurantCoordinate.title = objectHold.name
            
            self.mapView.addAnnotation(restaurantCoordinate)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
        loadedBack = true
        //reloadInputViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //Add code:
        
        //delete all Items when going back to main page
        //SelectedObjectInformation.sharedInstance.info.removeAll()
    }
    
    //table view protocol sub classes
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectedObjectInformation.sharedInstance.info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        var tempObject = objectInfo()
        let objectHold = SelectedObjectInformation.sharedInstance.info[indexPath.row]
        
        cell.restaurantImage.image = objectHold.image
        tempObject.image = objectHold.image
        
        cell.restaurantAggregateRating.text = "Rating: " + objectHold.rating
        tempObject.rating = objectHold.rating
        
        let convertedDistance = Double(getDistanceFromLocation(lat1: SavedRealLocation.sharedInstance.location.latitude, long1: SavedRealLocation.sharedInstance.location.longitude, lat2: objectHold.distance.latitude, long2: objectHold.distance.longitude)) / 1000
        
        cell.restaurantDistance.text = String(convertedDistance).padding(toLength: 4, withPad: "", startingAt: 0) + " km"
        
        tempObject.distance.latitude = objectHold.distance.latitude
        tempObject.distance.longitude = objectHold.distance.longitude
        
        cell.restaurantName.text = objectHold.name
        tempObject.name = objectHold.name
        
        tempObject.address = objectHold.address
        
        seletecedInformationCache.append(tempObject)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        PassedObjectInformation.sharedInstance.info = seletecedInformationCache[indexPath.row]
        row = indexPath.row
        performSegue(withIdentifier: "DetailedInfo", sender: nil)
        
    }
    
    @IBAction func testAction(_ sender: Any) {
        //ZomatoAPIFunctions.init().getListWithMethodParameters()
    }
    
    //Distance calculator
    func getDistanceFromLocation(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double{
        
        let coordinate₀ = CLLocation(latitude: lat1, longitude: long1)
        let coordinate₁ = CLLocation(latitude: lat2, longitude: long2)
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        
        return distanceInMeters
    
    }
    
    //Pin Annotation Function
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .purple
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //send info over to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if loadedBack{
            
            //go to object VC
            if let ovc = segue.destination as? ObjectViewController {
                
                ovc.metaData = fetchedResultsController.fetchedObjects
                ovc.dataController = dataController
                
            }
            
            //go to favorites VC
            if let fvc = segue.destination as? FavoritesViewController {
                
                fvc.metaData = fetchedResultsController.fetchedObjects
                fvc.dataController = dataController
                
            }
            
        } else{
            
            //go to object VC
            if let ovc = segue.destination as? ObjectViewController {
                
                ovc.metaData = metaData
                ovc.dataController = dataController
                
            }
            
            //go to favorites VC
            if let fvc = segue.destination as? FavoritesViewController {
                
                fvc.metaData = metaData
                fvc.dataController = dataController
                
            }
            
        }
        
    }

}

//this is here to update the data when loaded so it can be deleted as soon as it is saved.
extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            //tableView.insertRows(at: [newIndexPath!], with: .fade)
            //collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            //tableView.deleteRows(at: [indexPath!], with: .fade)
            //collectionView.deleteItems(at: [newIndexPath!])
            break
        case .update:
            //tableView.reloadRows(at: [indexPath!], with: .fade)
            //collectionView.reloadItems(at: [newIndexPath!])
            break
        case .move:
            //tableView.moveRow(at: indexPath!, to: newIndexPath!)
            //collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            break
        }
    }
}

