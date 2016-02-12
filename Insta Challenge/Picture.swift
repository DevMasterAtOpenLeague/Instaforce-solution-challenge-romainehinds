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
    
    var allPictures: [PictureData]!
    var picturesJSON: [JSON]!
    var loaded: Bool = false
    
    var allImages: [UIImage] = [UIImage]()
    
    var count: Int = 0
    private init(){
        self.picturesJSON = [JSON]()
        //self.loadPictures()
    }
    
    func loadPictures() {
        print("Loading Pictures")
        if !loaded {
            Alamofire.request(.GET, App.AUTH_TOKEN_URL).responseJSON {
                response in
                if let json = response.result.value {
                    let jsonObj = JSON(json)
                    self.loaded = true
                    self.picturesJSON = jsonObj["data"].arrayValue as [JSON]?
                    print("PictureJSON: \n\(self.picturesJSON)")
                    var count = 1
                    for json in self.picturesJSON {
                        var res: Resolution!
                        if count == 1 {
                            res = .low
                        }else if count == 2 || count == 3 {
                            res = .thumbnail
                        }else{
                            count = 1
                            res = .standard
                        }
                        
                        count++
                        
                        let data = self.extractPictureJSON(json, res: res)
                        let pictureData = PictureData(height: data.height, width: data.width, url: data.url, resolution: data.res)
                        
                        if self.allPictures == nil {
                            self.allPictures = [PictureData]()
                        }
                                    
                        self.allPictures.append(pictureData)
                    }
                }
            }
        }
    }
    
//    func getPictureData(res: Resolution) -> PictureData{
//        if self.picturesJSON == nil {
//            self.picturesJSON = [JSON]()
//        }
//        
//        if let data = self.picturesJSON.last {
//            let jsonData = extractPictureJSON(data, res: res)
//            
//            let pictureData = PictureData(height: jsonData.height, width: jsonData.width, url: jsonData.url, resolution: jsonData.res)
//            
//            if self.allPictures == nil {
//                self.allPictures = [PictureData]()
//            }
//            
//            self.allPictures.append(pictureData)
//
//        }
//        
//        return self.allPictures.last!
//    }
//    
    func extractPictureJSON(json: JSON, res: Resolution) -> (height: CGFloat, width: CGFloat, url: String, res: Resolution) {
        
        var height: CGFloat!
        var width: CGFloat!
        var url: String!
        
        switch res {
        case .low:
            height = CGFloat(json["images"]["low_resolution"]["height"].floatValue)
            width = CGFloat(json["images"]["low_resolution"]["width"].floatValue)
            url =  json["images"]["low_resolution"]["url"].stringValue
        case .standard:
            height = CGFloat(json["images"]["standard_resolution"]["height"].floatValue)
            width = CGFloat(json["images"]["standard_resolution"]["width"].floatValue)
            url =  json["images"]["standard_resolution"]["url"].stringValue
        case .thumbnail:
            height = CGFloat(json["images"]["thumbnail"]["height"].floatValue)
            width = CGFloat(json["images"]["thumbnail"]["width"].floatValue)
            url =  json["images"]["thumbnail"]["url"].stringValue
            
        }
        
        return (height, width, url, res)
    }
}

enum Resolution {
    case low, thumbnail, standard
}

struct PictureData {
    
    var height: CGFloat?
    var width: CGFloat?
    var url: String?
    var resolution: Resolution?
    
}




