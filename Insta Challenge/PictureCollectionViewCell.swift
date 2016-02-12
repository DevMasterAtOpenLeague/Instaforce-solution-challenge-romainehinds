//
//  PictureCollectionViewCell.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/11/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

class PictureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    var res: Resolution?
    var indexPath: NSIndexPath?
    
    var pictureJSON: SwiftyJSON.JSON? {
        didSet {
            if let res = self.res {
                if let json = self.pictureJSON {
                    let jsonData = self.extractPictureJSON(json, res: res)
                    self.pictureData = PictureData(height: jsonData.height, width: jsonData.width, url: jsonData.url, resolution: jsonData.res, name: "selfie")
                }
            }
        }
    }
    
    var pictureData: PictureData! {
        didSet {
            self.getPicturesInBackground()
        }
    }
    var queue: NSOperationQueue!
    
    func getPicturesInBackground() {
        queue = NSOperationQueue()
        let getPictureOperation = NSBlockOperation(block: {
            self.imageView.hnk_setImageFromURL(NSURL(string: self.pictureData.url!)!, placeholder: nil, format: nil, failure: {
                (error) in
                print("Error loading image: \(error)")
            }, success: {
                (image) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.imageView.image = image
                    self.blurEffectView.hidden = true
                    Picture.pictureInstance.allImages.append(self.imageView.image!)
                    Picture.pictureInstance.addImagePreviewDetails("#selfie", height: Double(self.pictureData.height!), image: self.imageView.image!)
                }
            })
        })

        queue.addOperation(getPictureOperation)
        
    }
    
    func getLargePicturesInBackground(pictureData: PictureData) {
        print("Getting large picture in background.")
        queue = NSOperationQueue()
        let getPictureOperation = NSBlockOperation(block: {

            self.imageView.hnk_setImageFromURL(NSURL(string: pictureData.url!)!, placeholder: nil, format: nil, failure: {
                (error) in
                print("Error loading image: \(error)")
                }, success: {
                    (image) in
                    print("Adding LargeImageDetails")
                    Picture.pictureInstance.addLargeImagePreviewDetails("#selfie", height: Double(self.pictureData.height!), image: image)
            })
        })
        queue.addOperation(getPictureOperation)
    }
    
    private func extractPictureJSON(json: SwiftyJSON.JSON, res: Resolution) -> (height: CGFloat, width: CGFloat, url: String, res: Resolution) {
        
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

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? InstaLayoutAttributes {
            imageHeightConstraint.constant = attributes.photoHeight
        }
    }
}

@IBDesignable
class RoundedBlurEffectView: UIVisualEffectView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    
}