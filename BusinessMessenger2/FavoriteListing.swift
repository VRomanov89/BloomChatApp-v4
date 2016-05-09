//
//  FavoriteListing.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/7/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import Foundation

class FavoriteListing{
    private var _businessDescription: String! // Description for the business
    private var _businessImageUrl: String? // Image URL for the business (OPTIONAL)
    private var _businessTitle: String! // Title for the business
    private var _businessAddress: String? // Address of the business
    private var _businessKey: String! // Description for the business
    
    var businessDescription: String? {
        return _businessDescription
    }
    
    var businessImageUrl: String? {
        return _businessImageUrl
    }
    
    var businessTitle: String {
        return _businessTitle
    }
    
    var businessAddress: String? {
        return _businessAddress
    }
    
    var businessKey: String {
        return _businessKey
    }
    
    init (businessDescription: String, businessImageUrl: String?, businessTitle: String, businessAddress: String?) {
        self._businessDescription = businessDescription
        self._businessImageUrl = businessImageUrl
        self._businessTitle = businessTitle
        self._businessAddress = businessAddress
    }
    
    init (businessKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._businessKey = businessKey
        
        if let businessImageUrl = dictionary["imageUrl"] as? String {
            self._businessImageUrl = businessImageUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._businessDescription = desc
        }
        
        if let title = dictionary["title"] as? String {
            self._businessTitle = title
        }
        
        if let address = dictionary["address"] as? String {
            self._businessAddress = address
        }
    }
    
}