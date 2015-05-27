//
//  DetailVC.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 24/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import Foundation
import UIKit

class DetailVC: UITableViewController, ImageDownloadDelegate {
    var md: MovieDetails?
    var arrDetail: NSArray?
    var queueImg: NSOperationQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
/*
        if (self.md.poster == nil)
        [self downloadThumb];
        else
        [self setTableBackground];
*/
        self.navigationItem.title = self.md?.title
        self.tableView.separatorColor = UIColor.darkGrayColor()
        
        self.queueImg = NSOperationQueue()
        self.queueImg?.name = "ActorListingQueue"
        self.queueImg?.maxConcurrentOperationCount = 10
        
        let path = NSBundle.mainBundle().pathForResource("DetailScreen", ofType: "plist")
        self.arrDetail = NSArray(contentsOfFile:path!)
        
        let dm = DataManager.sharedInstance
        let title = self.md?.title
        dm.getMovieDetail(title!)
        
        if self.md?.poster == nil {
            
        }
        else {
            
        }
    }

    override func viewWillDisappear(animated: Bool) {
        self.queueImg!.cancelAllOperations()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        self.queueImg!.cancelAllOperations()
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- VC logic

    //MARK:- ImageDownloadDelegate
    func imageLoaded(img: UIImage, path: NSIndexPath) {
        
        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            
            var image = img as UIImage?
            if image == nil {
                image = UIImage(named: "poster-dark.png")!
            }
            self.md?.updateCast(image!, index: path.row)
            
            var oldCell = self.tableView.cellForRowAtIndexPath(path) as! MovieListCell?
            oldCell?.imgVThumb.image = image
        })
        
    }
    
    func startThumbDownload(url: String, path: NSIndexPath) {
        self.queueImg?.addOperation(ImageDownloader(url: url, path: path, callback: self))
    }
    
    func loadImagesForOnscreenRows() {
        
//            if ([secTitle isEqualToString:@"Cast"] && self.md.cast.count > indexPath.row) {
//                MovieActor* m = [self.md.cast objectAtIndex:indexPath.row];
//                if (m.actorThumb == nil)
//                [self startIconDownloadForUrl:m.actorThumbURL forIndexPath:indexPath];
//            }
//        }
        
        let visiblePaths = self.tableView.indexPathsForVisibleRows()
        for indexPath in visiblePaths! {
            let dicSec: NSDictionary? = self.arrDetail?.objectAtIndex(indexPath.section) as? NSDictionary
            let secTitle: String? = dicSec?.objectForKey("SectionTitle") as? String
            if secTitle == "Cast" {
//                if count(self.md.cast) > indexPath.row {
//                
//                }
            }
        }
        
    }
    
    //MARK:- UIScrollViewDelegate
    // Load images for all onscreen rows when scrolling is finished
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }

    
}

