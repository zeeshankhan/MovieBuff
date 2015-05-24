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
    
        NetworkManager.sharedInstance.requestForData(method, url: url, param: params) { (response, error) -> Void in
            
            let res = response as? NSData
            let jsonObject: AnyObject?
            
            if response != nil {
                
                jsonObject = NSJSONSerialization.JSONObjectWithData(res!, options: .AllowFragments, error: nil)
                self.checkForErrorOnResponse(jsonObject)
            }
            else {
                let strRes = NSString(data: res!, encoding: NSUTF8StringEncoding)
                println(strRes)
            }
            
        }
        
    }
    
    func checkForErrorOnResponse(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            self.dataReceived(data!)
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
    
    override func dataReceived(data: AnyObject?) {
        if (data != nil && self.dataDelegate != nil) {
            self.dataDelegate?.refreshedList!(MovieDetails.movieList(data!))
        }
    }
}



