//
//  TextField1.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/19/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit
import QuartzCore

class TextField1: UITextField {
    
    override func awakeFromNib() {
        // Alight Placeholder and entered text to the left.
        self.textAlignment = NSTextAlignment.Left
        //Create the text color (RGB: 0/0/0) - BLACK
        self.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        print("\(self.frame.size.height)")
        
        
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, self.frame.size.height-1, self.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        self.layer.addSublayer(bottomBorder)
        self.layer.masksToBounds = true
    }
    
    
}