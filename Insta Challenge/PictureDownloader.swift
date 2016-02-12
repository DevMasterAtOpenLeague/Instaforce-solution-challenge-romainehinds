//
//  PictureDownloader.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/12/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import Foundation
import UIKit
import Haneke

class PictureDownloader {
    
    var picturesData: [PictureData]
    var imageDetails: [ImagePreviewDetail]
    private let queue = NSOperationQueue()
    private var opsArray = [NSBlockOperation]()
    var done: Bool
    
    
    init(data: [PictureData]){
        print("Downloader given PictureData: \(data)")
        self.picturesData = data
        self.done = false
        self.imageDetails = [ImagePreviewDetail]()
        queue.addOperationWithBlock{
            self.fetchImages()
        }
    }
    
    func fetchImages() {
        let cache = Shared.imageCache
        
        for data in self.picturesData {
            let url = NSURL(string: data.url!)
            let fetcher = NetworkFetcher<UIImage>(URL: url!)
            cache.fetch(fetcher: fetcher).onSuccess({
                image in
                let details = ImagePreviewDetail(title: data.name!, preferredHeight: Double(data.height!), image: image)
                self.imageDetails.append(details)
            })
        }
        
        print("Done fetching images: \(self.imageDetails)")
    }
    
    func downloadImages() {
        
        var opsArray = [NSBlockOperation]()
        
        for data in self.picturesData {
            
            let operation = NSBlockOperation {
                
                let imageView = UIImageView(image: UIImage(named: "loading"))
                print("Downloader will get image from URL: \(data.url!)")
                imageView.hnk_setImageFromURL(NSURL(string: data.url!)!)
                let details = ImagePreviewDetail(title: "#selfie", preferredHeight: Double(data.height!), image: imageView.image!)
                self.imageDetails.append(details)
                
                
            }
            
            opsArray.append(operation)
        }
        
        
        
        for ops in opsArray {
            queue.addOperation(ops)
        }
    }
}
