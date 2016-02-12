//
//  Picture.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/11/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Picture {
    
    static var pictureInstance = Picture()
    
    var allPictures: [Picture]!
    var pictureJSON: JSON!
    var loaded: Bool = false
    
    private init(){
        
    }
    
    func loadPictures() {
        print("Loading Pictures")
        if !loaded {
            Alamofire.request(.GET, App.AUTH_TOKEN_URL).responseJSON {
                response in
                if let json = response.result.value {
                    let jsonObj = JSON(json)
                    self.loaded = true
                    print("Json: \(jsonObj)")
                }
            }
        }
    
    }
}