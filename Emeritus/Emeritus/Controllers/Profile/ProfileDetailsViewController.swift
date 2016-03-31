//
//  ProfileDetailsViewController.swift
//  Emeritus
//
//  Created by SB on 12/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
class ProfileDetailsViewController: UIViewController,DetailTableViewHeaderViewProtocol,UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileDetailsTableView: UITableView!
   @IBOutlet weak var indicator: UIActivityIndicatorView!
    var selfProfileStatus:Bool=true
    var HeaderView:ProfileDetailTableHeaderView!
    var descriptionsArray:NSMutableArray=["swathi.tata@sourcebits.com","Developer","Development"]
    var descriptionsImagesArray:NSMutableArray=["mail_icon.png","industry_icon.png","university_icon.png"]
    var arrHobbies = [String]()
    var arrLblHobbies = [UILabel]()
    var userProfileDetails:Users!
    var cellHobbiesHeight = CGFloat(125)
    var imgPreview:UIImageView?
    var OnlineUsersObj:OnlineUsers!
    var onLoading:Bool = true
    var fromParticipants:Bool = false
   
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.hidesWhenStopped = false;
        indicator.hidden = true
      
        let webManager:MSWebManager=MSWebManager.sharedWebInstance() as MSWebManager
        webManager.setCountryCodeFor("")
      
        self.navigationItem.title="Profile"
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController?.navigationBar .setBackgroundImage(image, forBarMetrics:.Default)
        NSLog("de::%@", userProfileDetails)
        NSLog("de::%@", userProfileDetails.userID)
        
       OnlineUsersObj = OnlineUsers.sharedInstance()
      
        fillDescriptionArray()
    
        self.navigationItem.setHidesBackButton(true,animated:true)
        if(fromParticipants == true)
        {
            let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
            navigationItem.leftBarButtonItem = backButton
            backButton.tintColor=UIColor.whiteColor()
        }
        else
        {
            let backButton = UIBarButtonItem (image:UIImage(named:"hamburger.png"), style: .Plain, target: self,action: "menuAction")
            navigationItem.leftBarButtonItem = backButton
            backButton.tintColor=UIColor.whiteColor()
        }
        
        

        profileDetailsTableView.separatorColor=UIColor.clearColor()
      
      let nav = self.navigationController?.navigationBar
      
      let attributes = [
         NSForegroundColorAttributeName: UIColor.whiteColor(),
         NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
      ]
      
      nav?.titleTextAttributes = attributes
        
        if(userProfileDetails.hobbies != nil)
        {
            self.arrHobbies=userProfileDetails.hobbies.componentsSeparatedByString(",") as Array<String>
            for (_,element) in self.arrHobbies.enumerate()
            {
                if element == ""
                {
                    //self.arrHobbies.removeAtIndex(index)
                }
            }
            self.setupHobbiesLabel()
        }
    }
    
    func fillDescriptionArray()
    {
        descriptionsArray.removeAllObjects()
        if(userProfileDetails.emailID != nil)
        {
            descriptionsArray.addObject(userProfileDetails.emailID)
        }
        else
        {
            descriptionsArray.addObject(" ")
        }
        
        if(userProfileDetails.company != nil)
        {
            descriptionsArray.addObject(userProfileDetails.company)
        }
        else
        {
            descriptionsArray.addObject(" ")
        }
        
        if(userProfileDetails.education != nil)
        {
            descriptionsArray.addObject(userProfileDetails.education)
        }
        else
        {
            descriptionsArray.addObject(" ")
        }
        
    }
    
    func previewProfilePic(tapGest:UITapGestureRecognizer)
    {
      if(!(userProfileDetails.profileUrl == nil))
      {
        let imageRequest: NSURLRequest = NSURLRequest(URL: NSURL(string:userProfileDetails.profileUrl)!)
        
        NSURLConnection.sendAsynchronousRequest(imageRequest,
                    queue: NSOperationQueue.mainQueue(),
                    completionHandler:{response, data, error in
        
                self.imgPreview=UIImageView(frame: CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width))
                        self.imgPreview?.image=UIImage(data: data!)
                        self.imgPreview?.userInteractionEnabled=true
                        self.view.addSubview(self.imgPreview!)
                    let tap = UITapGestureRecognizer(target: self, action: "removePicLayer:")
                        tap.numberOfTapsRequired=1
                        self.imgPreview?.addGestureRecognizer(tap)
                 })
      }
    }
   
    
    func removePicLayer(tapGest:UITapGestureRecognizer)
    {
        self.imgPreview?.removeFromSuperview()
    }
    
    func setupHobbiesLabel()
    {
        for (_,element) in self.arrHobbies.enumerate()
        {
            let attributes = [
                NSFontAttributeName : UIFont.systemFontOfSize(14.0),
                NSForegroundColorAttributeName : UIColor(red: 240/255.0,green: 85/255.0, blue: 35/255.0, alpha: 1.0),
                NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSStrokeWidthAttributeName : 3.0]
            
            let title = NSAttributedString(string: element, attributes: attributes) //1
            
            let label = UILabel(frame: CGRectMake(0.0, 26.0, title.size().width+20, title.size().height+10)) //2
            label.textAlignment=NSTextAlignment.Center
            label.attributedText = title //3
            label.layer.borderColor=UIColor(red: 240/255.0,green: 85/255.0, blue: 35/255.0, alpha: 1.0).CGColor
            label.layer.borderWidth=1.0
            label.layer.cornerRadius=14
            arrLblHobbies.append(label)
        }
        
        if !(self.arrHobbies.isEmpty)
        {
        var horiz = CGFloat(10.0)
        var vert = CGFloat(self.arrLblHobbies[0].frame.size.height)
        for (_,element) in self.arrLblHobbies.enumerate()
        {
            let lbl = element
            if ((horiz + lbl.frame.size.width)<320)
            {
                
            }
            else
            {
                vert += lbl.frame.size.height + 10
                horiz = CGFloat(10.0)
            }
            horiz += lbl.frame.size.width + 5
        }
        cellHobbiesHeight = vert + 70
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
      NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateUserDetails:", name: "UserDetailsUpdated", object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UserDetailsUpdated", object: nil)
    }
    
    func updateUserDetails(dict : NSDictionary)
    {
      
        let SessionUserId = userProfileDetails.qbID
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        let selectedUser:Users=cdManager.viewProfile(NSNumber(integer:SessionUserId.integerValue)) as Users
            self.userProfileDetails=selectedUser
            arrHobbies = [String]()
            arrLblHobbies = [UILabel]()
       if(userProfileDetails.hobbies != nil)
       {
          self.arrHobbies=userProfileDetails.hobbies.componentsSeparatedByString(",") as Array<String>
          for (_,element) in self.arrHobbies.enumerate()
          {
             if element == ""
             {
                //self.arrHobbies.removeAtIndex(index)
             }
          }
       }
            setupHobbiesLabel()
            fillDescriptionArray()
      
            self.profileDetailsTableView.hidden = true
            dispatch_async(dispatch_get_main_queue(), {self.profileDetailsTableView.reloadData()});
            self.profileDetailsTableView.hidden = false
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func menuAction()
    {
        self.slideMenuController()?.toggleLeft()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Settings Action
    func settingsAction(rightBarButton:UIBarButtonItem)
    {
        let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(selfProfileStatus==false)
        {
           return 5
        }
        else
        {
           return 4
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 270
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        if indexPath.row==4
        {
            return 87
        }
        
        if indexPath.row==3
        {
            return CGFloat(cellHobbiesHeight)
        }
        else
        {
            return 45
        }
        
    }
   
   //////////ONLINE CHECK
   
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let bundle = NSBundle(forClass:self.dynamicType)
      let nib = UINib(nibName: "ProfileDetailTableHeaderView", bundle: bundle)
      let HeaderView = nib.instantiateWithOwner(self, options: nil)[0] as! ProfileDetailTableHeaderView
        HeaderView.detailDelegate=self
      
        if (userProfileDetails.firstname != nil)
        {
          HeaderView.nameLabel.text=userProfileDetails.firstname
        }
        
        if (userProfileDetails.lastName != nil)
        {
            HeaderView.nameLabel.text=HeaderView.nameLabel.text! + " " + userProfileDetails.lastName
        }
        
        if (userProfileDetails.designation != nil)
        {
            HeaderView.designationLabel.text=userProfileDetails.designation
        }
        
        if (userProfileDetails.city != nil)
        {
            HeaderView.LocationLabel.text=userProfileDetails.city
        }
        
        if (userProfileDetails.country != nil)
        {
            HeaderView.LocationLabel.text=HeaderView.LocationLabel.text! + ", " + CountryPickerModel.sharedInstance().countryNameFromId(userProfileDetails.country.stringValue)
        }
      
        if (userProfileDetails.industry != nil)
        {
         HeaderView.industryLabel.text = userProfileDetails.industry
        }
      
        let tapProfilePic = UITapGestureRecognizer(target: self, action: Selector("previewProfilePic:"))
        tapProfilePic.delegate = self
        tapProfilePic.numberOfTapsRequired=1
        HeaderView.profilePhoto.addGestureRecognizer(tapProfilePic)
      
        let userId=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
      NSLog("userProfileDetailsID:%@", userProfileDetails.qbID)
      if (userId == userProfileDetails.qbID.stringValue)
      {
         //HeaderView.activityIndicator.startAnimating()
         HeaderView.onlineStatusIndicatorImageView.image=UIImage(named:"online_status_indicator_profile.png")
      }
      
      else
      {
      let lastCheck = OnlineUsersObj.getUserLastCheck(userProfileDetails.qbID) as CLong
      if(lastCheck == 0  )
      {
         
         OnlineUsersObj.save(userProfileDetails.qbID, status: 2, lastCheck: 1)
         HeaderView.onlineStatusIndicatorImageView.hidden = true;
         APIServiceSessionManger.IsUserOnlineWithCompletionBlock(userProfileDetails.qbID, success: { (task, responseObject) -> Void in
            HeaderView.onlineStatusIndicatorImageView.hidden = false;
            if let dictionary = responseObject.objectForKey("response") as? NSDictionary
            {
               
               let onlineStatus:NSNumber = dictionary.objectForKey("online") as! NSNumber
               //var lastChec:NSNumber = dictionary.objectForKey("online") as! NSNumber
               self.OnlineUsersObj.save(self.userProfileDetails.qbID, status: onlineStatus, lastCheck: 2)
               if(onlineStatus.integerValue==1)
               {
                  HeaderView.onlineStatusIndicatorImageView.image=UIImage(named:"online_status_indicator_profile.png")
               }
               else
               {
                  HeaderView.onlineStatusIndicatorImageView.image=UIImage(named:"offline_status_indicator_profile.png")
               }
            }
            })
            { (task, error) -> Void in
               
               
         }
      }
         
      else
      {
         
         let onlineStatus:NSNumber = OnlineUsersObj.getUserStatus(userProfileDetails.qbID)
         if(onlineStatus.integerValue==1)
         {
            HeaderView.onlineStatusIndicatorImageView.image=UIImage(named:"online_status_indicator_profile.png")
         }
         else
         {
            HeaderView.onlineStatusIndicatorImageView.image=UIImage(named:"offline_status_indicator_profile.png")
         }
      }
      }
        
        if(selfProfileStatus==false)
        {
            HeaderView.hidingeditButton()
        }
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if((self.userProfileDetails.profileUrl) != nil)
            {
                let url = NSURL(string: self.userProfileDetails.profileUrl)
                if let data = NSData(contentsOfURL: url!)
                {
                        dispatch_async( dispatch_get_main_queue(), {
                                HeaderView.profilePhoto.image = UIImage(data: data)
                        });
                }
                else
                {
                        dispatch_async( dispatch_get_main_queue(), {
                                HeaderView.profilePhoto.image = UIImage(named:"avatar_profile_info.png")
                        });
                }
            }
            });
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if((self.userProfileDetails.coverUrl) != nil)
            {
                let url = NSURL(string: self.userProfileDetails.coverUrl)
                if let data = NSData(contentsOfURL: url!)
                {
                    dispatch_async( dispatch_get_main_queue(), {
                        HeaderView.coverPhotoImageView.image = UIImage(data: data)
                    });
                }
                else
                {
                    dispatch_async( dispatch_get_main_queue(), {
                        HeaderView.coverPhotoImageView.image = UIImage(named:"profile-bg@3x.png")
                    });
                }
            }
        });
        
        //let imageCache = SDImageCache.sharedImageCache()
        
