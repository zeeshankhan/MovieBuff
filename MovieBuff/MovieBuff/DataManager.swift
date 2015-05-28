//
//  DataManager.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 23/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation

typealias CompletionHandler = (response: AnyObject?) -> Void

class DataManager {
    
    let baseUrl = "http://api.themoviedb.org/"
    let apiVer = "3"
    let apiHolder = "?api_key="
    let APIKey = "433d425daefdff55eeb180ec5abfa479"
    var imgBaseUrl: String = ""
    
    class var sharedInstance: DataManager {
        struct Static {
            static var instance: DataManager?
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DataManager()
        }
        return Static.instance!
    }
    
    // For login / logout
    func testPOST() {
        let dic: NSDictionary = NSDictionary(objects: ["Zeeshan Khan", "bar"], forKeys: ["title", "body"])
        let strBasePath = "http://jsonplaceholder.typicode.com/posts"
        NetworkManager.sharedInstance.requestForData(.POST, url: strBasePath, param: dic) { response, error -> Void in
            NSUserDefaults.standardUserDefaults().setObject(response, forKey: "configuration")
        }
    }

    
    // What is backdrop in API?
    func getConfiguration() {
        // http://api.themoviedb.org/3/configuration?api_key=433d425daefdff55eeb180ec5abfa479
        // http://image.tmdb.org/t/p/w92//2DtPSyODKWXluIRV7PVru0SSzja.jpg

        let path = self.baseUrl + self.apiVer + "/configuration" + self.apiHolder + self.APIKey
        NetworkManager.sharedInstance.requestQueue?.maxConcurrentOperationCount = 1
        NetworkManager.sharedInstance.requestForData(.GET, url: path, param: NSDictionary()) { response, error -> Void in
            
            if (response != nil) {
                NSUserDefaults.standardUserDefaults().setObject(response, forKey: "configuration")
                let imgConfDic = response!.objectForKey("images") as? NSDictionary
                if imgConfDic != nil {
                    let baseUrl = imgConfDic?.objectForKey("base_url") as? String
                    if baseUrl != nil {
                        self.imgBaseUrl = baseUrl! + "w92"
                        //                let logoSizes = imgConfDic?.objectForKey("logo_sizes") as? NSArray
                        //                let is92Exist = logoSizes?.indexOfObject("w92")
                    }
                }
                else {
                    self.imgBaseUrl = "http://image.tmdb.org/t/p/w92"
                }
                
                println("Configuration loaded.")
                NetworkManager.sharedInstance.requestQueue?.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
            }
        }
    }

    
    func getMoviesList(text: String, completionBlock: CompletionHandler) {
        // http://api.themoviedb.org/3/search/movie?api_key=433d425daefdff55eeb180ec5abfa479&query=kick

        let dic: NSDictionary = NSDictionary(objects: [text], forKeys: ["query"])
        let path = self.baseUrl + self.apiVer + "/search/movie" + self.apiHolder + self.APIKey

        NetworkManager.sharedInstance.requestForData(.GET, url: path, param: dic) { response, error -> Void in
            if response != nil {
                completionBlock(response: MovieDetails.movieList(response!))
            }
        }

    }
    
    
    func getMovieDetail(movieId: String) {
        // http://api.themoviedb.org/3/movie/157336?api_key=433d425daefdff55eeb180ec5abfa479
        
        let path = self.baseUrl + self.apiVer + "/movie/" + movieId + self.apiHolder + self.APIKey
        NetworkManager.sharedInstance.requestForData(.GET, url: path, param: NSDictionary()) { response, error -> Void in
        }
    }
    
    func getMovieCasts(movieId: String) {
        // http://api.themoviedb.org/3/movie/157336/casts?api_key=433d425daefdff55eeb180ec5abfa479
        
        let path = self.baseUrl + self.apiVer + "/movie/" + movieId + "/casts" + self.apiHolder + self.APIKey
        NetworkManager.sharedInstance.requestForData(.GET, url: path, param: NSDictionary()) { response, error -> Void in
        }
    }

}



// http://api.themoviedb.org/3/genre/movie/list?api_key=433d425daefdff55eeb180ec5abfa479&id=157336
// http://api.themoviedb.org/3/search/collection?api_key=433d425daefdff55eeb180ec5abfa479&id=157336&query=kick



