//
//  ViewController.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 15/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, ImageDownloadDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    var searchBar: UISearchBar?
    var arrMovies: NSMutableArray?
    var dm: DataManager?
    var queueImg: NSOperationQueue?
    
    // MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To show login screen
//        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "login")

        self.initializeSeachBar()

        self.dm = DataManager.sharedInstance
        self.dm!.getConfiguration()

        self.arrMovies = NSMutableArray();

        self.queueImg = NSOperationQueue()
        self.queueImg?.name = "SearchListingQueue"
        self.queueImg?.maxConcurrentOperationCount = 10

        //WARNING:- test
        self.searchBar?.text = "Iron Man"
        self.dm?.getMoviesList(self.searchBar!.text) { response -> Void in
            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
            self.tableView.reloadData()
        }
        
//        self.dm?.getMoviesList("Superman") { response -> Void in
//            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
//            self.tableView.reloadData()
//        }
//
//        self.dm?.getMoviesList("Xmen") { response -> Void in
//            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
//            self.tableView.reloadData()
//        }
//
//        self.dm?.getMoviesList("Thor") { response -> Void in
//            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
//            self.tableView.reloadData()
//        }
//
//        self.dm?.getMoviesList("Batman") { response -> Void in
//            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
//            self.tableView.reloadData()
//        }
//
//        self.dm?.getMoviesList("Spiderman") { response -> Void in
//            self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
//            self.tableView.reloadData()
//        }

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(self.searchBar!)

//        let indexpath = self.tableView.indexPathsForSelectedRows()
//        self.tableView.deselectRowAtIndexPath(indexpath, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let loginVal = NSUserDefaults.standardUserDefaults().boolForKey("login")
        if loginVal == false {
            println("Showing Login")
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("login") as! LoginVC
            let navCont = UINavigationController(rootViewController: vc)
            self.presentViewController(navCont, animated: true, completion: nil)
        }
        else {
            println("existing user")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.queueImg!.cancelAllOperations()
        self.searchBar!.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        self.queueImg!.cancelAllOperations()
        super.didReceiveMemoryWarning()
    }

    //MARK:- Search Bar
    func initializeSeachBar() {
        let sc = self.navigationController?.navigationBar.frame.size
        self.searchBar = UISearchBar(frame: CGRectMake(10, 0, sc!.width-20, sc!.height))
        self.searchBar?.placeholder = "Search for movie"
        self.searchBar?.showsCancelButton = true
        self.searchBar?.delegate = self
        self.searchBar?.keyboardAppearance = .Dark
        self.searchBar?.barStyle = .Black
        self.searchBar?.translucent = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if count(searchBar.text) > 0 {
            self.dm?.getMoviesList(searchBar.text) { response -> Void in
                self.arrMovies?.addObjectsFromArray(response! as! [MovieDetails])
                self.tableView.reloadData()
            }

            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK:- Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMovies!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieListCell", forIndexPath: indexPath) as! MovieListCell
        let m: MovieDetails = self.arrMovies!.objectAtIndex(indexPath.row) as! MovieDetails
        cell.lblName.text = m.title
        
        let img = m.poster
        if img != nil {
            cell.imgVThumb?.image = img;
        }
        else {
            cell.imgVThumb?.image = UIImage(named: "poster-dark.png");
            if tableView.dragging == false && tableView.decelerating == false {
                self.startThumbDownload(m.posterURL, path: indexPath)
            }
        }
        return cell
    }
    
    //MARK:- ImageDownloadDelegate
    func imageLoaded(img: UIImage, path: NSIndexPath) {

        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            
            var image = img as UIImage?
            if image == nil {
                image = UIImage(named: "poster-dark.png")!
            }
            
            var m = self.arrMovies?.objectAtIndex(path.row) as! MovieDetails?
            m?.poster = image!
            self.arrMovies?.replaceObjectAtIndex(path.row, withObject: m!)
            
            var oldCell = self.tableView.cellForRowAtIndexPath(path) as! MovieListCell?
            oldCell?.imgVThumb.image = image
        })
        
    }
    
    func startThumbDownload(url: String, path: NSIndexPath) {
        self.queueImg?.addOperation(ImageDownloader(url: url, path: path, callback: self))
    }
    
    func loadImagesForOnscreenRows() {

        let visiblePaths = self.tableView.indexPathsForVisibleRows()
        for indexPath in visiblePaths! {
            let m = self.arrMovies?.objectAtIndex(indexPath.row) as! MovieDetails
            if m.poster == nil {
                self.startThumbDownload(m.posterURL, path: indexPath as! NSIndexPath)
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

    //MARK:- Detail VC
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "MovieDetails" {
            var dvc = segue.destinationViewController as! DetailVC
            let row = self.tableView.indexPathForSelectedRow()?.row
            dvc.md = self.arrMovies?.objectAtIndex(row!) as? MovieDetails
        }
    }

}

