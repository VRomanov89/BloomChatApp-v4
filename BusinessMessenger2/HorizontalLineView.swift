//
//  HorizontalLineView.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 3/26/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class HorizontalLineView: UIView {
    
    var lineWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    var lineColor: UIColor = UIColor.grayColor() { didSet { setNeedsDisplay() } }
    
    var lineCenter: CGFloat {
        return bounds.size.height / 2
    }
    
    var lineLength: CGFloat {
        return bounds.size.width
    }
    
    override func drawRect(rect: CGRect) {
        let horizontalPath = UIBezierPath()
        horizontalPath.lineWidth = lineWidth
        horizontalPath.moveToPoint(CGPoint(x: 0, y: lineCenter))
        horizontalPath.addLineToPoint(CGPoint(x: lineLength, y: lineCenter))
        lineColor.set()
        horizontalPath.stroke()
    }
}
