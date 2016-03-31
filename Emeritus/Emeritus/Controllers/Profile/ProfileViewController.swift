//
//  ProfileViewController.swift
//  Emeritus
//
//  Created by SB on 10/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import CoreLocation


class ProfileViewController: UIViewController,HeaderViewProtocol,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate,UITextFieldDelegate
{
    var selfUserProfileDetails:Users!
    var photosStatus:Bool=false
    var dataArrayToserver:NSMutableDictionary!
    var coverPhoto:Bool=false
    var profilePhoto:Bool=false
    var HeaderView:ERavtarView!
    var locality:NSString!
    var country:NSString!
    var targetTextField:UITextField!
    var titlesArray:NSMutableArray=["FIRST NAME","LAST NAME","EMAIL ID","CITY","COUNTRY","INDUSTRY","EDUCATION","COMPANY","DESIGNATION","HOBBIES"]
    var placeHoldersArray:NSMutableArray=["Your first name","Your last name","Your email address","City where you live", "Country where you live","Business sector","University or college name","Your company name","Your title name","Basketball,Photography etc"]
    
    @IBOutlet weak var profileTableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title="Profile Info"
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController?.navigationBar .setBackgroundImage(image, forBarMetrics:.Default)
        self.navigationItem.setHidesBackButton(true,animated:true)
        self.navigationController?.delegate=self
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!], forState: .Normal)
        profileTableView.pagingEnabled=false
        dataArrayToserver=NSMutableDictionary()
        
        self.preparingData()
        
    }
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification , object: nil)
    }
   
    func fetchSelfUserDetails()
    {
        print(LoginServices.sharedLogininstance().qb_account_ID)
        LoginServices.sharedLogininstance().fetchFromUserDefaults()
        MSCoreDataManager.sharedCoreDataInstance().fecthingTheUserProfileDetails(LoginServices.sharedLogininstance().userId, withresponseCallback: { (userDetails:Users!) -> Void in
            self.selfUserProfileDetails=userDetails
            self.preparingData()
        })
        
    }
    
    func preparingData()
    {
        if(!(selfUserProfileDetails==nil))
        {
            
            if (selfUserProfileDetails.firstname != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.firstname, forKey:"FIRST NAME")
            }
            if (selfUserProfileDetails.lastName != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.lastName, forKey:"LAST NAME")
            }
            if (selfUserProfileDetails.emailID != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.emailID, forKey:"EMAIL ID")
            }
            if (selfUserProfileDetails.city != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.city, forKey:"CITY")
            }
            if (selfUserProfileDetails.country != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.country, forKey:"COUNTRY")
            }
            
            if (selfUserProfileDetails.industry != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.industry, forKey:"INDUSTRY")
            }
            if (selfUserProfileDetails.education != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.education, forKey:"EDUCATION")
            }
            if (selfUserProfileDetails.company != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.company, forKey:"COMPANY")
            }
            if (selfUserProfileDetails.designation != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.designation, forKey:"DESIGNATION")
            }
            if (selfUserProfileDetails.hobbies != nil)
            {
                dataArrayToserver.setObject(selfUserProfileDetails.hobbies, forKey:"HOBBIES")
            }
            
        }
        profileTableView.reloadData()
    }
    @IBAction func tapAction(sender: AnyObject) {
     }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
    //MARK: - customise HeaderView Protocol Methods
    func coverPhotoAction()
    {
        if(!(targetTextField==nil))
        {
            targetTextField.resignFirstResponder()
            let contentInsets:UIEdgeInsets = UIEdgeInsetsZero;
            profileTableView.contentInset = contentInsets;
            profileTableView.scrollIndicatorInsets = contentInsets;
        }
        let photoActionSheet = UIActionSheet(title:nil /*"Select Image"*/, delegate: self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil,otherButtonTitles:"Choose from Gallery","Upload from Camera")
        photoActionSheet.showInView(self.view)
        photoActionSheet.tag=1
        photoActionSheet.cancelButtonIndex=photoActionSheet.numberOfButtons-1
        print(photoActionSheet.subviews);
        print("cover photo  action")
        
    }
    
    func avatartapAction()
    {
        
        if(!(targetTextField==nil))
        {
            targetTextField.resignFirstResponder()
            let contentInsets:UIEdgeInsets = UIEdgeInsetsZero;
            profileTableView.contentInset = contentInsets;
            profileTableView.scrollIndicatorInsets = contentInsets;
        }
        
        let photoActionSheet:UIActionSheet = UIActionSheet(title:nil, delegate: self, cancelButtonTitle:"Cancel",destructiveButtonTitle:nil,otherButtonTitles:"Choose from Gallery","Upload from Camera") as UIActionSheet
        photoActionSheet.showInView(self.view)
        photoActionSheet.tag=2
        photoActionSheet.cancelButtonIndex=photoActionSheet.numberOfButtons-1
        print("avatar tap action")
    }
    
    //MARK: - Actionsheet Delegate Methods
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(actionSheet.tag==1)
        {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.view.tag=1
            self.navigationController?.delegate=self
            imagePickerController.allowsEditing = true
            switch buttonIndex{
            case 0:
                //print("Clicked on cancel")
                actionSheet.dismissWithClickedButtonIndex(0, animated: true)
                break
                
            case 1:
                print("camera");
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
                {
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Camera is not available"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                }
                break
            case 2:
                
                print("gallery");
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                    
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                    
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                    
                }
                else  if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
                {
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Photos not available"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
                
                break
             default:
                print("Default");
                break
                
            }
            
        }
        if(actionSheet.tag==2)
        {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.view.tag=2
            self.navigationController?.delegate=self
            imagePickerController.allowsEditing = true
            switch buttonIndex{
            case 0:
                //print("Clicked on cancel")
                actionSheet.dismissWithClickedButtonIndex(0, animated: true)
                break
                
            case 1:
                print("camera");
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
                {
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Camera is not available"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                }
                break
            case 2:
                
                print("gallery");
                
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                    
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                    
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                    
                }
                else  if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
                {
                    imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
                    self.presentViewController(imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Photos not available"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
                
                break
             default:
                print("Default");
                break
                
            }
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        photosStatus=true
        if(picker.view.tag==1)
        {
            profilePhoto=true
            HeaderView.avatarImageView.image=image
        }
        if(picker.view.tag==2)
        {
            coverPhoto=true
            HeaderView.coverphotoImageView.image = image
            HeaderView.coverphotoImageView.clipsToBounds = true
            HeaderView.changingaddCoverPhotoToChangeCoverPhoto()
        }
        
        self.navigationItem.rightBarButtonItem?.title="Confirm"
    }
     func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    //MARK: - Action Sheet Delegate Methods
    
    func willPresentActionSheet(actionSheet: UIActionSheet)
    {
        //print(actionSheet.subviews)
        for  subview in actionSheet.subviews
        {
            if(subview.isKindOfClass(UIButton))
            {
                let button:UIButton=subview as! UIButton
                button.setTitleColor(UIColor.redColor(), forState:UIControlState.Normal)
            }
        }
    }
     // MARK: - Skip Action
    @IBAction func skipButtonAction(sender: AnyObject) {
         if(((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus"))) != nil)
        {
            if((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus")) as! String=="YES")
            {
                let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
                self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
            }
            else
            {
                goToHomeViewController()
            }
            
        }
        else
        {
                goToHomeViewController()
            
        }
     }
    
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return titlesArray.count
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 125
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 67
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        HeaderView=UINib(nibName:"ERavtarView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ERavtarView
        HeaderView.delegate=self
        
        if let _ = selfUserProfileDetails
        {
            if((selfUserProfileDetails.profileUrl) != nil)
            {
                HeaderView.avatarImageView.sd_setImageWithURL(NSURL(string:selfUserProfileDetails.profileUrl), placeholderImage:UIImage(named:"avatar_profile_info.png"))
            }
            if((selfUserProfileDetails.coverUrl) != nil)
            {
                HeaderView.coverphotoImageView.sd_setImageWithURL(NSURL(string:selfUserProfileDetails.coverUrl), placeholderImage:UIImage(named:"profile-bg@3x.png"))
               HeaderView.changingaddCoverPhotoToChangeCoverPhoto()
               
            }
        }
         return HeaderView
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProfileTableViewCell
        cell.titleLabel.text = titlesArray.objectAtIndex(indexPath.row) as? String
        cell.titleTextField.placeholder=placeHoldersArray.objectAtIndex(indexPath.row) as? String
        cell.titleTextField.enabled=true
        
        if(cell.titleLabel.text=="EMAIL ID")
        {
            
            cell.titleTextField.enabled=false
        }
        cell.titleTextField.tag=indexPath.row
        if(cell.titleLabel.text=="HOBBIES")
        {
            
            cell.titleTextField.returnKeyType = .Done
            
        }
        if(!(dataArrayToserver.objectForKey(titlesArray[indexPath.row])==nil))
        {
            cell.titleTextField.text=dataArrayToserver.objectForKey(titlesArray[indexPath.row]) as? String
        }
        return cell
     }
    //MARK: - TableView Delegate Methods
    func tableView(_tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
     }
    //MARK: - TextField Delegate Methods
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        let text = textField.text
        let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
        
        if(newText.characters.count>0)
        {
            self.navigationItem.rightBarButtonItem?.title="Confirm"
            dataArrayToserver.setObject(textField.text!, forKey:titlesArray[textField.tag] as! NSString)
            
        }
        else if(newText.characters.count==0)
        {
            self.navigationItem.rightBarButtonItem?.title="Skip"
            dataArrayToserver.removeObjectForKey(titlesArray[textField.tag])
            let allValuesArray:NSArray=dataArrayToserver.allValues
            if(!(allValuesArray.count==0))
            {
                print(dataArrayToserver)
                print(dataArrayToserver.count)
                self.navigationItem.rightBarButtonItem?.title="Confirm"
            }
            if(photosStatus==true)
            {
                self.navigationItem.rightBarButtonItem?.title="Confirm"
            }
        }
        return true
    }
     func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        if(!(dataArrayToserver.objectForKey(titlesArray[textField.tag])==nil))
        {
            textField.text=dataArrayToserver.objectForKey(titlesArray[textField.tag]) as? String
        }
        else
        {
            textField.text=""
            textField.placeholder=placeHoldersArray.objectAtIndex(textField.tag) as? String
            
        }
        targetTextField=textField
        
        return true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("8.0"))
        {
            var cell:UITableViewCell!
            if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("8.0"))
            {
                cell=textField.superview?.superview?.superview as! UITableViewCell
            }
            else
            {
                cell=textField.superview?.superview as! UITableViewCell
                
            }
            profileTableView.scrollToRowAtIndexPath(profileTableView.indexPathForCell(cell)!, atScrollPosition:UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        dataArrayToserver.setObject(textField.text!, forKey:titlesArray[textField.tag] as! NSString)
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        print(dataArrayToserver)
        
        if(textField.tag==8)
        {
            if(((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus"))) != nil)
            {
                if((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus")) as! String=="YES")
                {
                    let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
                    self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
                }
                else
                {
                    goToHomeViewController()
                }
                
            }
            else
            {
                goToHomeViewController()
            }
         }
        textField.resignFirstResponder()
        if(textField.tag==1)
        {
            let nextTextField=self.view.viewWithTag(textField.tag+2)
            nextTextField?.becomeFirstResponder()
            
        }
        else
        {
            let nextTextField=self.view.viewWithTag(textField.tag+1)
            nextTextField?.becomeFirstResponder()
        }
        return true
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        
        if(!(targetTextField==nil))
        {
            if let info = notification.userInfo {
                let kbsize:CGSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
                print(kbsize);
                let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbsize.height, 0.0)
                profileTableView.contentInset = contentInsets;
                profileTableView.scrollIndicatorInsets = contentInsets;
                var tableviewframe:CGRect=profileTableView.frame
                tableviewframe.size.height-=kbsize.height;
                if (targetTextField.tag < 3) {
                    
                    let scrollPoint:CGPoint = CGPointMake(0.0, 0.0)
                    profileTableView.contentOffset=scrollPoint
                }
                else if(targetTextField.tag>=4)
                {
                    let scrollPoint:CGPoint = CGPointMake(0.0,targetTextField.frame.origin.y+kbsize.height-55);
                    profileTableView.contentOffset=scrollPoint
                }
                
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(!(targetTextField==nil))
        {
            let contentInsets:UIEdgeInsets = UIEdgeInsetsZero;
            profileTableView.contentInset = contentInsets;
            profileTableView.scrollIndicatorInsets = contentInsets;
            
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
