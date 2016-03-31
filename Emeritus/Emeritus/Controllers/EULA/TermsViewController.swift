//
//  TermsViewController.swift
//  Emeritus
//
//  Copyright © 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        declineButton.layer.cornerRadius = 4.0
        acceptButton.layer.cornerRadius = 4.0
        
        textView.scrollRangeToVisible( NSMakeRange(0, 0) )
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func acceptAction(sender: AnyObject) {
        let alert = UIAlertView()
        alert.title = "Accept EULA"
        alert.message = "I agree to the Emeritus End User License Agreement (EULA)"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Agree")
        alert.tag = 2
        alert.delegate = self
        alert.show()
    }
    
    @IBAction func declineAction(sender: AnyObject) {
        let alert = UIAlertView()
        alert.title = "Decline EULA"
        alert.message = "You will not be able to use the app without accepting the EULA"
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if(alertView.tag==2)
        {
            if(buttonIndex==1)
            {
                NSUserDefaults.standardUserDefaults().setObject("YES", forKey:"termsAccepted")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.dismissViewControllerAnimated(false, completion: nil)
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
