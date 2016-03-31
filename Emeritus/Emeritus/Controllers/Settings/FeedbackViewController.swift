//
//  FeedbackViewController.swift
//  Emeritus
//
//  Created by SB on 11/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class FeedbackViewController: UIViewController , MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func sendingMailAction(sender: AnyObject) {
        
        let webManager:MSWebManager=MSWebManager.sharedWebInstance()
        webManager.feedbackWith(self.feedbackTextView.text, withResponseCallback: { (response : NSMutableDictionary!) -> Void in
            
            let actionSheetController: UIAlertController = UIAlertController(title: "Thank you", message: "We appreciate your feedback. Our team is working hard to improve the app experience and your feedback is valuable to us.", preferredStyle: .Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }
            actionSheetController.addAction(okAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            
        })
        
        //sendingFeedbackthroughEmail()
    }
    
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        
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
        self.sendBtn.enabled=false
        
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 16)!,NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func CancelAction(sender:UIBarButtonItem!)
    {
        //        print("Button tapped")
        self.navigationController?.popViewControllerAnimated(true)
        
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
            self.sendBtn.enabled=false
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
            self.sendBtn.enabled=false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
}