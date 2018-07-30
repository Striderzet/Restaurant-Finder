//
//  ZomatoConstants.swift
//  Final Project
//
//  Created by Tony Buckner on 7/5/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct ZomatoConstants {
    
    // MARK: Zomato
    struct Zomato {
        static let APIScheme = "https"
        static let APIHost = "developers.zomato.com"
        static let APIPath = "/api/v2.1/search"
    }
    
    //Zomato Parameter Keys
    struct ZomatoParameterKeys {
        static let Keyword = "q"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let SortBy = "sort"
        static let APIKey = "user-key"
        static let Application = "Application"
        static let Count = "count"
    }
    
    // MARK: Zomato Parameter Values
    struct ZomatoParameterValues {
        
        static let APIKey = "55cd5db5fb56e6df30f3d451cadd2493"
        static let ResponseFormat = "application/json"
        static let Sort = "real_distance"
        static let Count = "100"
        
    }
    
}
