//
//  DataManager.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 23/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation

@objc protocol DataManagerDelegate {
    optional func refreshedList(arrItems: NSArray?) -> Void
    optional func refreshDetailWithResponse(response: NSDictionary?) -> Void
}

@objc protocol DMCallBack {
    optional func dataReceived(data: AnyObject?) -> Void
}

class DataManager: NSObject, DMCallBack {
    
    let baseUrl = "http://api.themoviedb.org/"
    let apiVer = "3"
    let apiHolder = "?api_key="
    let APIKey = "433d425daefdff55eeb180ec5abfa479"
    
    
    weak var dataDelegate: DataManagerDelegate?
    
    init(delegate: DataManagerDelegate) {
        self.dataDelegate = delegate
    }
    
    func getDataFromServer(method: Method, url: String, params: NSDictionary) {
    
        NetworkManager.sharedInstance.requestForData(method, url: url, param: params) { response, error -> Void in
            
            if (response != nil && self.dataDelegate != nil) {
                self.dataReceived(response!)
            }
        }
        
    }
    
    //MARK:- Configuration
    func getConfiguration() {
        // http://api.themoviedb.org/3/configuration?api_key=433d425daefdff55eeb180ec5abfa479

        let path = self.baseUrl + self.apiVer + "/configuration" + self.apiHolder + self.APIKey
        self.getDataFromServer(.GET, url: path, params: NSDictionary())
    }
    
    func dataReceived(data: AnyObject?) {
        println("Setting Configuration")
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "configuration")
    }
}

class ConfigurationDM : DataManager, DataManagerDelegate {
    
//    class var sharedInstance: ConfigurationDM {
//        struct Static {
//            static var instance: ConfigurationDM?
//            static var onceToken: dispatch_once_t = 0
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = ConfigurationDM(delegate: self)
//        }
//        return Static.instance!
//    }
    
   override func dataReceived(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            if data!.isKindOfClass(NSDictionary) {
//                self.dataDelegate?.refreshedList!(MovieDetails.movieList(data!))
            }
            else {
                println("Data format is different than expected.")
            }
        }
    }

}


class MovieListDM : DataManager {
    
    func getMoviesList(text: String) {
        // http://api.themoviedb.org/3/search/movie?api_key=433d425daefdff55eeb180ec5abfa479&query=kick
        let dic: NSDictionary = NSDictionary(objects: [text], forKeys: ["query"])
        let path = self.baseUrl + self.apiVer + "/search/movie" + self.apiHolder + self.APIKey
        self.getDataFromServer(.GET, url: path, params: dic)
    }
    
    func testPOST() {
        let dic: NSDictionary = NSDictionary(objects: ["Zeeshan Khan", "bar"], forKeys: ["title", "body"])
        let strBasePath = "http://jsonplaceholder.typicode.com/posts"
        self.getDataFromServer(.POST, url: strBasePath, params: dic)
    }
    
    override func dataReceived(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            if data!.isKindOfClass(NSArray) {
                self.dataDelegate?.refreshedList!(MovieDetails.movieList(data!))
            }
            else {
                println("Data format is different than expected.")
            }
        }
    }
}

// First i need to fire is configuration
// What is backdrop in API?

// http://api.themoviedb.org/3/genre/movie/list?api_key=433d425daefdff55eeb180ec5abfa479&id=157336
// http://image.tmdb.org/t/p/w92//2DtPSyODKWXluIRV7PVru0SSzja.jpg
// http://api.themoviedb.org/3/search/collection?api_key=433d425daefdff55eeb180ec5abfa479&id=157336&query=kick


class MovieDetailDM: DataManager {
    
    func getMovieDetail(movieId: String) {
        // http://api.themoviedb.org/3/movie/157336?api_key=433d425daefdff55eeb180ec5abfa479
        
        let path = self.baseUrl + self.apiVer + "/movie/" + movieId + self.apiHolder + self.APIKey
        self.getDataFromServer(.GET, url: path, params: NSDictionary())
    }

    func getMovieCasts(movieId: String) {
        // http://api.themoviedb.org/3/movie/157336/casts?api_key=433d425daefdff55eeb180ec5abfa479
        
        let path = self.baseUrl + self.apiVer + "/movie/" + movieId + "/casts" + self.apiHolder + self.APIKey
        self.getDataFromServer(.GET, url: path, params: NSDictionary())
    }
    
    override func dataReceived(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            if data!.isKindOfClass(NSDictionary) {
                self.dataDelegate?.refreshDetailWithResponse!(data as? NSDictionary)
            }
            else {
                println("Data format is different than expected.")
            }
        }
    }
}

