 //
 //  ChatViewController.swift
//  Emeritus
//
///  Created by SB on 10/02/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//
 
import UIKit
import AssetsLibrary
import MediaPlayer
import MobileCoreServices
import MessageUI
 
 
@objc protocol chatCreatProtocol {
    
    func createChatThread(_:ChatViewController)
}

enum chatType {
    case LearningCircles
    case ClassChat
    case Hangouts   //not required and not using
    case ClassDiscussion
    case StartChat  //not required and not using
    case oneTOOneChat
    case GroupChat
}
 
//extension NSRange {
//    func toRange(string: String) -> Range<String.Index> {
//        let startIndex = advance(string.startIndex, self.location)
//        let endIndex = advance(startIndex, self.length)
//        return startIndex..<endIndex
//    }
//}

class ChatViewController: UIViewController, UITableViewDelegate, UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,othersTableViewCellDelegate,othersTableViewCellCaptionAndImageDelegate,passingImageAndTextToChatPageDelegate,othersTableViewCellCaptionAndImageDownload,personselfTableViewCellWithTextDelegate,personselfTableViewCellWithImageDelegate,selfTableViewCellCaptionAndImageDownload,MSAudioRecVCProtocol
 {
    
    @IBOutlet weak var uploadingFileLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomViewCnst: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableviewTopConstarint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintofTextView: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var greyedView: UIView!
    var chatTypeenum = chatType.LearningCircles
    @IBOutlet weak var chattextView: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var bottomViewheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chattextViewtopConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderLabelForTextView: UILabel!
    var messageList : NSMutableArray!
    var userNames:NSArray!
    var name:Users!
    var recId:NSNumber!
    var chatRoom:QBChatDialog!
    var dialogID : NSString!
    var buddiesButton:UIButton!
    var InfoButton:UIButton!
    var moved:Bool=false
    var kbsize:CGSize=CGSizeZero
    var tbHeight:CGFloat = 0
    var userId:NSString!
    var userName:String=""
    var customPersonTableViewCell:PersonSelfTableViewCell!
    var customOtherTableViewCell:OthersTableViewCell!
    var customePersonTableViewCellWithCaptionAndimage:SelfCaptionAndImageTableViewCell!
    var customeotherTableViewCellWithCaptionAndimage:OtherCaptionAndImageTableViewCell!
    var customeotherTableViewCellWithDownloadCaptionAndimage:OthercellWithCaptionAndDownloadCell!
    var customeselfTableViewCellWithDownloadCaptionAndimage:SelfImageDownloadOptionCell!
    var customResultsChatTableViewCell:PollResultsChatTableViewCell!
    var typingLabel:UILabel!
    var stoptexttimer:NSTimer!
    var attachimagePickerController:UIImagePickerController!
    var audioController:MSAudioRecVC!
    var PopupTableViewCellonOthers:OthersTableViewCell!
    var PopupTableViewCellonOthersCaptionAndImageView:OtherCaptionAndImageTableViewCell!
    var PopupTableViewCellonOthersCaptionDownload:OthercellWithCaptionAndDownloadCell!
    var library:ALAssetsLibrary?
    var moviePlayercontroller: MPMoviePlayerViewController!
    var isViewDidappearInChatPage:Bool=false
    var isDownloadingImagesOrVideos:Bool=false
    var timeinterval:NSDateComponents=ERDateComponents.defaultDateComponents()
    var attachmentView:AttachementOptionsView!
    var toggleVal:Bool!
    var textWidth:CGFloat!
    var textHeight:CGFloat!
    var loadingEarlierMessages:Bool=false
    var selectedIndexPath:NSIndexPath!
    var pollDiscussionType:Bool=false
    var classDiscussionType:Bool=false
    var allLearningCircleParticipants:String=""
    var OnlineUsersObj:OnlineUsers!
    var audioData:NSData!
    var delegate:chatCreatProtocol!
    var popToRootVC:Bool=false
    var isDeletingMode:Bool=false
    var onionView:UIView?
    var backView:UIView?
    var facultyLogin : Bool = false
    var senderFacultyArray : NSMutableArray!
    var audioPlayer:AVAudioPlayer!
    var refreshControl:UIRefreshControl!
    var isRefresh:Bool = false
    var fromMenu:Bool = false
    var colorBackground:UIColor = UIColor.whiteColor()
    var selectedRow :Int = 0
    
    var avatarProfileInfoImageString:String = "avatar_profile_info@2x.png"
    
    var failedLoadingMsg:FailedLoadingMsgV!
    
    var isConnectedNW:Bool = false;
    
    var internetReachable = Reachability.reachabilityForInternetConnection()
    var hostReachable = Reachability.reachabilityWithHostNames()
    
    var myMutableString = NSMutableAttributedString()
    var linkURL:NSURL = NSURL()
    
    override func canBecomeFirstResponder() -> Bool
    {
        return true;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let copyMenuItem = UIMenuItem(title: "Copy", action: Selector("CopyAction:"))
        let deleteMenuItem = UIMenuItem(title: "Delete", action: Selector("DeleteAction:"))
        let forwardMenuItem = UIMenuItem(title: "Forward", action: Selector("ForwardFile:"))
        UIMenuController.sharedMenuController().menuItems = [copyMenuItem,deleteMenuItem,forwardMenuItem]
        UIMenuController.sharedMenuController().update()
        
        toggleVal = false;
        library=ALAssetServices.defaultAssetsLibrary()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading earlier messages")
        self.refreshControl.tintColor = UIColor.grayColor()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.chatTableView.addSubview(refreshControl)
        
        let cellNib:UINib = UINib(nibName:"PersonSelfTableViewCell", bundle: nil) as UINib
        self.chatTableView.registerNib(cellNib, forCellReuseIdentifier: "PersonSelfTableViewCell")
        customPersonTableViewCell = cellNib.instantiateWithOwner(nil, options:  nil)[0]as! PersonSelfTableViewCell
        let personselfcellWithImageAndTextNib:UINib = UINib(nibName:"SelfCaptionAndImageTableViewCell", bundle: nil) as UINib
        self.chatTableView.registerNib(personselfcellWithImageAndTextNib, forCellReuseIdentifier: "SelfCaptionAndImageTableViewCell")
        customePersonTableViewCellWithCaptionAndimage = personselfcellWithImageAndTextNib.instantiateWithOwner(nil, options:  nil)[0]as! SelfCaptionAndImageTableViewCell
        let personselfcellWithWithCaptionandTextDownloadNib:UINib = UINib(nibName:"SelfImageDownloadOptionCell", bundle: nil) as UINib
        self.chatTableView.registerNib(personselfcellWithWithCaptionandTextDownloadNib, forCellReuseIdentifier: "SelfImageDownloadOptionCell")
        customeselfTableViewCellWithDownloadCaptionAndimage=personselfcellWithWithCaptionandTextDownloadNib.instantiateWithOwner(nil, options:  nil)[0]as! SelfImageDownloadOptionCell
        
        let otherchatcellNib:UINib = UINib(nibName:"OthersTableViewCell", bundle: nil) as UINib
        self.chatTableView.registerNib(otherchatcellNib, forCellReuseIdentifier: "OthersTableViewCell")
        customOtherTableViewCell = otherchatcellNib.instantiateWithOwner(nil, options:  nil)[0]as! OthersTableViewCell
        let otherchatcellNibWithCaptionandText:UINib = UINib(nibName:"OtherCaptionAndImageTableViewCell", bundle: nil) as UINib
        self.chatTableView.registerNib(otherchatcellNibWithCaptionandText, forCellReuseIdentifier: "OtherCaptionAndImageTableViewCell")
        customeotherTableViewCellWithCaptionAndimage = otherchatcellNibWithCaptionandText.instantiateWithOwner(nil, options:  nil)[0]as! OtherCaptionAndImageTableViewCell
        let otherchatcellNibWithCaptionandTextDownload:UINib = UINib(nibName:"OthercellWithCaptionAndDownloadCell", bundle: nil) as UINib
        self.chatTableView.registerNib(otherchatcellNibWithCaptionandTextDownload, forCellReuseIdentifier: "OthercellWithCaptionAndDownloadCell")
        customeotherTableViewCellWithDownloadCaptionAndimage = otherchatcellNibWithCaptionandTextDownload.instantiateWithOwner(nil, options:  nil)[0]as! OthercellWithCaptionAndDownloadCell
        
        let resultsTableViewCell:UINib = UINib(nibName:"PollResultsChatTableViewCell", bundle: nil) as UINib
        self.chatTableView.registerNib(resultsTableViewCell, forCellReuseIdentifier: "PollResultsChatTableViewCell")
        customResultsChatTableViewCell = resultsTableViewCell.instantiateWithOwner(nil, options:  nil)[0]as! PollResultsChatTableViewCell
        
        chatTableView.userInteractionEnabled = true
        chatTableView.hidden=true
        placeholderLabelForTextView.alpha=0.8
        messageList=NSMutableArray()
        userNames = NSMutableArray()
        
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        self.navigationItem.setHidesBackButton(true,animated:true)
        let nav = self.navigationController?.navigationBar
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        
        //Adding label on Navigation Bar
        typingLabel=UILabel(frame:CGRectMake(0,32, UIScreen.mainScreen().bounds.size.width,16))
        typingLabel.text="  typing..."
        typingLabel.textColor=UIColor.whiteColor()
        //        typingLabel.backgroundColor=UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha:1.0)
        typingLabel.backgroundColor=UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha:1.0)
        typingLabel.font=UIFont(name: "Avenir-Roman", size:13)
        
        typingLabel.hidden=true
        //        self.view.window?.addSubview(typingLabel)
        nav?.addSubview(typingLabel)
        
        tbHeight = self.view.frame.size.height;
        chattextView.layer.masksToBounds=true
        chattextView.layer.borderColor=UIColor(red: 54/255.0, green: 54/255.0, blue: 54/255.0, alpha: 0.57).CGColor
        chattextView.layer.borderWidth=0.5
        chattextView.layer.cornerRadius = 3;
        
        self.view.bringSubviewToFront(self.uploadingFileLabel)
        self.view.bringSubviewToFront(self.activityIndicatorView)
        
        userId=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
        //print(userId)
        self.navigationController?.navigationItem.title=userName
        switch chatTypeenum {

        case .oneTOOneChat:
            if(self.chatRoom == nil)
            {
                self.chatRoom = QBChatDialog(dialogID: self.dialogID as String, type: QBChatDialogType.Private)
            }
            self.chatRoom.occupantIDs = [UInt(self.recId)]
            self.navigationItem.title=userName
            break
            
        case .GroupChat:
            
            self.navigationItem.title=userName
            break
        case .LearningCircles:
            self.navigationItem.title=userName
            break
            
        default:
            break
            
        }
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 17)!
        ]
        nav?.titleTextAttributes = attributes
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 17)!], forState: UIControlState.Normal)
        chatTableView.separatorColor=UIColor.clearColor()
        chatTableView.separatorStyle=UITableViewCellSeparatorStyle.None
        
        if(fromMenu == false)
        {
            
            let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
            navigationItem.leftBarButtonItem = backButton
            backButton.tintColor=UIColor.whiteColor()
            
        }
        else
        {
            let ProfileButton:UIButton  = UIButton(frame:  CGRectMake(15, 0,23.0, 23.0))
            ProfileButton.setImage(UIImage(named: "hamburger.png"), forState: .Normal)
            ProfileButton.addTarget(self, action: "menuAction", forControlEvents: .TouchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ProfileButton)
        }
        
        
        OnlineUsersObj = OnlineUsers.sharedInstance()
        
        attachimagePickerController = UIImagePickerController()
        attachimagePickerController.delegate = self
        attachimagePickerController.allowsEditing = true
        chatTableView.backgroundColor=UIColor.whiteColor()
        if(pollDiscussionType==true)
        {
            let infoButton = UIBarButtonItem (image:UIImage(named:"mav-info.png"), style: .Plain, target: self,action: "InfoAction")
            infoButton.tintColor=UIColor.whiteColor()
            //            navigationItem.rightBarButtonItem = infoButton
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            participantsButton.tintColor=UIColor.whiteColor()
            navigationItem.rightBarButtonItems = [participantsButton,infoButton]
        }
        
        if(classDiscussionType==true)
        {
            let infoButton = UIBarButtonItem (image:UIImage(named:"mav-frozen.png"), style: .Plain, target: self,action: "InfoAction")
            infoButton.tintColor=UIColor.whiteColor()
            //            navigationItem.rightBarButtonItem = infoButton
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            participantsButton.tintColor=UIColor.whiteColor()
            navigationItem.rightBarButtonItems = [participantsButton,infoButton]
        }
        
        let loginservicesObj = LoginServices.sharedLogininstance()
        loginservicesObj.fetchFromUserDefaults()
        if(loginservicesObj.role.integerValue==3)
        {
            facultyLogin = true
        }
        
        failedLoadingMsg = FailedLoadingMsgV.init(frame: CGRectMake(0, (nav?.bounds.size.height)! + 20, self.view.frame.size.width, 40))
        self.view.addSubview(failedLoadingMsg)
        failedLoadingMsg.hidedSelf()
        
        
        failedLoadingMsg.hidedSelf()
        
        
        joinRoom()
        
        
        
    }
    
    func menuAction()
    {
        self.slideMenuController()?.toggleLeft()
    }
    
    func joinRoom()
    {
        //join room
        switch chatTypeenum
        {
            
        case .GroupChat:
            
            self.chatRoom.joinWithCompletionBlock({ (error:NSError?) -> Void in
                let forwardService  = ForwardService.sharedInstance()
                if(forwardService.attachment != nil)
                {
                    let message = QBChatMessage()
                    message.text = " "
                    message.attachments = [forwardService.attachment!]
                    let param = NSMutableDictionary()
                    param.setValue(true, forKey: "save_to_history")
                    message.customParameters = param
                    self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                        forwardService.attachment=nil
                        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                        let chatBubble = Chat.findOrCreateChatWithIdentifier((message).ID, inContext: cdManager.parentContext)
                        chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                        let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                        home.storeMessage(message)
                    })
                }
            })
            
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            navigationItem.rightBarButtonItem = participantsButton
            participantsButton.tintColor=UIColor.whiteColor()
            
            break
        case .LearningCircles:
            
            self.chatRoom.joinWithCompletionBlock({ (error:NSError?) -> Void in
                let forwardService  = ForwardService.sharedInstance()
                if(forwardService.attachment != nil)
                {
                    let message = QBChatMessage()
                    message.attachments = [forwardService.attachment!]
                    let param = NSMutableDictionary()
                    param.setValue(true, forKey: "save_to_history")
                    message.customParameters = param
                    self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                        forwardService.attachment=nil
                        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                        let chatBubble = Chat.findOrCreateChatWithIdentifier((message).ID, inContext: cdManager.parentContext)
                        chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                        let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                        home.storeMessage(message)
                    })
                }
            })
            
            //let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
            //navigationItem.leftBarButtonItem = backButton
            //backButton.tintColor=UIColor.whiteColor()
            
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            navigationItem.rightBarButtonItem = participantsButton
            participantsButton.tintColor=UIColor.whiteColor()
            
            //Onion Screen
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginStatus")) as! String=="YES")
            {
                if !(NSUserDefaults.standardUserDefaults().boolForKey("HasVisitedLeraningCircle"))
                {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasVisitedLeraningCircle")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    onionView = UIView(frame: self.view.frame)
                    onionView!.alpha=0.4
                    onionView!.backgroundColor=UIColor.blackColor()
                    backView = UIView(frame: CGRectMake(10, 80, self.view.frame.size.width-20, 100))
                    backView!.backgroundColor=UIColor.whiteColor()
                    backView!.layer.cornerRadius=6
                    let lblTip = UILabel(frame: CGRectMake(5, 0, backView!.frame.size.width-10, backView!.frame.size.height-10))
                    lblTip.text="This is the group to discuss assignments together"
                    lblTip.numberOfLines=4
                    lblTip.backgroundColor=UIColor.whiteColor()
                    lblTip.tintColor=UIColor.blackColor()
                    lblTip.layer.cornerRadius=10
                    //backView!.addSubview(lblTip)
                    //self.view.addSubview(onionView!)
                    //self.view.addSubview(backView!)
                    let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapGesture:"))
                    onionView!.addGestureRecognizer(tapGesture)
                }
            }
            
            break
            
            //        case .ClassDiscussion:
            //
            ////                var participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            ////                navigationItem.rightBarButtonItem = participantsButton
            ////                participantsButton.tintColor=UIColor.whiteColor()
            
        default:
            let forwardService  = ForwardService.sharedInstance()
            if(forwardService.attachment != nil)
            {
                let message = QBChatMessage()
                message.text = " "
                message.attachments = [forwardService.attachment!]
                message.senderID=UInt(userId.intValue)
                let param = NSMutableDictionary()
                param.setValue(true, forKey: "save_to_history")
                message.customParameters = param
                self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                    forwardService.attachment=nil
                    self.gettingMessagesFromQuickbloxs()
                })
            }
            break
            
        }
        
    }
    
    func tapGesture(sender: UIGestureRecognizer)
    {
        self.onionView!.removeFromSuperview()
        self.backView!.removeFromSuperview()
    }
    
    func refresh(sender:AnyObject)
    {
        isRefresh = true;
        gettingHistoryFromQuickbloxs()
        _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("endRefresh"), userInfo: nil, repeats: false)
        self.chatTableView.userInteractionEnabled = true
    }
    
    func endRefresh() {
        self.refreshControl.endRefreshing()
        isRefresh = false;
        self.chatTableView.userInteractionEnabled = true
    }
    
    func audioWithURL(fileUrl: NSURL!, withData data: NSData!) {
        
        if (NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!))
        {
            self.audioData=data
            let chatcaptionViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatCaptionViewController") as! ChatCaptionViewController
            chatcaptionViewController.audioUrl=fileUrl
            chatcaptionViewController.delegate=self
            chatcaptionViewController.audioName=fileUrl.lastPathComponent
            chatcaptionViewController.sendTouserName=self.userName
            self.navigationController?.pushViewController(chatcaptionViewController, animated: false)
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        else
        {
            self.showAlert("Alert", text: "Please check the setting to record audio")
        }
        
    }
    
    func gettingMessagesFromQuickbloxs()
    {
        let extendedRequest = NSMutableDictionary()
        extendedRequest.setValue("date_sent",forKey:"sort_desc")
        //extendedRequest.setValue(self.messageList.count,forKey:"skip")
        extendedRequest.setValue(20,forKey:"limit")
        if(!(self.dialogID == nil))
        {
            let resPage = QBResponsePage(limit:100, skip: 0)
            QBRequest.messagesWithDialogID(self.dialogID as String,
                extendedRequest: nil,
                forPage: resPage,
                successBlock: { (response: QBResponse, messages: [QBChatMessage]?, responcePage: QBResponsePage?) in
                    
                    let array = messages! as NSArray
                    
                    let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    cdManager.childContext.performBlock({ () -> Void in
                        
                        for (_, element) in array.enumerate()  {
                            let chatBubble = Chat.findOrCreateChatWithIdentifier((element as! QBChatMessage).ID, inContext: cdManager.parentContext)
                            chatBubble.storeMessage(element as! QBChatMessage, forDialogId: self.dialogID as String)
                            let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                            home.storeMessage(element as! QBChatMessage)
                            
                            if( (element as! QBChatMessage).read == false)
                            {
                                //                            QBChat.instance().readMessage(element as! QBChatMessage)
                                
                                QBChat.instance().readMessage(element as! QBChatMessage, completion:
                                    { (error) -> Void in
                                        
                                })
                                
                            }
                        }
                        do { try cdManager.childContext.save()} catch { }
                        
                        dispatch_sync(dispatch_get_main_queue(), {
                            
                            do { try cdManager.parentContext.save()} catch { }
                            self.fetchDataOnLoading(self.dialogID)
                        });
                        
                    })
                    
                }, errorBlock: {(response: QBResponse!) in
                    
            })
            
        }
        
    }
    
    func gettingHistoryFromQuickbloxs()
    {
        let extendedRequest = NSMutableDictionary()
        extendedRequest.setValue("date_sent",forKey:"sort_desc")
        extendedRequest.setValue(self.messageList.count,forKey:"skip")
        extendedRequest.setValue(20,forKey:"limit")
        
        let resPage = QBResponsePage(limit:20, skip: 0)
        QBRequest.messagesWithDialogID(self.dialogID as String,
            extendedRequest: nil,
            forPage: resPage,
            successBlock: { (response: QBResponse, messages: [QBChatMessage]?, responcePage: QBResponsePage?) in
                
                let array = messages! as NSArray
                
                let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                cdManager.childContext.performBlock({ () -> Void in
                    
                    for (_, element) in array.enumerate()  {
                        let chatBubble = Chat.findOrCreateChatWithIdentifier((element as! QBChatMessage).ID, inContext: cdManager.parentContext)
                        chatBubble.storeMessage(element as! QBChatMessage, forDialogId: self.dialogID as String)
                        let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                        home.storeMessage(element as! QBChatMessage)
                        if((element as! QBChatMessage).read == false)
                        {
                            QBChat.instance().readMessage(element as! QBChatMessage, completion:
                                { (error) -> Void in
                                    
                            })
                        }
                    }
                    do { try cdManager.childContext.save()} catch { }
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        
                        do { try cdManager.parentContext.save()} catch { }
                        self.fetchDataOnLoading(self.dialogID)
                    });
                    
                })
                
            }, errorBlock: {(response: QBResponse!) in
                
        })
    }
    
    func clearButtonAction()
    {
        switch chatTypeenum
        {
        case .GroupChat:
            
            if(fromMenu == false)
            {
                let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
                navigationItem.leftBarButtonItem = backButton
                backButton.tintColor=UIColor.whiteColor()
            }
            else
            {
                let ProfileButton:UIButton  = UIButton(frame:  CGRectMake(15, 0,23.0, 23.0))
                ProfileButton.setImage(UIImage(named: "hamburger.png"), forState: .Normal)
                ProfileButton.addTarget(self, action: "menuAction", forControlEvents: .TouchUpInside)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ProfileButton)
            }
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            navigationItem.rightBarButtonItem = participantsButton
            participantsButton.tintColor=UIColor.whiteColor()
            
            break

        case .LearningCircles:
            if(fromMenu == false)
            {
                let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
                navigationItem.leftBarButtonItem = backButton
                backButton.tintColor=UIColor.whiteColor()
            }
            else
            {
                let ProfileButton:UIButton  = UIButton(frame:  CGRectMake(15, 0,23.0, 23.0))
                ProfileButton.setImage(UIImage(named: "hamburger.png"), forState: .Normal)
                ProfileButton.addTarget(self, action: "menuAction", forControlEvents: .TouchUpInside)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ProfileButton)
            }
            
            let participantsButton = UIBarButtonItem (image:UIImage(named:"participants_icon@2x.png"), style: .Plain, target: self,action: "BuddiesAction")
            navigationItem.rightBarButtonItem = participantsButton
            participantsButton.tintColor=UIColor.whiteColor()
            break
        
        case .oneTOOneChat:
            let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
            navigationItem.leftBarButtonItem = backButton
            backButton.tintColor=UIColor.whiteColor()
            navigationItem.rightBarButtonItem=nil
            break
        
        default:
            break
        }

        selectedIndexPath=NSIndexPath()
        isDeletingMode=false
        self.fetchDataOnLoading(self.dialogID)
    }
    
    func deleteAction()
    {
        if(!(selectedIndexPath==nil))
        {
            
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            
            self.isDownloadingImagesOrVideos=false
            self.loadingEarlierMessages=false
            let chatobj:Chat=self.messageList.objectAtIndex(selectedIndexPath.row) as! Chat
            
            QBRequest.deleteMessagesWithIDs(Set(arrayLiteral:chatobj.chatID), forAllUsers: true, successBlock: { (response: QBResponse!) -> Void in
                cdManager.childContext.performBlock({ () -> Void in
                    let deletedObject:NSManagedObject=chatobj as NSManagedObject
                    
                    var deleteContext:NSManagedObjectContext
                    deleteContext=deletedObject.managedObjectContext!
                    deleteContext.deleteObject(cdManager.parentContext.objectWithID(chatobj.objectID))
                    
                    do { try cdManager.childContext.save()} catch { }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        do { try cdManager.parentContext.save()} catch { }
                        self.clearButtonAction()
                    })
                })
                }) { (response: QBResponse!) -> Void in
                    self.showAlert("Error", text: "Can't delete message")
            }
            
        }
    }
    
    func copyAction(notification: NSNotification)
    {
        
    }
    override func viewDidAppear(animated: Bool) {
        
        isViewDidappearInChatPage=true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        ChatService.instance().isOnline = true
        self.navigationController?.navigationBarHidden = false
        self.isDownloadingImagesOrVideos = false
        isViewDidappearInChatPage = false
        chattextView.resignFirstResponder()
        super.viewWillAppear(animated)
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        bottomViewCnst.constant=0
        
        if let _=self.dialogID
        {
            fetchDataOnLoading(self.dialogID)
        }
        
        self.gettingMessagesFromQuickbloxs()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyPressed:", name: UITextViewTextDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideTypingLabel", name: kNotificationUserIsStopTyping, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showTypingLabel", name: kNotificationUserIsStartTyping, object: nil)
        
        // Set chat notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectedNetwork:", name:kNetworkStatusConnected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disconnectedNetwork:", name:kNetworkStatusDisconnected, object: nil)
                
        //network reachable
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkNetworkStatus:", name:kReachabilityChangedNotification, object: nil)
        internetReachable.startNotifier()
        hostReachable.startNotifier()

    }
    
    func checkNetworkStatus(notice : NSNotification)
    {
        // called after network status changes
        let internetStatus : NetworkStatus = internetReachable.currentReachabilityStatus()
        switch (internetStatus)
        {
        case NetworkStatus.NotReachable:
            NSLog("The internet is down.")
            ChatService.instance().isNetworkConnected = false
            self.disconnectedNetwork()
            break
        case .ReachableViaWiFi:
            NSLog("The internet is working via WIFI.")
            ChatService.instance().isNetworkConnected = true
            self.connectedNetwork()
            break
        case .ReachableViaWWAN:
            NSLog("The internet is working via WWAN.")
            ChatService.instance().isNetworkConnected = true
            self.connectedNetwork()
            break
        }
        
        let hostStatus : NetworkStatus = hostReachable.currentReachabilityStatus()
        switch (hostStatus)
        {
        case .NotReachable:
            NSLog("A gateway to the host server is down.")
            ChatService.instance().isNetworkConnected = false
            self.disconnectedNetwork()
            break
        case .ReachableViaWiFi:
            NSLog("A gateway to the host server is working via WIFI.")
            ChatService.instance().isNetworkConnected = true
            self.connectedNetwork()
            break
        case .ReachableViaWWAN:
            NSLog("A gateway to the host server is working via WWAN.")
            ChatService.instance().isNetworkConnected = true
            self.connectedNetwork()
            break
        }
    }
    
    func attachAction()
    {
        chattextView.resignFirstResponder()
        moved=false;
        if toggleVal==false
        {
            greyedView.hidden=false
            toggleVal=true
            if attachmentView==nil
            {
                attachmentView=NSBundle.mainBundle().loadNibNamed("AttachementOptionsView", owner: self, options: nil).last as! AttachementOptionsView!
                attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,self.view.frame.size.height, attachmentView.frame.size.width, attachmentView.frame.size.height)
                attachmentView.layer.masksToBounds=true
                attachmentView.layer.cornerRadius=3.0
            }
            self.view.addSubview(attachmentView)
            attachmentView.attachmentAction={(tag) in
                
                if tag == 1
                {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                        self.attachimagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                        self.attachimagePickerController.view.tag=3000
                        self.attachimagePickerController.mediaTypes = [kUTTypeImage as String]
                        self.attachimagePickerController.allowsEditing = false
                        self.presentViewController(self.attachimagePickerController, animated: true, completion: nil)
                        
                    }
                }
                else  if tag == 2
                {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
                    {
                        self.attachimagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                        self.attachimagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                        self.attachimagePickerController.allowsEditing = false
                        self.presentViewController(self.attachimagePickerController, animated: true, completion: nil)
                    }
                    else
                    {
                        self.showAlert("Alert", text: "Camera is not available")
                    }
                }
                else  if tag == 3
                {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                        
                        self.attachimagePickerController.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
                        self.attachimagePickerController.view.tag=3000
                        self.attachimagePickerController.mediaTypes = [kUTTypeMovie as String]
                        self.attachimagePickerController.allowsEditing = false
                        self.presentViewController(self.attachimagePickerController, animated: true, completion: nil)
                        
                    }
                }
                    
                else if tag==4
                {
                    self.audioController=nil
                    self.audioController=MSAudioRecVC(nibName: "MSAudioRecVC", bundle: NSBundle.mainBundle())
                    self.audioController.delegateAudioRecVC=self
                    self.presentViewController(self.audioController, animated: true, completion: nil)
                }
                else
                {
                    
                }
                
            }
            UIView.animateWithDuration(0.2, delay:0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,(self.bottomView.frame.origin.y-self.attachmentView.frame.size.height-5), self.attachmentView.frame.size.width, self.attachmentView.frame.size.height)
                }) { (finished:Bool) -> Void in
            }
        }//togg
            
        else
        {
            toggleVal=false;
            if let _ = attachmentView//!(attachmentView==nil)
            {
                
                UIView.animateWithDuration(0.2, delay:0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    
                    self.attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,self.view.frame.size.height, self.attachmentView.frame.size.width, self.attachmentView.frame.size.height)
                    self.greyedView.hidden=true
                    self.toggleVal=false
                    }) { (finished:Bool) -> Void in
                        
                }
            }
        }
    }
    
    func InfoAction()
    {
        if(classDiscussionType==true)
        {
            let chatInfoViewController:FrozenPostViewController = UIStoryboard(name:"Chat", bundle: nil).instantiateViewControllerWithIdentifier("FrozenPostViewController") as! FrozenPostViewController
            self.navigationController?.pushViewController(chatInfoViewController, animated: true)
        }
        else
        {
            let chatInfoViewController:ClassChatInfoViewController = UIStoryboard(name:"Chat", bundle: nil).instantiateViewControllerWithIdentifier("ClassChatInfoViewController") as! ClassChatInfoViewController
            self.navigationController?.pushViewController(chatInfoViewController, animated: true)
        }
    }
    
    func backAction()
    {
        if(isViewDidappearInChatPage==true)
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.navigatingToBackPage()
            })
        }
    }
    
    func navigatingToBackPage()
    {
        
        if popToRootVC==true
        {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func BuddiesAction()
    {
        if(isViewDidappearInChatPage==true)
        {
            
            if(!(self.allLearningCircleParticipants==""))
            {
                let participantsVC = UIStoryboard(name: "Participants", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ParticipantsCollectionVC") as! ParticipantsCollectionVC
                participantsVC.strParticipants = self.allLearningCircleParticipants
                self.navigationController?.pushViewController(participantsVC, animated: true)
            }
            
        }
        
    }
    
    func showTypingLabel()
    {
        switch chatTypeenum {
        case  .oneTOOneChat:
            typingLabel.hidden=false
            break
        case  .GroupChat:
            
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "userID=%@",ChatService().typingUSerId ))
            if(!(filtered.count == 0))
            {
                for AnyObject in filtered{
                    
                    name = AnyObject as! Users
                }
            }
            self.typingLabel.hidden=false
            ///(name)
            self.typingLabel.text=name.userName+" typing........"
            
        case  .LearningCircles:
            
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "userID=%@",ChatService().typingUSerId ))
            if(!(filtered.count == 0))
            {
                for AnyObject in filtered{
                    
                    name = AnyObject as! Users
                }
            }
            self.typingLabel.hidden=false
            //(name)
            self.typingLabel.text=name.userName+" typing........"
            break
        default:
            break
        }
        
        //        for vw in self.view.subviews
        //        {
        //            if vw.tag==5000
        //            {
        //                typingLabel.frame=CGRectMake(0, 80, typingLabel.frame.size.width, typingLabel.frame.size.height)
        //            }
        //        }
    }
    
    func hideTypingLabel() {
        
        typingLabel.hidden=true
    }
    
    func sizeOfString (string: NSString, constrainedToWidth width: Double) -> CGSize {
        
        return string.boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18.0)],
            context: nil).size
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        if(gestureRecognizer.view==bottomView)
        {
            return false
        }
        
        return true
    }
    @IBAction func tapgestureAction(sender:UITapGestureRecognizer)
    {
        toggleVal=false;
        if(!(attachmentView==nil))
        {
            
            UIView.animateWithDuration(0.2, delay:0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,self.view.frame.size.height, self.attachmentView.frame.size.width, self.attachmentView.frame.size.height)
                }) { (finished:Bool) -> Void in
                    
                    self.attachmentView.removeFromSuperview()
                    //                    self.attachmentView=nil
                    self.greyedView.hidden=true
                    self.toggleVal=false
            }
        }
        let intrv = NSTimeInterval(0.3)
        UIView.animateWithDuration(intrv, animations: { () -> Void in
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        })
        self.chattextView.resignFirstResponder()
        
    }
    
    func keyPressed(notification: NSNotification)
    {
        
        let fixedWidth = chattextView.frame.size.width
        chattextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = chattextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = chattextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if(newFrame.size.height > ((self.view.frame.size.height)/(1.6)))
        {
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: (self.view.frame.size.height)/(1.6))
            chattextView.frame = newFrame;
        }
        else
        {
            chattextView.frame = newFrame;
        }
        bottomViewheightConstraint.constant=(newFrame.size.height) + 15
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        typingLabel.hidden=true
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNotificationDidReceiveNewMessage,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNotificationDidReceiveNewMessageFromRoom,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNotificationUserIsStopTyping,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNotificationUserIsStartTyping,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:MPMoviePlayerPlaybackDidFinishNotification,object:nil)
        if(!(attachmentView==nil))
        {
            
            UIView.animateWithDuration(0.2, delay:0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                self.attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,self.view.frame.size.height, self.attachmentView.frame.size.width, self.attachmentView.frame.size.height)
                }) { (finished:Bool) -> Void in
                    
                    self.attachmentView.removeFromSuperview()
                    self.attachmentView=nil
                    self.greyedView.hidden=true
                    self.toggleVal=false
            }
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNetworkStatusConnected,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kNetworkStatusDisconnected,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:kReachabilityChangedNotification,object:nil)
        
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if(!moved) {
            
            toggleVal=false;
            if(!(attachmentView==nil))
            {
                
                UIView.animateWithDuration(0.5, delay:0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    
                    self.attachmentView.frame=CGRectMake((self.view.frame.size.width-320)/2,self.view.frame.size.height, self.attachmentView.frame.size.width, self.attachmentView.frame.size.height)
                    }) { (finished:Bool) -> Void in
                        
                        self.attachmentView.removeFromSuperview()
                        self.greyedView.hidden=true
                }
            }
            moved = true;
        }
    }
    
    func gettingStringsize( text:NSString)->CGSize
    {
        var textSize:CGSize
        let attributes:NSDictionary=[NSFontAttributeName: UIFont.systemFontOfSize(14.0)]
        textSize=text.sizeWithAttributes(attributes as? [String : AnyObject])
        return textSize
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText lobjtext: String) -> Bool
    {
        if(textView.text.characters.count + (lobjtext.characters.count - range.length)==0)
        {
            placeholderLabelForTextView.hidden=false
            
        }
        else
        {
            placeholderLabelForTextView.hidden=true
            
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView)
    {
        //self.view.setNeedsLayout()
        let textHeight = (chattextView.contentSize.height)
        //NSLog("%@"chattextView.contentSize.height)
        bottomView.frame = CGRectMake(bottomView.frame.origin.x, bottomView.frame.origin.y, bottomView.frame.size.width, textHeight+30)
        if(!(self.recId===nil))
        {
            stoptexttimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("stopthetypeNotification"), userInfo: nil, repeats:false)
            //QBChat.instance().sendUserIsTypingToUserWithID(UInt(self.recId.intValue))
        }
        
    }
    
    func stopthetypeNotification()
    {
        if(!(self.recId===nil))
        {
            //QBChat.instance().sendUserStopTypingToUserWithID(UInt(self.recId.intValue))
            if(!(stoptexttimer==nil))
            {
                stoptexttimer.invalidate()
            }
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if(!(stoptexttimer==nil))
        {
            if(!(self.recId===nil))
            {
                // QBChat.instance().sendUserStopTypingToUserWithID(UInt(self.recId.intValue))
            }
            stoptexttimer.invalidate()
        }
        
        if(textView.text.characters.count==0)
        {
            placeholderLabelForTextView.hidden=false
            bottomViewCnst.constant=0
            
        }
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool
    {
        
        return true
    }
    /**
     For sending message.
     
     :param: sender button object
     */
    
    func msgSend()
    {
        //
        let message = QBChatMessage.markableMessage() ///
        message.text = self.chattextView.text
        message.dateSent=NSDate()
        textWidth=self.chattextView.contentSize.width
        textHeight=self.chattextView.contentSize.height
        let currenttimeInSeconds:NSTimeInterval=NSDate().timeIntervalSince1970
        let param = NSMutableDictionary()
        param.setValue(true, forKey: "save_to_history")
        param.setValue(currenttimeInSeconds,forKey: "date_sent")
        message.customParameters = param
        //message.senderID = LocalStorageService.shared().currentUser.ID
        switch chatTypeenum
        {
        case .oneTOOneChat:
            
            message.senderID=UInt(userId.intValue)
            message.markable = true;
            message.dateSent = NSDate()
            
            self.chatRoom.occupantIDs = [UInt(self.recId)]
            
            if ChatService.instance().isNetworkConnected {
                
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                //ChatService.instance().sendMessage(message)
                // self.chatRoom.recipientID = UInt(self.recId)
                
                self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                    if(error == nil)
                    {
                        NSLog("sent");
                        self.failedLoadingMsg.hideSelf()
                        //start storing in DB
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            //    print("This is run on the background queue")
                            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                            cdManager.childContext.performBlock({ () -> Void in
                                let bool:Bool = true
                                let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdManager.parentContext)
                                chatBubble.updateSendStatus(bool)
                                chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                                
                                let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                                home.storeMessage(message)
                                
                                //                            chatBubble.dialogID=self.dialogID
                                
                                do { try cdManager.childContext.save()} catch { }
                                
                                dispatch_sync(dispatch_get_main_queue(), {
                                    
                                    do { try cdManager.parentContext.save()} catch { }
                                    self.fetchDataOnLoading(self.dialogID)
                                });
                            })
                        })
                        
                    }
                    else
                    {
                        self.disconnectedNetwork()
                    }
                })
                
            }
            else{
                print("APIServiceSessionManger ************** NETWORK OFFLINE")
                self.disconnectedNetwork()
            }
            
            break
            
        case .GroupChat:
            if(ChatService.instance().isNetworkConnected){
                message.senderID=UInt(userId.intValue)
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                
                self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                    if (error == nil)
                    {
                        self.failedLoadingMsg.hideSelf()
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            //print("This is run on the background queue")
                            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                            cdManager.childContext.performBlock({ () -> Void in
                                let bool:Bool = true
                                let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdManager.parentContext)
                                chatBubble.updateSendStatus(bool)
                                chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                                let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdManager.childContext)
                                home.storeMessage(message)
                                
                                do { try cdManager.childContext.save()} catch { }
                                
                                dispatch_sync(dispatch_get_main_queue(), {
                                    
                                    do { try cdManager.parentContext.save()} catch { }
                                    self.fetchDataOnLoading(self.dialogID)
                                });
                            })
                        })
                    }
                    else
                    {
                        self.disconnectedNetwork()
                    }
                })
                
                
            }
            else{
                print("APIServiceSessionManger ************** NETWORK OFFLINE")
                self.disconnectedNetwork()
            }
            
            break
        case .LearningCircles:
            if( ChatService.instance().isNetworkConnected){
                message.senderID=UInt(userId.intValue)
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                print(message.senderID)
                
                self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                    if(error == nil)
                    {
                        self.failedLoadingMsg.hideSelf()
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            //print("This is run on the background queue")
                            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                            cdManager.childContext.performBlock({ () -> Void in
                                let bool:Bool = true
                                let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdManager.parentContext)
                                chatBubble.updateSendStatus(bool)
                                chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                                
                                do { try cdManager.childContext.save()} catch { }
                                
                                dispatch_sync(dispatch_get_main_queue(), {
                                    
                                    do { try cdManager.parentContext.save()} catch { }
                                    self.fetchDataOnLoading(self.dialogID)
                                });
                            })
                        })
                    }
                    else
                    {
                        self.disconnectedNetwork()
                    }
                })
                
                
            }
            else{
                print("APIServiceSessionManger ************** NETWORK OFFLINE")
                self.disconnectedNetwork()
            }
            
            break
            
        default:
            break
            
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.chatTableView.hidden=false
            if(self.messageList.count>1)
            {
                let lastRowNumber:Int=self.chatTableView.numberOfRowsInSection(0)-1
                let indexPath = NSIndexPath(forRow:lastRowNumber, inSection:0)
                self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated:false)
            }
        })
        
        self.chattextView.text=""
        
        if(self.chattextView.text.characters.count==0)
        {
            placeholderLabelForTextView.hidden=false
            bottomViewheightConstraint.constant=51
            
        }
        self.placeholderLabelForTextView.hidden=false
        stopthetypeNotification()
    }
    
    @IBAction func onSendClicked(sender: AnyObject) {
        
        let characterset:NSCharacterSet=NSCharacterSet.whitespaceAndNewlineCharacterSet()
        self.isDownloadingImagesOrVideos=false
        if(self.chattextView.text.characters.count==0)
        {
            self.showAlert("Alert", text: "Please enter message to post")
        }
        else if(chattextView.text.stringByTrimmingCharactersInSet(characterset).characters.count==0)
        {
            self.showAlert("Alert", text: "Please enter message to post")
            placeholderLabelForTextView.hidden=false
            chattextView.resignFirstResponder()
            bottomViewheightConstraint.constant=51
            
        }
        else{
            
            self.msgSend()
            let fixedWidth = chattextView.frame.size.width
            chattextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = chattextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = chattextView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            chattextView.frame = newFrame;
            bottomViewheightConstraint.constant=newFrame.size.height
        }
    }
    
    //MARK mark Chat Notifications
    
    func chatDidReceiveMessageNotification(notification: NSNotification){
        
        self.isDownloadingImagesOrVideos=false
        fetchDataOnLoading(self.dialogID)
        //        dispatch_async(dispatch_get_main_queue(), {
        //
        //            self.chatTableView.hidden=false
        //            self.chatTableView.reloadData()
        //
        //            if(self.messageList.count>1)
        //            {
        //                let lastRowNumber:Int=self.chatTableView.numberOfRowsInSection(0)-1
        //                let indexPath = NSIndexPath(forRow:lastRowNumber, inSection:0)
        //                self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated:false)
        //
        //            }
        //        })
        
    }
    
    func animateViewToPosition( viewToMove:UIView, direction:Bool)
    {
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, tbHeight - kbsize.height)
        //self.view.setNeedsLayout()
        //self.bottomView.layo
        
    }
    
    func popupButtonClickedOnPersonSelfCell(row:Int)
    {
        let popupActionSheet = UIActionSheet(title:nil /*"Select Image"*/, delegate: self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil,otherButtonTitles:"View Profile")
        popupActionSheet.showInView(self.view)
        
    }
    
    func popupButtonClickedOnOthersCell(cell: OthersTableViewCell)
    {
        chattextView.resignFirstResponder()
        PopupTableViewCellonOthersCaptionAndImageView=nil
        PopupTableViewCellonOthers=cell
        selectedRow = self.chatTableView.indexPathForCell(cell)!.row
        goToProfile()
        
    }
    
    func popupButtonClickedOnOthersCellWthCaptionAndImage(cell: OtherCaptionAndImageTableViewCell)
    {
        chattextView.resignFirstResponder()
        PopupTableViewCellonOthers=nil
        PopupTableViewCellonOthersCaptionAndImageView=cell
        selectedRow = self.chatTableView.indexPathForCell(cell)!.row
        goToProfile()
    }
    
    func goToProfile()
    {
        switch self.chatTypeenum
        {
        case .oneTOOneChat:
            
            break
            
        default:
            break
        }
        
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        let chatobj:Chat=self.messageList.objectAtIndex(selectedRow) as! Chat
        let occupantId:NSNumber=chatobj.senderID
        let selectedUser:Users=cdManager.viewProfile(occupantId) as Users
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
        profileViewController.selfProfileStatus=false
        profileViewController.userProfileDetails=selectedUser
        profileViewController.fromParticipants = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.messageList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let chatObj = messageList.objectAtIndex(indexPath.row) as! Chat
        
        if(chatObj.chatText != nil)
        {
            if chatObj.chatText.rangeOfString("8ff73418bded3b5") != nil
            {
                return 235
            }
        }
        if(!(chatObj.senderID == nil))
        {
            let senderIdString:NSString = chatObj.senderID.stringValue
            if(userId == senderIdString)
            {
                if((chatObj.isAttachmentExists == nil) && (chatObj.attachmentID == nil))
                {
                    self.configurePersonTableViewCell(customPersonTableViewCell, atIndexPath: indexPath, isFaculty:false)
                    customPersonTableViewCell.layoutSubviews()
                    let height:CGFloat = customPersonTableViewCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                    return height
                }
                else
                {
                    if(!(chatObj.thumbNail == nil) )
                    {
                        if(chatObj.mediaType == "audio")
                        {
                            return 233
                        }
                        else
                        {
                            return 233
                        }
                    }
                    else
                    {
                        return 140;
                    }
                }
            }
            else
            {
                if((chatObj.isAttachmentExists == nil) && (chatObj.attachmentID == nil))
                {
                    self.configureOtherTableViewCell(customOtherTableViewCell, atIndexPath: indexPath, isFaculty:false)
                    customOtherTableViewCell.layoutSubviews()
                    let height:CGFloat = customOtherTableViewCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                    return height
                }
                else
                {
                    if(!(chatObj.thumbNail == nil) )
                    {
                        if(chatObj.mediaType == "audio")
                        {
                            return 233
                        }
                        else
                        {
                            return 233
                        }
                    }
                    else
                    {
                        return 135;
                    }
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let chatobj:Chat = self.messageList.objectAtIndex(indexPath.row) as! Chat
        if(!(chatobj.senderID == nil))
        {
            if(chatobj.chatText != nil)
            {
                if chatobj.chatText.rangeOfString("8ff73418bded3b5") != nil{
                    let cell: PollResultsChatTableViewCell = tableView.dequeueReusableCellWithIdentifier("PollResultsChatTableViewCell", forIndexPath: indexPath) as! PollResultsChatTableViewCell
                    //cell.handleString(chatobj.chatText)
                    print(chatobj.chatText)
                    return cell
                }
            }
            
            let senderIdString:NSString=chatobj.senderID.stringValue
            if(userId == senderIdString)
            {
                if facultyLogin == true
                {
                    if((chatobj.isAttachmentExists == nil) && (chatobj.attachmentID == nil))
                    {
                        let cell: PersonSelfTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonSelfTableViewCell", forIndexPath: indexPath) as! PersonSelfTableViewCell
                        self.configurePersonTableViewCell(cell, atIndexPath: indexPath, isFaculty:true)
                        cell.delegate = self
                        return cell
                    }
                    else if(!(chatobj.thumbNail==nil))
                    {
                        let cell: SelfCaptionAndImageTableViewCell = tableView.dequeueReusableCellWithIdentifier("SelfCaptionAndImageTableViewCell", forIndexPath: indexPath) as! SelfCaptionAndImageTableViewCell
                        self.configurePersonTableViewCellWithImageAndCaption(cell, atIndexPath: indexPath, isFaculty:true)
                        cell.delegate = self
                        return cell
                    }
                    else
                    {
                        let cell: SelfImageDownloadOptionCell = tableView.dequeueReusableCellWithIdentifier("SelfImageDownloadOptionCell", forIndexPath: indexPath) as! SelfImageDownloadOptionCell
                        self.configureselfcellWithCaptionAndDownloadCell(cell, atIndexPath: indexPath, isFaculty:true)
                        cell.delegateFordownloadselfCell = self
                        return cell
                    }
                }
                else
                {
                    if((chatobj.isAttachmentExists == nil) && (chatobj.attachmentID == nil))
                    {
                        let cell: PersonSelfTableViewCell = tableView.dequeueReusableCellWithIdentifier("PersonSelfTableViewCell", forIndexPath: indexPath) as! PersonSelfTableViewCell
                        self.configurePersonTableViewCell(cell, atIndexPath: indexPath, isFaculty:false)
                        cell.delegate = self
                        return cell
                    }
                    else if(!(chatobj.thumbNail == nil))
                    {
                        let cell: SelfCaptionAndImageTableViewCell = tableView.dequeueReusableCellWithIdentifier("SelfCaptionAndImageTableViewCell", forIndexPath: indexPath) as! SelfCaptionAndImageTableViewCell
                        self.configurePersonTableViewCellWithImageAndCaption(cell, atIndexPath: indexPath, isFaculty:false)
                        cell.delegate = self
                        return cell
                    }
                    else
                    {
                        let cell: SelfImageDownloadOptionCell = tableView.dequeueReusableCellWithIdentifier("SelfImageDownloadOptionCell", forIndexPath: indexPath) as! SelfImageDownloadOptionCell
                        self.configureselfcellWithCaptionAndDownloadCell(cell, atIndexPath: indexPath, isFaculty:false)
                        cell.delegateFordownloadselfCell = self
                        return cell
                    }
                }
            }
            else if(!(userId == senderIdString))
            {
                //refactor some
                let isSenderFaculty = true;
                if (isSenderFaculty == true)
                {
                    if(chatobj.attachmentID == nil)
                    {
                        let cell: OthersTableViewCell = tableView.dequeueReusableCellWithIdentifier("OthersTableViewCell", forIndexPath: indexPath) as! OthersTableViewCell
                        self.configureOtherTableViewCell(cell, atIndexPath:indexPath, isFaculty:true)
                        cell.delegate = self
                        return cell
                    }
                    else if(!(chatobj.thumbNail == nil))
                    {
                        let cell: OtherCaptionAndImageTableViewCell = tableView.dequeueReusableCellWithIdentifier("OtherCaptionAndImageTableViewCell", forIndexPath: indexPath) as! OtherCaptionAndImageTableViewCell
                        self.configureOtherTableViewCellWithImageAndText(cell, atIndexPath: indexPath, isFaculty:true)
                        cell.delegateFordownloadCell = self
                        return cell
                    }
                    else
                    {
                        let cell: OthercellWithCaptionAndDownloadCell = tableView.dequeueReusableCellWithIdentifier("OthercellWithCaptionAndDownloadCell", forIndexPath: indexPath) as! OthercellWithCaptionAndDownloadCell
                        self.configureOthercellWithCaptionAndDownloadCell(cell, atIndexPath: indexPath, isFaculty:true)
                        cell.delegateFordownloadOthersCell = self
                        return cell
                    }
                }
            }
        }
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tapgestureLabel(strURL: NSURL)
    {
        UIApplication.sharedApplication().openURL(strURL)
        NSLog("url \(strURL) ")
    }
    
    func tappedLinkDetector(link:String)
    {
        let string = link
        let types: NSTextCheckingType = [.Address, .Link]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatchesInString(string, options: [], range: NSMakeRange(0, (string as NSString).length)) { (result, flags, _) in
            print(result)
            print(string);
            
            let url:NSURL = (result?.URL)!
            self.linkURL = url
            print(url)
            self.tapgestureLabel(url)
        }
    }
    
    func configurePersonTableViewCell(cell:PersonSelfTableViewCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        
        let chatobj:Chat=self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        for AnyObject in filtered{
            
            name = AnyObject as! Users
        }
        if(filtered.count == 0)
        {
            cell.profileImageView.image=UIImage(named: avatarProfileInfoImageString)
            
        }
        else
        {
            if(!(name.profileUrl==nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image=UIImage(named: avatarProfileInfoImageString)
            }
            
        }
        
        cell.onlineindicator.image=UIImage(named:"online_indicator_chat.png")
        cell.contentLabel.text=chatobj.chatText
        
        
        if(!(chatobj.dateTime==nil))
        {
            self.timeinterval=self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            if(self.timeinterval.hour>=4)
            {
                cell.timeLabel.text=String(chatobj.dateTime.date)
                
            }
            else
            {
                cell.timeLabel.text=String(chatobj.dateTime.time)
            }
            
        }
        else
        {
            cell.timeLabel.text=""
        }
        cell.backgroundColor=colorBackground
        
        if(!(selectedIndexPath==nil))
        {
            if(selectedIndexPath==indexPath)
            {
                //cell.OverLay.hidden=false
            }
            else
            {
                cell.OverLay.hidden=true
            }
        }
        
        cell.OverLay.frame = cell.SubContentView.frame
        
        cell.contentLabel.userInteractionEnabled = true
        
        cell.contentLabel.userHandleLinkTapHandler = { label, handle, range in
            
            NSLog("User handle \(handle) tapped")
            self.tappedLinkDetector(handle)
        }
        
        cell.contentLabel.hashtagLinkTapHandler = { label, hashtag, range in
            
            NSLog("Hashtah \(hashtag) tapped")
            self.tappedLinkDetector(hashtag)
        }
        
        cell.contentLabel.urlLinkTapHandler = { label, handle, range in
            
            NSLog("User handle \(handle) tapped")
            self.tappedLinkDetector(handle)
        }
        
    }
    
    func configureselfcellWithCaptionAndDownloadCell(cell:SelfImageDownloadOptionCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        let chatobj:Chat=self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        let attachment = QBChatAttachment()
        attachment.ID = chatobj.attachmentID
        attachment.type = chatobj.attachmentType
        attachment.url = chatobj.attachmentUrl
        cell.attachment = attachment
        for AnyObject in filtered
        {
            name = AnyObject as! Users
        }
        
        if(filtered.count == 0)
        {
            cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
        }
        else
        {
            if(!(name.profileUrl == nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
            }
        }
        cell.onlineStatusIndicator.image = UIImage(named:"online_indicator_chat.png")
        
        if(indexPath.row > 0)
        {
        }
        else
        {
            cell.profileImageView.hidden = false
            cell.onlineStatusIndicator.hidden = false
        }
        if(!(chatobj.dateTime == nil))
        {
            self.timeinterval = self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            
            if(self.timeinterval.hour >= 12)
            {
                cell.timeLabel.text = String(chatobj.dateTime.date)
            }
            else
            {
                cell.timeLabel.text = String(chatobj.dateTime.time)
            }
        }
        else
        {
            cell.timeLabel.text = ""
        }
        
        //cell.contentLabel.text = chatobj.chatText
        
        //cell.backgroundColor = colorBackground
        
        if(!(chatobj.mediaType == nil))
        {
            if(chatobj.mediaType == "video")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedvideo.png")
            }
            else if(chatobj.mediaType == "photo")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedimage.png")
            }
            else if(chatobj.mediaType == "audio")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedaudio.png")
            }
        }
        if(!(chatobj.attachmentType == nil))
        {
            if((chatobj.attachmentType == "image") || (chatobj.attachmentType == "photo"))
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedimage.png")
            }
            else if(chatobj.attachmentType == "video")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedvideo.png")
            }
            else if(chatobj.attachmentType == "audio")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_selfDownloadedaudio.png")
            }
        }
        if(!(selectedIndexPath == nil))
        {
            if(selectedIndexPath == indexPath)
            {
                //cell.OverLay.hidden=false
            }
            else
            {
                cell.OverLay.hidden = true
            }
        }
        
        cell.OverLay.frame = cell.subContentView.frame
    }
    
    func configurePersonTableViewCellWithImageAndCaption(cell:SelfCaptionAndImageTableViewCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        let chatobj:Chat=self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        let attachment = QBChatAttachment()
        attachment.ID = chatobj.attachmentID
        attachment.type = chatobj.attachmentType
        attachment.url = chatobj.attachmentUrl
        cell.attachment = attachment
        
        for AnyObject in filtered
        {
            name = AnyObject as! Users
        }
        
        if(filtered.count == 0)
        {
            cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
        }
        else
        {
            if(!(name.profileUrl == nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
            }
        }
        cell.onlineIndicatorstatus.image = UIImage(named:"online_indicator_chat.png")
        
        if(indexPath.row > 0)
        {
            cell.profileImageView.hidden = true
            cell.onlineIndicatorstatus.hidden = true
        }
        else
        {
            cell.profileImageView.hidden = false
            cell.onlineIndicatorstatus.hidden = false
        }
        
        // display the timestamp
        if(!(chatobj.dateTime == nil))
        {
            self.timeinterval = self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            
            if(self.timeinterval.hour >= 12)
            {
                // if over 12 hours have passed, display the date instead of actual timestamp
                cell.timeLabel.text = String(chatobj.dateTime.date)
            }
            else
            {
                // if less than 12 hours have passed, display the timestamp
                cell.timeLabel.text = String(chatobj.dateTime.time)
            }
        }
        else
        {
            // if timestamp is unavailable, blank it and dont display anything
            cell.timeLabel.text = ""
        }
        
        //cell.contentLabel.text=chatobj.chatText
        
        if(!(chatobj.thumbNail == nil))
        {
            cell.thumnail.image = UIImage(data:chatobj.thumbNail)
        }
        else
        {
            if(!(chatobj.attachmentType == nil))
            {
                if(chatobj.attachmentType == "video")
                {
                    cell.thumnail.image = UIImage(named:"DefaultVideoThumbnail.png")
                }
                else if(chatobj.attachmentType == "photo"||chatobj.attachmentType=="image")
                {
                    cell.thumnail.image = UIImage(named:"DefaultImageThumbnail.jpg")
                }
            }
        }
        
        if(!(chatobj.mediaType == nil))
        {
            if(chatobj.mediaType == "video" && (!(chatobj.thumbNail == nil)))
            {
                cell.playButton.hidden = false
            }
            else if(chatobj.mediaType == "photo")
            {
                cell.playButton.hidden = true
            }
            else if(chatobj.mediaType == "audio")
            {
                cell.playButton.hidden = false
            }
        }
        
        if(!(chatobj.attachmentType == nil))
        {
            if((chatobj.attachmentType == "image") || (chatobj.attachmentType == "photo"))
            {
                cell.playButton.hidden = true
            }
            else if((chatobj.attachmentType == "video" && (!(chatobj.thumbNail == nil))) || chatobj.attachmentType == "audio")
            {
                cell.playButton.hidden = false
            }
        }
        
        cell.backgroundColor=colorBackground
        if(!(selectedIndexPath == nil))
        {
            if(selectedIndexPath == indexPath)
            {
                //cell.OverLay.hidden=false
            }
            else
            {
                cell.OverLay.hidden = true
            }
        }
    }
    
    func configureResultTableViewCell(cell:OthersTableViewCell! ,atIndexPath indexPath:NSIndexPath, withString resultsString:String)->Void
    {
        
    }
    
    func configureOtherTableViewCell(cell:OthersTableViewCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        let chatobj:Chat = self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        for AnyObject in filtered
        {
            name = AnyObject as! Users
        }
        
        let lastCheck = OnlineUsersObj.getUserLastCheck(chatobj.senderID) as CLong
        if (name == nil)
        {
            // BlockedUserManager.blockUserWithId(chatobj.senderID)
        }
        else
        {
            // Display online status of user
            if(lastCheck == 0)
            {
                OnlineUsersObj.save(chatobj.senderID, status: 2, lastCheck: 1)
                cell.onlineStatusIndicator.hidden = true;
                APIServiceSessionManger.IsUserOnlineWithCompletionBlock(chatobj.senderID, success: { (task, responseObject) -> Void in
                    cell.onlineStatusIndicator.hidden = false;
                    if let dictionary = responseObject.objectForKey("response") as? NSDictionary
                    {
                        let onlineStatus:NSNumber = dictionary.objectForKey("online") as! NSNumber
                        self.OnlineUsersObj.save(chatobj.senderID, status: onlineStatus, lastCheck: 2)
                        if(onlineStatus.integerValue == 1)
                        {
                            cell.onlineStatusIndicator.image = UIImage(named:"online_indicator_participants.png")
                        }
                        else
                        {
                            cell.onlineStatusIndicator.image = UIImage(named:"offline_indicator_participants.png")
                        }
                    }
                    })
                    { (task, error) -> Void in
                }
            }
            else
            {
                let onlineStatus:NSNumber = OnlineUsersObj.getUserStatus(chatobj.senderID)
                if(onlineStatus.integerValue == 1)
                {
                    cell.onlineStatusIndicator.image = UIImage(named:"online_indicator_participants.png")
                }
                else
                {
                    cell.onlineStatusIndicator.image = UIImage(named:"offline_indicator_participants.png")
                }
            }
        }
        
        // display the full name of the user
        if(filtered.count == 0)
        {
            cell.nameLabel.text = ""
            cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
        }
        else
        {
            switch self.chatTypeenum
            {
            case .oneTOOneChat:
                // for one-to-one chat, do not display the users name
                cell.nameLabel.text = ""
                break
                
            default:
                // for all other chat types, display the full name of the user
                cell.nameLabel.text = name.firstname + " " + name.lastName
                break
            }
            
            // display the profile photo for the user
            if(!(name.profileUrl == nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
            }
        }
        
        // if theuser is blocked, do not display any messages from said user
        if(BlockedUserManager.isUserBlockedWithId(chatobj.senderID) == true)
        {
            cell.contentLabel.text = "Message blocked"
            cell.contentLabel.textColor = UIColor.grayColor()
        }
        else
        {
            cell.contentLabel.text = chatobj.chatText
            //cell.contentLabel.textColor = UIColor.blackColor()
        }
        cell.backgroundColor = colorBackground
        
        // TODO: revisit this logic and implement correctly
        if(indexPath.row>0)
        {
        
        }
        else
        {
            cell.profileImageView.hidden = false
            cell.onlineStatusIndicator.hidden = false
        }
        
        // display timestamp
        if(!(chatobj.dateTime == nil))
        {
            self.timeinterval = self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            if(self.timeinterval.hour >= 12)
            {
                cell.timeLabel.text = String(chatobj.dateTime.date)
            }
            else
            {
                cell.timeLabel.text = String(chatobj.dateTime.time)
            }
        }
        else
        {
            cell.timeLabel.text = ""
        }
        
        cell.contentLabel.userHandleLinkTapHandler = { label, handle, range in
            
            NSLog("User handle \(handle) tapped")
            self.tappedLinkDetector(handle)
        }
        
        cell.contentLabel.hashtagLinkTapHandler = { label, hashtag, range in
            
            NSLog("Hashtah \(hashtag) tapped")
            self.tappedLinkDetector(hashtag)
        }
        
        cell.contentLabel.urlLinkTapHandler = { label, handle, range in
            
            NSLog("User handle \(handle) tapped")
            self.tappedLinkDetector(handle)
        }
        
    }
    
    func configureOtherTableViewCellWithImageAndText(cell:OtherCaptionAndImageTableViewCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        let chatobj:Chat=self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        for AnyObject in filtered{
            
            name = AnyObject as! Users
        }
        let attachment = QBChatAttachment()
        attachment.ID = chatobj.attachmentID
        attachment.type = chatobj.attachmentType
        attachment.url = chatobj.attachmentUrl
        cell.attachment = attachment
        
        
        if(filtered.count == 0)
        {
            cell.nameLabel.text=""
            cell.profileImageView.image=UIImage(named: avatarProfileInfoImageString)
        }
        else
        {
            switch self.chatTypeenum
            {
            case .oneTOOneChat:
                
                cell.nameLabel.text = ""
                break
                
            default:
                cell.nameLabel.text = name.firstname + " " + name.lastName
                break
                
            }
            if(!(name.profileUrl==nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image=UIImage(named: avatarProfileInfoImageString)
            }
            
        }
        
        let lastCheck = OnlineUsersObj.getUserLastCheck(chatobj.senderID) as CLong
        if(lastCheck == 0)
        {
            OnlineUsersObj.save(chatobj.senderID, status: 2, lastCheck: 1)
            cell.onlineStatusIndicator.hidden = true;
            APIServiceSessionManger.IsUserOnlineWithCompletionBlock(chatobj.senderID, success: { (task, responseObject) -> Void in
                cell.onlineStatusIndicator.hidden = false;
                if let dictionary = responseObject.objectForKey("response") as? NSDictionary
                {
                    
                    let onlineStatus:NSNumber = dictionary.objectForKey("online") as! NSNumber
                    self.OnlineUsersObj.save(chatobj.senderID, status: onlineStatus, lastCheck: 2)
                    if(onlineStatus.integerValue==1)
                    {
                        cell.onlineStatusIndicator.image=UIImage(named:"online_indicator_participants.png")
                    }
                    else
                    {
                        cell.onlineStatusIndicator.image=UIImage(named:"offline_indicator_participants.png")
                    }
                }
                })
                { (task, error) -> Void in
            }
        }
            
        else
        {
            let onlineStatus:NSNumber = OnlineUsersObj.getUserStatus(chatobj.senderID)
            if(onlineStatus.integerValue==1)
            {
                cell.onlineStatusIndicator.image=UIImage(named:"online_indicator_participants.png")
            }
            else
            {
                cell.onlineStatusIndicator.image=UIImage(named:"offline_indicator_participants.png")
            }
        }
        
        if(indexPath.row>0)
        {
        }
        else
        {
            cell.profileImageView.hidden=false
            cell.onlineStatusIndicator.hidden=false
        }
        
        if(!(chatobj.dateTime==nil))
        {
            self.timeinterval=self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            
            if(self.timeinterval.hour>=12)
            {
                cell.timeLabel.text=String(chatobj.dateTime.date)
            }
            else
            {
                cell.timeLabel.text=String(chatobj.dateTime.time)
            }
        }
        else
        {
            cell.timeLabel.text=""
        }
        
        if(!(chatobj.thumbNail==nil))
        {
            cell.thumbnailView.image=UIImage(data:chatobj.thumbNail)
        }
        else
        {
            
            if(!(chatobj.attachmentType==nil))
            {
                if(chatobj.attachmentType=="video")
                {
                    cell.thumbnailView.image=UIImage(named:"DefaultVideoThumbnail.png")
                }
                else if(chatobj.attachmentType=="photo"||chatobj.attachmentType=="image")
                {
                    cell.thumbnailView.image=UIImage(named:"DefaultImageThumbnail.jpg")
                    
                }
            }
            
        }
        if(!(chatobj.mediaType==nil))
        {
            if(chatobj.mediaType=="video"&&(!(chatobj.thumbNail==nil)))
            {
                cell.playButton.hidden=false
            }
            else if(chatobj.mediaType=="photo")
            {
                cell.playButton.hidden=true
            }
            else if(chatobj.mediaType=="audio")
            {
                cell.playButton.hidden=false
            }
        }
        if(!(chatobj.attachmentType==nil))
        {
            if((chatobj.attachmentType=="image")||(chatobj.attachmentType=="photo"))
            {
                cell.playButton.hidden=true
            }
            else if((chatobj.attachmentType=="video"&&(!(chatobj.thumbNail==nil))) || chatobj.attachmentType=="audio")
            {
                cell.playButton.hidden=false
            }
        }
        cell.backgroundColor=colorBackground
    }
    
    func configureOthercellWithCaptionAndDownloadCell(cell:OthercellWithCaptionAndDownloadCell! ,atIndexPath indexPath:NSIndexPath, isFaculty:Bool)->Void
    {
        let chatobj:Chat=self.messageList.objectAtIndex(indexPath.row) as! Chat
        let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
        let attachment = QBChatAttachment()
        attachment.ID = chatobj.attachmentID
        attachment.type = chatobj.attachmentType
        attachment.url = chatobj.attachmentUrl
        cell.attachment = attachment
        for AnyObject in filtered
        {
            name = AnyObject as! Users
        }
        if(filtered.count == 0)
        {
            cell.nameLabel.text = ""
            cell.profileImageView.image = UIImage(named: avatarProfileInfoImageString)
        }
        else
        {
            switch self.chatTypeenum
            {
            case .oneTOOneChat:
                cell.nameLabel.text = ""
                break
                
            default:
                cell.nameLabel.text = name.firstname + " " + name.lastName
                break
            }

            if(!(name.profileUrl==nil))
            {
                let photourl = NSURL(string:name.profileUrl)
                cell.profileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named: avatarProfileInfoImageString))
            }
            else
            {
                cell.profileImageView.image=UIImage(named: avatarProfileInfoImageString)
            }
        }
        
        if(indexPath.row>0)
        {
            
        }
        else
        {
            cell.profileImageView.hidden = false
            cell.onlineStatusIndicator.hidden = false
        }
        
        if(!(chatobj.dateTime == nil))
        {
            self.timeinterval = self.gettingDifferenceBetweenToDayAndFromDatabse(chatobj.dateTime) as NSDateComponents
            if(self.timeinterval.hour >= 12)
            {
                cell.timeLabel.text = String(chatobj.dateTime.date)
            }
            else
            {
                cell.timeLabel.text = String(chatobj.dateTime.time)
            }
        }
        else
        {
            cell.timeLabel.text = ""
        }
        
        cell.contentLabel.text = chatobj.chatText
        
        cell.backgroundColor = colorBackground
        
        if(!(chatobj.mediaType == nil))
        {
            if(chatobj.mediaType == "video")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_othersDownloadvideo.png")
            }
            else if(chatobj.mediaType == "photo")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_image.png")
            }
            else if(chatobj.mediaType == "audio")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_othersDownloadedaudio.png")
            }
        }
        if(!(chatobj.attachmentType == nil))
        {
            if((chatobj.attachmentType == "image") || (chatobj.attachmentType == "photo"))
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_image.png")
            }
            else if(chatobj.attachmentType == "video")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_othersDownloadvideo.png")
            }
            else if(chatobj.attachmentType == "audio")
            {
                cell.backgroundImageViewForDownload.image = UIImage(named:"ic_othersDownloadedaudio.png")
            }
        }
        
    }
    
    func gettingDifferenceBetweenToDayAndFromDatabse(dateFromdb:NSDate!)->NSDateComponents
    {
        var interval:NSDateComponents=ERDateComponents.defaultDateComponents() as NSDateComponents
        let calendar:NSCalendar=NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        //var timeZone:NSTimeZone=NSTimeZone(name: timezonename)!
        
        if(NSDate().compare(dateFromdb)==NSComparisonResult.OrderedDescending)
        {
            interval=calendar.components( [.Year , .Day , .Hour , .Minute , .Second], fromDate: dateFromdb, toDate:NSDate(), options:NSCalendarOptions.MatchStrictly) as NSDateComponents
        }
        else  if(NSDate().compare(dateFromdb)==NSComparisonResult.OrderedSame)
        {
            //today time
            interval=calendar.components( [.Year , .Day , .Hour , .Minute , .Second], fromDate: dateFromdb, toDate: NSDate(), options:NSCalendarOptions.MatchStrictly) as NSDateComponents
            
        }
        
        return interval
        
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        attachAction()
        
    }
    //MARK: - Actionsheet Delegate Methods
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        
        if(actionSheet.tag == 2000){
            
            switch buttonIndex{
                
            case 0:
                //("Clicked on cancel")
                actionSheet.dismissWithClickedButtonIndex(0, animated: true)
                break
                
            case 1:
                //print("gallery");
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                    attachimagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    attachimagePickerController.view.tag=3000
                    attachimagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                    attachimagePickerController.allowsEditing = false
                    self.presentViewController(attachimagePickerController, animated: true, completion: nil)
                    
                }
                    
                else
                {
                    self.showAlert("Alert", text: "Photos not available")
                }
                
                break
            case 2:
                print("camera");
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
                {
                    attachimagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                    attachimagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                    attachimagePickerController.allowsEditing = false
                    
                    self.presentViewController(attachimagePickerController, animated: true, completion: nil)
                    
                }
                else
                {
                    self.showAlert("Alert", text: "Camera is not available")
                }
                break
                
            default:
                print("Default");
                break
                
            }
        }
        else{
            
            switch buttonIndex{
                
            case 0:
                //print("Clicked on cancel")
                actionSheet.dismissWithClickedButtonIndex(0, animated: true)
                break
                
            case 1:
                let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                let chatobj:Chat=self.messageList.objectAtIndex(selectedRow) as! Chat
                let occupantId:NSNumber=chatobj.senderID
                let selectedUser:Users=cdManager.viewProfile(occupantId) as Users
                let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
                profileViewController.selfProfileStatus=false
                profileViewController.userProfileDetails=selectedUser
                self.navigationController?.pushViewController(profileViewController, animated: true)
                break
            case 2:
                var occupantId:NSNumber!
                var lobjusername:String!
                switch chatTypeenum {
                case  .oneTOOneChat:
                    return
                case  .GroupChat:
                    var newIndexPath: NSIndexPath = NSIndexPath();
                    if(!(PopupTableViewCellonOthersCaptionAndImageView==nil))
                    {
                        newIndexPath = self.chatTableView.indexPathForCell(PopupTableViewCellonOthersCaptionAndImageView)!
                    }
                    else if(!(PopupTableViewCellonOthers==nil))
                    {
                        newIndexPath = self.chatTableView.indexPathForCell(PopupTableViewCellonOthers)!
                    }
                    else if(!(PopupTableViewCellonOthersCaptionDownload==nil))
                    {
                        newIndexPath = self.chatTableView.indexPathForCell(PopupTableViewCellonOthersCaptionDownload)!
                    }
                    let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
                    let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", chatobj.senderID))
                    if(filtered.count == 0)
                    {
                        userName=""
                    }
                    else
                    {
                        userName=name.firstname
                        lobjusername=name.firstname
                    }
                    occupantId=chatobj.senderID
                    break
                default:
                    break
                }
                
                let chatDialog:QBChatDialog=QBChatDialog(coder: NSCoder())!
                chatDialog.name=lobjusername
                if(QBSession.currentSession().sessionDetails!.userID == occupantId){
                    
                    return;
                }
                chatDialog.occupantIDs=[occupantId]
                //chatDialog.type = QBChatDialogTypePrivate;
                let fReq: NSFetchRequest = NSFetchRequest(entityName: Home.entityName() as! NSString as String)
                fReq.returnsObjectsAsFaults = false
                fReq.predicate = NSPredicate(format: "recepientID = %@", occupantId)
                
                let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                
                do {
                    let list = try cdManager.childContext.executeFetchRequest(fReq)
                    
                    if(list.count >= 1){
                        var array:NSArray = NSArray()
                        array = list
                        for AnyObject in array{
                            let temp = AnyObject as! Home
                            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                            self.navigationController?.pushViewController(chatViewController, animated: true)
                            chatViewController.userName=lobjusername
                            chatViewController.chatTypeenum=chatType.oneTOOneChat
                            chatViewController.dialogID = temp.dialogID
                            
                        }
                    }
                    
                }
                catch {
                }
                
                break
                
            case 3:
                break
                
            default:
                print("Default");
                break
                
            }
            
        }
        
    }
    
    func imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        
        if(picker==attachimagePickerController)
        {
            let mediatype:NSString=info[UIImagePickerControllerMediaType] as! NSString
            
            if((mediatype==String(kUTTypeVideo))||(mediatype==String(kUTTypeMovie)))
            {
                if(info[UIImagePickerControllerReferenceURL]==nil)
                {
                    let fileurl:NSURL=info[UIImagePickerControllerMediaURL] as! NSURL
                    
                    let outurl = NSURL.fileURLWithPath(NSTemporaryDirectory().stringByAppendingPathComponent("\(NSDate())").stringByAppendingString(".mp4"))
                    let datapre = NSData(contentsOfURL: fileurl)!
                    print("Size Before Compression: \(datapre.length / 1048576 ) mb")
                    
                    self.convertVideo(fileurl, outputURL: outurl, withCompleteBlock: { (outputURLA) -> Void in
                        if (outputURLA != nil)
                        {
                            let data = NSData(contentsOfURL: outputURLA)
                            print("File size after compression: \(Double(data!.length / 1048576)) mb")
                            self.library?.saveVideo(outputURLA, toAlbum:"Eruditus Videos", withCompletionBlock: { (savedassetUrl:NSURL!) -> Void in
                                let assetLib:ALAssetsLibrary=ALAssetServices.defaultAssetsLibrary()
                                assetLib.assetForURL(savedassetUrl, resultBlock: { (asset:ALAsset!) -> Void in
                                    let videoRep:ALAssetRepresentation=asset.defaultRepresentation()
                                    let fileName:NSString=videoRep.filename() as NSString
                                    let chatcaptionViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatCaptionViewController") as! ChatCaptionViewController
                                    chatcaptionViewController.videoUrl=savedassetUrl
                                    chatcaptionViewController.delegate=self
                                    chatcaptionViewController.videoName=fileName
                                    chatcaptionViewController.sendTouserName=self.userName
                                    self.navigationController?.pushViewController(chatcaptionViewController, animated: false)
                                    self.dismissViewControllerAnimated(false, completion: nil)
                                    
                                    }, failureBlock: { (error:NSError!) -> Void in
                                        
                                        if let errordesription=error
                                        {
                                            print(errordesription.localizedDescription)
                                        }
                                })
                                
                                }, andFailureBlock: { (error:NSError!) -> Void in
                                    
                                    if let errordesription=error
                                    {
                                        print(errordesription.localizedDescription)
                                    }
                            })
                        }
                    })
                    
                    
                    
                }
                else
                {
                    let assetUrl:NSURL=info[UIImagePickerControllerReferenceURL] as! NSURL
                    let outurl = NSURL.fileURLWithPath(NSTemporaryDirectory().stringByAppendingPathComponent("\(NSDate())").stringByAppendingString(".mp4"))
                    
                    self.convertVideo(assetUrl, outputURL: outurl, withCompleteBlock: { (outputURLA) -> Void in
                        if (outputURLA != nil)
                        {
                            let data = NSData(contentsOfURL: outputURLA)
                            print("File size after compression: \(Double(data!.length / 1048576)) mb")
                            //print(assetUrl)
                            self.library?.saveVideo(outputURLA, toAlbum:"Eruditus Videos", withCompletionBlock: { (savedassetUrl:NSURL!) -> Void in
                                
                                let assetLib:ALAssetsLibrary=ALAssetServices.defaultAssetsLibrary()
                                assetLib.assetForURL(savedassetUrl, resultBlock: { (asset:ALAsset!) -> Void in
                                    let videoRep:ALAssetRepresentation=asset.defaultRepresentation()
                                    let fileName:NSString=videoRep.filename() as NSString
                                    let chatcaptionViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatCaptionViewController") as! ChatCaptionViewController
                                    chatcaptionViewController.videoUrl=savedassetUrl
                                    chatcaptionViewController.delegate=self
                                    chatcaptionViewController.videoName=fileName
                                    chatcaptionViewController.sendTouserName=self.userName
                                    self.navigationController?.pushViewController(chatcaptionViewController, animated: false)
                                    self.dismissViewControllerAnimated(false, completion: nil)
                                    
                                    }, failureBlock: { (error:NSError!) -> Void in
                                        
                                        if let errordesription=error
                                        {
                                            print(errordesription.localizedDescription)
                                        }
                                })
                                
                                }, andFailureBlock: { (error:NSError!) -> Void in
                                    
                                    if let errordesription=error
                                    {
                                        print(errordesription.localizedDescription)
                                    }
                            })
                        }
                    })
                    
                    
                    
                }
                
            }
                
            else
            {
                var tempImage:UIImage=info[UIImagePickerControllerOriginalImage] as! UIImage
                tempImage = scaleImage(tempImage, toSize: CGSizeMake(150, 100))
                if(info[UIImagePickerControllerReferenceURL]==nil)
                {
                    
                    let rotateImage:UIImage=UIImage.rotateUIImage(tempImage) as UIImage
                    self.library?.saveImage(rotateImage, toAlbum: "Emeritus Images", withCompletionBlock: { (asseturl:NSURL!) -> Void in
                        
                        let assetLib:ALAssetsLibrary=ALAssetServices.defaultAssetsLibrary()
                        assetLib.assetForURL(asseturl,resultBlock: {(imageAsset:ALAsset!) -> Void in
                            
                            let imageRep:ALAssetRepresentation=imageAsset.defaultRepresentation()
                            //print(imageRep.size())
                            let fileName:NSString=imageRep.filename() as NSString
                            var imageData:NSData!
                            
                            let chatcaptionViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatCaptionViewController") as! ChatCaptionViewController
                            chatcaptionViewController.imageToSend=tempImage
                            chatcaptionViewController.sendTouserName=self.userName
                            chatcaptionViewController.delegate=self
                            chatcaptionViewController.videoUrl=nil
                            chatcaptionViewController.imageType=fileName.lastPathComponent.pathExtension
                            chatcaptionViewController.imageName=fileName
                            chatcaptionViewController.imageRefURl=asseturl
                            self.navigationController?.pushViewController(chatcaptionViewController, animated: true)
                            self.dismissViewControllerAnimated(false, completion: nil)
                            
                            }, failureBlock: { (error:NSError!) -> Void in
                                
                        })
                        
                        }, andFailureBlock: { (error:NSError!) -> Void in
                            
                            if let errordesription=error
                            {
                                print(errordesription.localizedDescription)
                            }
                    })
                }
                else
                {
                    let imagerefURL:NSURL=info[UIImagePickerControllerReferenceURL] as! NSURL
                    let assetLib:ALAssetsLibrary=ALAssetServices.defaultAssetsLibrary()
                    assetLib.assetForURL(imagerefURL,resultBlock: {(imageAsset:ALAsset!) -> Void in
                        let imageRep:ALAssetRepresentation=imageAsset.defaultRepresentation()
                        //print(imageRep.size())
                        let fileName:NSString=imageRep.filename() as NSString
                        
                        let chatcaptionViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatCaptionViewController") as! ChatCaptionViewController
                        chatcaptionViewController.imageToSend=tempImage
                        chatcaptionViewController.sendTouserName=self.userName
                        chatcaptionViewController.delegate=self
                        chatcaptionViewController.videoUrl=nil
                        chatcaptionViewController.imageName=fileName
                        chatcaptionViewController.imageRefURl=imagerefURL
                        chatcaptionViewController.imageType=fileName.lastPathComponent.pathExtension
                        self.navigationController?.pushViewController(chatcaptionViewController, animated: true)
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                        }, failureBlock: { (error:NSError!) -> Void in
                            
                    })
                }
                
            }
        }
        else
        {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    func convertVideo(inputUrl: NSURL, outputURL: NSURL, withCompleteBlock:(outputURLA:NSURL!) -> Void)
    {
        //setup video writer
        let videoAsset = AVURLAsset(URL: inputUrl, options: nil) as AVAsset
        
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        let videoSize = videoTrack.naturalSize
        
        let videoWriterCompressionSettings = Dictionary(dictionaryLiteral:(AVVideoAverageBitRateKey,NSNumber(integer:200000)))
        
        let videoWriterSettings: [String:AnyObject] = [AVVideoCodecKey: AVVideoCodecH264,
            AVVideoCompressionPropertiesKey: videoWriterCompressionSettings,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoWriterSettings)
        
        videoWriterInput.expectsMediaDataInRealTime = true
        
        videoWriterInput.transform = videoTrack.preferredTransform
        
        
        let videoWriter = try! AVAssetWriter(URL: outputURL, fileType: AVFileTypeQuickTimeMovie)
        
        videoWriter.addInput(videoWriterInput)
        
        let videoReaderSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        
        let videoReader = try! AVAssetReader(asset: videoAsset)
        
        videoReader.addOutput(videoReaderOutput)
        
        
        
        //setup audio writer
        let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
        
        audioWriterInput.expectsMediaDataInRealTime = false
        
        videoWriter.addInput(audioWriterInput)
        
        
        //setup audio reader
        
        let audioTrack = videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as AVAssetTrack
        
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil) as AVAssetReaderOutput
        
        let audioReader = try! AVAssetReader(asset: videoAsset)
        
        
        audioReader.addOutput(audioReaderOutput)
        
        videoWriter.startWriting()
        
        
        //start writing from video reader
        videoReader.startReading()
        
        videoWriter.startSessionAtSourceTime(kCMTimeZero)
        
        //dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue", nil)
        
        let queue = dispatch_queue_create("processingQueue", nil)
        
        videoWriterInput.requestMediaDataWhenReadyOnQueue(queue, usingBlock: { () -> Void in
            print("Export starting")
            
            while videoWriterInput.readyForMoreMediaData
            {
                var sampleBuffer:CMSampleBufferRef!
                
                sampleBuffer = videoReaderOutput.copyNextSampleBuffer()
                
                if (videoReader.status == AVAssetReaderStatus.Reading && sampleBuffer != nil)
                {
                    videoWriterInput.appendSampleBuffer(sampleBuffer)
                    
                }
                    
                else
                {
                    videoWriterInput.markAsFinished()
                    
                    if videoReader.status == AVAssetReaderStatus.Completed
                    {
                        if audioReader.status == AVAssetReaderStatus.Reading || audioReader.status == AVAssetReaderStatus.Completed
                        {
                            
                        }
                        else {
                            
                            
                            audioReader.startReading()
                            
                            videoWriter.startSessionAtSourceTime(kCMTimeZero)
                            
                            let queue2 = dispatch_queue_create("processingQueue2", nil)
                            
                            
                            audioWriterInput.requestMediaDataWhenReadyOnQueue(queue2, usingBlock: { () -> Void in
                                
                                while audioWriterInput.readyForMoreMediaData
                                {
                                    var sampleBuffer:CMSampleBufferRef!
                                    
                                    sampleBuffer = audioReaderOutput.copyNextSampleBuffer()
                                    
                                    print(sampleBuffer == nil)
                                    
                                    if (audioReader.status == AVAssetReaderStatus.Reading && sampleBuffer != nil)
                                    {
                                        audioWriterInput.appendSampleBuffer(sampleBuffer)
                                        
                                    }
                                        
                                    else
                                    {
                                        audioWriterInput.markAsFinished()
                                        
                                        if (audioReader.status == AVAssetReaderStatus.Completed)
                                        {
                                            
                                            videoWriter.finishWritingWithCompletionHandler({ () -> Void in
                                                
                                                while true
                                                {
                                                    if videoWriter.status == .Completed
                                                    {
                                                        let data = NSData(contentsOfURL: outputURL)!
                                                        
                                                        print("Finished: Byte Size After Compression: \(data.length ) mb")
                                                        
                                                        //Networking().uploadVideo(data, fileName: "Video")
                                                        withCompleteBlock(outputURLA: outputURL)
                                                        
                                                        break
                                                    }
                                                }
                                                
                                                
                                            })
                                            break
                                        }
                                    }
                                }
                            })
                            break
                        }
                    }
                }// Second if
                
            }//first while
            
        })// first block
        // return
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        if(!(attachmentView==nil))
        {
            attachmentView.removeFromSuperview()
            attachmentView=nil
        }
        
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y);
        return true
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        //self.view.layoutIfNeeded()
        // _:CGFloat = -kbsize.height; // tweak as needed
        let  movementDuration:NSTimeInterval = 0.3; // tweak as needed
        UIView.beginAnimations("animateTextField",context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        bottomViewCnst.constant=0
        //self.view.layoutIfNeeded()
        UIView.commitAnimations()
        kbsize.height = 0;
        self.animateViewToPosition(bottomView, direction: true)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let info = notification.userInfo {
            kbsize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
            print(kbsize);
            self.animateViewToPosition(bottomView, direction: true)
        }
        
    }
    
    func fetchDataOnLoading(dialogID : NSString){
        self.refreshControl.endRefreshing()
        let fetchRequest = createHomeFetchRequest()
        
        
        fetchRequest.predicate = (NSPredicate(format: "dialogID = %@", dialogID))
        let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        //CD DBmayur
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.parentContext.performBlock({ () -> Void in
            do{
                let list = try cdManager.parentContext.executeFetchRequest(fetchRequest)
                self.messageList = NSMutableArray(array:list) as NSMutableArray
                if(self.messageList.count==0)
                {
                    
                    //self.gettingMessagesFromQuickbloxs()
                }
                else if ( self.messageList.count > 0 )
                {
                    self.senderFacultyArray = nil
                    self.senderFacultyArray = NSMutableArray()
                }
                
                self.fetchUserNames()
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.chatTableView.hidden=false
                    self.chatTableView.reloadData()
                    //                    if(self.isDownloadingImagesOrVideos==false&&self.loadingEarlierMessages==false)
                    //                    {
                    if(self.messageList.count>0)
                    {
                        let lastRowNumber:Int=self.chatTableView.numberOfRowsInSection(0)-1
                        let indexPath = NSIndexPath(forRow:lastRowNumber, inSection:0)
                        if(self.isRefresh == false)
                        {
                            self.chatTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated:false)
                            
                        }
                        
                    }
                    //                    }
                    
                    self.chatTableView.userInteractionEnabled = true
                    
                })
            }
            catch
            {
                
            }
        })
        
    }
    
    func fetchUserNames(){
        
        let fetchRequest = createUserNameFetchRequest()
        
        //CD DBmayur
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.parentContext.performBlock({ () -> Void in
            
            do {
                let list = try cdManager.parentContext.executeFetchRequest(fetchRequest )
                self.userNames = list
            } catch { }
            dispatch_async(dispatch_get_main_queue(), {
                
                self.chatTableView.hidden=false
                self.chatTableView.reloadData()
                
            })
            
        })
        
    }
    
    func createUserNameFetchRequest() -> NSFetchRequest{
        let fReq: NSFetchRequest = NSFetchRequest(entityName: Users.entityName() as! NSString as String)
        fReq.returnsObjectsAsFaults = false
        return fReq
    }
    
    func createHomeFetchRequest() -> NSFetchRequest{
        let fReq: NSFetchRequest = NSFetchRequest(entityName: Chat.entityName() as! NSString as String)
        //let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        //fReq.sortDescriptors = [sortDescriptor]
        fReq.returnsObjectsAsFaults = false
        return fReq
    }
    
    func sendVideo(url:NSURL,captionText : NSString,videoname:NSString){
        
        var cell:SelfCaptionAndImageTableViewCell!
        let message = QBChatMessage()
        message.text = "Attachment"
        let param = NSMutableDictionary()
        param.setValue(true, forKey: "save_to_history")
        message.customParameters = param
        message.text = captionText as String
        message.senderID = LocalStorageService.shared().currentUser.ID
        
        if((message.text=="")||(message.text==nil))
        {
            message.text="File Attachments"
        }
        switch self.chatTypeenum
        {
        case .oneTOOneChat:
            
            break
            
        case .GroupChat:
            break
        default:
            break
            
        }
        message.senderID = LocalStorageService.shared().currentUser.ID
        
        let asset:AVAsset=AVAsset(URL: url)
        let imagegenerator:AVAssetImageGenerator=AVAssetImageGenerator(asset: asset) as AVAssetImageGenerator
        imagegenerator.appliesPreferredTrackTransform=true
        var time:CMTime=asset.duration
        time.value=3
        var imageData = NSData()
        do
        {
            let imageRef = try imagegenerator.copyCGImageAtTime(time, actualTime:nil)
            let thumbnailImage:UIImage=UIImage(CGImage:imageRef)
            let thumnail = UIImage.generatePhotoThumbnail(thumbnailImage,withSide: 140) as UIImage
            imageData = NSData(data:UIImageJPEGRepresentation(thumnail,1.0)!) as NSData
        }
        catch
        {
        }
        
        //Saving thumnail to DB.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                
                let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                cdmanager.childContext!.performBlock {
                    
                    let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdmanager.childContext)
                    home.storeMessage(message)
                    
                    do { try cdmanager.childContext.save()} catch { }
                    do { try cdmanager.parentContext.save()} catch { }
                    
                }
                return
            }
            
        }
        
        UIImage.videoBytesFromUrlBlockWithSuccess(url, success: { (videodata:NSData!) -> Void in
            
            let lobjData:NSData=NSData(data:videodata)
            
            QBRequest.TUploadFile(lobjData, fileName: videoname as String, contentType: "video/mov", isPublic: true, successBlock: { (responce:QBResponse, blob:QBCBlob) -> Void in
                
                if(!(cell==nil))
                {
                    cell.progressView.hidden=true
                }
                
                let attachment = QBChatAttachment()
                
                attachment.ID = String(blob.ID)
                print("blobid4  ",blob.ID)
                
                attachment.type = "video"
                if((message.text=="")||(message.text==nil))
                {
                    message.text="File Attachments"
                }
                
                message.attachments = [attachment]
                
                let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                
                cdmanager.childContext!.performBlock {
                    
                    let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                    chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                    
                    chatBubble.updateThumnail(imageData)
                    chatBubble.updateIsAttachmentFlag(true)
                    chatBubble.updateAssetPath(url.absoluteString)
                    chatBubble.attachmentID = String(blob.ID)
                    chatBubble.mediaType = "video"
                    NSUserDefaults.standardUserDefaults().setObject(lobjData, forKey: chatBubble.attachmentID)
                    do { try cdmanager.childContext.save()} catch { }
                    do { try cdmanager.parentContext.save()} catch { }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.fetchDataOnLoading(self.dialogID)
                        self.uploadingFileLabel.hidden = true
                        self.activityIndicatorView.hidden = true
                    }
                    
                }
                
                switch self.chatTypeenum
                {
                case .oneTOOneChat:
                    
                    //print(UInt(self.recId))
                    message.senderID = LocalStorageService.shared().currentUser.ID
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    
                    break
                    
                case .GroupChat:
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    break
                case .LearningCircles:
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        
                        //print("APIServiceSessionManger ************* NETWORK REACHABLE")
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    break
                    
                default:
                    print("Default");
                    break
                    
                }
                }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                    
                }, errorBlock: { (responce:QBResponse) -> Void in
                    self.uploadingFileLabel.hidden = true
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                    self.showAlert("Error", text: "Can't send video file. Check internet connection.")
            })
            }) { (error:String!) -> Void in
                //
        }
        
    }
    
    func sendingAudioAndCaptiontextbackToChatPage(attachedUrl: NSURL, captionText: NSString, nameOfTheAudio: NSString!) {
        
        if(!(AFNetworkReachabilityManager.sharedManager().reachable))
        {
            self.showAlert("Can't send message", text: "Check internet connection")
            return
        }
        
        self.view.userInteractionEnabled = false
        self.uploadingFileLabel.hidden = false
        self.activityIndicatorView.hidden = false
        // let cell:SelfCaptionAndImageTableViewCell!
        let message = QBChatMessage()
        message.text = "Attachment"
        let param = NSMutableDictionary()
        param.setValue(true, forKey: "save_to_history")
        message.customParameters = param
        message.text = captionText as String
        message.senderID = LocalStorageService.shared().currentUser.ID
        
        if((message.text=="")||(message.text==nil))
        {
            message.text="File Attachments"
        }
        switch self.chatTypeenum
        {
        case .oneTOOneChat:
            break
            
        case .GroupChat:
            break
        default:
            break
            
        }
        message.senderID = LocalStorageService.shared().currentUser.ID
        //Saving thumnail to DB.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            dispatch_async(dispatch_get_main_queue()) {
                let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                
                cdmanager.childContext!.performBlock {
                    
                    let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                    //chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                    //chatBubble.updateThumnail(imageData)
                    chatBubble.updateIsAttachmentFlag(true)
                    chatBubble.updateAssetPath(attachedUrl.absoluteString)
                    
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        chatBubble.updateSendStatus(true)
                    }
                    else{
                        // print("APIServiceSessionManger ************** NETWORK OFFLINE")
                        chatBubble.updateSendStatus(false)
                    }
                    chatBubble.mediaType="audio"
                    chatBubble.attachmentType="audio"
                    chatBubble.thumbNail = NSData()
                    
                    //home.storeMessage(message)
                    
                    do { try cdmanager.childContext.save()} catch { }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                    }
                }
                return
            }
            QBRequest.TUploadFile(self.audioData, fileName: nameOfTheAudio as String, contentType: "audio/mp3", isPublic: true, successBlock: { (responce:QBResponse, blob:QBCBlob) -> Void in
                //                    SVProgressHUD.dismiss()
                let attachment = QBChatAttachment()
                
                attachment.ID = String(blob.ID)
                
                attachment.type = "audio"
                if((message.text=="")||(message.text==nil))
                {
                    message.text="File Attachments"
                }
                
                message.attachments = [attachment]
                
                
                let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                
                cdmanager.childContext!.performBlock {
                    
                    let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                    chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                    chatBubble.attachmentID = String(blob.ID)
                    chatBubble.mediaType = "video"
                    NSUserDefaults.standardUserDefaults().setObject(self.audioData, forKey: chatBubble.attachmentID)
                    
                    chatBubble.fileContentType = blob.contentType;
                    chatBubble.fileName = blob.name;
                    do { try cdmanager.childContext.save()} catch { }
                    do { try cdmanager.parentContext.save()} catch { }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.uploadingFileLabel.hidden = true
                        self.activityIndicatorView.hidden = true
                        self.view.userInteractionEnabled = true
                        self.fetchDataOnLoading(self.dialogID)
                    }
                    
                }
                
                switch self.chatTypeenum
                {
                case .oneTOOneChat:
                    message.senderID = LocalStorageService.shared().currentUser.ID
                    
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    
                    break
                    
                case .GroupChat:
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    break
                case .LearningCircles:
                    if( AFNetworkReachabilityManager.sharedManager().reachable){
                        self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                            if(error == nil)
                            {
                                NSLog("sent");
                            }
                            else
                            {
                                NSLog("error: %@", error!);
                            }
                        })
                        
                    }
                    break
                    
                default:
                    print("Default");
                    break
                    
                }
                }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                    
                }, errorBlock: { (responce:QBResponse) -> Void in
                    self.uploadingFileLabel.hidden = true
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                    self.showAlert("Error", text: "Can't send audio file. Check internet connection.")            })
            
        }
    }
    
    func sendingvideoAndCaptiontextbackToChatPage(attachedUrl:NSURL,captionText:NSString,nameOfTheVideo:NSString!)
    {
        
        if(AFNetworkReachabilityManager.sharedManager().reachable)
        {
            sendVideo(attachedUrl, captionText:captionText, videoname: nameOfTheVideo)
            self.uploadingFileLabel.hidden = false
            self.activityIndicatorView.hidden = false
            self.isDownloadingImagesOrVideos=false
            
        }
        else
        {
            self.showAlert("Can't send message", text: "Check internet connection")
        }
    }
    
    func sendingImageAndCaptiontextbackToChatPage(attachedImage:UIImage,captionText:NSString,imageNameToupload:NSString,imageCompletePath:NSURL,typeofTheImage:NSString)
    {
        
        if(!(AFNetworkReachabilityManager.sharedManager().reachable))
        {
            self.showAlert("Can't send message", text: "Check internet connection")
            return
        }
        self.uploadingFileLabel.hidden = false
        self.activityIndicatorView.hidden = false
        
        //var cell:SelfCaptionAndImageTableViewCell!
        self.isDownloadingImagesOrVideos=false
        let message = QBChatMessage()
        let param = NSMutableDictionary()
        param.setValue(true, forKey: "save_to_history")
        message.customParameters = param
        message.text = captionText as String
        message.senderID = LocalStorageService.shared().currentUser.ID
        
        switch self.chatTypeenum
        {
        case .oneTOOneChat:
            break
        case .GroupChat:
            break
        default:
            break
        }
        //Saving thumnail to DB.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                
                cdmanager.childContext!.performBlock {
                    
                    let home = Home.findOrCreateHomeWithIdentifier(self.dialogID as String, inContext: cdmanager.childContext)
                    home.storeMessage(message)
                    
                    do { try cdmanager.childContext.save()} catch { }
                    do { try cdmanager.parentContext.save()} catch { }
                    
                }
            }
            
        }
        let thumnail = attachedImage
        let imageData = NSData(data: UIImageJPEGRepresentation(thumnail, 1.0)!) as NSData
        
        QBRequest.TUploadFile(imageData, fileName: imageNameToupload as String, contentType: "image/png", isPublic: true, successBlock: { (responce:QBResponse, blob:QBCBlob) -> Void in
            let attachment = QBChatAttachment()
            
            attachment.ID = String(blob.ID)
            
            attachment.type = "photo"
            if((message.text=="")||(message.text==nil))
            {
                message.text="File Attachments"
            }
            
            message.attachments = [attachment]
            dispatch_async(dispatch_get_main_queue()) {
                self.uploadingFileLabel.hidden = true
                self.activityIndicatorView.hidden = true
            }
            
            message.senderID = LocalStorageService.shared().currentUser.ID
            
            switch self.chatTypeenum
            {
            case .oneTOOneChat:
                
                if( AFNetworkReachabilityManager.sharedManager().reachable){
                    self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                        if(error == nil)
                        {
                            NSLog("sent");
                        }
                        else
                        {
                            NSLog("error: %@", error!);
                        }
                    })
                    
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                        chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                        chatBubble.updateSendStatus(false)
                        chatBubble.updateThumnail(imageData)
                        chatBubble.updateIsAttachmentFlag(true)
                        chatBubble.updateFileName(imageCompletePath.relativePath)
                        chatBubble.updateAssetPath(imageCompletePath.absoluteString)
                        chatBubble.mediaType="photo"
                        chatBubble.attachmentType="photo"
                        
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fetchDataOnLoading(self.dialogID)
                            self.uploadingFileLabel.hidden = true
                            self.activityIndicatorView.hidden = true
                        }
                    }
                }
                break
                
            case .GroupChat:
                if( AFNetworkReachabilityManager.sharedManager().reachable){
                    self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                        if(error == nil)
                        {
                            NSLog("sent");
                        }
                        else
                        {
                            NSLog("error: %@", error!);
                        }
                    })
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                        chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                        chatBubble.updateSendStatus(false)
                        chatBubble.updateThumnail(imageData)
                        chatBubble.updateIsAttachmentFlag(true)
                        chatBubble.updateFileName(imageCompletePath.relativePath)
                        chatBubble.updateAssetPath(imageCompletePath.absoluteString)
                        chatBubble.mediaType="photo"
                        chatBubble.attachmentType="photo"
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fetchDataOnLoading(self.dialogID)
                            self.uploadingFileLabel.hidden = true
                            self.activityIndicatorView.hidden = true
                        }
                    }
                }
                break
            case .LearningCircles:
                if( AFNetworkReachabilityManager.sharedManager().reachable){
                    self.chatRoom.sendMessage(message, completionBlock: { (error:NSError?) -> Void in
                        if(error == nil)
                        {
                            NSLog("sent");
                        }
                        else
                        {
                            NSLog("error: %@", error!);
                        }
                    })
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(message.ID, inContext: cdmanager.childContext)
                        chatBubble.storeMessage(message, forDialogId: self.dialogID as String)
                        chatBubble.updateSendStatus(false)
                        chatBubble.updateThumnail(imageData)
                        chatBubble.updateIsAttachmentFlag(true)
                        chatBubble.updateFileName(imageCompletePath.relativePath)
                        chatBubble.updateAssetPath(imageCompletePath.absoluteString)
                        chatBubble.mediaType="photo"
                        chatBubble.attachmentType="photo"
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fetchDataOnLoading(self.dialogID)
                            self.uploadingFileLabel.hidden = true
                            self.activityIndicatorView.hidden = true
                        }
                    }
                }
                break
                
            default:
                print("Default");
                break
                
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                
            }, errorBlock: { (responce:QBResponse) -> Void in
                self.uploadingFileLabel.hidden = true
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                self.showAlert("Error", text: "Can't send image file. Check internet connection.")
        })
        
    }
    
    func downloadVideo(chatObj:Chat,newIndexPath: NSIndexPath,othersCell:OthercellWithCaptionAndDownloadCell){
        
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, data:NSData) -> Void in
            print("attid",chatObj.attachmentID)
            othersCell.progressView.hidden=true
            print(chatObj.attachmentID)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                let videoData = data
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                
                videoData.writeToFile(appFile, atomically: true)
                let url = NSURL(fileURLWithPath: appFile)
                
                let asset:AVAsset=AVAsset(URL: url)
                let imagegenerator:AVAssetImageGenerator=AVAssetImageGenerator(asset: asset) as AVAssetImageGenerator
                imagegenerator.appliesPreferredTrackTransform=true
                let time = CMTimeMakeWithSeconds(1.0, 1)
                var actualTime : CMTime = CMTimeMake(0, 0)
                
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: chatObj.attachmentID)
                var imageData = NSData()
                do
                {
                    let imageRef = try imagegenerator.copyCGImageAtTime(time, actualTime:&actualTime)
                    let thumbnailImage:UIImage=UIImage(CGImage:imageRef)
                    let thumnail = UIImage.generatePhotoThumbnail(thumbnailImage,withSide: 140) as UIImage
                    imageData = NSData(data:UIImageJPEGRepresentation(thumnail,1.0)!) as NSData
                }
                catch
                {
                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                        chatBubble.updateAssetPath(url.absoluteString)
                        chatBubble.updateThumnail(imageData)
                        chatBubble.mediaType="video"
                        
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { };
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fetchDataOnLoading(self.dialogID)
                        }
                        
                    }
                    self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                    
                }
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(othersCell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
        
    }
    
    func downloadVideoForSelfCell(chatObj:Chat,newIndexPath: NSIndexPath,selfcell:SelfImageDownloadOptionCell){
        
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, data:NSData) -> Void in
            selfcell.progressView.hidden=true
            print(chatObj.attachmentID)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                var tempDirectory:NSString
                tempDirectory=NSTemporaryDirectory()
                let videoData = data
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                
                videoData.writeToFile(appFile, atomically: true)
                let url = NSURL(fileURLWithPath: appFile)
                
                let asset:AVAsset=AVAsset(URL: url)
                let imagegenerator:AVAssetImageGenerator=AVAssetImageGenerator(asset: asset) as AVAssetImageGenerator
                imagegenerator.appliesPreferredTrackTransform=true
                let time = CMTimeMakeWithSeconds(1.0, 1)
                var actualTime : CMTime = CMTimeMake(0, 0)
                
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: chatObj.attachmentID)
                var imageData = NSData()
                do
                {
                    let imageRef = try imagegenerator.copyCGImageAtTime(time, actualTime:&actualTime)
                    let thumbnailImage:UIImage=UIImage(CGImage:imageRef)
                    let thumnail = UIImage.generatePhotoThumbnail(thumbnailImage,withSide: 140) as UIImage
                    imageData = NSData(data:UIImageJPEGRepresentation(thumnail,1.0)!) as NSData
                }
                catch
                {
                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                        chatBubble.updateAssetPath(url.absoluteString)
                        chatBubble.updateThumnail(imageData)
                        chatBubble.mediaType="video"
                        
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { };
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.fetchDataOnLoading(self.dialogID)
                        }
                        
                    }
                    self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                    
                }
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(selfcell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
        
    }
    
    func downloadAudio(chatObj:Chat,newIndexPath: NSIndexPath,othersCell:OthercellWithCaptionAndDownloadCell){
        
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, data:NSData) -> Void in
            
            othersCell.progressView.hidden=true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                var tempDirectory:NSString
                tempDirectory=NSTemporaryDirectory()
                let getImagePath = tempDirectory.stringByAppendingPathComponent(chatObj.attachmentID)
                NSFileManager.defaultManager().createFileAtPath(getImagePath, contents: data, attributes: nil)
                //  print(videourl)
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: chatObj.attachmentID)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                        chatBubble.mediaType="audio"
                        chatBubble.thumbNail = NSData()
                        
                        
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { };
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                        }
                        
                    }
                }
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(othersCell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
        
    }
    
    func downloadAudioForSelfCell(chatObj:Chat,newIndexPath: NSIndexPath,selfcell:SelfImageDownloadOptionCell){
        
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, data:NSData) -> Void in
            
            selfcell.progressView.hidden=true
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                var tempDirectory:NSString
                tempDirectory=NSTemporaryDirectory()
                let getImagePath = tempDirectory.stringByAppendingPathComponent(chatObj.attachmentID)
                NSFileManager.defaultManager().createFileAtPath(getImagePath, contents: data, attributes: nil)
                //  print(videourl)
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: chatObj.attachmentID)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    
                    cdmanager.childContext!.performBlock {
                        
                        let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                        chatBubble.mediaType="audio"
                        chatBubble.thumbNail = NSData()
                        
                        
                        do { try cdmanager.childContext.save()} catch { }
                        do { try cdmanager.parentContext.save()} catch { };
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                        }
                        
                    }
                }
                
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(selfcell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
        
    }
    //
    //
    func downloadImage(chatObj : Chat,newIndexPath: NSIndexPath,cell:OthercellWithCaptionAndDownloadCell){
        
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, imageData:NSData) -> Void in
            
            cell.progressView.hidden=true
            let image = UIImage(data: imageData)
            let rotatedimage=UIImage.rotateUIImage(image)
            
            //Saving thumnail to DB.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let thumnail = image
                let imageData:NSData=NSData(data: UIImageJPEGRepresentation(thumnail!, 1.0)!) as NSData
                
                self.library?.saveImage(rotatedimage, toAlbum: "Emeritus Images", withCompletionBlock: { (asseturl:NSURL!) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                        cdmanager.childContext!.performBlock {
                            
                            let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                            chatBubble.updateAssetPath(asseturl.absoluteString)
                            chatBubble.updateThumnail(imageData)
                            
                            chatBubble.mediaType="photo"
                            do { try cdmanager.childContext.save()} catch { }
                            do { try cdmanager.parentContext.save()} catch { };
                            dispatch_async(dispatch_get_main_queue()) {
                                self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                            }
                        }
                        
                        return
                    }
                    }, andFailureBlock: { (error:NSError!) -> Void in
                        
                        self.isDownloadingImagesOrVideos=false
                        
                        if let errordesription=error
                        {
                            print(errordesription.localizedDescription)
                        }
                })
            }
            
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(cell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
        
    }
    
    func downloadImageActionForSelfCell(chatObj : Chat,newIndexPath: NSIndexPath,cell:SelfImageDownloadOptionCell){
        QBRequest.downloadFileWithID(UInt(chatObj.attachmentID)!, successBlock: { (responce:QBResponse, imagedata:NSData) -> Void in
            cell.progressView.hidden=true
            let image = UIImage(data: imagedata)
            let rotatedimage=UIImage.rotateUIImage(image)
            print(chatObj.attachmentID)
            //Saving thumnail to DB.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let thumnail = image
                let imageData:NSData=NSData(data: UIImageJPEGRepresentation(thumnail!, 1.0)!) as NSData
                
                self.library?.saveImage(rotatedimage, toAlbum: "Emeritus Images", withCompletionBlock: { (asseturl:NSURL!) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let cdmanager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                        
                        cdmanager.childContext!.performBlock {
                            
                            let chatBubble = Chat.findOrCreateChatWithIdentifier(chatObj.chatID, inContext: cdmanager.childContext)
                            chatBubble.updateAssetPath(asseturl.absoluteString)
                            chatBubble.updateThumnail(imageData)
                            
                            chatBubble.mediaType="photo"
                            
                            do { try cdmanager.childContext.save()} catch { }
                            do { try cdmanager.parentContext.save()} catch { };
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.chatTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:newIndexPath.row, inSection: newIndexPath.section)], withRowAnimation: .Automatic)
                            }
                        }
                        
                        return
                    }
                    
                    }, andFailureBlock: { (error:NSError!) -> Void in
                        
                        self.isDownloadingImagesOrVideos=false
                        
                        if let errordesription=error
                        {
                            print(errordesription.localizedDescription)
                        }
                })
                
            }
            }, statusBlock: { (request:QBRequest, status:QBRequestStatus?) -> Void in
                self.makeProgressView(cell.progressView, percentOfCompletion: CGFloat(status!.percentOfCompletion))
            }) { (responce:QBResponse) -> Void in
                
        }
    }
    
    func downloadButtonActionCaptionAndImageDownload(cell: OthercellWithCaptionAndDownloadCell)
    {
        loadingEarlierMessages=true
        isDownloadingImagesOrVideos=true
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.chatTableView.indexPathForCell(cell)!
        let cellRect=self.chatTableView.rectForRowAtIndexPath(newIndexPath)
        _=self.chatTableView.convertRect(cellRect, toView:self.chatTableView.superview)
        let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
        if(chatobj.attachmentType == "photo")
        {
            downloadImage(chatobj, newIndexPath: newIndexPath,cell:cell)
        }
        else if(chatobj.attachmentType == "video"){
            
            downloadVideo(chatobj,newIndexPath: newIndexPath,othersCell:cell)
        }
        
        if(chatobj.attachmentType == "audio"){
            
            downloadAudio(chatobj,newIndexPath: newIndexPath,othersCell:cell)
        }
    }
    
    func popupButtonActionCaptionAndImageDownload(cell: OthercellWithCaptionAndDownloadCell)
    {
        chattextView.resignFirstResponder()
        PopupTableViewCellonOthers=nil
        PopupTableViewCellonOthersCaptionDownload=cell
        selectedRow = self.chatTableView.indexPathForCell(cell)!.row
        goToProfile()
    }
    
    func selfdownloadButtonActionCaptionAndImageDownload(cell: SelfImageDownloadOptionCell)
    {
        loadingEarlierMessages=true
        isDownloadingImagesOrVideos=true
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.chatTableView.indexPathForCell(cell)!
        let cellRect=self.chatTableView.rectForRowAtIndexPath(newIndexPath)
        _=self.chatTableView.convertRect(cellRect, toView:self.chatTableView.superview)
        let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
        if(chatobj.attachmentType == "photo")
        {
            downloadImageActionForSelfCell(chatobj, newIndexPath: newIndexPath,cell:cell)
        }
        else if(chatobj.attachmentType == "video"){
            
            downloadVideoForSelfCell(chatobj,newIndexPath:newIndexPath,selfcell: cell)
        }
            
        else if(chatobj.attachmentType == "audio"){
            
            downloadAudioForSelfCell(chatobj,newIndexPath:newIndexPath,selfcell: cell)
        }
        
    }
    
    func tappedOnThumbNailOtherCell(cell: OtherCaptionAndImageTableViewCell)
    {
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.chatTableView.indexPathForCell(cell)!
        let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
        
        if(!(chatobj.assetPath==nil))
        {
            if(chatobj.attachmentType=="image"||chatobj.attachmentType=="photo"||chatobj.mediaType=="photo")
            {
                let assetUrl:NSURL?=NSURL(string:chatobj.assetPath)
                
                self.library?.checkMediaExistedOrNot(assetUrl, withStatusBlock: { (status:Bool) -> Void in
                    
                    if(status==true)
                    {
                        self.library?.getImageFromAssetUrl(assetUrl, withCompletionBlock: { (imageFromAssetUrl:UIImage!) -> Void in
                            
                            let imageviewController:ImageWebViewController?=ImageWebViewController(nibName:"ImageWebViewController", bundle: nil) as ImageWebViewController
                            let rotatedimage=UIImage.rotateUIImage(imageFromAssetUrl)
                            imageviewController?.imageFromchatPage=rotatedimage
                            self.navigationController?.pushViewController(imageviewController!, animated: true)
                            
                            }, andFailureBlock: { (error:NSError!) -> Void in
                                
                                if let errorInfo=error
                                {
                                    print(errorInfo.description)
                                }
                        })
                    }
                    else
                    {
                        self.showAlert("Alert", text: "Media no longer available")
                    }
                })
            }
            
        }
        
    }
    
    func tappedOnThumbNailOnSelfCelll(cell: SelfCaptionAndImageTableViewCell)
    {
        if(isDeletingMode==false)
        {
            var newIndexPath: NSIndexPath = NSIndexPath();
            newIndexPath = self.chatTableView.indexPathForCell(cell)!
            let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
            if(!(chatobj.assetPath==nil))
            {
                if(chatobj.attachmentType=="image"||chatobj.attachmentType=="photo"||chatobj.mediaType=="photo")
                {
                    let assetUrl:NSURL?=NSURL(string:chatobj.assetPath)
                    
                    self.library?.checkMediaExistedOrNot(assetUrl, withStatusBlock: { (status:Bool) -> Void in
                        
                        if(status==true)
                        {
                            self.library?.getImageFromAssetUrl(assetUrl, withCompletionBlock: { (imageFromAssetUrl:UIImage!) -> Void in
                                
                                let imageviewController:ImageWebViewController?=ImageWebViewController(nibName:"ImageWebViewController", bundle: nil) as ImageWebViewController
                                let rotatedimage=UIImage.rotateUIImage(imageFromAssetUrl)
                                imageviewController?.imageFromchatPage=rotatedimage
                                self.navigationController?.pushViewController(imageviewController!, animated: true)
                                
                                }, andFailureBlock: { (error:NSError!) -> Void in
                                    
                                    if let errorInfo=error
                                    {
                                        print(errorInfo.description)
                                    }
                            })
                        }
                        else
                        {
                            self.showAlert("Alert", text: "Media no longer available")
                        }
                    })
                }
                
            }
        }
    }
    func tableView(tableView: UITableView,
        shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        selectedIndexPath=indexPath
        isDeletingMode=true
        return true
    }
    
    func tableView( tableView: UITableView,
        performAction action: Selector,
        forRowAtIndexPath indexPath: NSIndexPath,
        withSender sender: AnyObject?)
    {
        
    }
    
    func tableView(tableView: UITableView,
        canPerformAction action: Selector,
        forRowAtIndexPath indexPath: NSIndexPath,
        withSender sender: AnyObject?) -> Bool
    {
        selectedIndexPath=indexPath
        isDeletingMode=true
        return true
    }
    
    func longPressActionOnSelfDownloadCell(cell: SelfImageDownloadOptionCell)
    {
        deleteAction()
    }
    
    func longPressActionOnSelfCaptionAndImageCell(cell: SelfCaptionAndImageTableViewCell)
    {
        deleteAction()
    }
    
    func longPressActionOnSelfCellWithText(cell: PersonSelfTableViewCell)
    {
        deleteAction()
    }
    
    func playButtonClickedOnSelfCell(cell:SelfCaptionAndImageTableViewCell)
    {
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.chatTableView.indexPathForCell(cell)!
        let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
        if(!(chatobj.attachmentID == nil))
        {
            if(!(NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) == nil))
            {
                if(chatobj.mediaType == "video")
                {
                    let videoData =  NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) as! NSData
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                    
                    videoData.writeToFile(appFile, atomically: true)
                    let url = NSURL(fileURLWithPath: appFile)
                    
                    self.moviePlayercontroller = MPMoviePlayerViewController(contentURL:url)
                    self.presentMoviePlayerViewControllerAnimated(self.moviePlayercontroller)
                    self.moviePlayercontroller.moviePlayer.play()
                    
                    if let _ = self.moviePlayercontroller{
                        
                        NSNotificationCenter.defaultCenter().addObserver(self,selector: "videoHasFinishedPlaying:",name: MPMoviePlayerPlaybackDidFinishNotification,
                            object: nil)
                        self.moviePlayercontroller.moviePlayer.scalingMode = .AspectFit
                    }
                    
                }
                else
                {
                    
                    let audioData = NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) as! NSData
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                    
                    audioData.writeToFile(appFile, atomically: true)
                    let url = NSURL(fileURLWithPath: appFile)
                    
                    let mpPlayer = MPMoviePlayerViewController(contentURL: url)
                    
                    presentMoviePlayerViewControllerAnimated(mpPlayer)
                }
            }
            
        }
        
    }
    
    func playButtonClickedOnOthersCell(cell:OtherCaptionAndImageTableViewCell)
    {
        
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.chatTableView.indexPathForCell(cell)!
        let chatobj:Chat=self.messageList.objectAtIndex(newIndexPath.row) as! Chat
        if(!(chatobj.attachmentID == nil))
        {
            if(NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) != nil)
            {
                
                if(chatobj.mediaType == "video")
                {
                    let videoData =  NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) as! NSData
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                    
                    videoData.writeToFile(appFile, atomically: true)
                    let url = NSURL(fileURLWithPath: appFile)
                    self.moviePlayercontroller = MPMoviePlayerViewController(contentURL:url)
                    self.presentMoviePlayerViewControllerAnimated(self.moviePlayercontroller)
                    self.moviePlayercontroller.moviePlayer.play()
                    
                    if let _ = self.moviePlayercontroller{
                        
                        NSNotificationCenter.defaultCenter().addObserver(self,selector: "videoHasFinishedPlaying:",name: MPMoviePlayerPlaybackDidFinishNotification,
                            object: nil)
                        self.moviePlayercontroller.moviePlayer.scalingMode = .AspectFit
                    }
                }
                else
                {
                    
                    let audioData = NSUserDefaults.standardUserDefaults().objectForKey(chatobj.attachmentID) as! NSData
                    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let appFile = documentsDirectory.stringByAppendingPathComponent("MyFile.m4v")
                    
                    audioData.writeToFile(appFile, atomically: true)
                    let url = NSURL(fileURLWithPath: appFile)
                    
                    let mpPlayer = MPMoviePlayerViewController(contentURL: url)
                    
                    presentMoviePlayerViewControllerAnimated(mpPlayer)
                    
                }
                
            }
            
        }
    }
    
    func forwardButtonClickedOnOthersCell(cell: OtherCaptionAndImageTableViewCell)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func forwardButtonClickedOnOthersDownloadCell(cell: OthercellWithCaptionAndDownloadCell)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func forwardButtonClickedOnCell(cell: SelfCaptionAndImageTableViewCell)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func forwardButtonClickedOnDCell(cell: SelfImageDownloadOptionCell)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func videoHasFinishedPlaying(notification: NSNotification){
        
        //    print("Video finished playing")
        
        /* Find out what the reason was for the player to stop */
        let reason =
        notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
            as! NSNumber?
        
        if let _ = reason{
            
            stopPlayingVideo()
        }
        
    }
    
    func makeProgressView(progressView: UCZProgressView, percentOfCompletion: CGFloat){
        progressView.hidden=false
        progressView.progress=CGFloat(percentOfCompletion)
        progressView.showsText=false
        progressView.backgroundView.backgroundColor=UIColor.clearColor()
        progressView.backgroundColor=UIColor.clearColor()
        progressView.tintColor=UIColor.grayColor()
        progressView.radius = 30.0;
        progressView.lineWidth = 3.0;
    }
    
    func showAlert(title: String, text: String){
        let alert = UIAlertView()
        alert.title = title
        alert.message = text
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func stopPlayingVideo() {
        if let player = moviePlayercontroller{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            moviePlayercontroller.moviePlayer.stop()
            player.view.removeFromSuperview()
            NSNotificationCenter.defaultCenter().removeObserver(self,name:MPMoviePlayerPlaybackDidFinishNotification,object:nil)
        }
        
    }
    
    func scaleImage(image:UIImage,  toSize:CGSize) -> UIImage {
        
        let aspectRatioAwareSize = self.aspectRatioAwareSize(image.size, boxSize: toSize)
        UIGraphicsBeginImageContextWithOptions(aspectRatioAwareSize, false, 0.0);
        
        image.drawInRect(CGRectMake(0, 0, aspectRatioAwareSize.width , aspectRatioAwareSize.height))
        let retVal = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return retVal
    }
    
    func aspectRatioAwareSize(imageSize: CGSize, boxSize: CGSize) -> CGSize {
        
        let wi = imageSize.width
        let hi = imageSize.height
        let ws = boxSize.width
        let hs = boxSize.height
        
        let r1:CGFloat = ws/wi
        let r2:CGFloat = hs/hi
        var minimum:CGFloat = 1;
        if ( r1 <= r2 ){
            minimum = r1
        }
        else{
            minimum = r2
        }
        
        let retVal : CGSize
        retVal = CGSizeMake( wi * minimum, hi * minimum )
        return retVal
    }
    
    func hideFailedLoadingMsg(){
        
        if ( failedLoadingMsg != nil )
        {
            failedLoadingMsg.hidedSelf()
        }
    }
   
    func connectedNetwork(){
        if ( failedLoadingMsg != nil )
        {
            failedLoadingMsg.hideSelf()
            if ( isConnectedNW == false ){
                gettingMessagesFromQuickbloxs()
            }
            isConnectedNW = true
        }
    }
    
    func disconnectedNetwork(){
        if ( failedLoadingMsg != nil )
        {
            failedLoadingMsg.showSelf()
            isConnectedNW = false
            _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hideFailedLoadingMsg"), userInfo: nil, repeats: false)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
 }
