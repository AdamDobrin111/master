//
//  EditProfileViewController.swift
//  Emeritus
//
//  Created by SB on 22/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController,HeaderViewProtocol,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate
{
    
    var dataArrayToserver:NSMutableDictionary!
    var saveButton:UIBarButtonItem!
    var targetTextField:UITextField!
    var photosStatus:Bool=false
    var userProfileDetailsFromDb:Users!
    var countryPickerModel:CountryPickerModel!

    @IBOutlet weak var topConst: NSLayoutConstraint!
    var coverPhotoForEditProfile:Bool=false
    var profilePhotoForEditProfile:Bool=false
    @IBOutlet weak var ProfileListTableView: UITableView!
    var pickerView: UIPickerView!
    var HeaderView:ERavtarView!
    var titlesArrayForEditProfile:NSMutableArray=["FIRST NAME","LAST NAME","EMAIL ID","CITY","COUNTRY","INDUSTRY","EDUCATION","COMPANY","DESIGNATION","HOBBIES"]
    var placeHoldersArrayForEditProfile:NSMutableArray=["Your first name","Your last name","Your email address","City where you live", "Country where you live","Business sector","University or college name","Your company name","Your title name","Basketball,Photography etc"]
    
    var textFieldFName:UITextField?=UITextField()
    var textFieldLName:UITextField?=UITextField()
    var textFieldCountry:UITextField?=UITextField()
    var fromConfirmation:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerModel = CountryPickerModel.sharedInstance()
        self.pickerView = UIPickerView()
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        dataArrayToserver=NSMutableDictionary()
        self.navigationItem.title="Edit Profile"
        self.navigationItem.setHidesBackButton(true,animated:true)
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        if(fromConfirmation == false)
        {
          navigationItem.leftBarButtonItem = backButton
        }
        backButton.tintColor=UIColor.whiteColor()
         if(fromConfirmation == true)
        {
           saveButton = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "saveAction")
        }
        
        saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveAction")
        navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem?.enabled=true
        backButton.tintColor=UIColor.whiteColor()
        
        if(fromConfirmation == true)
        {
            topConst.constant = 64
            //self.view.layoutIfNeeded()
            //self.view.setNeedsLayout()
        }
        
        preparingData()
       
      
    }
    
    func preparingData()
    {
        if(!(userProfileDetailsFromDb==nil))
        {
            if (userProfileDetailsFromDb.firstname != nil)
            {
                dataArrayToserver.setObject(userProfileDetailsFromDb.firstname, forKey:"FIRST NAME")
            }
            else
            {
                dataArrayToserver.setObject("", forKey:"FIRST NAME")
            }
            
            if (userProfileDetailsFromDb.lastName != nil)
            {
                dataArrayToserver.setObject(userProfileDetailsFromDb.lastName, forKey:"LAST NAME")
            }
            else
            {
                dataArrayToserver.setObject("", forKey:"LAST NAME")
            }
            
            if (userProfileDetailsFromDb.emailID != nil)
            {
                dataArrayToserver.setObject(userProfileDetailsFromDb.emailID, forKey:"EMAIL ID")
            }
            else
            {
                dataArrayToserver.setObject("", forKey:"EMAIL ID")
            }
            
            if (userProfileDetailsFromDb.city != nil)
            {
                dataArrayToserver.setObject(userProfileDetailsFromDb.city, forKey:"CITY")
            }
            else
            {
                dataArrayToserver.setObject("", forKey:"CITY")
            }
            
            if (userProfileDetailsFromDb.country != nil)
            {
                dataArrayToserver.setObject(CountryPickerModel.sharedInstance().countryNameFromId(userProfileDetailsFromDb.country.stringValue), forKey:"COUNTRY")
            }
            else
            {
                dataArrayToserver.setObject("", forKey:"COUNTRY")
            }
            
         if (userProfileDetailsFromDb.industry != nil)
         {
            dataArrayToserver.setObject(userProfileDetailsFromDb.industry, forKey:"INDUSTRY")
         }
         else
         {
            dataArrayToserver.setObject("", forKey:"INDUSTRY")
         }
            
         if (userProfileDetailsFromDb.education != nil)
         {
            dataArrayToserver.setObject(userProfileDetailsFromDb.education, forKey:"EDUCATION")
         }
         else
         {
            dataArrayToserver.setObject("", forKey:"EDUCATION")
         }
            
         if (userProfileDetailsFromDb.company != nil)
         {
            dataArrayToserver.setObject(userProfileDetailsFromDb.company, forKey:"COMPANY")
         }
         else
         {
            dataArrayToserver.setObject("", forKey:"COMPANY")
         }
            
         if (userProfileDetailsFromDb.designation != nil)
         {
            dataArrayToserver.setObject(userProfileDetailsFromDb.designation, forKey:"DESIGNATION")
         }
         else
         {
            dataArrayToserver.setObject("", forKey:"DESIGNATION")
         }
            
         if (userProfileDetailsFromDb.hobbies != nil)
         {
            dataArrayToserver.setObject(userProfileDetailsFromDb.hobbies, forKey:"HOBBIES")
         }
         else
         {
            dataArrayToserver.setObject("", forKey:"HOBBIES")
            }
         
        }
        ProfileListTableView.reloadData()
    }
   
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification , object: nil)
        
    }
   
   func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
      return 1
   }
   
   func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return countryPickerModel.countryArray.count
   }
   
   func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return (countryPickerModel.countryArray[row] as! Country).countryName
   }
   
   func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
   {
      self.textFieldCountry!.text = (self.countryPickerModel.countryArray[row] as! Country).countryName
      let countryId = (self.countryPickerModel.countryArray[row] as! Country).countryId
      dataArrayToserver.setObject(countryId, forKey:"COUNTRY")
      saveButton.enabled=true
   }
   
    func coverPhotoAction()
    {
        self.view.endEditing(true)
        let photoActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil,otherButtonTitles:"Choose from Gallery","Upload from Camera")
        photoActionSheet.showInView(self.view)
        photoActionSheet.tag=2
        photoActionSheet.cancelButtonIndex=photoActionSheet.numberOfButtons-1
        
        print("cover photo  action")
        
    }
    
    func avatartapAction()
    {
        self.view.endEditing(true)
        let photoActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle:"Cancel",destructiveButtonTitle:nil,otherButtonTitles:"Choose from Gallery","Upload from Camera")
        photoActionSheet.tag=1
        photoActionSheet.showInView(self.view)
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
        imagePickerController.allowsEditing = true
        
        switch buttonIndex{
            
        case 0:
//            print("Clicked on cancel")
            actionSheet.dismissWithClickedButtonIndex(0, animated: true)
            break
            
        case 1:
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
        case 2:
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
            
        default:
            print("Default");
            break
            
        }
            
        }
        else if (actionSheet.tag==2)
        {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.view.tag=2
            imagePickerController.allowsEditing = true
            
            switch buttonIndex{
                
            case 0:
//                print("Clicked on cancel")
                actionSheet.dismissWithClickedButtonIndex(0, animated: true)
                break
                
            case 1:
//                print("gallery");
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
            case 2:
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
                
            default:
                print("Default");
                break
                
            }

        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        if(picker.view.tag==1)
        {
            HeaderView.avatarImageView.image=image
            profilePhotoForEditProfile=true
        }
        if(picker.view.tag==2)
        {
            HeaderView.coverphotoImageView.image = image
            //HeaderView.coverphotoImageView.clipsToBounds = true
            HeaderView.changingaddCoverPhotoToChangeCoverPhoto()
            coverPhotoForEditProfile=true
        }
        photosStatus=true
        
        saveButton.enabled=true
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
    
    func saveAction()
    {
        if let _=textFieldFName , let _=textFieldLName
        {
//        if (textFieldFName!.text?.characters.count==0 || textFieldLName!.text?.characters.count==0)
//        {
//            let alert = UIAlertView()
//            alert.title = "Alert"
//            alert.message = "Please enter name"
//            alert.addButtonWithTitle("OK")
//            alert.show()
//            return
//        }
        }
        let webManager:MSWebManager=MSWebManager.sharedWebInstance() as MSWebManager
        if(profilePhotoForEditProfile)
        {
            webManager.uploadProfileImage(HeaderView.avatarImageView.image) { (response:NSMutableDictionary!) -> Void in
                
            }
        }
        if(coverPhotoForEditProfile)
        {
            webManager.uploadCoverImage(HeaderView.coverphotoImageView.image) { (response:NSMutableDictionary!) -> Void in

            }
        }
        webManager.updateProfile(dataArrayToserver as Dictionary) { (responseDict:NSMutableDictionary!) -> Void in
           webManager.participant()
            if(self.fromConfirmation == true)
            {
                if(((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus"))) != nil)
                {
                    if((NSUserDefaults.standardUserDefaults().objectForKey("WalkThoughStatus")) as! String=="YES")
                    {
//                        let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
//                        self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
                    }
                    else
                    {
                        self.goToHomeViewController()
                    }
                    
                }
                else
                {
                    self.goToHomeViewController()
                    
                }
            }
            else
            {
               self.navigationController?.popViewControllerAnimated(true) 
            }
            
        }
        
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TextField Delegate Methods
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        if (textField.tag==0 || textField.tag==1)
        {
            if textField.text?.characters.count>=64 && string != ""
            {
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Max char length has been reached"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
        }
        
        let text = textField.text
      
        var newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string) as NSString
      
        if(newText == "")
         {
            newText = " "
         }
      
        if(newText.length > 0)
        {
            saveButton.enabled=true
         if((titlesArrayForEditProfile[textField.tag] as! NSString) != "COUNTRY")
         {
            dataArrayToserver.setObject(newText, forKey:titlesArrayForEditProfile[textField.tag] as! NSString)
         }
         
        }
            
        else if(newText.length==0)
        {
            saveButton.enabled=false
            dataArrayToserver.removeObjectForKey(titlesArrayForEditProfile[textField.tag])
            let allValuesArray:NSArray=dataArrayToserver.allValues
            if(!(allValuesArray.count==0))
            {
                print(dataArrayToserver)
                print(dataArrayToserver.count)
                saveButton.enabled=true
            }
            if(photosStatus==true)
            {
                saveButton.enabled=true
                
            }
        }
          return true
    }
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return titlesArrayForEditProfile.count
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
//        HeaderView=UINib(nibName:"ERavtarView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ERavtarView
//        return HeaderView.frame.size.height
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
        if((userProfileDetailsFromDb.profileUrl) != nil)
        {
            HeaderView.avatarImageView.sd_setImageWithURL(NSURL(string:userProfileDetailsFromDb.profileUrl), placeholderImage:UIImage(named:"avatar_profile_info.png"))
        }
        if((userProfileDetailsFromDb.coverUrl) != nil)
        {
            HeaderView.coverphotoImageView.sd_setImageWithURL(NSURL(string:userProfileDetailsFromDb.coverUrl), placeholderImage:UIImage(named:"profile-bg@3x.png"))
            HeaderView.changingaddCoverPhotoToChangeCoverPhoto()
        }
        return HeaderView
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProfileTableViewCell
        cell.titleLabel.text = titlesArrayForEditProfile.objectAtIndex(indexPath.row) as? String
        cell.titleTextField.placeholder=placeHoldersArrayForEditProfile.objectAtIndex(indexPath.row) as? String
        if(cell.titleLabel.text=="EMAIL ID")
        {
            cell.titleTextField.enabled=false
            cell.titleTextField.textColor = UIColor.grayColor()
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: "emailIdTapAction")
            cell.addGestureRecognizer(gestureRecognizer)
        }
        else
        {
            cell.titleTextField.enabled=true
        }
        if(!(dataArrayToserver.objectForKey(titlesArrayForEditProfile[indexPath.row])==nil))
        {
            cell.titleTextField.text=dataArrayToserver.objectForKey(titlesArrayForEditProfile[indexPath.row]) as? String
        }
        else
        {
            cell.titleTextField.placeholder=placeHoldersArrayForEditProfile.objectAtIndex(indexPath.row) as? String
            
        }
      
        cell.titleTextField.autocapitalizationType = .Words
      
        if (cell.titleLabel.text=="COUNTRY")
        {
         self.textFieldCountry = cell.titleTextField
         cell.titleTextField.inputView = self.pickerView
            
            if (userProfileDetailsFromDb.country != nil)
            {
                dataArrayToserver.setObject(userProfileDetailsFromDb.country, forKey:"COUNTRY")
            }
            
        }
      
        if (cell.titleLabel.text=="FIRST NAME")
        {
            self.textFieldFName=cell.titleTextField
            cell.titleTextField.autocapitalizationType = .Words
        }
        if (cell.titleLabel.text=="LAST NAME")
        {
            self.textFieldLName=cell.titleTextField
            cell.titleTextField.autocapitalizationType = .Words
        }
      
        cell.titleTextField.autocorrectionType = .No
        cell.titleTextField.spellCheckingType = .No
      
        cell.titleTextField.tag=indexPath.row
        
        return cell
    }
    //MARK: - TableView Delegate Methods
    func tableView(_tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
     }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        
        if(!(dataArrayToserver.objectForKey(titlesArrayForEditProfile[textField.tag])==nil))
        {
            textField.text=dataArrayToserver.objectForKey(titlesArrayForEditProfile[textField.tag]) as? String
        }
        else
        {
            textField.text=""
            textField.placeholder=placeHoldersArrayForEditProfile.objectAtIndex(textField.tag) as? String
            
        }
        targetTextField=textField
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if(textField.tag==9)
        {
            saveAction()
            
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
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("8.0"))
        {
            var cell:UITableViewCell!
            if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("8.0"))
            {
                cell=textField.superview as! UITableViewCell
            }
            else
            {
                cell=textField.superview?.superview as! UITableViewCell
                
            }
            ProfileListTableView.scrollToRowAtIndexPath(ProfileListTableView.indexPathForCell(cell)!, atScrollPosition:UITableViewScrollPosition.Top, animated: true)
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
      if(textField.text == "")
      {
         dataArrayToserver.setObject(" ", forKey:titlesArrayForEditProfile[textField.tag] as! NSString)
         return
      }
      if((titlesArrayForEditProfile[textField.tag] as! NSString) != "COUNTRY")
      {
        dataArrayToserver.setObject(textField.text!, forKey:titlesArrayForEditProfile[textField.tag] as! NSString)
      }
      
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(!(targetTextField==nil))
        {
            if let info = notification.userInfo {
                let kbsize:CGSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
                let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbsize.height, 0.0)
                ProfileListTableView.contentInset = contentInsets;
                ProfileListTableView.scrollIndicatorInsets = contentInsets;
                var tableviewframe:CGRect=ProfileListTableView.frame
                tableviewframe.size.height-=kbsize.height;
                if (targetTextField.tag < 3) {
                    
                    let scrollPoint:CGPoint = CGPointMake(0.0, 0.0)
                    ProfileListTableView.contentOffset=scrollPoint
                }
                    
                else if(targetTextField.tag==3)
                {
                    
                }
                else
                {
                    let scrollPoint:CGPoint = CGPointMake(0.0,targetTextField.frame.origin.y+kbsize.height-55);
                    ProfileListTableView.contentOffset=scrollPoint
                }
            }
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        
        if(!(targetTextField==nil))
        {
            let contentInsets:UIEdgeInsets = UIEdgeInsetsZero;
            ProfileListTableView.contentInset = contentInsets;
            ProfileListTableView.scrollIndicatorInsets = contentInsets;
        }
    }
   
   func emailIdTapAction ()
   {
      let alert = UIAlertView()
      alert.message = "This field is not editable. Please get in touch with your course administrator to change your email id."
      alert.title = "Contact Administrator"
      alert.addButtonWithTitle("OK")
      alert.show()
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
