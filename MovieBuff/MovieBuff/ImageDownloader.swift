//
//  ImageDownloader.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 24/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ImageDownloadDelegate {
    func imageLoaded(img: UIImage, path: NSIndexPath)
}

class ImageDownloader: NSOperation {
    
    var imageUrl: String?
    var cellPath: NSIndexPath?
    weak var delegate: ImageDownloadDelegate?
    
    init(url: String, path: NSIndexPath, callback: ImageDownloadDelegate) {
        self.imageUrl = url;
        self.cellPath = path;
        self.delegate = callback;
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        autoreleasepool {
            
            let url = NSURL(string: self.imageUrl!)
            let imgData = NSData(contentsOfURL: url!)
            var image: UIImage?
            if imgData != nil {
                image = UIImage(data: imgData!)
            }
            else {
                image = UIImage(named: "poster-dark.png")
                println("Image download error: \(self.imageUrl!)")
            }
            
            if !self.cancelled && self.delegate != nil {
                self.delegate?.imageLoaded(image!, path: self.cellPath!)
            }

        }
        
    }
}