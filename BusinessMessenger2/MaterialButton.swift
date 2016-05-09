//
//  MaterialButton.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 12/22/15.
//  Copyright © 2015 EEEnthusiast. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        self.titleLabel?.textAlignment = NSTextAlignment.Center //Aligns the content of the button.
    }


}
