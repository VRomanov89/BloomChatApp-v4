//
//  TabBarController1.swift
//  BusinessMessenger2
//
//  Created by Volodymyr Romanov on 2/21/16.
//  Copyright © 2016 EEEnthusiast. All rights reserved.
//

import UIKit

class TabBarController1: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        //self.tabBarController?.tabBar.backgroundColor = UIColor.whiteColor()
        UITabBar.appearance().tintColor = UIColor.redColor()
        
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        self.tabBar.backgroundColor = UIColor.whiteColor()
        
        // Sets the background color of the selected UITabBarItem (using and plain colored UIImage with the width = 1/5 of the tabBar (if you have 5 items) and the height of the tabBar)
        //UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.blueColor(), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        
    }
}
