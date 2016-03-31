//
//  ViewController.swift
//  Eruditus
//
//  Created by Swathi Tata on 09/12/14.
//  Copyright (c) 2014 Swathi Tata. All rights reserved.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func viewWillAppear(animated: Bool)
  {
   super.viewWillAppear(animated)
    var image:UIImage = UIImage()
    self.navigationController?.navigationBar .setBackgroundImage(image, forBarMetrics:.Default)
    
   }
    @IBAction func settingsbuttonAction(sender: UIButton) {
        let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsStoryBoardID") as! SettingsViewController
        self.navigationController?.pushViewController(settingsViewController, animated: true)

    }
    @IBAction func loginButtonAction(sender: UIButton) {
        let loginViewControllerObj = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LoginStoryBoardID") as! LoginViewController
        self.navigationController?.pushViewController(loginViewControllerObj, animated: true)
    }
    
   
    @IBAction func pollRequest(sender: UIButton)
    {
        let pollViewControllerObj = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollStoryBoardID") as! PollViewController
        self.navigationController?.pushViewController(pollViewControllerObj, animated: true)
    }
   //MARK:- Profile Button Action
    
    @IBAction func profileButtonAction(sender: AnyObject) {
        
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
        
    }
    @IBAction func viewProfileButtonAction(sender: AnyObject) {
        
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }
}

