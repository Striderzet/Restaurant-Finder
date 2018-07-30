//
//  ZomatoApi.swift
//  Final Project
//
//  Created by Tony Buckner on 7/5/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ZomatoAPIFunctions {
    
    func getListWithMethodParameters(lat: Double, lon: Double, okToGo: @escaping(_ good: Bool, _ errorCode: String) -> Void){
        
        //Method parameters setup
        //testing currently set for NYC
        //ZomatoConstants.ZomatoParameterKeys.Latitude: 40.6840183062555,
        //ZomatoConstants.ZomatoParameterKeys.Longitude: -74.0217937125541,
        let methodParameters = [
            ZomatoConstants.ZomatoParameterKeys.Latitude: lat,
            ZomatoConstants.ZomatoParameterKeys.Longitude: lon,
            ZomatoConstants.ZomatoParameterKeys.SortBy: ZomatoConstants.ZomatoParameterValues.Sort,
            ZomatoConstants.ZomatoParameterKeys.Count: ZomatoConstants.ZomatoParameterValues.Count
            ] as [String : AnyObject]
        
        getZomatoRestaurantData(methodParameters){ loadedGood, alertCode in
            
            okToGo(loadedGood, alertCode)
            
        }
        
    }
    
    // MARK: Helper for Creating a URL from Parameters
    private func ZomatoURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = ZomatoConstants.Zomato.APIScheme
        components.host = ZomatoConstants.Zomato.APIHost
        components.path = ZomatoConstants.Zomato.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        //print(components.url!)
        return components.url!
    }
    
    //function to call Zomato API
    private func getZomatoRestaurantData(_ methodParameters: [String: AnyObject], loadedGood: @escaping(_ good: Bool, _ alertCode: String) -> Void) {
        
        // create session and request
        let session = URLSession.shared
        
        //this part of the code forms the line:
        //curl -X GET --header "Accept: application/json" --header "user-key: 55cd5db5fb56e6df30f3d451cadd2493" "https://developers.zomato.com/api/v2.1/search?lat=40.6840183062555&lon=-74.0217937125541&sort=real_distance"
        var request = URLRequest(url: ZomatoURLFromParameters(methodParameters))
        request.httpMethod = "GET"
        request.addValue(ZomatoConstants.ZomatoParameterValues.APIKey, forHTTPHeaderField: ZomatoConstants.ZomatoParameterKeys.APIKey)
        request.addValue(ZomatoConstants.ZomatoParameterValues.ResponseFormat, forHTTPHeaderField: ZomatoConstants.ZomatoParameterKeys.Application)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                loadedGood(false, "net")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                loadedGood(false, "net")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                loadedGood(false, "nil")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                loadedGood(false, "info")
                return
            }
            //break the data down into a subscript dictionary
            let restaurauntList: [[String:AnyObject]]! = parsedResult["restaurants"] as! [[String:AnyObject]]
            
            performUIUpdatesOnMain {
                //load all elements into an array for the table
                for elements in restaurauntList {
                    
                    var keyInfo = objectInfo()
                    let imageURL = elements["restaurant"]!["featured_image"] as? String
                    let location = elements["restaurant"]!["location"] as? [String: AnyObject]
                    
                    if imageURL != "" {
                        self.getZomatoThumbnailWithUrl(imageString: imageURL!) { image, good in
                            
                            if good{
                                keyInfo.image = image
                                keyInfo.name = elements["restaurant"]!["name"] as! String
                                var ratingNumber = elements["restaurant"]!["user_rating"] as! [String:AnyObject]
                                
                                let latString = location!["latitude"]
                                let longString = location!["longitude"]
                                keyInfo.distance.latitude = (latString?.doubleValue)!
                                keyInfo.distance.longitude = (longString?.doubleValue)!
                                
                                keyInfo.address = location!["address"] as! String
                    
                                keyInfo.rating = ratingNumber["aggregate_rating"] as! String
                                
                                SelectedObjectInformation.sharedInstance.info.append(keyInfo)
                            }
                        }
                    }
                }
            }
            
            //confirmed loaded good
            loadedGood(true, "GOOD")
            
            //test data print
            //print(restaurauntList[0]["restaurant"]!["user_rating"])
           
        }
        
        // start the task!
        task.resume()
    }
    
    //to get thumbnail pic for metadata
    private func getZomatoThumbnailWithUrl(imageString: String, goodImage: @escaping(_ image: UIImage, _ good: Bool) -> Void){
        
        let imageURL = URL(string: imageString)!
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            //checks for a URL returned error code before it grabs the data and loads it
            if error == nil {
                let downloadImage = UIImage(data: data)
                if downloadImage != nil{
                    goodImage(downloadImage!, true)
                }
            }
        }
        
        task.resume()
        
    }
    
    
}
