//
//  ERThirdTutorialPageController.swift
//  Emeritus
//
//  Created by SB on 17/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

class ERThirdTutorialPageController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
    }
    @IBAction func skipButtonAction(sender: AnyObject) {
        
        if(!((NSUserDefaults.standardUserDefaults().objectForKey("ShownFromSettingsForWalkThrough"))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("ShownFromSettingsForWalkThrough")) as! String=="YES")
            {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
        }
        else
        {
            self.dismissViewControllerAnimated(false, completion: nil)
            
            if ((NSUserDefaults.standardUserDefaults().objectForKey("firstRun")) == nil)
            {
                NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "firstRun")
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
    }
    
    func goToHomeViewController()
    {
        let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard : UIStoryboard = UIStoryboard(name: "HomeTimeLine", bundle: nil)
        let homeTimeLineNavigationController:UINavigationController=storyboard.instantiateViewControllerWithIdentifier("HomeTimeLineNavigationController") as! UINavigationController
        let menuViewController:MenuViewController=storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        menuViewController.homeTimeLineNavigationControllerConst = homeTimeLineNavigationController
        let slideMenuController = SlideMenuController(mainViewController: homeTimeLineNavigationController, leftMenuViewController: menuViewController)
        appdelegate.window?.rootViewController = slideMenuController
        appdelegate.window?.makeKeyAndVisible()
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */ 
}
