//
//  ConvoListing.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 1/2/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import Foundation
import UIKit


// This class is used to define the "Conversations" Tab of the application. Currently, each row has the following:
// 1. Image of the business with which you are chatting.
// 2. Title of the business with which you are chatting.
// 3. Most recent message sent/received in the conversation.
class ConvoListing{
    private var _convoKey: String! // Conversation Key
    private var _imageUrl: String? // 2. Title of the business with which you are chatting.
    private var _businessTitle: String? // 2. Title of the business with which you are chatting.
    private var _businessType: String?
    private var _newestMessage: String? // 3. Most recent message sent/received in the conversation.
    private var _newestMessageTimestam: Int?
    private var _newestMessageTimestamp2: NSDate?
    
    var convoKey: String {
        return _convoKey
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var businessTitle: String? {
        return _businessTitle
    }
    
    var businessType: String? {
        return _businessType
    }
    
    var newestMessage: String? {
        return _newestMessage
    }
    
    var newestMessageTimestamp: Int? {
        return _newestMessageTimestam
    }
    
    var newestMessageTimestamp2: NSDate? {
        return _newestMessageTimestamp2
    }

    
    init (imageUrl: String?, businessTitle: String) {
        //self._imageUrl = imageUrl
        //self._businessTitle = businessTitle
        
    }
    
    init (convoKey: String, dictionary: Dictionary<String, AnyObject>, businessName: String) {
        self._convoKey = convoKey
        if let messages = dictionary["messages"] as? Dictionary<String, AnyObject> {
            for message in messages {
                if message.1["timestamp"]! != nil {
                    let mymessage = message.1["timestamp"]!! as! Int
                    if newestMessageTimestamp < mymessage{
                        self._newestMessageTimestam = mymessage
                        self._newestMessage = message.1["content"] as? String
                        let date2 = NSDate(timeIntervalSince1970: (message.1["timestamp"] as! NSTimeInterval)/1000)
                        self._newestMessageTimestamp2 = date2
                    }
                    
                }
                if message.1["timestamp"] != nil {
                }
            }
        }
    }
    
    internal func setTitle(businessName:String) {
        self._businessTitle = "\(businessName)"
    }
    
    internal func setImageUrl(imgUrl:String?) {
        self._imageUrl = "\(imgUrl)"
    }
    
    internal func setType(businessName:String) {
        self._businessType = "\(businessName)"
        print("\(businessName)")
    }
}