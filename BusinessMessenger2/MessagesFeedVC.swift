//
//  MessagesFeedVC.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/2/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class MessagesFeedVC: JSQMessagesViewController {
    
    // Array which stores messages of the current conversation.
    var messages = [JSQMessage]()
    
    // Color setting of the incoming and outgoing bubbles.
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    // ConvoID - holds the ID of the current conversation. Used to retrieve messages from Firebase.
    var convoID = String()
    var convoTitle = String()
    var businessID = String()
    var favoritedBusiness = Bool()
    let dateFormatter = NSDateFormatter()
    

    // Cancel button - segue off.
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // START: FAVORITES HANDLING -----------------------------------------------------------
    
    // Favorite button - add current business to favorites.
    @IBAction func favoriteButtonPress(sender: AnyObject) {
        //print("test")
        if favoritedBusiness == false {
            //print("\(businessID)")
            let addBusines = DataService.ds.REF_USERS_Current.childByAppendingPath("favorites").childByAppendingPath("\(businessID)")
            addBusines.setValue(true)
            updateFavorite(true)
            favoritedBusiness = true
        }else {
            let addBusines = DataService.ds.REF_USERS_Current.childByAppendingPath("favorites").childByAppendingPath("\(businessID)")
            addBusines.removeValue()
            updateFavorite(false)
            favoritedBusiness = false
        }
    }
    @IBOutlet weak var favoriteButtonIcon: UIButton!

    func updateFavorite(status: Bool) {
        //print("\(status)")
        if status == true {
            if let image = UIImage(named: "favoriteON.png") {
                //self.favoriteButtonIcon.setImage(image, forState: .Normal)
            }
            favoritedBusiness = true
        }else{
            if let image = UIImage(named: "favoriteOFF.png") {
                //self.favoriteButtonIcon.setImage(image, forState: .Normal)
            }
            favoritedBusiness = false
        }
    }
    
    // END FAVORITES HANDLING -----------------------------------------------------------
    
    // BusinessID retrieval function.
    func getBusinessID() {
        DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").observeEventType(.Value, withBlock: {snapshot in
            if let businessIDtemp = snapshot.value.objectForKey("to") {
                self.businessID = businessIDtemp as! String
                DataService.ds.REF_USERS_Current.childByAppendingPath("favorites").childByAppendingPath("\(self.businessID)").observeEventType(.Value, withBlock: {snapshot in
                    //print("\(snapshot.value)")
                    if snapshot.value is NSNull {
                        self.updateFavorite(false)
                    }else{
                        self.updateFavorite(true)
                    }
                })
            }
        })
        //updateFavorite()
    }


    override func viewDidLoad() {
        //print("\(convoID)")
        super.viewDidLoad()
        testQuery()
        title = convoTitle
        setupBubbles()
        //self.senderId = "test" // 3
        //self.senderDisplayName = ""
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // Update business ID based on convo.
        getBusinessID()
        dateFormatter.dateStyle = .MediumStyle
        
    }
    
    func testQuery() {
        let ref = DataService.ds.REF_BusinessListing
        ref.queryOrderedByKey().queryEqualToValue("BloomChat2")
            .observeEventType(.Value, withBlock: { snapshot in
                
                if snapshot.value is NSNull {
                    // The value is null
                    print("null")
                }else{
                    print(snapshot.value)
                }
            })
    }
    
    //override func viewdidAppea

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
            return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return messages.count
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleGreenColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
            let message = messages[indexPath.item] // 1
            if message.senderId == senderId { // 2
                return outgoingBubbleImageView
            } else { // 3
                return incomingBubbleImageView
            }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
            return nil
    }
    
    func addMessage(id: String, text: String, date: NSDate) {
        let message = JSQMessage(senderId: id, senderDisplayName: "", date: date, text: text)
        messages.append(message)
    }
    
    func addMessage2(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
    }
    
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
                as! JSQMessagesCollectionViewCell
            
            let message = messages[indexPath.item]
            
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
            //print("\(message.date)")
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            var vladsDate = self.dateFormatter.stringFromDate(message.date)
            //cell.cellTopLabel!.text = "\(vladsDate)"
            return cell
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
        senderDisplayName: String!, date: NSDate!) {
            
            let text: Dictionary<String, AnyObject> = [
                "content": text,
                "sender": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
                "timestamp": FirebaseServerValue.timestamp()
            ]
            
            let firebaseText = DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").childByAppendingPath("messages").childByAutoId()
            firebaseText.setValue(text)
            
            // 4
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            JSQSystemSoundPlayer.jsq_playMessageSentAlert()
            
            // 5
            finishSendingMessage()
            
    }
    
    private func observeMessages() {
        // 1
        let messagesQuery = DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").childByAppendingPath("messages")
        // 2
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            // 3
            let id = snapshot.value["sender"] as! String
            //print("\(id)")
            let text = snapshot.value["content"] as! String
            
            if let date = snapshot.value["timestamp"] as? NSTimeInterval {
                //print("\(date/1000)")
                let date2 = NSDate(timeIntervalSince1970: date/1000)
                self.addMessage(id, text: text, date: date2)
            }else{
                self.addMessage2(id, text: text)
            }
            self.finishReceivingMessage()
        }
    }
    
    func dateFromMilliseconds(ms: NSNumber) -> NSDate {
        return NSDate(timeIntervalSince1970:Double(ms) / 1000.0)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        //return NSAttributedString(string:"\(message.date)")
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

}
