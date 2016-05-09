//
//  FeedMessages.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/1/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import Firebase
//import Alamofire

class FeedMessages: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // TableView - Displays the messages.
    @IBOutlet weak var tableView: UITableView!
    
    // Field - TextField for entering new messages.
    @IBOutlet weak var messageField: UITextField!
    
    // Constraint - constraint which pins the bottom text field to the view.
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // BUTTON - "Send" Message to Firebase.
    @IBAction func sendMessageButton(sender: AnyObject) {
        if let txt = messageField.text where txt != "" {
            self.messageToFirebase()
        }
    }
    var messages = [Message]()
    
    var convoID = String() // This string receives the conversation ID which is needed to retrieve current messages.

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.messageField.delegate = self// Required to hide keyboard on "Return" key press
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard") // Recognize a screen tap in order to hide keyboard.
        

        // Retrieve messages.
        DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").childByAppendingPath("messages").observeEventType(.Value, withBlock: {snapshot in
            //print(snapshot.value)
            self.messages = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    //print("\(snap)")
                    if let messageDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        print("\(key)")
                        let message = Message(dictionary: messageDict)
                        self.messages.append(message)
                    }
                }
            }
            
            self.tableView.reloadData() //Once new messages are retrieved, rebuild the table.
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        //print(message.messageContent)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as? MessageCell {
            cell.configureCell(message)
            return cell
        } else {
            return MessageCell()
        }
    }
    
    //Function which hides the keyboard on "Return" key press.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Function which hides keyboard on external key press
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Function which should bring the text field above the keyboard.
    // NOT WORKING - 2/14/2016
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    // This function will create a message on the Firebase side based on what the user has entered.
    // Generated: Unique ID (sutomatically), "content" - the content of the message, "sender" - the ID of the user.
    func messageToFirebase(){
        var text: Dictionary<String, AnyObject> = [
            "content": messageField.text!,
            "sender": NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String,
            "timestamp": FirebaseServerValue.timestamp()
        ]
        
        let firebaseText = DataService.ds.REF_CONVOS.childByAppendingPath("\(convoID)").childByAppendingPath("messages").childByAutoId()
        firebaseText.setValue(text)
        messageField.text = ""
    }
}
