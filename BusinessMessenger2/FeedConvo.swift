//
//  FeedConvo.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 1/1/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase
var convoListings = [ConvoListing]()

class FeedConvo: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func returnButton(segue:UIStoryboardSegue) {
        
    }
    
    //Dictionary which holds ConversationID:BusinessID! Required to see if the user already has a conversation with the current business!
    //var userCurrentConversations = [String:String]()
    func updateUserCurrentConversations() {
        DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("BloomChat\(DataService.ds.USER_ID)").observeEventType(.Value, withBlock: {snapshot in
            print("\(snapshot.value)")
            if (snapshot.value is NSNull){
                self.createBloomChatConvo()
            }
        })
    }
    
    func createBloomChatConvo(){
        let newConvoID = createConversation("BloomChat\(DataService.ds.USER_ID)")
        let firebaseNewUserConvo = DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
        firebaseNewUserConvo.setValue(true)
        let firebaseNewBusinessConvo = DataService.ds.REF_BusinessListing.childByAppendingPath("BloomChat").childByAppendingPath("conversations").childByAppendingPath("\(newConvoID)")
        firebaseNewBusinessConvo.setValue(true)
        createFirstBCMEssage(newConvoID)
    }
    
    func createConversation(to: String) -> String {
        let conversation: Dictionary<String, AnyObject> = [
            "to": "BloomChat",
            "from": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
        ]
        let firebaseText = DataService.ds.REF_CONVOS.childByAppendingPath("BloomChat\(NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String)")
        firebaseText.setValue(conversation)
        let postId = firebaseText.key
        return postId
    }
    
    func createFirstBCMEssage(convoID: String) {
        let text: Dictionary<String, AnyObject> = [
            "content": "Welcome to BloomChat! Use this conversation to message our team and we will get back to you as soon as possible!",
            "sender": "BloomChat",
            "timestamp": FirebaseServerValue.timestamp()
        ]
        let firebaseText = DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").childByAppendingPath("messages").childByAutoId()
        firebaseText.setValue(text)
    }
    
    var convoListings = [ConvoListing]()
    var convoKeyArray: [String] = []
    static var imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the background color of the Navigation Bar to Black.
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        updateUserCurrentConversations()
        //createBloomChatConvo()

        
        //Set the background of selected image to (RGB: 34/192/100) - GREEN
        let numberOfItems = CGFloat((tabBarController?.tabBar.items!.count)!)
        let tabBarItemSize = CGSize(width: (tabBarController?.tabBar.frame.width)! / numberOfItems, height: (tabBarController?.tabBar.frame.height)!)
        tabBarController?.tabBar.selectionIndicatorImage = UIImage.imageWithColor(UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)

        
        tableView.delegate = self
        tableView.dataSource = self
        var userConvos = [String]()
        var convoBusinessDict = [String: AnyObject]()
        
        // This code filters through the conversations linked to the current user.
        DataService.ds.REF_USERS_Current.childByAppendingPath("conversations").observeEventType(.Value, withBlock: {snapshot in
            userConvos.removeAll()
            //print ("test")
            //print("\(snapshot)")
                if let convos = snapshot.children.allObjects as? [FDataSnapshot] {
                    //print("\(snapshot)")
                    for snap in convos {
                        userConvos.append(snap.key)
                        print("\(snap.key)")
                    }
                }
            self.tableView.reloadData()
        
        // This code retrieves all conversations
        DataService.ds.REF_CONVOS.observeEventType(.Value, withBlock: {snapshot in
            self.convoListings.removeAll()
            self.convoKeyArray.removeAll()
            //print ("test")
            self.convoListings = []
            //Data parsing from Firebase. The goal is to breakdown the data received and store in a local model.
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    for convo in userConvos {
                    // Going into the children of the main object for the conversations.
                        //print("\(snap)")
                        if convo == snap.key {
                            //print(snap.value)
                            //print(snap.value)
                            if let businessDict = snap.value as? Dictionary<String, AnyObject> {
                                
                                let test = businessDict["to"] as? String
                                let key = snap.key
                                self.convoKeyArray.append("\(key)")
                                //print("\(snap.value)")
                                let post = ConvoListing(convoKey: key, dictionary: businessDict, businessName: "test")
                                
                                if test != nil {
                                DataService.ds.REF_BusinessListing.childByAppendingPath(test).childByAppendingPath("title/").observeEventType(.Value, withBlock: { snapshot2 in
                                    if let test3 = snapshot2.value as? String {
                                        post.setTitle(test3)
                                        self.tableView.reloadData()
                                    }
                                })
                                DataService.ds.REF_BusinessListing.childByAppendingPath(test).childByAppendingPath("type/").observeEventType(.Value, withBlock: { snapshot2 in
                                    if let test3 = snapshot2.value as? String {
                                        post.setType(test3)
                                        self.tableView.reloadData()
                                    }
                                })
                                }
                                var test2 = post.newestMessageTimestamp
                                if (businessDict["messages"] != nil) {
                                    self.convoListings.append(post)
                                }
                                
                            }
                        }
                    }
                }
            }
            self.convoListings.sortInPlace({$0.newestMessageTimestamp > $1.newestMessageTimestamp})
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        })
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let convo = convoListings[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("ConvoCell") as? ConvoCell {
            cell.request?.cancel() //Cancel the request if scrolling.
            cell.configureCell(convo)
            return cell
        }else {
            return ConvoCell()
        }
        return tableView.dequeueReusableCellWithIdentifier("ConvoCell") as! ConvoCell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CurrentConvo") {
            let navVc = segue.destinationViewController as! UINavigationController // 1
            let chatVc = navVc.viewControllers.first as! MessagesFeedVC // 2
            print("\(DataService.ds.USER_ID)")
            chatVc.senderId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
                //DataService.ds.USER_ID // 3
            chatVc.senderDisplayName = "" // 4
            chatVc.convoID = convoListings[(tableView.indexPathForSelectedRow?.row)!].convoKey
            chatVc.convoTitle = convoListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle!
            //print("\(convoListings[(tableView.indexPathForSelectedRow?.row)!].businessTitle!)")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        performSegueWithIdentifier("CurrentConvo", sender: self)
    }
}
