//
//  AppDelegate.swift
//  Emeritus
//
//  Created by SB on 09/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var homeViewCtrl : HomeTimeLineViewController!
    var arrDelete : NSMutableArray!
    var pollManager:PollManager!
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        AVAudioSession.sharedInstance().requestRecordPermission { (grant:Bool) -> Void in
            if !grant
            {
                let alert = UIAlertView(title: "Info!", message: "EMERITUS is requesting access to the microphone. Please enable it from Settings > Privacy > Microphone.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
        self.window?.backgroundColor=UIColor(red: 239.0/256, green: 239.0/256, blue: 239.0/256, alpha: 1.0)
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("8.0"))
        {
            if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
                let settings = UIUserNotificationSettings(forTypes: [.Badge , .Sound , .Alert], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            }
            else
            {
                let settings = UIUserNotificationSettings(forTypes: [.Badge , .Sound , .Alert], categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            }
        }
        else
        {
            let settings = UIUserNotificationSettings(forTypes: [.Badge , .Sound , .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
        
        // Set Quickblox settings
        // TODO These should be made configurable and picked up from the appropriate config files.
        QBSettings.setAccountKey("qdyvqax7suRj7hgwbx5Z")
        QBSettings.setApiEndpoint("https://apieruditusprod.quickblox.com", chatEndpoint: "chateruditusprod.quickblox.com", forServiceZone: QBConnectionZoneTypeProduction)
        QBSettings.setServiceZone(QBConnectionZoneTypeProduction)
        QBSettings.setApplicationID(4)
        QBSettings.setAuthKey("9hsgpp6aWNyGSzV")
        QBSettings.setAuthSecret("2D-amALh2C8JmtH")
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        [UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated:false)]
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! String=="YES")
            {
                let storyboard : UIStoryboard = UIStoryboard(name: "HomeTimeLine", bundle: nil)
                let homeTimeLineNavigationController:UINavigationController=storyboard.instantiateViewControllerWithIdentifier("HomeTimeLineNavigationController") as! UINavigationController
                let menuViewController:MenuViewController=storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
                menuViewController.homeTimeLineNavigationControllerConst = homeTimeLineNavigationController
                let slideMenuController = SlideMenuController(mainViewController: homeTimeLineNavigationController, leftMenuViewController: menuViewController)
                self.window?.rootViewController = slideMenuController
                self.window?.makeKeyAndVisible()
                let delay = 1.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    
                    self.homeViewCtrl=homeTimeLineNavigationController.viewControllers.first as! HomeTimeLineViewController
                    self.homeViewCtrl.indicatorLabel.text="Authenticating To ChatServer"
                    
                    let userName:String=LoginServices.sharedLogininstance().qbuserName as String
                    let password:String=LoginServices.sharedLogininstance().password as String
                    SessionService.instance().createSession(userName, andPassword:password, withCompletionBlock: { (responseStatus:Bool) -> Void in
                        if(responseStatus==true)
                        {
                            self.homeViewCtrl.indicatorLabel.text="Login To ChatServer"
                            self.gettingHomeFeedResponse()
                            self.homeViewCtrl.hideIndicatorView()
                        }
                        else
                        {
                            self.homeViewCtrl.hideIndicatorView()
                        }
                    })
                })
            }
        }
        
        if(((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus"))) == nil)
        {
            NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"WalkThoughStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        self.arrDelete=NSMutableArray();
        
        return true
    }
    
    func gettingHomeFeedResponse()
    {
        pollManager = PollManager.instance()
        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        if(AFNetworkReachabilityManager.sharedManager().reachable)
        {
            webManager.HomeFeed({ (homeresponseDictionary:NSMutableDictionary!) -> Void in
                if((homeresponseDictionary.objectForKey("status")) as! NSString=="Success")
                {
                    let response:NSDictionary=homeresponseDictionary.objectForKey("response") as! NSDictionary
                    print(response);
                    if let _ = response.objectForKey("dialogList") as? NSMutableArray
                    {
                        cdManager.insertChatItems(response.objectForKey("dialogList") as! NSMutableArray)
                    }
                    else
                    {
                        NSNotificationCenter.defaultCenter().postNotificationName("Homefeed", object: self, userInfo: nil)
                    }
                    
                    if let frozenArray = response.objectForKey("stickyPostList") as? NSMutableArray
                    {
                        
                        FrozenPostManager.sharedDispatchInstance.removeFrozenArray()
                        
                        for (_, element) in frozenArray.enumerate() {
                            let dict = element as! NSDictionary
                            let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                            let frozenPost = FrozenPost.findOrCreateUsersWithIdentifier(dict["id"] as! NSNumber, inContext: cdmanager.childContext)
                            frozenPost.longDesc = dict["longDescription"] as! String
                            frozenPost.shortDesc = dict["shortDescription"] as! String
                            let endDateInterval:NSTimeInterval = NSTimeInterval(dict["endDate"] as! Int)
                            frozenPost.endDate = NSDate(timeIntervalSince1970: endDateInterval)
                            
                            FrozenPostManager.sharedDispatchInstance.arrayFrozen.addObject(frozenPost)
                            
                        }
                        
                        let preCount:Int = FrozenPostManager.sharedDispatchInstance.fronzenPostsPreCounts
                        let curCount:Int = FrozenPostManager.sharedDispatchInstance.getFrozenPostsCount()
                        if( preCount != curCount ){
                            
                            if FrozenPostManager.sharedDispatchInstance.didFrozenPostsAppear == true {
                                
                                FrozenPostManager.sharedDispatchInstance.fronzenPostsPreCounts = curCount
                                FrozenPostManager.sharedDispatchInstance.refreshForzenPosts()
                                
                            }
                            
                        }
                        
                        if let dict = frozenArray.lastObject as? NSDictionary
                        {
                            NSUserDefaults.standardUserDefaults().setObject(dict["shortDescription"], forKey: "shortDescription")
                            NSUserDefaults.standardUserDefaults().setObject(dict["longDescription"], forKey: "longDescription")
                        }
                        else
                        {
                            NSUserDefaults.standardUserDefaults().removeObjectForKey("shortDescription")
                            NSUserDefaults.standardUserDefaults().removeObjectForKey("longDescription")
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName("Homefeed", object: self, userInfo: nil)
                    }
                }
                else
                {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    if(!(homeresponseDictionary.objectForKey("errorMessage")==nil))
                    {
                        alert.message = homeresponseDictionary.objectForKey("errorMessage") as? String
                    }
                    else
                    {
                        alert.message="Invalid response from server"
                    }
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            })
        }
        else
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "No Internet Connectivity"
            alert.addButtonWithTitle("OK")
            //alert.show()
        }
    }
    
    func storeURL() -> NSURL {
        
        var documentsDirectory:NSString
        documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Emeritus.sqlite")
        let fileUrl = NSURL(fileURLWithPath: path)
        
        return fileUrl
    }
    
    func modelURL() -> NSURL {
        
        let path = NSBundle.mainBundle().pathForResource("Emeritus", ofType: "momd")
        let fileUrl = NSURL(fileURLWithPath: path!)
        return fileUrl
    }
    
    func quickbloxsAuthentication()
    {
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! String=="YES")
            {
                LoginServices.sharedLogininstance().fetchFromUserDefaults()
            }
        }
    }
    
    func showingLoginScreen()
    {
        deletingDatabse()
        let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewNavigationController:UINavigationController=storyboard.instantiateViewControllerWithIdentifier("LoginNavigationViewController") as! UINavigationController
        self.window?.rootViewController=loginViewNavigationController
        
    }
    
    /**
     Deleting Database
     */
    func deletingDatabse()
    {
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        
        if(cdManager.deleteDatabase())
        {
            LoginServices.sharedLogininstance().resetUserInfo()
        }
        else
        {
            let alert = UIAlertView()
            alert.title = "Connection Error"
            alert.message = "There was a problem connecting to the server. Please ensure you are connected to the internet."
            alert.addButtonWithTitle("OK")
            //alert.show()
        }
    }
    
    //MARK:- Push Notification Delegate Methods
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        NSUserDefaults.standardUserDefaults().setObject(deviceToken,forKey:"DeviceToken")
        let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let subscription: QBMSubscription! = QBMSubscription()
        
        subscription.notificationChannel = QBMNotificationChannelAPNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            }) { (response: QBResponse!) -> Void in
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        if application.applicationState == UIApplicationState.Inactive{
            let dlgID:NSString = userInfo["dialog_id"] as! NSString
            NSLog("%@", dlgID)
            
            ChatService.instance().strGetedDlgIDFromPush = dlgID as String
            NSLog("%@", ChatService.instance().strGetedDlgIDFromPush)
            NSNotificationCenter.defaultCenter().postNotificationName(kGotoChatRoom, object: self, userInfo: nil)
        }
    }
    
    
    //MARK:- UIApplication Delegate Methods
    
    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! NSString=="YES")
            {
                ChatService.instance().disconnectWithCompletionBlock()
            }
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! NSString=="YES")
            {
                ChatService.instance().connectWithUser()
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! String=="YES")
            {
                ChatService.instance().disconnectWithCompletionBlock()
                ChatService.instance().logout()
            }
        }
    }
    
    func creatingSessionAndLogin()
    {
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")))==nil))
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! String=="YES")
            {
                let activityIndicatorBaseView:UIView=UIView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2-200/2,UIScreen.mainScreen().bounds.size.height/2-100/2, 200, 80))
                activityIndicatorBaseView.backgroundColor=UIColor(red: 31/255.0, green: 160/255.0, blue: 124/255.0, alpha: 1.0)
                let userName:String=LoginServices.sharedLogininstance().qbuserName as String
                let password:String=LoginServices.sharedLogininstance().password as String
                SessionService.instance().createSession(userName, andPassword:password, withCompletionBlock: { (responseStatus:Bool) -> Void in
                    if(responseStatus==true)
                    {
                        self.gettingHomeFeedResponse()
                    }
                    else
                    {
                        //                        let alert = UIAlertView()
                        //                        alert.title = "Alert"
                        //                        alert.message = "Problem while creating session"
                        //                        alert.addButtonWithTitle("OK")
                        //                        alert.show()
                        
                    }
                })
            }
        }
    }
}

