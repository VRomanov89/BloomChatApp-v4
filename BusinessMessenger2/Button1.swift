//
//  Button1.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/19/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import QuartzCore

class Button1: UIButton {
    override func awakeFromNib() {
        //Create the rounded sides of the button by dividing the height of the object by 2.
        layer.cornerRadius = 10
        //Create the background color (RGB: 34/192/100) - GREEN 22C064 (34, 192, 100)
        layer.backgroundColor = UIColor(red: 34/255, green: 192/255, blue: 100/255, alpha: 1).CGColor
        //Create a shadow for the button.
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
        //Set the color of the text to white in Normal state.
        self.setTitleColor(UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1), forState: UIControlState.Normal)

        
        self.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
