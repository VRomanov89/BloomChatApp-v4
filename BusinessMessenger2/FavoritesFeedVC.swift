//
//  FavoritesFeedVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/6/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase

class FavoritesFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteListings = [FavoriteListing]()
    var favoriteKeys = [String]()
    var newConvoID = String()
    var userConvosBusinessIDs = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Call function which updtes current user conversations. Used to see if a new conversation is needed when the user selects a business.
        convoExists()
        
        //This call is made to retrieve the current "Favorites" of the user.
        DataService.ds.REF_USERS_Current.childByAppendingPath("favorites").observeEventType(.Value, withBlock: {snapshot in
            //print(snapshot.value)
            self.favoriteKeys.removeAll()
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    //print(snap.key)
                    //This call is made on the keys of the favorites retrieved in snapshot.
                    self.favoriteKeys.append(snap.key)
                }
            }
            self.updateBusinesses()
        })
        
        
    }
    
    func updateBusinesses() {
        DataService.ds.REF_BusinessListing.observeEventType(.Value, withBlock: {snapshot2 in
            //print(snapshot2.value)
            self.favoriteListings = []
            if let snapshots = snapshot2.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    
                    for eachKey in self.favoriteKeys {
                        if eachKey == snap.key {
                            if let businessDict = snap.value as? Dictionary<String, AnyObject> {
                                //print(snap.value)
                                let key = snap.key
                                let post = FavoriteListing(businessKey: key, dictionary: businessDict)
                                self.favoriteListings.append(post)
                            }
                        }
                    }
                    // Going into the children of the main object for the business.
                    
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorite = favoriteListings[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteCell") as? FavoriteCell {
            cell.request?.cancel() //Cancel the request if scrolling.
            
            var img: UIImage? //Creating an "empty" img.
            
            //Verify that Image Url exists. If not, don't do anything. Else, check the cache.
            //print("\(favorite.businessDescription)")
            if let url = favorite.businessImageUrl {
                img = FeedBus.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(favorite, img: img) //Passes the img.
            return cell
        } else {
            return FavoriteCell()
        }
        return tableView.dequeueReusableCellWithIdentifier("FavoriteCell") as! BusCell
        self.tableView.reloadData()
    }
    
    // This function is called when a row is selected.
    // Current Functionality: Start conversation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        //01. Need to verify if convo already exists!!!
        var newConvoID = ""
        var newConvoRequired = true
        
        for businessID in userConvosBusinessIDs.keys {
            //print("id: \(businessID)")
            if businessID == favoriteListings[(tableView.indexPathForSelectedRow?.row)!].businessKey {
                //print("corrent!")
                if newConvoRequired == true {
                    self.newConvoID = userConvosBusinessIDs[businessID]!
                    newConvoRequired = false
                }
            }
        }
        //1. Create a new conversation
        if newConvoRequired == false {
            performSegueWithIdentifier("currentConvoFromBusiness", sender: self)
        }else {        //1. Create a new conversation
        let newConvoID = createConversation(favoriteListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)
        
        //2. IF the above ID is created successfully, create a reference to the conversation on the user & business side.
        if newConvoID != "" && "\(favoriteListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)" != "" {
            //Add a conversation reference from the user.
            //print("check1")
            let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewUserConvo.setValue(true)
            //print("check2")
            //Add a conversation reference from the business.
            let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("\(favoriteListings[(tableView.indexPathForSelectedRow?.row)!].businessKey)").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
            firebaseNewBusinessConvo.setValue(true)
            //print("check3")
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
        let firebaseUserConvos = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.ChildAdded, withBlock: {snapshot in
            let firebaseUserConvos = DataService.ds.REF_CONVOS.childByAppendingPath("\(snapshot.key)").observeEventType(.Value, withBlock: {snapshot2 in
                if let businessIDpotential = snapshot2.value.objectForKey("to") {
                    self.userConvosBusinessIDs[businessIDpotential as! String] = "\(snapshot.key)"
                }
            })
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "currentConvoFromBusiness") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
            //DataService.ds.USER_ID // 3
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = newConvoID
            chatVc.convoTitle = favoriteListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle
            //print("\(convoListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle!)")
        }
    }
    
    // Handle the swipe & delete row functionality.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //REMOVE Rirebase reference from user - NOTE: Important to do before removing from table; otherwise values don't match.
            let addBusines = DataService.ds.REF_USERS_Current.childByAppendingPath("favorites").childByAppendingPath("\(favoriteListings[indexPath.row].businessKey)")
            addBusines.removeValue()
            // Delete the row from the data source
            favoriteListings.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


}
