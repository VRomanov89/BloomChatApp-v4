//
//  View1.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/19/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class View1: UIView {
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 1).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
