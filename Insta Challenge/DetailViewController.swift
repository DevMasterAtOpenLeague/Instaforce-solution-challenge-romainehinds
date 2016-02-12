//
//  DetailViewController.swift
//  Insta Challenge
//
//  Created by Romaine Hinds on 2/12/16.
//  Copyright © 2016 Romaine Hinds. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // Property to hold the detail item's title.
    var detailItemTitle: String?
    var image: UIImage?
    
    @IBOutlet weak var backgroundBlurEffectView: UIVisualEffectView!
    @IBOutlet weak var detailImageBlurEffectView: RoundedBlurEffectView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Preview action items.
    lazy var previewActions: [UIPreviewActionItem] = {
        func previewActionForTitle(title: String, style: UIPreviewActionStyle = .Default) -> UIPreviewAction {
            return UIPreviewAction(title: title, style: style) { previewAction, viewController in
                guard let detailViewController = viewController as? DetailViewController,
                    item = detailViewController.detailItemTitle else { return }
                
                print("\(previewAction.title) triggered from `DetailViewController` for item: \(item)")
            }
        }
        
        let action1 = previewActionForTitle("Default Action")
        let action2 = previewActionForTitle("Destructive Action", style: .Destructive)
        
        let subAction1 = previewActionForTitle("Sub Action 1")
        let subAction2 = previewActionForTitle("Sub Action 2")
        let groupedActions = UIPreviewActionGroup(title: "Sub Actions…", style: .Default, actions: [subAction1, subAction2] )
        
        return [action1, action2, groupedActions]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Update the user interface for the detail item.
        if let detail = detailItemTitle {
            navigationItem.title = detail
        }
        
        if let image = image {
            self.imageView.image = image
        }
        
        // Set up the detail view's `navigationItem`.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Preview actions
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        return previewActions
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
