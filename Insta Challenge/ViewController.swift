//
//  ViewController.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/11/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class ViewController: UIViewController {

    //properties
    var authenticated: Bool!
    var pictures: Picture!
    var patternCount: Int = 1
    var downloader: PictureDownloader!
    
    //MARK:- Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backgroundBlurEffectView: UIVisualEffectView!
    @IBOutlet weak var photoBlurEffectView: RoundedBlurEffectView!
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    
    /// An alert controller used to notify the user if 3D touch is not available.
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        
        if let layout = self.pictureCollectionView.collectionViewLayout as? InstaLayout {
            layout.delegate = self
        }
        self.pictureCollectionView.delegate = self
        self.checkAuth()
        
        // Check for force touch feature, and add force touch/previewing capability.
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
        else {
            // Create an alert to display to the user.
            alertController = UIAlertController(title: "3D Touch Not Available", message: "Unsupported device.", preferredStyle: .Alert)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present the alert if necessary.
        if let alertController = alertController {
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            
            // Clear the `alertController` to ensure it's not presented multiple times.
            self.alertController = nil
        }
    }
    
    // MARK: UIStoryboardSegue Handling
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = pictureCollectionView.indexPathsForSelectedItems()![0]
            let previewDetail = pictures.previewDetails[indexPath.item]
            
            let detailViewController = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            
            // Pass the `title` to the `detailViewController`.
            detailViewController.detailItemTitle = previewDetail.title
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loadPictures(sender: AnyObject) {
        self.pictureCollectionView.dataSource = self
        downloader = PictureDownloader(data: self.pictures.largePicturesData)
        
    }
    
    
    /**
     Check the authenticated variable stored in the UserDefaults.
     If authenticated
        webView is hidden and disabled.
     
     otherwise, 
        attempt to authenticate.
     
    */
    func checkAuth() {
        if authenticated == nil {
            note("authenticated is nil. Loading from NSUserDefaults.")
            let defaults = NSUserDefaults.standardUserDefaults()
            self.authenticated = defaults.boolForKey("auth") //safe, get false if doesnt exist yet.
        }
        
        if authenticated! {
            self.webView.hidden = true
            self.webView = nil
            App.TOKEN = NSUserDefaults.standardUserDefaults().objectForKey("auth-token") as! String
            note("User is authenticated. Disabling wenView.")
            self.pictures = Picture.pictureInstance
            self.pictures.loadPictures()
            
        }else{
            note("User is NOT authenticated. Presenting webView.")
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: App.AUTH_REQUEST_URL)!))
            
        }
    }
    private func getJSONInBackground() -> NSBlockOperation {
        let queue = NSOperationQueue()
        let getOperation = NSBlockOperation(block: {
            self.pictures.loadPictures()
            print("Pics loaded.")
            
        })
        queue.addOperation(getOperation)
        return getOperation
    }
    internal func note(message: String) {
        print("Insta-Challenge ::> \(message)")
    }
}

//MARK:- UIWebviewDelegate
extension ViewController: UIWebViewDelegate {
    
    /**
     
     - Returns: False (Default) or true if the intended URL request is valid and stored as the *currentRequest*
    */
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        note("Request: \(request)")
        
        if let url = request.URL {
            if url.absoluteString.rangeOfString(App.AUTH_URI_BASE_URL) != nil {
                note("SUCCESS AUTH TOKEN DISABLE TEST - PASSED!")
                
                //grab token
                let tokenUrl = NSString(string: (request.URL?.absoluteString)!).substringFromIndex(32)
                App.TOKEN = String(tokenUrl)
                NSUserDefaults.standardUserDefaults().setObject(App.TOKEN, forKey: "auth-token")
                //hide webView n disable
                self.webView.hidden = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "auth")
                self.authenticated = true
                checkAuth() //Recheck authentication.
            }else{
                note("FAILED AUTH TOKEN TEST")
            }
        }
        
        return true
    }
    
    
}

// MARK:- InstaLayoutDelegate
extension ViewController: InstaLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
    
        let image = self.pictures.allPictures[indexPath.item]
        return image.height!
        
    }
    
    func photoSize() -> (width: CGFloat, height: CGFloat) {
        
        if self.patternCount == 1 {
            return (480.0, 480.0)
        }else if self.patternCount == 2 || self.patternCount == 3 {
            return (150.0, 150.0)
        }else if self.patternCount > 3 {
            self.patternCount = 1
            return (480.0, 480.0)
        }else{
            return (150.0, 150.0)
        }
        
        
    }
}

//MARK:- UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("CollectionViewDelegate detected cell selection at indexPath: \(indexPath)")
        currentIndexPath = indexPath
    }
}

// MARK:- UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count is: \(self.pictures.picturesJSON.count)")
        return self.pictures.picturesJSON.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! PictureCollectionViewCell
        
        if self.patternCount == 1 {
            cell.res = Resolution.low
        }else if self.patternCount == 2 || self.patternCount == 3 {
            cell.res = Resolution.thumbnail
        }else if self.patternCount > 3 {
            self.patternCount = 1
            cell.res = Resolution.thumbnail
        }
        cell.indexPath = indexPath
        self.patternCount++
        cell.pictureJSON = self.pictures.picturesJSON[indexPath.row]
        
        
        
        return cell
    }
    
    
}

// MARK: UIViewControllerPreviewingDelegate
extension ViewController: UIViewControllerPreviewingDelegate {
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = pictureCollectionView.indexPathForItemAtPoint(location) else { return nil }
        guard let cell = pictureCollectionView.cellForItemAtIndexPath(indexPath) else { return nil }
        
        // Create a detail view controller and set its properties.
        guard let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController else { return nil }
       
        let cellName = self.pictures.allPictures[indexPath.row].name
        var previewDetail: ImagePreviewDetail!
        for pics in downloader.imageDetails {
            if pics.title == cellName {
                previewDetail = pics
            }
        }
        //cell.imageView.image = previewDetail.image
        detailViewController.detailItemTitle = previewDetail.title
        detailViewController.image = previewDetail.image
        /*
        Set the height of the preview by setting the preferred content size of the detail view controller.
        Width should be zero, because it's not used in portrait.
        */
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: previewDetail.preferredHeight)
        
        // Set the source rect to the cell frame, so surrounding elements are blurred.
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        showViewController(viewControllerToCommit, sender: self)
    }
}
