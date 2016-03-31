//
//  ERWalkThroughPageViewController.swift
//  Emeritus
//
//  Created by SB on 17/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
class ERWalkThroughPageViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    var FirstviewController:ERFirstTutorialPageController!
    var secondviewController:ERSecondTutorialPageController!
    var thirdviewController:ERThirdTutorialPageController!
    var FourthViewController:ERFourthTutorialPageController!
    var FifthviewController:ERFifthTutorialPageControlle!
    var currentController:AnyObject!
    //var pageControl:SMPageControl!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        FirstviewController = 	UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERFirstTutorialPageController") as! ERFirstTutorialPageController
        secondviewController = 	UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERSecondTutorialPageController") as! ERSecondTutorialPageController
        thirdviewController = 	UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERThirdTutorialPageController") as! ERThirdTutorialPageController
        FourthViewController = 	UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERFourthTutorialPageController") as! ERFourthTutorialPageController
        FifthviewController = 	UIStoryboard(name: "WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERFifthTutorialPageControlle") as! ERFifthTutorialPageControlle
        
        let viewControllers: NSArray = [FirstviewController]
        self.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        self.doubleSided = false
        self.dataSource=self
        self.delegate=self
        self.view.backgroundColor=UIColor.clearColor()
        
        //        self.pageIndicatorImage=UIImage(named:"unselected_dot_white.png")
        //        self.currentPageIndicatorImage=UIImage(named:"selected_dot_white.png")
        
        //        pageControl=SMPageControl()
        //        pageControl.frame = CGRectMake(self.view.frame.size.width/2-100/2,self.view.frame.size.height-(20+30),100,20);
        //        pageControl.numberOfPages = 5;
        //        pageControl.currentPage = 0;
        //        pageControl.backgroundColor=UIColor.clearColor()
        //
        //        pageControl.pageIndicatorImage=UIImage(named:"unselected_dot_white.png")
        //        pageControl.currentPageIndicatorImage=UIImage(named:"selected_dot_white.png")
        //        self.view.addSubview(pageControl)
        //        self.view.bringSubviewToFront(pageControl)
        
        //        [self.view setBackgroundColor:[UIColor blackColor]];
        NSUserDefaults.standardUserDefaults().setObject("NO", forKey:"WalkThoughStatus")
        NSUserDefaults.standardUserDefaults().synchronize()
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
    
    //    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    //        return 5
    //    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var beforeViewController:UIViewController!
        
        if (viewController.isKindOfClass(ERSecondTutorialPageController)) {
            
            beforeViewController=FirstviewController
        }
        else if (viewController.isKindOfClass(ERThirdTutorialPageController)) {
            
            beforeViewController=secondviewController
        }
        else if (viewController.isKindOfClass(ERFourthTutorialPageController)) {
            
            beforeViewController=thirdviewController
        }
        else if (viewController.isKindOfClass(ERFifthTutorialPageControlle))
        {
            beforeViewController=FourthViewController
            
        }
        //        currentController=beforeViewController
        //        if let vc=beforeViewController
        //        {
        //        self.setIndexByController(beforeViewController)
        //        }
        
        return beforeViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        
        var afterViewController:UIViewController!
        if (viewController.isKindOfClass(ERFirstTutorialPageController)) {
            
            afterViewController=secondviewController
            
        }
        else if (viewController.isKindOfClass(ERSecondTutorialPageController)) {
            
            afterViewController=thirdviewController
        }
        else if (viewController.isKindOfClass(ERThirdTutorialPageController)) {
            
            afterViewController=FourthViewController
        }
        else if (viewController.isKindOfClass(ERFourthTutorialPageController)) {
            
            afterViewController=FifthviewController
        }
        //        currentController=afterViewController
        //        if let vc=afterViewController
        //        {
        //        self.setIndexByController(afterViewController)
        //        }
        return afterViewController
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed
        {
            //print("doe..")
            //            var arrVC=previousViewControllers
            //            var viewcontroller:UIViewController!=arrVC.last as! UIViewController
            //            if let vc=currentController as? UIViewController
            //            {
            //                var viewcontroller:UIViewController!=currentController as! UIViewController
            //                if (viewcontroller.isKindOfClass(ERFirstTutorialPageController)) {
            //
            //                    pageControl.currentPage=0
            //
            //                }
            //                else if (viewcontroller.isKindOfClass(ERSecondTutorialPageController))
            //                {
            //                    pageControl.currentPage=1
            //                }
            //                else if (viewcontroller.isKindOfClass(ERThirdTutorialPageController))
            //                {
            //                    pageControl.currentPage=2
            //                }
            //                else if (viewcontroller.isKindOfClass(ERFourthTutorialPageController))
            //                {
            //                    pageControl.currentPage=3
            //                }
            //                else if (viewcontroller.isKindOfClass(ERFifthTutorialPageControlle))
            //                {
            //                    pageControl.currentPage=4
            //                }
            //            }
        }
        
    }
    
    func setIndexByController(ctrl:UIViewController)
    {
        //        if let vc=ctrl as? UIViewController
        //        {
        //            var viewcontroller:UIViewController!=vc
        //            if (viewcontroller.isKindOfClass(ERFirstTutorialPageController)) {
        //
        //                pageControl.currentPage=0
        //
        //            }
        //            else if (viewcontroller.isKindOfClass(ERSecondTutorialPageController))
        //            {
        //                pageControl.currentPage=1
        //            }
        //            else if (viewcontroller.isKindOfClass(ERThirdTutorialPageController))
        //            {
        //                pageControl.currentPage=2
        //                //pageControl.currentPage=1
        //            }
        //            else if (viewcontroller.isKindOfClass(ERFourthTutorialPageController))
        //            {
        //                pageControl.currentPage=3
        //            }
        //            else if (viewcontroller.isKindOfClass(ERFifthTutorialPageControlle))
        //            {
        //                pageControl.currentPage=4
        //            }
        //        }
    }
    
    //    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject])
    //    {
    //        for viewcontroller in pendingViewControllers
    //        {
    //            if (viewcontroller.isKindOfClass(ERFirstTutorialPageController)) {
    //
    //                   pageControl.currentPage=0
    //
    //            }
    //            else if (viewcontroller.isKindOfClass(ERSecondTutorialPageController))
    //            {
    //                 pageControl.currentPage=1
    //            }
    //            else if (viewcontroller.isKindOfClass(ERThirdTutorialPageController))
    //            {
    //                pageControl.currentPage=2
    //            }
    //            else if (viewcontroller.isKindOfClass(ERFourthTutorialPageController))
    //            {
    //                 pageControl.currentPage=3
    //            }
    //            else if (viewcontroller.isKindOfClass(ERFifthTutorialPageControlle))
    //            {
    //                pageControl.currentPage=4
    //            }
    //        }
    //    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}