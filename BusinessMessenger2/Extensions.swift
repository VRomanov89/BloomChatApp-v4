//
//  Extensions.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/21/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}