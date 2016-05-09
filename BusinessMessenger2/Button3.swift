//
//  Button3.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/20/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class Button3: UIButton {
    override func awakeFromNib() {
        //Create the rounded sides of the button by dividing the height of the object by 2.
        //layer.cornerRadius = self.frame.size.height / 2
        //Create the background color (RGB: 0/0/0) - BLACK
        layer.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).CGColor
        //Create a shadow for the button.
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        //Create a border for the button.
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 19/255, green: 82/255, blue: 226/255, alpha: 1).CGColor

        
        //Set the color of the text to white in Normal state. (RGB: 255/255/255) - WHITE
        self.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), forState: UIControlState.Normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
}
