//
//  ChangePswdViewController.swift
//  Emeritus
//
//  Created by SB on 10/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation

class ChangePswdViewController: UIViewController,UITextFieldDelegate,UIAlertViewDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    var textFieldName="PassWord"
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let webManager:MSWebManager=MSWebManager.sharedWebInstance() as MSWebManager
        webManager.setCountryCodeFor("")
        
        scrollView.contentSize=CGSizeMake(320, self.view.frame.size.height+50)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.setHidesBackButton(true,animated:true)
         let skipButton = UIBarButtonItem(title:"Confirm", style:.Plain, target: self, action: "SkipAction:")
        navigationItem.rightBarButtonItem = nil
        skipButton.tintColor=UIColor.whiteColor()

        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!], forState: UIControlState.Normal)
        configureTextField()

    }
     func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
         if(textField.tag==1)
        {
        textFieldName="ConfirmPassWord"
        textField.resignFirstResponder()
        let nextTextField=self.view.viewWithTag(textField.tag+1)
        nextTextField?.becomeFirstResponder()
        }
        else
        {
            if(self.navigationItem.rightBarButtonItem?.title=="Confirm")
            {
                cofirmAction()
            }
            else
            {
                
                let SessionUserId:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
                let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                let selectedUser:Users=cdManager.viewProfile(NSNumber(integer:SessionUserId.integerValue)) as Users
                let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
                profileViewController.fromConfirmation = true
                profileViewController.userProfileDetailsFromDb=selectedUser
                self.navigationController?.pushViewController(profileViewController, animated: true)
            }

        }
        return false
    }

    func SkipAction(sender:UIBarButtonItem!)
    {
        
        if(self.navigationItem.rightBarButtonItem?.title=="Confirm")
        {
           cofirmAction()
        }
    }
    
    func cofirmAction()
    {
        
            if((!(passwordTextField.text?.characters.count==0))&&(!(confirmPasswordTextField.text?.characters.count==0)))
            {
                if(((passwordTextField.text?.characters.count>=6))&&((confirmPasswordTextField.text?.characters.count>=6)))//(passwordTextField.text==confirmPasswordTextField.text)
                {
                    if(!(passwordTextField.text==confirmPasswordTextField.text))//((!(countElements(passwordTextField.text)>=6))&&(!(countElements(confirmPasswordTextField.text)>=6)))
                    {
                        let alert = UIAlertView()
                        alert.title = "Alert"
                        alert.message = "Please make sure password and confirm passwords are same"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                    else if(AFNetworkReachabilityManager.sharedManager().reachable)
                    {
                    let webManager:MSWebManager=MSWebManager.sharedWebInstance()
                    webManager.createNewPassword(passwordTextField.text, withResponseCallback: { (responsedictionary:NSMutableDictionary!) -> Void in
                        
                        if((responsedictionary.objectForKey("status")) as! String=="Error")
                        {
                            let alert = UIAlertView()
                            alert.title = "Alert"
                            if(!(responsedictionary.objectForKey("errorMessage")==nil))
                            {
                                alert.message = responsedictionary.objectForKey("errorMessage") as? String
                            }
                            else
                            {
                                alert.message="Invalid response from server"
                            }
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        else  if((responsedictionary.objectForKey("status")) as! String=="Success")
                        {
                            let SessionUserId:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
                            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                            let selectedUser:Users=cdManager.viewProfile(NSNumber(integer:SessionUserId.integerValue)) as Users
                            let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
                            profileViewController.fromConfirmation = true
                            profileViewController.userProfileDetailsFromDb=selectedUser
                            self.navigationController?.pushViewController(profileViewController, animated: true)
                        }
                    })
                    }
                    else
                    {
                        let alert = UIAlertView()
                        alert.title = "Alert"
                        alert.message = "No Internet connectivity"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }

                }
                else
                {
                    let alert = UIAlertView()
                    alert.title = "Password Error"
                    alert.message = "Password should be atleast of 6 characters"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
            else
            {
                let alert = UIAlertView()
                alert.title = "Password Error"
                alert.message = "please enter all details"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            
    }
    
    func textField(lobjtextField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
         if(lobjtextField==passwordTextField)
        {
            let text = passwordTextField.text
            let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
            
            if(newText.characters.count>=1)
            {
                if(!(confirmPasswordTextField.text?.characters.count==0))
                {
                  let nav = self.navigationController?.navigationBar
                  let skipButton = UIBarButtonItem(title:"Confirm", style:.Plain, target: self, action: "SkipAction:")
                  navigationItem.rightBarButtonItem = skipButton
                  
                  skipButton.tintColor=UIColor.whiteColor()
                  
                  let attributes = [
                     NSForegroundColorAttributeName: UIColor.whiteColor(),
                     NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
                  ]
                  nav?.titleTextAttributes = attributes
                  navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!], forState: UIControlState.Normal)
                }
                else
                {
                  self.navigationItem.rightBarButtonItem = nil
                }
                
            }
            else if(newText.characters.count==0)
            {
               self.navigationItem.rightBarButtonItem = nil
                
            }
         }
        if(lobjtextField==confirmPasswordTextField)
        {
            let text = confirmPasswordTextField.text
            let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
            if(newText.characters.count>=1)
            {
                if(!(passwordTextField.text?.characters.count==0))
                {
                  let nav = self.navigationController?.navigationBar
                  let skipButton = UIBarButtonItem(title:"Confirm", style:.Plain, target: self, action: "SkipAction:")
                  navigationItem.rightBarButtonItem = skipButton
                  
                  skipButton.tintColor=UIColor.whiteColor()
                  
                  let attributes = [
                     NSForegroundColorAttributeName: UIColor.whiteColor(),
                     NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
                  ]
                  nav?.titleTextAttributes = attributes
                  navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!], forState: UIControlState.Normal)                }
                else
                {
                    self.navigationItem.rightBarButtonItem = nil
                }
                
            }
            else if(newText.characters.count==0)
            {
                self.navigationItem.rightBarButtonItem = nil
                
            }
            
        }
        

        return true
    }

     func textFieldDidBeginEditing(textField: UITextField) {
        //keyborad Height:253
            scrollView.contentOffset = CGPointMake(0.0,textField.frame.origin.y-(253-55));
   
        }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        scrollView.contentOffset = CGPointZero;
    }

    func configureTextField() {
        
        confirmPasswordTextField.returnKeyType = .Done
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
}
