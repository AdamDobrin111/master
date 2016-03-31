//
//  LoginViewController.swift
//  Emeritus
//
//  Created by SB on 11/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

//
//  ViewController.swift
//  Emeritus
//
//  Created by SB on 10/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(self.location)
        let endIndex = startIndex.advancedBy(self.length)
        return startIndex..<endIndex
    }
}
import UIKit
import Foundation

class LoginViewController: UIViewController, UIAlertViewDelegate
{
    
    @IBOutlet weak var ProceedBarButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    var passwdViewController:ChangePswdViewController!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicatorBaseView: UIView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBAction func websiteLinkOpen(sender: UIButton) {
        self.openUrl(sender.titleLabel?.text);
        
    }
    
    @IBAction func forgetPasswordAction(sender: AnyObject) {
        let alert = UIAlertView()
        alert.title = "Recover Password"
        alert.message = "Please enter the email address your account is registered with"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("OK")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.delegate = self
        alert.tag = 2
        alert.show()
    }
    
    var pollManager:PollManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize=CGSizeMake(320, self.view.frame.size.height+100)
        scrollView.scrollEnabled = false;
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        
        ProceedBarButton.enabled=false
        loginButton.enabled=false
        
        indicatorBaseView.layer.masksToBounds=true
        indicatorBaseView.layer.cornerRadius=10.0
        indicatorBaseView.layer.borderWidth=3.0
        indicatorBaseView.layer.borderColor=UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.5).CGColor
        indicatorBaseView.backgroundColor=UIColor(red: 31/255.0, green: 160/255.0, blue: 124/255.0, alpha: 1.0)
        indicatorBaseView.hidden=true
        
        if((((NSUserDefaults.standardUserDefaults().objectForKey("LaunchStatus")))==nil))
        {
            NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"LaunchStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
            self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
            
        }
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.text=""
        indicatorBaseView.hidden=true
        if(!(((NSUserDefaults.standardUserDefaults().objectForKey("LaunchStatus")))==nil))
        {
            
            if ((NSUserDefaults.standardUserDefaults().objectForKey("termsAccepted")) == nil)
            {
                let termsPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("TermsViewController") as! TermsViewController
                self.navigationController?.presentViewController(termsPage, animated:false, completion: nil)
            }
            
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"LaunchStatus")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let walkThroughPage = UIStoryboard(name:"WalkThrough", bundle: nil).instantiateViewControllerWithIdentifier("ERWalkThroughPageViewController") as! ERWalkThroughPageViewController
            self.navigationController?.presentViewController(walkThroughPage, animated:false, completion: nil)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        indicatorBaseView.hidden=false
        
    }
    
    @IBAction func ProceedAction(sender:UIButton) {
        indicatorBaseView.hidden=false
        indicatorLabel.text="Confirmation Process"
        
        textField.resignFirstResponder()
        
        if(textField.text?.characters.count>0)
        {
            if(AFNetworkReachabilityManager.sharedManager().reachable)
            {
                APIServiceSessionManger.ConfirmationCodeWithCompletionBlock(textField.text!, success: { (task, responseObject) -> Void in
                    
                    //                    print(responseObject)
                    
                    let responsedictionary:NSDictionary=responseObject as! NSDictionary
                    if((responsedictionary.objectForKey("status")) as! String=="Error")
                    {
                        let alert = UIAlertView()
                        
                        if(!(responsedictionary.objectForKey("errorMessage")==nil))
                        {
                            alert.title = "Invalid Code"
                            alert.message = "Please correct the Confirmation Code and try again"
                        }
                        else
                        {
                            alert.title = "Error"
                            alert.message="Invalid response from server"
                        }
                        alert.addButtonWithTitle("OK")
                        alert.show()
                        self.indicatorBaseView.hidden=true
                    }
                    else  if((responsedictionary.objectForKey("status")) as! String=="Success")
                    {
                        LoginServices.sharedLogininstance().loginResponseDictionary=responsedictionary as [NSObject : AnyObject]
                        LoginServices.sharedLogininstance().ExtractValuesFromDictionary()
                        LoginServices.sharedLogininstance().saveToUserDefaults()
                        LoginServices.sharedLogininstance().fetchFromUserDefaults()
                        NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"LoginStatus")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        //Participants
                        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
                        webManager.participant()
                        
                        let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        appdelegate.quickbloxsAuthentication()
                        self.indicatorBaseView.hidden=false
                        self.indicatorLabel.text="Authenticating To Chatserver"
                        SessionService.instance().createSession(LoginServices.sharedLogininstance().qbuserName, andPassword:LoginServices.sharedLogininstance().password, withCompletionBlock: { (responseStatus:Bool) -> Void in
                            if(responseStatus==true)
                            {
                                self.indicatorBaseView.hidden=false
                                self.indicatorLabel.text="Login To Chat Server"
                                
                                
                                self.gettingHomeFeedResponse()
                                
                                
                                NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"LoginStatus")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                                let passwordViewController:ChangePswdViewController=storyboard.instantiateViewControllerWithIdentifier("ChangePswdViewController")as! ChangePswdViewController
                                self.navigationController!.pushViewController(passwordViewController, animated: true)
                                //                                self.subscribeForNotifications()
                            }
                            else
                            {
                                let alert = UIAlertView()
                                alert.title = "Alert"
                                alert.message = "Problem while creating session 1"
                                alert.addButtonWithTitle("OK")
                                alert.show()
                            }
                        })
                        
                    }
                    
                    }) { (task, error) -> Void in
                        self.indicatorBaseView.hidden=true
                        print(error)
                        let alert = UIAlertView()
                        alert.title = "Alert"
                        alert.message = "Problem while getting login response"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                }
                
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
    
    func openUrl(url:String!) {
        
        let targetURL=NSURL(string: url)
        let application=UIApplication.sharedApplication()
        application.openURL(targetURL!);
        
    }
    
    func textField(lobjtextField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        let text = lobjtextField.text
        let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
        
        if(lobjtextField==textField)
        {
            if(newText.characters.count>=1)
            {
                ProceedBarButton.enabled=true
            }
            else if(newText.characters.count==0)
            {
                ProceedBarButton.enabled=false
                
            }
        }
        else
        {
            if(lobjtextField==emailTextField)
            {
                let text = emailTextField.text
                let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
                
                if(newText.characters.count>=1)
                {
                    if(!(passwordTField.text!.characters.count==0))
                    {
                        loginButton.enabled=true
                    }
                    else
                    {
                        loginButton.enabled=false
                    }
                    
                }
                else if(newText.characters.count==0)
                {
                    loginButton.enabled=false
                    
                }
            }
            if(lobjtextField==passwordTField)
            {
                let text = passwordTField.text
                let newText = text!.stringByReplacingCharactersInRange(range.toRange(text!), withString: string)
                if(newText.characters.count>=1)
                {
                    if(!(emailTextField.text!.characters.count==0))
                    {
                        loginButton.enabled=true
                    }
                    else
                    {
                        loginButton.enabled=false
                    }
                    
                }
                else if(newText.characters.count==0)
                {
                    loginButton.enabled=false
                    
                }
                
            }
        }
        
        return true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField.tag == 1)
        {
            return;
        }
        scrollView.contentOffset = CGPointMake(0.0,textField.frame.origin.y-(253-55));
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        scrollView.contentOffset = CGPointZero;
    }
    
    func configureTextField() {
        
        passwordTField.returnKeyType = .Done
    }
    
    @IBAction func login(sender: UIButton) {
        
        if((emailTextField.text!.characters.count==0)&&(passwordTField.text!.characters.count==0))
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter  user name and password"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else if((emailTextField.text!.characters.count==0))
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter email id"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else if((passwordTField.text!.characters.count==0))
        {
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Please enter password"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else
        {
            if(AFNetworkReachabilityManager.sharedManager().reachable)
            {
                indicatorBaseView.hidden=false
                indicatorLabel.text="Login Into Application"
                APIServiceSessionManger.loginWithCompletionBlock(emailTextField.text!, passWord:passwordTField.text!, success: { (task, responseObject) -> Void in
                    
                    //                    print(responseObject)
                    
                    let responsedictionary:NSDictionary=responseObject as! NSDictionary
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
                        self.indicatorBaseView.hidden=true
                    }
                    else  if((responsedictionary.objectForKey("status")) as! String=="Success")
                    {
                        LoginServices.sharedLogininstance().loginResponseDictionary=responsedictionary as [NSObject : AnyObject]
                        LoginServices.sharedLogininstance().ExtractValuesFromDictionary()
                        LoginServices.sharedLogininstance().saveToUserDefaults()
                        LoginServices.sharedLogininstance().fetchFromUserDefaults()
                        NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"LoginStatus")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        //Participants
                        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
                        webManager.participant()
                        
                        let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        appdelegate.quickbloxsAuthentication()
                        self.indicatorBaseView.hidden=false
                        self.indicatorLabel.text="Authenticating To Chatserver"
                        SessionService.instance().createSession(LoginServices.sharedLogininstance().qbuserName, andPassword:LoginServices.sharedLogininstance().password, withCompletionBlock: { (responseStatus:Bool) -> Void in
                            if(responseStatus==true)
                            {
                                self.indicatorBaseView.hidden=false
                                self.indicatorLabel.text="Login To Chat Server"
                                
                                self.gettingHomeFeedResponse()
                                let appdelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                                
                                let storyboard : UIStoryboard = UIStoryboard(name: "HomeTimeLine", bundle: nil)
                                let homeTimeLineNavigationController:UINavigationController=storyboard.instantiateViewControllerWithIdentifier("HomeTimeLineNavigationController") as! UINavigationController
                                
                                //let homeViewController = UIStoryboard(name:"HomeTimeLine", bundle: nil).instantiateViewControllerWithIdentifier("HomeTimeLineViewController") as! HomeTimeLineViewController
                                let menuViewController:MenuViewController=storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
                                menuViewController.homeTimeLineNavigationControllerConst = homeTimeLineNavigationController
                                let slideMenuController = SlideMenuController(mainViewController: homeTimeLineNavigationController, leftMenuViewController: menuViewController)
                                appdelegate.window?.rootViewController = slideMenuController
                                appdelegate.window?.makeKeyAndVisible()
                                
                                //                                        self.subscribeForNotifications()
                            }
                            else
                            {
                                self.indicatorBaseView.hidden=true
                                let alert = UIAlertView()
                                alert.title = "Alert"
                                alert.message = "Problem while creating session 2"
                                alert.addButtonWithTitle("OK")
                                alert.show()
                            }
                        })
                    }
                    
                    }, failure: { (task, error) -> Void in
                        self.indicatorBaseView.hidden=true
                        print(error)
                        let alert = UIAlertView()
                        alert.title = "Alert"
                        alert.message = "Problem while getting login response"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                        
                })
                
            }
            else
            {
                self.indicatorBaseView.hidden=true
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "No Internet Connectivity"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
        }
    }
    
    
    func subscribeForNotifications()
    {
        
        let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? NSData
        
        if(deviceToken == nil)
        {
            return
        }
        
        let subscription = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannelAPNS;
        subscription.deviceUDID = deviceId;
        subscription.deviceToken = deviceToken;
        
        QBRequest.createSubscription(subscription, successBlock: { (responce:QBResponse, subscriptions:[QBMSubscription]?) -> Void in
            NSLog("Successfull response!");
            }) { (responce:QBResponse) -> Void in
                
        }
        
        //        QBRequest.registerSubscriptionForDeviceToken(deviceToken!, uniqueDeviceIdentifier: deviceId, successBlock: { (responce:QBResponse, subscriptions:[QBMSubscription]?) -> Void in
        //            NSLog("Successfull response!");
        //            }) { (error:QBError?) -> Void in
        //               NSLog("bad response!");
        //        }
    }
    
    func gettingHomeFeedResponse()
    {
        pollManager = PollManager.instance()
        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        if(AFNetworkReachabilityManager.sharedManager().reachable)
        {
            webManager.HomeFeed({ (homeresponseDictionary:NSMutableDictionary!) -> Void in
                if((homeresponseDictionary.objectForKey("status")) as! String=="Success")
                {
                    let response:NSDictionary=homeresponseDictionary.objectForKey("response") as! NSDictionary
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
                        
                        if let dict = frozenArray.objectAtIndex(0) as? NSDictionary
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
            alert.show()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if(textField.tag==2)
        {
            textField.resignFirstResponder()
            let nextTextField=self.view.viewWithTag(textField.tag+1)
            nextTextField?.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
            return true
        }
        
        //textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.tag == 2)
        {
            indicatorBaseView.hidden=false
            indicatorLabel.text="Process"
            let email = View.textFieldAtIndex(0)!.text
            APIServiceSessionManger.forgotPasswordWithCompletionBlock(email!, success: { (task, responseObject) -> Void in
                self.indicatorBaseView.hidden=true
                let alert = UIAlertView()
                alert.title = "Thank You"
                alert.message = "Please check your registered email id for a link to reset your password"
                alert.addButtonWithTitle("OK")
                alert.show()
                }) { (task, error) -> Void in
                    self.indicatorBaseView.hidden=true
                    print(error)
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Problem while sending your email"
                    alert.addButtonWithTitle("OK")
                    alert.show()
            }
        }
    }
}
