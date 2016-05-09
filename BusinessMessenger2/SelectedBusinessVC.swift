//
//  SelectedBusinessVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/20/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class SelectedBusinessVC: UIViewController {
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessAddressLabel: UILabel!
    
    var placesID = String()
    var businessName = String()
    var businessAddress = String()
    var businessPlaceID = String()
    var businessType = String()
    var newConvoID = String()
    
    @IBAction func startConversationButton(sender: UIButton) {
        var newConvoRequired = true
        for (convo, business) in userCurrentConversations {
            if business == self.businessPlaceID {
                newConvoID = convo
                newConvoRequired = false
            }
        }
        
        
        
        if newConvoRequired == false {
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }else {
            // Assuming the business does not exist yet!!! Will need to come back and create a verification.
            
            var newBusinessID = createNewBusinessListing()
            
            
            var newConvoID = createConversation(newBusinessID)
            //2. IF the above ID is created successfully, create a reference to the conversation on the user & business side.
            if newConvoID != "" && "\(newBusinessID)" != "" {
                //Add a conversation reference from the user.
                let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
                firebaseNewUserConvo.setValue(true)
                //Add a conversation reference from the business.
                let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("\(newBusinessID)").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
                firebaseNewBusinessConvo.setValue(true)
                self.newConvoID = newConvoID
                performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
            }else{
                print("Something went wrong... Failed to create conversation!")
            }
        }
        
    }
    
    func createNewBusinessListing() -> String {
        let business: Dictionary<String, AnyObject> = [
            "title": self.businessName,
            "description": self.businessAddress,
            "PlaceID": self.businessPlaceID,
            "type": self.businessType
        ]
        let firebaseText = DataService.ds.REF_BusinessListing.childByAutoId()
        firebaseText.setValue(business)
        var postId = firebaseText.key
        
        if postId != nil {
            return postId
        } else {
            return ""
        }
    }
    
    func createConversation(to: String) -> String {
        let conversation: Dictionary<String, AnyObject> = [
            "to": to,
            "from": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
        ]
        let firebaseText = DataService.ds.REF_CONVOS.childByAutoId()
        firebaseText.setValue(conversation)
        var postId = firebaseText.key
        
        if postId != nil {
            return postId
        } else {
            return ""
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Dictionary which holds ConversationID:BusinessID! Required to see if the user already has a conversation with the current business!
    var userCurrentConversations = [String:String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        businessNameLabel.text = businessName
        businessAddressLabel.text = businessAddress
        updateUserCurrentConversations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUserCurrentConversations() {
        DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.ChildAdded, withBlock: {snapshot in
            // snapshot.key holds the ID of a conversation at this point.
            // We need to retrieve the associated businesslisting with this conversation!
            let firebaseUserConvos = DataService.ds.REF_CONVOS.childByAppendingPath("\(snapshot.key)").observeEventType(.Value, withBlock: {snapshot2 in
                //print("ID: \(snapshot2.value.objectForKey("to")!)")
                if let businessIDpotential = snapshot2.value.objectForKey("to") {
                    self.userCurrentConversations[snapshot.key] = "\(businessIDpotential as! String)"
                }
            })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "currentConvoFromBusiness") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = newConvoID
            chatVc.convoTitle = businessName
        }
    }
}
