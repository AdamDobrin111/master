//
//  MenuViewController.swift
//  Emeritus
//
//  Created by code-inspiration 1 on 10/20/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//
import UIKit

class MenuViewController: UIViewController
{
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var SettingsView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var groupView: UIView!
    
    var homeController: HomeTimeLineViewController!
    var homeTimeLineNavigationControllerConst:UINavigationController!
    
    @IBOutlet weak var logoutView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("homeTap:"))
        homeView!.addGestureRecognizer(tapGesture)
        
        let profileGesture = UITapGestureRecognizer(target: self, action: Selector("profileTap:"))
        profileView!.addGestureRecognizer(profileGesture)
        
        let classGesture = UITapGestureRecognizer(target: self, action: Selector("classTap:"))
        classView!.addGestureRecognizer(classGesture)
        
        let circleGesture = UITapGestureRecognizer(target: self, action: Selector("circleTap:"))
        circleView!.addGestureRecognizer(circleGesture)
        
        let groupGesture = UITapGestureRecognizer(target: self, action: Selector("groupTap:"))
        groupView!.addGestureRecognizer(groupGesture)
        
        let settingsGesture = UITapGestureRecognizer(target: self, action: Selector("settingsTap:"))
        SettingsView!.addGestureRecognizer(settingsGesture)
        
        let logoutGesture = UITapGestureRecognizer(target: self, action: Selector("logoutTap:"))
        logoutView!.addGestureRecognizer(logoutGesture)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func homeTap(sender: UIGestureRecognizer)
    {
        let storyboard : UIStoryboard = UIStoryboard(name: "HomeTimeLine", bundle: nil)
        let homeTimeLineNavigationController:UINavigationController=storyboard.instantiateViewControllerWithIdentifier("HomeTimeLineNavigationController") as! UINavigationController
        self.slideMenuController()?.changeMainViewController(homeTimeLineNavigationController, close: true)
        homeTimeLineNavigationControllerConst = homeTimeLineNavigationController
    }
    
    func profileTap(sender: UIGestureRecognizer)
    {
        let SessionUserId:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
        dispatch_async(dispatch_get_main_queue(), {
            
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            let selectedUser:Users=cdManager.viewProfile(NSNumber(integer:SessionUserId.integerValue)) as Users
            
            let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
            profileViewController.selfProfileStatus=true
            profileViewController.userProfileDetails=selectedUser
            let navCont = UINavigationController(rootViewController: profileViewController)
            
            self.slideMenuController()?.changeMainViewController(navCont, close: true)
        })
    }
    
    func classTap(sender: UIGestureRecognizer)
    {
        if let home = self.slideMenuController()!.classData
        {
            
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatViewController.fromMenu = true
            chatViewController.dialogID = home.dialogID
            chatViewController.chatTypeenum=chatType.GroupChat
            chatViewController.userName=home.name
            chatViewController.classDiscussionType=true
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
             if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            
            let navCont = UINavigationController(rootViewController: chatViewController)
            self.slideMenuController()?.changeMainViewController(navCont, close: true)
        }
            
        else
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There is no available Class Discussion"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func circleTap(sender: UIGestureRecognizer)
    {
        if let home = self.slideMenuController()?.circleData
        {
            
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatViewController.fromMenu = true
            chatViewController.dialogID = home.dialogID
            chatViewController.chatTypeenum=chatType.LearningCircles
            chatViewController.classDiscussionType=false
            chatViewController.userName=home.name
            
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
             
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            
            let navCont = UINavigationController(rootViewController: chatViewController)
            self.slideMenuController()?.changeMainViewController(navCont, close: true)
        }
            
        else
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There is no available Learning Circle"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func groupTap(sender: UIGestureRecognizer)
    {
        if let home = self.slideMenuController()?.groupData
        {
            
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatViewController.fromMenu = true
            chatViewController.dialogID = home.dialogID
            chatViewController.classDiscussionType=false
            chatViewController.chatTypeenum=chatType.GroupChat
            chatViewController.userName=home.name
             
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
             //to show participants
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            
            let navCont = UINavigationController(rootViewController: chatViewController)
            self.slideMenuController()?.changeMainViewController(navCont, close: true)
        }
        else
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "There is no available Hangout"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func settingsTap(sender: UIGestureRecognizer)
    {
        let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        let navCont = UINavigationController(rootViewController: settingsViewController)
        self.slideMenuController()?.changeMainViewController(navCont, close: true)
    }
    
    func logoutTap(sender: UIGestureRecognizer)
    {
        showAlertForLogout()
    }
    
    func showAlertForLogout()
    {
        let alert = UIAlertView()
        alert.title = "Logout"
        alert.tag=2
        alert.delegate=self
        alert.message = "\n Are you sure you want to Logout?"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int)
    {
        if(alertView.tag==2)
        {
            if(buttonIndex==1)
            {
                QBChat.instance().disconnectWithCompletionBlock({ (error:NSError?) -> Void in
                    let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                    appdelegate.showingLoginScreen()
                    NSUserDefaults.standardUserDefaults().setObject("NO", forKey:"LoginStatus")
                    NSUserDefaults.standardUserDefaults().synchronize()
                })
            }
        }
        else if(alertView.tag==1)
        {
            if(buttonIndex==1)
            {
                if(AFNetworkReachabilityManager.sharedManager().reachable)
                {
                    MSWebManager.sharedWebInstance().DeleteAccountwithResponseCallback({ (responseDictionary:NSMutableDictionary!) -> Void in
                        
                        if((responseDictionary.objectForKey("status")) as! String=="Error")
                        {
                            let alert = UIAlertView()
                            alert.title = "Alert"
                            if(!(responseDictionary.objectForKey("errorMessage")==nil))
                            {
                                alert.message = responseDictionary.objectForKey("errorMessage") as? String
                            }
                            else
                            {
                                alert.message="Invalid response from server"
                            }
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        else  if((responseDictionary.objectForKey("status")) as! String=="Success")
                        {
                            let alert = UIAlertView()
                            alert.title = "Request Submitted"
                            alert.message="An Administrator will review your request and contact you shortly."
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
                    alert.show()
                }
            }
        }
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
