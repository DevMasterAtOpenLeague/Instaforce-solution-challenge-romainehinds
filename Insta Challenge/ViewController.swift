//
//  ViewController.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/11/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import UIKit

struct App {
    
    private static let CLIENT_ID = "944761ef064d4004b6751adfd0bc6f25"
    private static let CLIENT_SECRET = "27add98158184b4b8415b6778bb9a7ab"
    static let REDIRECT_URI = "https://localhost"
    
    static let AUTH_REQUEST_URL = "https://api.instagram.com/oauth/authorize/?client_id=\(CLIENT_ID)&redirect_uri=\(REDIRECT_URI)&scope=public_content&response_type=token"
    
    static var AUTH_TOKEN_URL: NSURL!
    
}

class ViewController: UIViewController {

    var authenticated: Bool!
    
    @IBOutlet weak var webView: UIWebView!
    
    /*
    Using the Instagram API, create an iPhone app that displays photos tagged with hashtag #selfie and arranges them using the pattern: big, small, small (repeating). Then implement one of the following features: Tap to enlarge, Drag and drop reordering, or Infinite scrolling. Scrolling should be smooth so performance is essential. Complete as much as you can within one day. Be creative and have fun. Good luck!
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.webView.delegate = self
        
        //TODO: check authentication
        self.checkAuth()
        
        //TODO: set web view to instagram auth page
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            note("User is authenticated. Disabling wenView.")
            self.webView.hidden = true
            self.webView = nil
        }else{
            note("User is NOT authenticated. Presenting webView.")
            self.webView.loadRequest(NSURLRequest(URL: NSURL(string: App.AUTH_REQUEST_URL)!))
        }
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
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        note("webView: Started")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        note("webView: Ended")
    }
}

