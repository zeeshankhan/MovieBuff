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
    var posterURL: String?
    
    class func movieList(response: AnyObject) -> NSArray {
        var arr = NSMutableArray()
        let movies = response as! NSArray
        for dic in movies {
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
        self.posterURL = dicInfo.objectForKey("urlPoster") as? String
    }
    
    func updateResponse(response: NSDictionary) {
    
    }
    
    func updateCast(thumb: UIImage, index: Int) {
    
    }
}