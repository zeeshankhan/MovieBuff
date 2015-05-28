//
//  MovieDetail.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 23/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation
import UIKit

class MovieDetails {
    
    var poster: UIImage?
    var dicMovie: NSMutableDictionary?

    var title: String?
    var movieId: String?
    var releaseDate: String?
    var posterURL: String = ""
    
    var overview: String?
    var runtime: String?
    var status: String?
    var genres: String?
    var language: String?

    
    class func movieList(response: AnyObject) -> NSArray {
        var arr = NSMutableArray()
        let results = response.objectForKey("results") as! NSArray
        for dic in results {
            arr.addObject(MovieDetails(movie: dic as! NSDictionary))
        }
        return NSArray(array: arr)
    }

    init(movie: NSDictionary) {
        self.dicMovie = movie.mutableCopy() as? NSMutableDictionary
        self.initailizeMovieProperties(movie)
    }
    
    func initailizeMovieProperties(dicInfo:NSDictionary) {
        self.title = dicInfo.objectForKey("title") as? String
        
        self.movieId = dicInfo.objectForKey("id") as? String
        self.releaseDate = dicInfo.objectForKey("release_date") as? String
        
        let poster_path = dicInfo.objectForKey("poster_path") as? String
        if poster_path != nil {
            self.posterURL =  DataManager.sharedInstance.imgBaseUrl + poster_path!
        }
    }
    
    var config: NSDictionary {
        struct Static {
            static var conf: NSDictionary?
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken, {() -> Void in
            Static.conf = NSUserDefaults.standardUserDefaults().objectForKey("configuration") as? NSDictionary
        })
        return Static.conf!
    }
    
    
    func updateResponse(response: NSDictionary) {
    
    }
    
    func updateCast(thumb: UIImage, index: Int) {
    
    }
}