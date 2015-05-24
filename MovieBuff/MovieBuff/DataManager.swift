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
    
    
    func dataReceived(data: AnyObject?) {
        println("Data manager")
    }
}


class MovieListDM : DataManager {
    
    func getMoviesList(text: String) {
        let dic: NSDictionary = NSDictionary(objects: [text, "10"], forKeys: ["title", "limit"])
        let strBasePath = "http://www.myapifilms.com/imdb?token=3962c3d1-e56d-40fd-b392-3b03bc621454"
        self.getDataFromServer(.GET, url: strBasePath, params: dic)
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

class MovieDetailDM: DataManager {
    
    func getMovieDetail(movieId: String) {
        let dic: NSDictionary = NSDictionary(objects: [movieId, "S"], forKeys: ["idIMDB", "actors"])
        let strBasePath = "http://www.myapifilms.com/imdb?token=3962c3d1-e56d-40fd-b392-3b03bc621454"
        self.getDataFromServer(.GET, url: strBasePath, params: dic)
    }
    
    override func dataReceived(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            if data!.isKindOfClass(NSArray) {
                self.dataDelegate?.refreshDetailWithResponse!(data as? NSDictionary)
            }
            else {
                println("Data format is different than expected.")
            }
        }
    }
}

