//
//  PrivacyPolicyViewController.swift
//  Emeritus
//
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation

class PrivacyPolicyViewController: UIViewController {
    @IBOutlet weak var privacyDescriptionLabel: UILabel!
    
    @IBAction func goToPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://privacy.emeritus.org")!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
    }
    
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
    }
}
