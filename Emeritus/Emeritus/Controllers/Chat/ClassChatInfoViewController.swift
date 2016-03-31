//
//  ClassChatInfoViewController.swift
//  Emeritus
//
//  Created by SB on 13/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
class ClassChatInfoViewController: UIViewController,NavigationToChatPageDlegate
{
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    var homeData:Home!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        self.navigationItem.setHidesBackButton(true,animated:true)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.title="Poll Results"
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        // Do any additional setup after loading the view.
        addingView()
    }
    
    func addingView()
    {
        
        let classchatinfoview:ClassChatInfoView=(NSBundle.mainBundle().loadNibNamed("ClassChatInfoView", owner: self, options: nil)).first as! ClassChatInfoView
        classchatinfoview.frame=CGRectMake(0, 0,320, 568)
        mainScrollView.addSubview(classchatinfoview)
        
        let classchatinfoSecondview:ClassChatInfoSecondView=(NSBundle.mainBundle().loadNibNamed("ClassChatInfoSecondView", owner: self, options: nil)).first as! ClassChatInfoSecondView
        classchatinfoSecondview.delegate=self
        classchatinfoSecondview.homeDataFromClassChatMainPage=homeData
        classchatinfoSecondview.frame=CGRectMake(0,568,320,568)
        mainScrollView.addSubview(classchatinfoSecondview)
        mainScrollView.contentSize=CGSizeMake(320, 950)
        
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navigatingToChatPage(home:Home)
    {
        let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        self.navigationController?.pushViewController(chatViewController, animated: true)
        chatViewController.dialogID = home.dialogID
        //chatViewController.chatTypeenum=chatType.GroupChat
        chatViewController.chatTypeenum=chatType.ClassDiscussion
        chatViewController.popToRootVC=true
        chatViewController.userName=home.name
        chatViewController.classDiscussionType=true
        
        //  print(home.chatRoom)
        chatViewController.chatRoom = home.chatRoom as! QBChatDialog
        updateUnreadMessageCount(home)
    }
    
    func updateUnreadMessageCount(homeObj:Home)
    {
        homeObj.unreadMessageCount=NSNumber(integer:0)
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.childContext.performBlock({ () -> Void in
            do { try cdManager.parentContext.save()} catch { }
            do { try cdManager.childContext.save()} catch { }
            
        })
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
