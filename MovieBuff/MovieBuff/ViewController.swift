//
//  ViewController.swift
//  MovieBuff
//
//  Created by Zeeshan Khan on 15/05/15.
//  Copyright (c) 2015 Zeeshan Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataManagerDelegate, ImageDownloadDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tblMovieList: UITableView!
    var searchBar: UISearchBar?

    var arrMovies: NSMutableArray?
    var dm: MovieListDM?
    var queueImg: NSOperationQueue?
    
    // MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // To show login screen
//        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "login")

        self.initializeSeachBar()

        self.dm = MovieListDM(delegate: self)
        self.arrMovies = NSMutableArray();

        self.queueImg = NSOperationQueue()
        self.queueImg?.name = "SearchListingQueue"
        self.queueImg?.maxConcurrentOperationCount = 10
        
        self.searchBar?.text = "Iron Man"
//        self.dm?.getMoviesList(self.searchBar!.text)
        
//        self.dm?.testPOST()
        
//        self.dm?.getMoviesList("Superman")
//        self.dm?.getMoviesList("Xmen")
//        self.dm?.getMoviesList("Thor")
//        self.dm?.getMoviesList("Batman")
//        self.dm?.getMoviesList("Spiderman")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addSubview(self.searchBar!)

//        let indexpath = self.tblMovieList.indexPathsForSelectedRows()
//        self.tblMovieList.deselectRowAtIndexPath(indexpath, animated: true)
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
            self.dm!.getMoviesList(searchBar.text)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK:- DataManagerDelegate
    func refreshedList(arrItems: NSArray?) {
        self.arrMovies?.addObjectsFromArray(arrItems! as! [MovieDetails])
        self.tblMovieList.reloadData()
    }

    
    //MARK:- Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrMovies!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
                self.startThumbDownload(m.posterURL!, path: indexPath)
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
            
            var oldCell = self.tblMovieList.cellForRowAtIndexPath(path) as! MovieListCell?
            oldCell?.imgVThumb.image = image
        })
        
    }
    
    func startThumbDownload(url: String, path: NSIndexPath) {
        self.queueImg?.addOperation(ImageDownloader(url: url, path: path, callback: self))
    }
    
    func loadImagesForOnscreenRows() {

        let visiblePaths = self.tblMovieList.indexPathsForVisibleRows()
        for indexPath in visiblePaths! {
            let m = self.arrMovies?.objectAtIndex(indexPath.row) as! MovieDetails
            if m.poster == nil {
                self.startThumbDownload(m.posterURL!, path: indexPath as! NSIndexPath)
            }
        }
        
    }
    
    //MARK:- UIScrollViewDelegate
    // Load images for all onscreen rows when scrolling is finished
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }

    //MARK:- Detail VC
    
}

