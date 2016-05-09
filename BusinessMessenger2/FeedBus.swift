//
//  FeedBus.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 12/31/15.
//  Copyright © 2015 EEEnthusiast. All rights reserved.
//
// TO DO LIST
// 1. Email verification - User Firebase (-8 = no account, -5
// 2. Password verification
// DONE 3. Keyboard closure
//

import UIKit
import Firebase

class FeedBus: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var businessListings = [BusinessListing]()
    static var imageCache = NSCache()
    
    var newConvoID = String()
    var convoIDfound = String()
    
    var userConvosBusinessIDs = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the background color of the Navigation Bar to Black.
        self.tabBarController?.tabBar.barTintColor = UIColor.blackColor()
        
        // Call function which updtes current user conversations. Used to see if a new conversation is needed when the user selects a business.
        convoExists()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.placeholder = "Search for your favorite stores, restaurants ,etc."
        
        //Listen to ANY Firebase changes.
        DataService.ds.REF_BusinessListing.observeEventType(.Value, withBlock: {snapshot in
            
            self.businessListings = []
            //Data parsing from Firebase. The goal is to breakdown the data received and store in a local model.
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    
                    // Going into the children of the main object for the business.
                    if let businessDict = snap.value as? Dictionary<String, AnyObject> {
                        //print(snap.value)
                        let key = snap.key
                        let post = BusinessListing(businessKey: key, dictionary: businessDict)
                        self.businessListings.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let listing = businessListings[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("BusCell") as? BusCell {
            cell.request?.cancel() //Cancel the request if scrolling.
            
            var img: UIImage? //Creating an "empty" img.
            
            //Verify that Image Url exists. If not, don't do anything. Else, check the cache.
            //print("\(listing.businessImageUrl)")
            if let url = listing.businessImageUrl {
                img = FeedBus.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(listing, img: img) //Passes the img.
            return cell
        } else {
            return BusCell()
        }
        return tableView.dequeueReusableCellWithIdentifier("BusCell") as! BusCell
        self.tableView.reloadData()
    }
    
    // This function is called when a row is selected.
    // Current Functionality: Start conversation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        //01. Need to verify if convo already exists!!!
        print(userConvosBusinessIDs)
        var newConvoID = ""
        var newConvoRequired = true
        
        for businessID in userConvosBusinessIDs.keys {
            print("id: \(businessID)")
            if businessID == businessListings[(tableView.indexPathForSelectedRow?.row)!].businessKey {
                print("corrent!")
                if newConvoRequired == true {
                    self.newConvoID = userConvosBusinessIDs[businessID]!
                    newConvoRequired = false
                }
            }
        }
        //1. Create a new conversation
        if newConvoRequired == false {
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }else {
        newConvoID = createConversation(businessListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)
        //2. IF the above ID is created successfully, create a reference to the conversation on the user & business side.
        if newConvoID != "" && "\(businessListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)" != "" {
            //Add a conversation reference from the user.
            print("check1")
            let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewUserConvo.setValue("true")
            print("check2")
            //Add a conversation reference from the business.
            let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("\(businessListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewBusinessConvo.setValue("true")
            print("check3")
            self.newConvoID = newConvoID
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }else{
            print("Something went wrong... Failed to create conversation!")
        }
        }
    }
    
    
    //This function creates a new conversation based on the business reference and returns the ID. If it fals, it returns an empty string ("")
    func createConversation(to: String) -> String {
        let conversation: Dictionary<String, AnyObject> = [
            "to": to,
            "from": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
            "timestamp": FirebaseServerValue.timestamp()
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
    
    
    
    // Need to implement to see if the conversation already exists.
    func convoExists () {
        //print(businessID)
        //self.convoIDfound = ""
        let firebaseUserConvos = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.ChildAdded, withBlock: {snapshot in
            //print(snapshot.key)
            let firebaseUserConvos = DataService.ds.REF_CONVOS.childByAppendingPath("\(snapshot.key)").observeEventType(.Value, withBlock: {snapshot2 in
                //print("ID: \(snapshot2.value.objectForKey("to")!)")
                if let businessIDpotential = snapshot2.value.objectForKey("to") {
                    self.userConvosBusinessIDs[businessIDpotential as! String] = "\(snapshot.key)"
                }
            })
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let convoKeyArray = ["test1","test2", "test3"]
        //print("\(convoKeyArray[0])")
        //let destination = segue.destinationViewController as? MessagesFeedVC
        //destination!.convoID = convoKeyArray[(tableView.indexPathForSelectedRow?.row)!]
        if (segue.identifier == "currentConvoFromBusiness") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            //DataService.ds.USER_ID // 3
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = newConvoID
            chatVc.convoTitle = businessListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle
            //print("\(convoListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle!)")
        }
    }


}
