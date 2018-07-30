//
//  FavoritesViewController.swift
//  Final Project
//
//  Created by Tony Buckner on 7/19/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FavoritesViewController: UITableViewController {
    
    //local cache array
    var seletecedInformationCache = [objectInfo]()
    
    //loaded back flag to reload data
    var loadedBack = false
    
    //data controller code and fetch requests
    var dataController:DataController!
    
    //metadata var (single object)
    var metaData: [MetaData]!
    
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
        //place code here
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupFetchedResultsController()
        loadedBack = true
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadedBack{
            return (fetchedResultsController.sections?[0].numberOfObjects)!
        } else {
            return metaData.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        //default value
        
        var info = MetaData()
        
        if loadedBack{
            info = fetchedResultsController.object(at: indexPath)
        } else {
            info = metaData[indexPath.row]
        }
        
        var tempObject = objectInfo()
        
        cell.restaurantAggregateRating.text = "Rating: " + info.rating!
        tempObject.rating = info.rating!
        
        cell.restaurantName.text = info.name
        tempObject.name = info.name!
        
        let dataImage = info.thumbnailPic
        cell.restaurantImage.image = UIImage(data:dataImage! ,scale:1.0)
        tempObject.image = UIImage(data:dataImage! ,scale:1.0)!
        
        tempObject.address = info.address!
        
        seletecedInformationCache.append(tempObject)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        PassedObjectInformation.sharedInstance.info = seletecedInformationCache[indexPath.row]
        performSegue(withIdentifier: "DetailedInfo", sender: nil)
        
    }
    
    //send info over to next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if loadedBack{
            //go to object VC
            if let ovc = segue.destination as? ObjectViewController {
                
                ovc.metaData = fetchedResultsController.fetchedObjects
                ovc.dataController = dataController
                
            }
        } else {
            //go to object VC
            if let ovc = segue.destination as? ObjectViewController {
                
                ovc.metaData = metaData
                ovc.dataController = dataController
            }
        }
        
    }
}

//this is here to update the data when loaded so it can be deleted as soon as it is saved.
extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    
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
