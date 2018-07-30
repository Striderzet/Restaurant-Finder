//
//  GlobalSingletonVariables.swift
//  Final Project
//
//  Created by Tony Buckner on 7/8/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

//selected object information singleton
class SelectedObjectInformation {
    static let sharedInstance = SelectedObjectInformation()
    var info: [objectInfo] = []
}

//passed info for detailed view
class PassedObjectInformation {
    static let sharedInstance = PassedObjectInformation()
    var info = objectInfo()
}

//this singleton will hold all data accross the app and will be an instrument to search, add, and delete data from the core data stack
class MetaDataSingleton {
    static let sharedInstance = MetaDataSingleton()
    var metaData = [MetaData]()
}

struct objectInfo {
    var name = String()
    var distance = latLon()
    var rating = String()
    var image = UIImage()
    var address = String()
}

//latitude longitude singleton
class SavedRealLocation {
    static let sharedInstance = SavedRealLocation()
    var location = latLon()
}

struct latLon {
    var latitude = Double()
    var longitude = Double()
    
    init() {
        latitude = 0.0
        longitude = 0.0
    }
}