//                if((self.userProfileDetails.profileUrl) != nil)
//                {
//                    
//                    let url = NSURL(string: self.userProfileDetails.profileUrl)
//                    if let data = NSData(contentsOfURL: url!)
//                        {
//                            HeaderView.profilePhoto.image = UIImage(data: data)
//                        }
//                    else
//                        {
//                            HeaderView.profilePhoto.image = UIImage(named:"avatar_profile_info.png")
//                        }
//                    print(self.userProfileDetails.profileUrl)
//                    
//                }
        
//                if((self.userProfileDetails.coverUrl) != nil)
//                {
//                    let url = NSURL(string: self.userProfileDetails.coverUrl)
//                    if let data = NSData(contentsOfURL: url!)
//                    {
//                        HeaderView.coverPhotoImageView.image = UIImage(data: data)
//                    }
//                    else
//                    {
//                        HeaderView.coverPhotoImageView.image = UIImage(named:"profile-bg@3x.png")
//                    }
//                    
//                    print(self.userProfileDetails.coverUrl)
//                }
        
     
         return HeaderView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if indexPath.row==3
        {
            let identifier = "HobbiesCell"
            
            tableView.registerNib(UINib(nibName: "HobbiesCell", bundle: nil), forCellReuseIdentifier: identifier)
            
            let topLevelObjects = NSBundle.mainBundle().loadNibNamed("HobbiesCell", owner: self, options: nil) as NSArray
            
            let cell = topLevelObjects.objectAtIndex(0) as! HobbiesCell
            
            cell.firstHobby.hidden=true
            cell.secondHobby.hidden=true
            
            let SessionUserId = userProfileDetails.qbID
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            let selectedUser:Users=cdManager.viewProfile(SessionUserId) as Users
            self.userProfileDetails=selectedUser
            arrHobbies = [String]()
            arrLblHobbies = [UILabel]()
            if(userProfileDetails.hobbies != nil)
            {  if (userProfileDetails.hobbies != ",")
            {
                self.arrHobbies=userProfileDetails.hobbies.componentsSeparatedByString(",") as Array<String>
                for (index,element) in self.arrHobbies.enumerate()
                {
                    if element == " "
                    {
                        self.arrHobbies.removeAtIndex(index)
                    }
                    
                    if element == ""
                    {
                        //self.arrHobbies.removeAtIndex(index)
                    }
                }
                }
            }
            setupHobbiesLabel()
            
            if !(self.arrHobbies.isEmpty)
            {
                var horiz = CGFloat(10.0)
                var vert = CGFloat(self.arrLblHobbies[0].frame.size.height)
                
                for (_,element) in self.arrLblHobbies.enumerate()
                {
                    let lbl = element
                    if ((horiz + lbl.frame.size.width)<320)
                    {
                        lbl.frame = CGRectOffset(lbl.frame, horiz, vert)
                        cell.contentView.addSubview(lbl)
                    }
                    else
                    {
                        vert += lbl.frame.size.height + 10
                        horiz = CGFloat(10.0)
                        lbl.frame = CGRectOffset(lbl.frame, horiz, vert)
                        cell.contentView.addSubview(lbl)
                    }
                    horiz += lbl.frame.size.width + 5
                }
            }
            
            return cell
            
        }
        else
        {
            if indexPath.row==4
            {
                let identifier = "BlockUserCell"
                tableView.registerNib(UINib(nibName: "BlockUserCell", bundle: nil), forCellReuseIdentifier: identifier)
                let topLevelObjects = NSBundle.mainBundle().loadNibNamed("BlockUserCell", owner: self, options: nil) as NSArray
                let cell = topLevelObjects.objectAtIndex(0) as! BlockUserCell
                
                var isUserBlocked:Bool = false
                
                if let qbId=userProfileDetails.qbID
                {
                    isUserBlocked = BlockedUserManager.isUserBlockedWithId(qbId)
                }
                
                cell.reportButton.addTarget(self, action: "reportAction:", forControlEvents: UIControlEvents.TouchUpInside)
                
                if(isUserBlocked == true)
                {
                    cell.blockButton.setTitle("Unblock User", forState: UIControlState.Normal)
                    cell.blockButton.setTitle("Unblock User", forState: UIControlState.Selected)
                    cell.blockButton.addTarget(self, action: "unblockAction:", forControlEvents: UIControlEvents.TouchUpInside)

                }
                else
                {
                    cell.blockButton.setTitle("Block User", forState: UIControlState.Normal)
                    cell.blockButton.setTitle("Block User", forState: UIControlState.Selected)
                    cell.blockButton.addTarget(self, action: "blockAction:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! ProfileDetailTableViewCell
            let description:String=descriptionsArray[indexPath.row] as! String
            let descriptionImage:UIImage=UIImage(named:descriptionsImagesArray[indexPath.row] as! String)! as UIImage
            cell.settingdescriptionTodescriptionLabel(description,descimage:descriptionImage)
            
            return cell
            
        }
        
    }
    
    func reportAction(sender:UIButton!)
    {
        let feedbackViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
        feedbackViewController.reportUserId = userProfileDetails.userID;
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
    func unblockAction(sender:UIButton!)
    {
        if let qbId=userProfileDetails.qbID
        {
            BlockedUserManager.unBlockUserWithId(qbId)
        }
        self.profileDetailsTableView.reloadData()
    }
    
    func blockAction(sender:UIButton!)
    {
        if let qbId=userProfileDetails.qbID
        {
            BlockedUserManager.blockUserWithId(qbId)
        }
        self.profileDetailsTableView.reloadData()
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
     }
    //MARK: - Profile Detail TableView HeaderView Protocols
    func editButtonAction()
    {
        let SessionUserId:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
        dispatch_async(dispatch_get_main_queue(), {
            
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            let selectedUser:Users=cdManager.viewProfile(NSNumber(integer:SessionUserId.integerValue)) as Users
            NSLog("d:%@", selectedUser)
            let editprofileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
            editprofileViewController.userProfileDetailsFromDb=selectedUser
            
            self.navigationController?.pushViewController(editprofileViewController, animated: true)
         })
    }
    
    func photoAlbumAction()
    {
        let profileViewPhotoController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfilePhotosViewController") as! ProfilePhotosViewController
        profileViewPhotoController.userID=NSString(format: "%@",userProfileDetails.userID)
        profileViewPhotoController.qbID=NSString(format: "%@",userProfileDetails.qbID)
        self.navigationController?.pushViewController(profileViewPhotoController, animated: true)

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
