//
//  ObjectViewController.swift
//  Final Project
//
//  Created by Tony Buckner on 7/4/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ObjectViewController: UIViewController{
    
    @IBOutlet weak var thumbnailPic: UIImageView!
    @IBOutlet weak var restName: UITextView!
    @IBOutlet weak var restAddress: UITextView!
    @IBOutlet weak var restRating: UITextView!
    @IBOutlet weak var favoriteSwitchValue: UISwitch!
    
    //passed info variable when loaded for view values
    let passedInfo = PassedObjectInformation.sharedInstance.info
    
    //data controller code and fetch requests
    var dataController:DataController!
    
    //metadata var (Array object)
    var metaData: [MetaData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        thumbnailPic.image = passedInfo.image
        restRating.text = "Rating: " + passedInfo.rating
        restAddress.text = passedInfo.address
        restName.text = passedInfo.name
        
        //sets favortie flag to true if it is already a favorite
        var place = 0
        while place < metaData.count{
            let results = metaData[place]
            print(results.isFavorite)
            print(results.name!)
            print(passedInfo.name)
            if (results.isFavorite) && (results.name! == passedInfo.name){
                
                favoriteSwitchValue.isOn = true
            }
            place += 1
        }
        print(favoriteSwitchValue.isOn)
        //favoriteSwitchValue.isOn = true
    }
    
    @IBAction func favoriteSwitch(_ sender: Any) {
        
        //save the data
        if favoriteSwitchValue.isOn {
            print("Turned ON")
            let newFav = MetaData(context: dataController.viewContext)
            newFav.creationDate = Date()
            let imageData: Data? = UIImagePNGRepresentation(passedInfo.image)
            newFav.thumbnailPic = imageData
            newFav.address = passedInfo.address
            newFav.name = passedInfo.name
            newFav.rating = passedInfo.rating
            newFav.isFavorite = true
            try? dataController.viewContext.save()
            print(newFav)
        }
        
        //delete the data
        if !favoriteSwitchValue.isOn {
            print("Turned OFF")
            
            var place = 0
            while place < MetaDataSingleton.sharedInstance.metaData.count{
                let results = MetaDataSingleton.sharedInstance.metaData[place]
                if passedInfo.name == results.name{
                    //let dataToDelete = fetchedResultsController?.object(at: IndexPath(row: place, section: 0))
                    dataController.viewContext.delete(results)
                    try? dataController.viewContext.save()
                }
                place += 1
            }
        }
    }
}

//this is here to update the data when loaded so it can be deleted as soon as it is saved.
extension ObjectViewController: NSFetchedResultsControllerDelegate {
    
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
