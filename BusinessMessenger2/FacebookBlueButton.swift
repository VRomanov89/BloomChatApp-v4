//
//  FacebookBlueButton.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/26/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class FacebookBlueButton: UIButton {
    override func awakeFromNib() {
        //Create the rounded sides of the button by dividing the height of the object by 2.
        layer.cornerRadius = 10
        //Create the background color (RGB: 19/82/205) - BLUE 3B5998 (59, 89, 152)
        layer.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1).CGColor
        //Create a shadow for the button.
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        //Create a border for the button. (RGB: 19/82/205) - BLUE
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 19/255, green: 82/255, blue: 226/255, alpha: 1).CGColor
        //layer.
        
        //Set the color of the text to white in Normal state. (RGB: 10/70/205) - BLUE
        self.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), forState: UIControlState.Normal)
        //self.imageEdgeInsets =
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
