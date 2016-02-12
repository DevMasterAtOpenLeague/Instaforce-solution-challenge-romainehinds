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

struct App {
    
    private static let CLIENT_ID = "5bae4fcc540645d98f45563325d1ee27"
    private static let CLIENT_SECRET = "af25db7edd0f4843ae4a36ec35592203"
    static let REDIRECT_URI = "https://localhost"
    static let AUTH_URI_BASE_URL = "https://localhost/#access_token="
    
    static let AUTH_REQUEST_URL
        = "https://api.instagram.com/oauth/authorize/?client_id=\(App.CLIENT_ID)&redirect_uri=\(App.REDIRECT_URI)&scope=public_content&response_type=token"
    
    static var AUTH_TOKEN_URL: String {
        get {
            return "https://api.instagram.com/v1/tags/selfie/media/recent?access_token=" + TOKEN
        }
    }
    
    static var TOKEN: String! {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(TOKEN, forKey: "auth-token")
        }
    }
}

class ViewController: UIViewController {

    //properties
    var authenticated: Bool!
    var pictures: Picture!
    var patternCount: Int = 1
    
    
    
    //MARK:- Outlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backgroundBlurEffectView: UIVisualEffectView!
    @IBOutlet weak var photoBlurEffectView: RoundedBlurEffectView!
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    
    
    /*
    Using the Instagram API, create an iPhone app that displays photos tagged with hashtag #selfie and arranges them using the pattern: big, small, small (repeating). Then implement one of the following features: Tap to enlarge, Drag and drop reordering, or Infinite scrolling. Scrolling should be smooth so performance is essential. Complete as much as you can within one day. Be creative and have fun. Good luck!
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.webView.delegate = self
        
        
        if let layout = self.pictureCollectionView.collectionViewLayout as? InstaLayout {
            layout.delegate = self
        }
        
        self.checkAuth()
        
        //TODO: check authentication
        //self.checkAuth() //Moved to viewWillAppear
        //self.pictureCollectionView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loadPictures(sender: AnyObject) {
        print("setting datasoure")
        self.pictureCollectionView.dataSource = self
        print("Pictures: \(self.pictures)")
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
        print("height current image: \(image) ")
        return image.height!
//        let size = CGSize(width: image.width!, height: image.height!)
//        
//        let  boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
//        let rect  = AVMakeRectWithAspectRatioInsideRect(size, boundingRect)
//        return rect.size.height
        
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
        
        self.patternCount++
        cell.pictureJSON = self.pictures.picturesJSON[indexPath.row]
        
        
        
        return cell
    }
    
    
}

