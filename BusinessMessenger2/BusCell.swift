//
//  BusCell.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 12/31/15.
//  Copyright © 2015 EEEnthusiast. All rights reserved.
//
// TO DO
// 1. Add functionality to "Start conversation" Button.

import UIKit
import Alamofire
import Firebase

class BusCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var businessAddress: UILabel!
    
    /*@IBAction func convoButton(sender: AnyObject) { // Need to create new convo
        convoRef.observeEventType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                //This means that there is no conversation existing with this business.
            } else {
                
            }
        })
    } */
    
    var listing: BusinessListing!
    var request: Request?
    var convoRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg?.clipsToBounds = true
    }

    func configureCell(listing: BusinessListing, img: UIImage?) {
        self.listing = listing
        convoRef = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath(listing.businessKey)
        //print(listing.businessDescription)
        //print(listing.businessDescription)
        
        self.descText.text = listing.businessDescription
        self.descText.editable = false
        self.descText.selectable = false
        //print(listing.businessTitle)
        self.title.text = "\(listing.businessTitle)"
        
        if listing.businessAddress != nil {
            self.businessAddress.text = listing.businessAddress
        }
        
        //print(listing.businessImageUrl)
        // If there is an image URL.
        if listing.businessImageUrl != nil {
            if img != nil {
                
                self.profileImg.image = img // Use cached image
            } else {
                request = Alamofire.request(.GET, listing.businessImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: {request, response, data, err in
                    if err == nil {
                        //Do if lets if needed!!!
                        let img = UIImage(data: data!)! //Gab image data
                        self.profileImg.image = img
                        FeedBus.imageCache.setObject(img, forKey: self.listing.businessImageUrl!) //Store data to the cache.
                    }
                })
            }
        } else {
            self.profileImg.hidden = true //Hide the image view if there is no URL/image specified for this business.
            self.profileImg.addConstraint(NSLayoutConstraint(item: profileImg, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        }
        convoRef.observeEventType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                //This means that there is no conversation existing with this business.
            } else {
                
            }
        })
    }
}
