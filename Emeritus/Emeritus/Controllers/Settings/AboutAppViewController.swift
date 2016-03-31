//
//  AboutAppViewController.swift
//  Emeritus
//
//  Created by SB on 11/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation

class AboutAppViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appDescriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        
        //appDescriptionLabel.text = "Emeritus Institute of Management is a consortium of three global business schools: Columbia Business School, MIT Sloan a school of Management and the Tuck School of Business at Dartmouth. Emeritus was formed to address the learning and development needs of emerging leaders in global, high growth markets like Asia Pacific, Middle East, India & China. Emeritus Institute of Management is based in Singapore. Apart from Singapore, it will have a footprint in Boston, Mumbai and Dubai and will expand to China and other markets."
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
    }
}
