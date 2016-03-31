//
//  ChangePasswordViewController.swift
//  Emeritus
//
//  Created by SB on 13/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

class UpadatePassWordViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var  doneButtonItem:UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        scrollView.contentSize=CGSizeMake(self.view.frame.width, self.view.frame.size.height+50)
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
      
        self.navigationItem.title="Change Password"
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes

       let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        
        doneButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: "doneAction")
        navigationItem.rightBarButtonItem = doneButtonItem
        doneButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        doneButtonItem.enabled=false
        
        configureTextField()

    }
    
    override func viewWillAppear(animated: Bool) {
        
        confirmPassword.text=""
        newPassword.text=""
        currentPassword.text=""
        
    }
    
    func doneAction()
    {
        if((newPassword.text!.characters.count==0)||(confirmPassword.text!.characters.count==0)||(currentPassword.text!.characters.count==0))
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter all details"
            alert.addButtonWithTitle("OK")
            alert.show()

        }
        else if(newPassword.text==confirmPassword.text)
        {
            if(!(newPassword.text!.characters.count>=6) && !(confirmPassword.text!.characters.count>=6))
            {
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Password should be of 6 characters"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            else if(AFNetworkReachabilityManager.sharedManager().reachable)
            {
            let webManager:MSWebManager=MSWebManager.sharedWebInstance()
            webManager.changePassword(newPassword.text, oldPwd:currentPassword.text, withResponseCallback: { (responseDictionary:NSMutableDictionary!) -> Void in
                
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
                    alert.title = "Alert"
                    alert.message = "Successfully Updated"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.backAction()
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
            alert.title = "Alert"
            alert.message = "please make sure new password and confirm passwords are same"
            alert.addButtonWithTitle("OK")
            alert.show()

        }
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
         if(textField.tag==1)
        {
            textField.resignFirstResponder()
            let nextTextField=self.view.viewWithTag(textField.tag+1)
            nextTextField?.becomeFirstResponder()
        }
        else if(textField.tag==2)
        {
            textField.resignFirstResponder()
            let nextTextField=self.view.viewWithTag(textField.tag+1)
            nextTextField?.becomeFirstResponder()
        }
        else if(textField.tag==3)
        {
            textField.resignFirstResponder()
            doneButtonItem.tintColor=UIColor.whiteColor()
            doneButtonItem.enabled=true
             doneAction()
        
        }

        
        return false
    }

    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField.tag == 1)
        {
            return;
        }
        
        //keyborad Height:253
       // scrollView.contentOffset = CGPointMake(0.0,textField.frame.origin.y-(253-55));
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if(textField==currentPassword)
        {
            doneButtonItem.enabled=false
            if((!(newPassword.text!.characters.count==0))&&(!(confirmPassword.text!.characters.count==0)))
            {
                doneButtonItem.tintColor=UIColor.whiteColor()
                doneButtonItem.enabled=true
            }
        
            
        }
        if(textField==newPassword)
        {
            doneButtonItem.enabled=false
            if((!(confirmPassword.text!.characters.count==0))&&(!(currentPassword.text!.characters.count==0)))
            {
                doneButtonItem.tintColor=UIColor.whiteColor()
                doneButtonItem.enabled=true
            }
                 }
             if(textField==confirmPassword)
        {
            let text = textField.text
            let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
            if(newText.characters.count>=1)
            {
                doneButtonItem.tintColor=UIColor.whiteColor()
                doneButtonItem.enabled=true
            }
            else if(newText.characters.count==0)
            {
                doneButtonItem.enabled=false
    
            }
            
        }
        return true
   
}
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        scrollView.contentOffset = CGPointZero;
    }
    
    func configureTextField() {
        
       confirmPassword.returnKeyType = .Done
        
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
