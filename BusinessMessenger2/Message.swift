//
//  Message.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/14/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import Foundation

class Message {
    
    //STRING (MANDATORY) - Content of the message
    private var _messageContent: String!
    
    //STRING (MANDATORY) - ID of the sender of the message
    private var _messageSender: String!
    
    private var _messageCellAlignment: Bool!
    
    
    var messageContent: String {
        return _messageContent
    }
    
    var messageSender: String {
        return _messageSender
    }
    
    var messageCellAlignment: Bool {
        return _messageCellAlignment
    }
    
    init(messageContent: String, messageSender: String) {
        self._messageContent = messageContent
        self._messageSender = messageSender
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let content = dictionary["content"] as? String {
            self._messageContent = content
        }
        
        if let sender = dictionary["sender"] as? String {
            self._messageSender = sender
            if sender == NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String {
                self._messageCellAlignment = true
            }else{
                self._messageCellAlignment = false
            }
        }
    }
}