//
//  SettingsViewController.swift
//  Emeritus
//
//  Created by SB on 10/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UIAlertViewDelegate,AudioAlertCellProtocol
{
    
    @IBOutlet weak var tableView: UITableView!
    var tabelOfContents:NSMutableArray=[]
    var DeleteButton:UIButton = UIButton()
    var switchButton:UISwitch = UISwitch()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        adjustingPropertiesOfTableView()
        tabelOfContents = ["About App", "Rate", "Feedback","Audio Alerts", "Privacy Policy", "Contact","Walkthrough","Change Password","Delete Account","Logout"]
         self.navigationItem.setHidesBackButton(true,animated:true)
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"hamburger.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        
        self.tableView.separatorColor = UIColor(patternImage: UIImage(named:"separator_grey1@2x.png")!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func backAction()
    {
        self.slideMenuController()?.toggleLeft()
    }
    
    func adjustingPropertiesOfTableView()->Void
    {
        self.tableView.frame = CGRectMake(self.view.frame.origin.x,64,self.view.frame.size.width,self.view.frame.size.height-64)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        //        var separatorImage=UIImage(named:"separator_full_width")
        self.tableView.separatorColor=UIColor(red: 127/255.0, green: 127/255.0, blue: 127/255.0, alpha:0.5)
    }
    
    func valueChanged( state:UIControlState)
    {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.tabelOfContents.count
    }
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let CellIdentifier = "SettingsCell"
        let cell:SettingsTableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! SettingsTableViewCell
        cell.textLabel?.text = self.tabelOfContents.objectAtIndex(indexPath.row) as! NSString as String
        cell.textLabel?.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 0.87)
        cell.textLabel?.font = UIFont(name: "Avenir", size: 16.0)
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        if indexPath.row==3
        {
            let identifier = "AudioAlertCell"
            var cell: AudioAlertTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? AudioAlertTableViewCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: "AudioAlertTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? AudioAlertTableViewCell
                cell.AudioAlertTableViewcellDelegate=self
                
            }
            cell.titleLabel.text = self.tabelOfContents.objectAtIndex(indexPath.row) as! NSString as String
            return cell
        }
        if((cell.textLabel?.text=="Walkthrough")||(cell.textLabel?.text=="Delete Account")||(cell.textLabel?.text=="Logout")||(cell.textLabel?.text=="Change Password"))
        {
            cell.cellAccessoryImageView.hidden=true
        }
        else
        {
            cell.cellAccessoryImageView.hidden=false
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0
        {
            self.performSegueWithIdentifier("AboutAppSegue", sender: indexPath.row)
            
        }
         else if indexPath.row == 1
        {
         UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1055359311")!)
        }
         
        else if indexPath.row == 2
        {
            self.performSegueWithIdentifier("FeedbackSegue", sender: indexPath.row)
        }
        else if indexPath.row == 4
        {
            self.performSegueWithIdentifier("PrivacypolicySegue", sender: indexPath.row)
        }
            
        else if indexPath.row == 5
        {
            self.performSegueWithIdentifier("contactPushSegue", sender: indexPath.row)
        }
            
        else if indexPath.row == 7
        {
            self.performSegueWithIdentifier("changepasswordSegue", sender: indexPath.row)
        }
        else if indexPath.row == 8
        {
            showAlertForDeleteAccount("Delete Account",alertMessage:"\n Are you sure you want to delete your account?")
        }
        else if indexPath.row == 9
        {
            showAlertForLogout()
        }
        else if indexPath.row==6
        {
            let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
            NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"ShownFromSettingsForWalkThrough")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
            
        }
        else if indexPath.row==7
        {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let passwdViewController=storyboard.instantiateViewControllerWithIdentifier("ChangePswdViewController") as! ChangePswdViewController
            NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"ShownFromSettingsForChangePassword")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.navigationController!.pushViewController(passwdViewController, animated: true)   
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)->Void
    {
        
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
         if(alertView.tag==2)
        {
            if(buttonIndex==1)
            {
                if(QBChat.instance().isConnected())
                {
                    QBChat.instance().disconnectWithCompletionBlock({ (error:NSError?) -> Void in
                        //self.navigationController?.popToRootViewControllerAnimated(true)
                        let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        appdelegate.showingLoginScreen()
                        NSUserDefaults.standardUserDefaults().setObject("NO", forKey:"LoginStatus")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        //var cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                        //cdManager.deleteDatabase()
                    })
                }
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
    // Function to init a UIAlertView and show it
    func showAlertForDeleteAccount(rowTitle:NSString,alertMessage:NSString) {
        let alert = UIAlertView()
        alert.title = rowTitle as String
        alert.message = alertMessage as String
        alert.tag=1
        alert.delegate=self
        alert.addButtonWithTitle("No")
        alert.addButtonWithTitle("Yes")
        alert.show()
    }
    
    func showAlertForLogout() {
        let alert = UIAlertView()
        alert.title = "Logout"
        alert.tag=2
        alert.delegate=self
        alert.message = "\n Are sure you want to Logout?"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("OK")
        alert.show()
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
 }
