//
//  ERWalkThroughPage.swift
//  Emeritus
//
//  Created by SB on 17/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

class ERWalkThroughPage: UIViewController{
    
    var pageViewController:ERWalkThroughPageViewController!
    @IBOutlet weak var PagecontainerView: UIView!
    var centeredImages:NSMutableArray=["classDiscussion.png","classchat.png","poll.png","participants.png"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController=UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
        pageViewController.view.frame=CGRectMake(PagecontainerView.frame.origin.x, 0, PagecontainerView.frame.size.width, PagecontainerView.frame.size.height)
        PagecontainerView.addSubview(pageViewController.view);
        
        [UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated:false)]
        
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        //
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
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
