//
//  InstaLayout.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/12/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import Foundation
import UIKit

struct Movable {
    var offset : CGPoint = CGPointZero
    var sourceCell : UICollectionViewCell
    var representationImageView : UIView
    var currentIndexPath : NSIndexPath
}

protocol InstaLayoutDelegate {
    
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth:CGFloat) -> CGFloat
    func photoSize() -> (width: CGFloat, height: CGFloat)
    
}

class InstaLayoutAttributes:UICollectionViewLayoutAttributes {
    
    
    var photoHeight: CGFloat = 0.0
    
    // Override copyWithZone to conform to NSCopying protocol
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! InstaLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    // Override isEqual
    override func isEqual(object: AnyObject?) -> Bool {
        if let attributtes = object as? InstaLayoutAttributes {
            if( attributtes.photoHeight == photoHeight  ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class InstaLayout: UICollectionViewLayout {
    
    var delegate:InstaLayoutDelegate!
    
    //properties
    var numberOfColumns = 2
    var cellPadding: CGFloat = 6.0
    var bundle: Movable?
    
    
    //Array to keep a cache of attributes.
    private var cache = [InstaLayoutAttributes]()
    
    //Content height and size
    private var contentHeight:CGFloat  = 0.0
    private var contentWidth: CGFloat {
//        let insets = collectionView!.contentInset
//        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
        return delegate.photoSize().width
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return InstaLayoutAttributes.self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        //Only calculate once
        if cache.isEmpty {
            
            //Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            //Iterates through the list of items in the first section
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                let width = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
                let height = cellPadding +  photoHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                //Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = InstaLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                //Updates the collection view content height
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        }
    }
    
    
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        //Loop through the cache and look for items in the rect
        for attributes  in cache {
            if CGRectIntersectsRect(attributes.frame, rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}


    

