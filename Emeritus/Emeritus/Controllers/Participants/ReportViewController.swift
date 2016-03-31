import UIKit
import Foundation
import MessageUI

class ReportViewController: UIViewController , MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    var reportUserId:NSNumber!
    @IBAction func sendingMailAction(sender: AnyObject) {
        
        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
        
        webManager.reportUserWithId(reportUserId, textReport: self.feedbackTextView.text) { (responce:NSMutableDictionary!) -> Void in
            let alert = UIAlertView()
            alert.title = "Thank you"
            alert.message = "We appreciate your report. We treat any misuse of the terms of use and EULA very seriously. An administrator will be in touch"
            alert.addButtonWithTitle("OK")
            alert.show()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        //sendingFeedbackthroughEmail()
    }
    
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "Please use this form to report any misuse of terms of use and/or EULA by a user. \n\nThe message will be forwarded to an administrator for review and action will be taken within 24 hours from receipt. \n\nPlease include details of the user you are reporting and any additional information that may help the administrator take effective action.\n\nAn administrator may contact you if additional information is required"
        self.navigationItem.setHidesBackButton(true,animated:true)
        
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "keyboardDoneButtonTapped:")]
        
        numberToolbar.sizeToFit()
        feedbackTextView.inputAccessoryView = numberToolbar
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let cancelButton:UIButton  = UIButton(frame:CGRectMake(15,0,58.0,30.0))
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.contentHorizontalAlignment=UIControlContentHorizontalAlignment.Left
        cancelButton.contentEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 0);
        cancelButton.addTarget(self, action: "CancelAction:", forControlEvents: .TouchUpInside)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        
        let nav = self.navigationController?.navigationBar
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        
        navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!], forState: UIControlState.Normal)
        
        self.sendBtn.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        self.sendBtn.enabled=true
        
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func CancelAction(sender:UIBarButtonItem!)
    {
        //        print("Button tapped")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += (keyboardSize.height - 50)
        }
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= (keyboardSize.height - 50)
        }
    }
    
    
    func keyboardDoneButtonTapped(notification: NSNotification)
    {
        view.endEditing(true)
    }
    
    
    @IBAction func tapgestureAction(sender: AnyObject) {
        
        feedbackTextView.resignFirstResponder()
    }
    //****************** Sending Data through Email *************************************/
    func sendingFeedbackthroughEmail()->Void
    {
        if MFMailComposeViewController.canSendMail()
        {
            let messageBody = feedbackTextView.text
            let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
            //var toRecipents = ["bhagya.sri522@gmail.com"]
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("User Feedback")
            mailComposer.title = "Email"
            mailComposer.setMessageBody(messageBody!, isHTML: false)
            
            //mailComposer.setToRecipients(toRecipents)
            mailComposer.shouldAutorotate()
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    //     *************** Mail Composer Delegate methods *************************************/
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            NSLog("Mail cancelled")
            break
        case MFMailComposeResultSaved.rawValue:
            NSLog("Mail saved")
            break
        case MFMailComposeResultSent.rawValue:
            NSLog("Mail sent")
            break
        case MFMailComposeResultFailed.rawValue:
            NSLog("Mail sent failure: %@", [error!.localizedDescription])
            break
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        
        placeHolderLabel.hidden=true
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if(textView.text.characters.count==0)
        {
            placeHolderLabel.hidden=false
            self.sendBtn.enabled=true
        }
        else
        {
            self.sendBtn.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            self.sendBtn.enabled=true
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if(text=="\n")
        {
            textView.resignFirstResponder()
            if(textView.text.characters.count==0)
            {
                placeHolderLabel.hidden=false
            }
            else
            {
                placeHolderLabel.hidden=true
            }
            return false;
        }
        if(text.characters.count>0)
        {
            self.sendBtn.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            self.sendBtn.enabled=true
        }
        if(textView.text.characters.count==0)
        {
            //            self.sendBtn.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
            self.sendBtn.enabled=true
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}