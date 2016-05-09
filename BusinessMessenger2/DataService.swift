//
//  DataService.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 12/22/15.
//  Copyright © 2015 EEEnthusiast. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "businessmessenger2.firebaseIO.com"

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)") // Main Firebase Reference
    private var _REF_BusinessListing = Firebase(url: "\(URL_BASE)/businessListing") // Firebase Reference - Business Listings
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users") // Firebase Reference - Users
    private var _REF_CONVOS = Firebase(url: "\(URL_BASE)/conversations") // Firebase Reference - Conversations
    private var _REF_USERS_Current = Firebase(url: "\(URL_BASE)/users/\(KEY_UID)") // Main Firebase Reference - Current User
    
    private var _USER_ID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
    
    // OLD References
    //private var _REF_CONVOS_Current = Firebase(url: "\(URL_BASE)/users/\(KEY_UID)/conversations")
    //private var _REF_MESSAGES = Firebase(url: "\(URL_BASE)/messages") // Firebase Reference - Messages
    

    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_BusinessListing: Firebase {
        return _REF_BusinessListing
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USERS_Current: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        //print("\(uid)")
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    var REF_CONVOS: Firebase {
        return _REF_CONVOS
    }
    
    var USER_ID: String {
        var user = ""
        if let userID = _USER_ID {
            //return _USER_ID!
            user = _USER_ID!
        }
        return user
    }
    
    /*var REF_Messages: Firebase {
        return _REF_MESSAGES
    }*/
    
    /*var REF_CONVOS_Current: Firebase {
        return _REF_CONVOS_Current
    }*/
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).updateChildValues(user)
    }
    
    func createFirebaseConvo(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}