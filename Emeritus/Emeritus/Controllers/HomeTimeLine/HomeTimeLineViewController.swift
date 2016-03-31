//
//  HomeTimeLineViewController.swift
//  Emeritus
//
//  Created by SB on 22/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: self.startIndex.advancedBy(r.startIndex), end: self.startIndex.advancedBy(r.endIndex)))
    }
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    var ns: NSString {
        return self as NSString
    }
    var pathExtension: String? {
        return ns.pathExtension
    }
    var lastPathComponent: String? {
        return ns.lastPathComponent
    }
}

func SYSTEM_VERSION_EQUAL_TO(version: NSString) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version as String,
        options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedSame
}

func SYSTEM_VERSION_GREATER_THAN(version: NSString) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version as String,
        options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending
}

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: NSString) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version as String,
        options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
}

func SYSTEM_VERSION_LESS_THAN(version: NSString) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version as String,
        options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
}

func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: NSString) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version as String,
        options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedDescending
}

public extension NSDate {
    
    //there is a performance lag with date formatter.
    var date: String {
        let formatter=ERDateFormatter.defaultDateFormater()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "dd MMM"
        return formatter.stringFromDate(self)
    }
    var time: String {
        let formatter = ERDateFormatter.defaultDateFormater()
        formatter.timeZone=NSTimeZone(name:NSTimeZone.systemTimeZone().name)
        formatter.dateFormat = "hh:mm a"
        return formatter.stringFromDate(self)
    }
    var weekday: String {
        let formatter = ERDateFormatter.defaultDateFormater()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "EEEE"
        return formatter.stringFromDate(self)
    }
    
    func formatted(format:String) -> String {
        let formatter = ERDateFormatter.defaultDateFormater()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

class HomeTimeLineViewController: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var homeListTableView: UITableView!
    var homeData : NSArray = NSArray()
    var homeListItems : NSMutableArray = NSMutableArray()
    var userNames:NSArray!
    var name:Users!
    var customGroupTableCell:GroupChatTableViewCell!
    var customoneTooneChatCell:OneToOneChatTableViewCell!
    var customlearningCirclesChatCell:LearningCirclesTableViewCell!
    var custompollCell:PollTableViewCell!
    var isViewDidappear:Bool=false
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicatorBaseView: UIView!
    @IBOutlet weak var indicatorLabel: UILabel!
    var timeinterval:NSDateComponents=ERDateComponents.defaultDateComponents()
    var chatTypeenum = chatType.LearningCircles
    @IBOutlet weak var tableViewtopConstraint:NSLayoutConstraint!
    @IBOutlet weak var frozenPostView: UIView!
    @IBOutlet weak var frozenPostLabel: UILabel!
    var loginservicesObj:LoginServices!
    var timer:NSTimer!
    var pollManager:PollManager!
    var indexPathForClassChat:NSIndexPath = NSIndexPath()
    var indexPathForGroupChat:NSIndexPath = NSIndexPath()
    var indexPathForLearningCircle:NSIndexPath = NSIndexPath()
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //frozenPostLabel.font = UIFont(name: "Avenir", size:17)
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reachabilityChanged"), name: AFNetworkingReachabilityDidChangeNotification , object: nil)
        
        self.homeListTableView.userInteractionEnabled = false;
        self.activityIndicator.startAnimating()
        _ = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: Selector("waitSome"), userInfo: nil, repeats: false)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data")
        self.refreshControl.tintColor = UIColor.grayColor()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.homeListTableView.addSubview(refreshControl)
        
        let nFrozenPostsCout = FrozenPostManager.sharedDispatchInstance.frozenPostsCounts
        if nFrozenPostsCout == 0{
            hideFrozenPost()
        }
        else if nFrozenPostsCout == 1{
            showFrozenPost()
            frozenPostLabel.text=FrozenPostManager.sharedDispatchInstance.arrayFrozen.objectAtIndex(0).shortDesc
        }
        else if nFrozenPostsCout > 1{
            showFrozenPost()
            frozenPostLabel.text="Frozen Post (1+)"
        }
        
        stayOnline();
        pollManager = PollManager.instance()
        self.navigationController?.delegate=self
        self.navigationController?.interactivePopGestureRecognizer!.enabled=false
        
        let cellNib:UINib = UINib(nibName:"GroupChatTableViewCell", bundle: nil) as UINib
        self.homeListTableView.registerNib(cellNib, forCellReuseIdentifier: "GroupChatTableViewCell")
        customGroupTableCell = cellNib.instantiateWithOwner(nil, options:  nil)[0]as! GroupChatTableViewCell
        
        let onetoonechatcellNib:UINib = UINib(nibName:"OneToOneChatTableViewCell", bundle: nil) as UINib
        self.homeListTableView.registerNib(onetoonechatcellNib, forCellReuseIdentifier: "OneToOneChatTableViewCell")
        customoneTooneChatCell = onetoonechatcellNib.instantiateWithOwner(nil, options:  nil)[0]as! OneToOneChatTableViewCell
        
        let learningcirclecellNib:UINib = UINib(nibName:"LearningCirclesTableViewCell", bundle: nil) as UINib
        self.homeListTableView.registerNib(learningcirclecellNib, forCellReuseIdentifier: "LearningCirclesTableViewCell")
        customlearningCirclesChatCell = learningcirclecellNib.instantiateWithOwner(nil, options:  nil)[0]as! LearningCirclesTableViewCell
        
        let PollTableViewcellNib:UINib = UINib(nibName:"PollTableViewCell", bundle: nil) as UINib
        self.homeListTableView.registerNib(PollTableViewcellNib, forCellReuseIdentifier: "PollTableViewCell")
        custompollCell = PollTableViewcellNib.instantiateWithOwner(nil, options:  nil)[0]as! PollTableViewCell
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "goToClass")
        frozenPostView!.addGestureRecognizer(tapGesture)
        
        //homeListTableView.hidden=true
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        
        self.navigationController?.interactivePopGestureRecognizer!.enabled=false
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.title="EMERITUS"
        self.navigationItem.setHidesBackButton(true,animated:true)
        let ProfileButton:UIButton  = UIButton(frame:  CGRectMake(15, 0,23.0, 23.0))
        ProfileButton.setImage(UIImage(named: "hamburger.png"), forState: .Normal)
        ProfileButton.addTarget(self, action: "profileAction", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: ProfileButton)
        
        let participantsButton=UIBarButtonItem (image:UIImage(named:"participants_icon.png"), style: .Plain, target: self,action: "participantsAction")
        participantsButton.image=UIImage(named:"participants_icon.png")
        participantsButton.tintColor=UIColor.whiteColor()
        navigationItem.rightBarButtonItem = participantsButton
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(17.0)
        ]
        nav?.titleTextAttributes = attributes
        userNames=NSArray()
        
        indicatorBaseView.layer.masksToBounds=true
        indicatorBaseView.layer.cornerRadius=10.0
        indicatorBaseView.layer.borderWidth=3.0
        indicatorBaseView.layer.borderColor=UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.5).CGColor
        indicatorBaseView.backgroundColor=UIColor(red: 31/255.0, green: 160/255.0, blue: 124/255.0, alpha: 1.0)
        hideIndicatorView()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kHomeTimeLineListVCRefreshKey , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"KDeleteReload" , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"Homefeed" , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kNotificationDidReceiveNewMessage , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kNotificationDidReceiveNewMessageFromRoom , object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList:", name: kHomeTimeLineListVCRefreshKey, object: nil)
        
        ChatService.instance().isOnline = false
        ChatService.instance().strCurDlgID = "";
        
        isViewDidappear=false
        loginservicesObj=LoginServices.sharedLogininstance()
        loginservicesObj.fetchFromUserDefaults()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kGotoChatRoom , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotoChatRoom:", name:kGotoChatRoom, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reterivingDataFromDatabase", name:"KDeleteReload", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reterivingDataFromDatabase", name:"Homefeed", object: nil)
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
        
        self.view.bringSubviewToFront(activityIndicator)
        let delay = 1.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            
            NSThread.detachNewThreadSelector(Selector("reterivingDataFromDatabase"), toTarget:self, withObject:nil)
        })
        reterivingDataFromDatabase()
        
        // Set chat notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "chatRoomDidReceiveMessageNotification:", name: kNotificationDidReceiveNewMessageFromRoom, object: nil)
        
        APIServiceSessionManger.GetPollWithCompletionBlock("6", success: { (responseObject) -> Void in
            if let _ = responseObject.objectForKey("status") as? NSString
            {
                if let responce = responseObject.objectForKey("response") as? NSDictionary
                {
                    self.pollManager = PollManager.instance()
                    self.pollManager.parseDictionary(responce as [NSObject : AnyObject])
                }
                self.homeListTableView.reloadData()
                
                let nFrozenPostsCout = FrozenPostManager.sharedDispatchInstance.frozenPostsCounts
                if nFrozenPostsCout == 0{
                    self.hideFrozenPost()
                }
                else if nFrozenPostsCout == 1{
                    self.showFrozenPost()
                    self.frozenPostLabel.text=FrozenPostManager.sharedDispatchInstance.arrayFrozen.objectAtIndex(0).shortDesc
                }
                else if nFrozenPostsCout > 1{
                    self.showFrozenPost()
                    self.frozenPostLabel.text="Frozen Post (1+)"
                }
            }
            
            }) { ( error) -> Void in
                print(error)
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Problem while getting polls"
                alert.addButtonWithTitle("OK")
                //alert.show()
        }
        
        let webManager:MSWebManager=MSWebManager.sharedWebInstance() as MSWebManager
        webManager.setCountryCodeFor("")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gettingHomeFeedResponse()
        
    }
    
    func showFrozenPost()
    {
        tableViewtopConstraint.constant=60
        frozenPostView.hidden=false
    }
    
    func hideFrozenPost()
    {
        tableViewtopConstraint.constant=10
        frozenPostView.hidden=true
    }
    
    func refresh(sender:AnyObject)
    {
        self.homeListTableView.userInteractionEnabled = false;
        APIServiceSessionManger.GetPollWithCompletionBlock("6", success: { (responseObject) -> Void in
            if let _ = responseObject.objectForKey("status") as? NSString
            {
                if let responce = responseObject.objectForKey("response") as? NSDictionary
                {
                    self.pollManager = PollManager.instance()
                    self.pollManager.parseDictionary(responce as [NSObject : AnyObject])
                }
                self.homeListTableView.reloadData()
                
            }
            
            }) { ( error) -> Void in
                print(error)
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Problem while getting polls"
                alert.addButtonWithTitle("OK")
                alert.show()
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gettingHomeFeedResponse()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: Selector("someSelector"), userInfo: nil, repeats: false)
        
    }
    
    func someSelector() {
        self.homeListTableView.userInteractionEnabled = true;
        self.activityIndicator.stopAnimating()
    }
    
    func waitSome() {
        self.homeListTableView.userInteractionEnabled = true;
        self.activityIndicator.stopAnimating()
    }
    
    func stayOnline()
    {
        let webManager:MSWebManager = MSWebManager.sharedWebInstance() as MSWebManager
        webManager.stayOnline();
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.creatingSessionAndLogin()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        isViewDidappear=true
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.homeViewCtrl=self;
        
        let webManager:MSWebManager = MSWebManager.sharedWebInstance() as MSWebManager
        webManager.participant();
        
        if(self.timer != nil)
        {
            self.timer.invalidate();
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: Selector("stayOnline"), userInfo: nil, repeats: true)
        
    }
    
    func goToClass()
    {
        slideMenuController()
        let frozenPostVC:FrozenPostViewController = UIStoryboard(name:"Chat", bundle: nil).instantiateViewControllerWithIdentifier("FrozenPostViewController") as! FrozenPostViewController
        self.navigationController?.pushViewController(frozenPostVC, animated: true)
    }
    
    func updateChatServer(strMsg:NSString, recipent_ID:NSInteger, sender_ID:NSInteger, dialog_ID:NSString, chatRoom:QBChatDialog)
    {
        
        let message = QBChatMessage()
        message.text = strMsg as String
        let param = NSMutableDictionary()
        param.setValue(true, forKey: "save_to_history")
        message.customParameters = param
        
        switch chatTypeenum
        {
        case .oneTOOneChat:
            
            message.recipientID = UInt(recipent_ID)
            message.senderID=UInt(sender_ID)
            if( AFNetworkReachabilityManager.sharedManager().reachable){
                
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                ChatService.instance().sendMessage(message)
            }
            break
            
        case .GroupChat:
            if( AFNetworkReachabilityManager.sharedManager().reachable){
                
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                ChatService.instance().sendMessage(message, toRoom:chatRoom)
            }
            break
        case .LearningCircles:
            if( AFNetworkReachabilityManager.sharedManager().reachable){
                
                print("APIServiceSessionManger ************* NETWORK REACHABLE")
                ChatService.instance().sendMessage(message, toRoom: chatRoom)
            }
            break
            
        default:
            break
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func unhideIndicatorView()
    {
        self.view.bringSubviewToFront(indicatorBaseView)
        homeListTableView.allowsSelection=false
        indicatorBaseView.hidden=false
        
    }
    
    func hideIndicatorView()
    {
        indicatorBaseView.hidden=true
        homeListTableView.allowsSelection=true
        
    }
    
    func participantsAction()
    {
        if(isViewDidappear)
        {
            dispatch_async(dispatch_get_main_queue(), {
                
                let participantViewController = UIStoryboard(name: "Participants", bundle: nil).instantiateViewControllerWithIdentifier("ParticipantsViewController") as! ParticipantsViewController
                self.navigationController?.pushViewController(participantViewController, animated: true)
                
            })
        }
    }
    
    func profileAction()
    {
        self.slideMenuController()?.toggleLeft()
    }
    
    func createUserNameFetchRequest() -> NSFetchRequest{
        let fReq: NSFetchRequest = NSFetchRequest(entityName: Users.entityName() as! NSString as String)
        fReq.returnsObjectsAsFaults = false
        return fReq
    }
    
    func fetchUserNames(){
        
        let fetchRequest = createUserNameFetchRequest()
        
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.parentContext.performBlock({ () -> Void in
            
            do {
                let list = try cdManager.childContext.executeFetchRequest(fetchRequest)
                self.userNames = list
                self.slideMenuController()!.usernames = self.userNames
            }
            catch
            {
                
            }
            
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
        
    }
    
    //MARK: Preparing HomefetchRequest to reterive data from home entity
    
    func createHomeFetchRequest() -> NSFetchRequest{
        let fReq: NSFetchRequest = NSFetchRequest(entityName: Home.entityName() as! NSString as String)
        fReq.returnsObjectsAsFaults = false
        let prioritysortDescriptor = NSSortDescriptor(key: "priority", ascending: false)
        let sortDescriptor = NSSortDescriptor(key: "lastMessageTimeStamp", ascending: false)
        let sortDescriptors = [prioritysortDescriptor,sortDescriptor]
        fReq.sortDescriptors = sortDescriptors
        return fReq
    }
    
    func reterivingDataFromDatabase()
    {
        self.refreshControl.endRefreshing()
        let fetchRequest = createHomeFetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        //CD DB
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.childContext.performBlock({ () -> Void in
            
            do {
                let list = try cdManager.childContext.executeFetchRequest(fetchRequest)
                self.homeListItems.removeAllObjects()
                self.homeListItems =  NSMutableArray(array: list)
                
                if(self.homeListItems.count==0)
                {
                    //self.activityIndicator.stopAnimating()
                }
                self.fetchUserNames()
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.homeListTableView.reloadData()
                    
                })
            }
            catch
            {
                
            }
            
        })
        
        
        let nFrozenPostsCout = FrozenPostManager.sharedDispatchInstance.frozenPostsCounts
        if nFrozenPostsCout == 0{
            hideFrozenPost()
        }
        else if nFrozenPostsCout == 1{
            showFrozenPost()
            frozenPostLabel.text=FrozenPostManager.sharedDispatchInstance.arrayFrozen.objectAtIndex(0).shortDesc
        }
        else if nFrozenPostsCout > 1{
            showFrozenPost()
            frozenPostLabel.text="Frozen Post (1+)"
        }
    }
    
    // MARK: Chat Notifications
    
    func chatDidReceiveMessageNotification(notification: NSNotification){
        
        reterivingDataFromDatabase()
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.homeListTableView.reloadData()
        })
    }
    
    // MARK: Caluclating Difference between current date and date from database
    
    func gettingDifferenceBetweenToDayAndFromDatabse(dateFromdb:NSDate)->NSDateComponents
    {
        var interval:NSDateComponents=ERDateComponents.defaultDateComponents() as NSDateComponents
        //        var calendar:NSCalendar=NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        let calendar:NSCalendar=NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
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
    //MARK: - TableView DataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return homeListItems.count
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if homeListItems.count != 0 {
            let lobjhomeData:Home?=homeListItems.objectAtIndex(indexPath.section) as? Home
            if(!(lobjhomeData==nil))
            {
                if(lobjhomeData?.type.integerValue==1)
                {
                    self.configureLearningCirclesCell(customlearningCirclesChatCell, atIndexPath: indexPath)
                    customlearningCirclesChatCell.layoutSubviews()
                    let height:CGFloat  = customlearningCirclesChatCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                    if((lobjhomeData?.lastMessageText==nil)&&(lobjhomeData?.lastMessageTimeStamp==nil))
                    {
                        return height + 20;
                    }
                    else
                    {
                        return height + 1;
                    }
                    
                }
                else if((lobjhomeData?.type.integerValue==2)||(lobjhomeData?.type.integerValue==4) || (lobjhomeData?.type.integerValue==5))
                {
                    self.configureGroupChatCell(customGroupTableCell, atIndexPath: indexPath)
                    customGroupTableCell.layoutSubviews()
                    let height:CGFloat  = customGroupTableCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                    if((lobjhomeData?.lastMessageText==nil)&&(lobjhomeData?.lastMessageTimeStamp==nil))
                    {
                        return height + 20;
                    }
                    else
                    {
                        return height + 1;
                    }
                    
                }
                    
                else if(lobjhomeData?.type.integerValue==3)
                {
                    self.configureOneToOneChatCell(customoneTooneChatCell, atIndexPath: indexPath)
                    customoneTooneChatCell.layoutSubviews()
                    let height:CGFloat  = customoneTooneChatCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
                    return height + 5;
                }
                    
                else if(lobjhomeData?.type.integerValue==6)
                {
                    return 145
                }
            }
        }
        
        
        return 0
    }
    
    func configureGroupChatCell(cell:GroupChatTableViewCell! ,atIndexPath indexPath:NSIndexPath)->Void
    {
        let homeitem=homeListItems.objectAtIndex(indexPath.section) as! Home
        cell.titleLabel.text=homeitem.name
        
        if(homeitem.lastMessageText==nil)
        {
            cell.descriptionLabel.text=""
        }
        else
        {
            if(homeitem.lastMessageText.characters.count>130)
            {
                cell.descriptionLabel.text=homeitem.lastMessageText[0...130]
            }
            else
            {
                cell.descriptionLabel.text=homeitem.lastMessageText
            }
        }
        if(!(homeitem.participantPhotoUrl==nil))
        {
            if(homeitem.type.integerValue==4)
            {
                cell.iconImageView.sd_setImageWithURL(NSURL(string: homeitem.participantPhotoUrl), placeholderImage:UIImage(named:"class-discussion.png"))
                self.slideMenuController()!.indexPathForClassChat = indexPath
                self.slideMenuController()?.classData = homeitem
                self.indexPathForClassChat = indexPath;
            }
            else if(homeitem.type.integerValue==2)
            {
                self.slideMenuController()!.indexPathForGroupChat = indexPath;
                self.slideMenuController()?.groupData = homeitem
                cell.iconImageView.sd_setImageWithURL(NSURL(string: homeitem.participantPhotoUrl), placeholderImage:UIImage(named:"group-discussion.png"))
            }
            else if(homeitem.type.integerValue==5)
            {
                cell.iconImageView.sd_setImageWithURL(NSURL(string: homeitem.participantPhotoUrl), placeholderImage:UIImage(named:"poll-discussion.png"))
            }
        }
        else
        {
            if(homeitem.type.integerValue==4)
            {
                self.slideMenuController()!.indexPathForClassChat = indexPath
                self.slideMenuController()?.classData = homeitem
                self.indexPathForClassChat = indexPath;
                cell.iconImageView.image=UIImage(named:"class-discussion.png")
            }
            else if(homeitem.type.integerValue==2)
            {
                self.slideMenuController()!.indexPathForGroupChat = indexPath;
                self.slideMenuController()?.groupData = homeitem
                cell.iconImageView.image=UIImage(named:"group-discussion.png")
            }
            else if(homeitem.type.integerValue==5)
            {
                cell.iconImageView.image=UIImage(named:"poll-discussion.png")
            }
        }
        
        if(!(homeitem.unreadMessageCount.integerValue==0))
        {
            let countInString:NSString=String(homeitem.unreadMessageCount.integerValue)
            let size:CGSize=gettingLabelWithsize(String(homeitem.unreadMessageCount.integerValue))
            cell.UnreadcountButtonwidthConstraint.constant=size.width+size.width
            cell.UnreadcountButtonheightConstraint.constant=size.height+size.height/4
            if(countInString.length<=3)
            {
                cell.UnreadcountButton.setTitle(String(homeitem.unreadMessageCount.integerValue), forState: UIControlState.Normal)
            }
            else
            {
                cell.UnreadcountButton.setTitle("+"+countInString.substringToIndex(3), forState: UIControlState.Normal)
            }
            cell.UnreadcountButton.hidden=false
        }
        else
        {
            cell.UnreadcountButton.hidden=true
        }
        if(!(homeitem.lastMessageTimeStamp==nil))
        {
            self.timeinterval=self.gettingDifferenceBetweenToDayAndFromDatabse(homeitem.lastMessageTimeStamp) as NSDateComponents
            
            if(self.timeinterval.day==1)
            {
                cell.endMessageLabel.text="Last message yesterday"
            }
            else  if(self.timeinterval.day>1)
            {
                cell.endMessageLabel.text="Last message at"+" "+String(homeitem.lastMessageTimeStamp.date).uppercaseString
            }
            else
            {
                cell.endMessageLabel.text="Last message at"+" "+String(homeitem.lastMessageTimeStamp.time).uppercaseString
            }
        }
        else
        {
            cell.endMessageLabel.text=""
        }
    }
    
    func configureLearningCirclesCell(cell:LearningCirclesTableViewCell!, atIndexPath indexPath:NSIndexPath)->Void
    {
        let homeitem=homeListItems.objectAtIndex(indexPath.section) as! Home
        cell.titleLabel.text=homeitem.name
        
        self.slideMenuController()!.indexPathForLearningCircle = indexPath;
        self.slideMenuController()?.circleData = homeitem
        
        if(homeitem.lastMessageText==nil)
        {
            cell.descriptionLabel.text=""
            
        }
        else
        {
            if(homeitem.lastMessageText.characters.count>130)
            {
                cell.descriptionLabel.text=homeitem.lastMessageText[0...130]
                
            }
            else
            {
                cell.descriptionLabel.text=homeitem.lastMessageText
                
            }
        }
        if(!(homeitem.participantPhotoUrl==nil))
        {
            cell.logoImageView.sd_setImageWithURL(NSURL(string: homeitem.participantPhotoUrl), placeholderImage:UIImage(named:"learning-circle@3x.png"))
        }
        else
        {
            cell.logoImageView.image=UIImage(named:"learning-circle@.png")
            
        }
        if(!(homeitem.unreadMessageCount.integerValue==0))
        {
            let countInString:NSString=String(homeitem.unreadMessageCount.integerValue)
            let size:CGSize=gettingLabelWithsize(String(homeitem.unreadMessageCount.integerValue))
            cell.UnreadcountButtonwidthConstraint.constant=size.width+size.width
            cell.UnreadcountButtonheightConstraint.constant=size.height+size.height/4
            if(countInString.length<=3)
            {
                cell.UnreadcountButton.setTitle(String(homeitem.unreadMessageCount.integerValue), forState: UIControlState.Normal)
                
            }
            else
            {
                cell.UnreadcountButton.setTitle("+"+countInString.substringToIndex(3), forState: UIControlState.Normal)
            }
            cell.UnreadcountButton.hidden=false
        }
        else
        {
            cell.UnreadcountButton.hidden=true
        }
        if(!(homeitem.lastMessageTimeStamp==nil))
        {
            self.timeinterval=self.gettingDifferenceBetweenToDayAndFromDatabse(homeitem.lastMessageTimeStamp) as NSDateComponents
            
            if(self.timeinterval.day>=1)
            {
                
                cell.endMessagaeLabel.text="Last message on "+String(homeitem.lastMessageTimeStamp.date)+", "+String(homeitem.lastMessageTimeStamp.time).uppercaseString
            }
            else
            {
                cell.endMessagaeLabel.text="Last message at"+" "+String(homeitem.lastMessageTimeStamp.time).uppercaseString
            }
        }
        else
        {
            cell.endMessagaeLabel.text=""
        }
        if(!(homeitem.participantImages==nil))
        {
            let allParticipantsPhotoUrls:NSMutableArray = NSMutableArray()
            
            let participantsArray:NSArray = homeitem.participants.componentsSeparatedByString(",") as NSArray
            
            for AnyObject in participantsArray
            {
                
                let userID = AnyObject as! String
                if(!(userID == ""))
                {
                    let i = NSNumber(integer: Int(userID)!)
                    let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format:"qbID=%@",i))
                    
                    for AnyObject in filtered{
                        
                        let partic = AnyObject as? Users
                        if (!(partic!.profileUrl == nil))
                        {
                            allParticipantsPhotoUrls.addObject(partic!.profileUrl)
                        }
                    }
                }
                
            }
            
            let allParticipantsImageViews:NSMutableArray=NSMutableArray()
            allParticipantsImageViews.addObject(cell.firstPersonImage)
            allParticipantsImageViews.addObject(cell.secondPersonImage)
            allParticipantsImageViews.addObject(cell.thirdPersonImage)
            allParticipantsImageViews.addObject(cell.fourthPersonImage)
            allParticipantsImageViews.addObject(cell.fifthPersonImage)
            var indexOfprofileImageView:Int=0
            for _ in allParticipantsImageViews
            {
                let profileImage:UIImageView=allParticipantsImageViews.objectAtIndex(indexOfprofileImageView) as! UIImageView
                if(indexOfprofileImageView>=allParticipantsPhotoUrls.count)
                {
                    profileImage.hidden=true
                    
                }
                indexOfprofileImageView++
            }
            
            var index:Int=0
            for photoUrl in allParticipantsPhotoUrls
            {
                if index<allParticipantsImageViews.count
                {
                    let lobjprofileImageView:UIImageView=allParticipantsImageViews.objectAtIndex(index) as! UIImageView
                    
                    if(photoUrl as! NSString=="")
                    {
                        lobjprofileImageView.image=UIImage(named:"avatar_profile_info@2x.png")
                    }
                    else
                    {
                        let photourl = NSURL(string:(photoUrl as! NSString) as String)
                        if(!(photourl == nil))
                        {
                            lobjprofileImageView.sd_setImageWithURL(photourl, placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
                        }
                    }
                }
                index++
            }
            if(allParticipantsPhotoUrls.count>allParticipantsImageViews.count)
            {
                cell.remainingPersonsCountLabel.hidden=false
                cell.remainingPersonsCountBaseView.hidden=false
                
                let difference:Int=allParticipantsPhotoUrls.count-allParticipantsImageViews.count
                cell.remainingPersonsCountLabel.text=String(difference)
            }
            else
            {
                cell.remainingPersonsCountLabel.hidden=true
                cell.remainingPersonsCountBaseView.hidden=true
                
            }
        }
    }
    
    func tableView(_tableView: UITableView,
        willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            if cell.respondsToSelector("setSeparatorInset:") {
                cell.separatorInset = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setLayoutMargins:") {
                cell.layoutMargins = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
                cell.preservesSuperviewLayoutMargins = false
            }
    }
    
    func configureOneToOneChatCell(cell:OneToOneChatTableViewCell! ,atIndexPath indexPath:NSIndexPath)->Void
    {
        
        let homeitem=homeListItems.objectAtIndex(indexPath.section) as! Home
        if(!(homeitem.recepientID==nil))
        {
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format:"qbID=%@",homeitem.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as? Users
            }
            if(filtered.count == 0)
            {
                cell.titleLabel.text="User deleted"
                NSLog("deleted user id%@",homeitem.recepientID);
            }
            else
            {
                if let actualFirstName = name.firstname
                {
                    cell.titleLabel.text=actualFirstName
                }
                else if let actualLastName = name.lastName
                {
                    cell.titleLabel.text=actualLastName
                }
            }
            if(!(homeitem.lastMessageTimeStamp==nil))
            {
                
                self.timeinterval=self.gettingDifferenceBetweenToDayAndFromDatabse(homeitem.lastMessageTimeStamp) as NSDateComponents
                
                if(self.timeinterval.day>=1)
                {
                    cell.endMessageLAbel.text="Last message on "+String(homeitem.lastMessageTimeStamp.date)+", "+String(homeitem.lastMessageTimeStamp.time).uppercaseString
                }
                else
                {
                    cell.endMessageLAbel.text="Last message at"+" "+String(homeitem.lastMessageTimeStamp.time).uppercaseString
                }
            }
            else
            {
                cell.endMessageLAbel.text=""
            }
            if(!(homeitem.lastMessageText==nil))
            {
                if(homeitem.lastMessageText.characters.count>130)
                {
                    cell.descriptionLabel.text=homeitem.lastMessageText[0...130]
                }
                else
                {
                    cell.descriptionLabel.text=homeitem.lastMessageText
                }
            }
            else
            {
                cell.descriptionLabel.text=""
            }
            //   temp comment need to uncomment
            if let _ = name
            {
                if let _ = name.profileUrl //(!(name.profileUrl==nil))
                {
                    let photourl = NSURL(string:name.profileUrl)
                    cell.profileImage.sd_setImageWithURL(photourl, placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
                }
                else
                {
                    cell.profileImage.image=UIImage(named:"avatar_profile_info@2x.png")
                }
            }
            
            if(!(homeitem.unreadMessageCount.integerValue==0))
            {
                let countInString:NSString=String(homeitem.unreadMessageCount.integerValue)
                let size:CGSize=gettingLabelWithsize(String(homeitem.unreadMessageCount.integerValue))
                cell.UnreadcountButtonwidthConstraint.constant=size.width+size.width
                cell.UnreadcountButtonheightConstraint.constant=size.height+size.height/4
                if(countInString.length<=3)
                {
                    cell.UnreadcountButton.setTitle(String(homeitem.unreadMessageCount.integerValue), forState: UIControlState.Normal)
                }
                else
                {
                    cell.UnreadcountButton.setTitle("+"+countInString.substringToIndex(3), forState: UIControlState.Normal)
                }
                cell.UnreadcountButton.hidden=false
            }
            else
            {
                cell.UnreadcountButton.hidden=true
            }
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if homeListItems.count != 0 {
            let lobjhomeData:Home?=homeListItems.objectAtIndex(indexPath.section) as? Home
            if(!(lobjhomeData==nil))
            {
                if(lobjhomeData?.type.integerValue==1 )
                {
                    let cell: LearningCirclesTableViewCell = tableView.dequeueReusableCellWithIdentifier("LearningCirclesTableViewCell", forIndexPath: indexPath) as! LearningCirclesTableViewCell
                    let celllayer:CALayer=cell.layer as CALayer
                    //celllayer.cornerRadius=5.0
                    self.configureLearningCirclesCell(cell, atIndexPath: indexPath)
                    return cell
                }
                    
                else if(lobjhomeData?.type.integerValue==2||lobjhomeData?.type.integerValue==4 || lobjhomeData?.type.integerValue==5)
                {
                    let cell: GroupChatTableViewCell = tableView.dequeueReusableCellWithIdentifier("GroupChatTableViewCell", forIndexPath: indexPath) as! GroupChatTableViewCell
                    let celllayer:CALayer=cell.layer as CALayer
                    //celllayer.cornerRadius=5.0
                    self.configureGroupChatCell(cell, atIndexPath: indexPath)
                    return cell
                    
                }
                    
                else if((lobjhomeData?.type.integerValue==3))
                {
                    let cell: OneToOneChatTableViewCell = tableView.dequeueReusableCellWithIdentifier("OneToOneChatTableViewCell", forIndexPath: indexPath) as! OneToOneChatTableViewCell
                    let celllayer:CALayer=cell.layer as CALayer
                    //celllayer.cornerRadius=5.0
                    self.configureOneToOneChatCell(cell, atIndexPath: indexPath)
                    
                    return cell
                }
                    
                else if((lobjhomeData?.type.integerValue==6))
                {
                    
                    let cell: PollTableViewCell = tableView.dequeueReusableCellWithIdentifier("PollTableViewCell", forIndexPath: indexPath) as! PollTableViewCell
                    
                    if(!(lobjhomeData?.lastMessageTimeStamp==nil))
                    {
                        cell.endDateLabel.text=lobjhomeData?.lastMessageTimeStamp.date
                    }
                    
                    cell.titleLabel.text=lobjhomeData?.pollTitle
                    cell.descriptionLabel.text = lobjhomeData?.pollDescription
                    
                    let celllayer:CALayer=cell.layer as CALayer
                    //celllayer.cornerRadius=5.0
                    return cell
                }
            }
        }
        
        
        return UITableViewCell()
    }
    
    func calculatingHeightOfTheString( contentString:String, font:UIFont)->CGSize
    {
        return contentString.boundingRectWithSize(CGSize(width: 300, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil).size
    }
    
    
    func deselectRowAtIndexPath(indexPath: NSIndexPath,
        animated: Bool)
    {
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if indexPath.section < homeListItems.count
        {
            let lobjhomeData:Home?=homeListItems.objectAtIndex(indexPath.section) as? Home
            if(!(lobjhomeData==nil))
            {
                if(lobjhomeData?.type.integerValue==3)
                {
                    return true
                }
                else
                {
                    return false
                }
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
//        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        if(editingStyle==UITableViewCellEditingStyle.Delete)
        {
            
//            let homeDataobj:Home?=homeListItems.objectAtIndex(indexPath.section) as? Home
//            let dialogID:NSString?=homeDataobj?.dialogID
//            
//            let apDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
//            if(!AFNetworkReachabilityManager.sharedManager().reachable)
//            {
//                apDelegate.arrDelete.addObject(dialogID!);
//                cdManager.saveDeleteDiagPlistRecord()
//            }
//            if(!(homeDataobj==nil))
//            {
//                cdManager.childContext.performBlock({ () -> Void in
//                    let deletedObject:NSManagedObject=homeDataobj! as NSManagedObject
//                    
//                    var deleteContext:NSManagedObjectContext
//                    deleteContext=deletedObject.managedObjectContext!
//                    deleteContext.deleteObject(cdManager.childContext.objectWithID(homeDataobj!.objectID))
//                    do { try cdManager.childContext.save()} catch { }
//                    
//                    //delete from chat table
//                    cdManager.deleteChatIncontext(cdManager.childContext, dialogID: dialogID as! String)
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        do { try cdManager.parentContext.save()} catch { }
//                        self.reterivingDataFromDatabase()
//                    })
//                })
//            }
            
        }
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        
        let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            
            tableView.dataSource?.tableView!(tableView, commitEditingStyle:.Delete, forRowAtIndexPath:indexPath)
            
            if ( self.homeListItems.count > 0 )
            {
                let lobjhomeData = self.homeListItems.objectAtIndex(indexPath.section) as! Home
                
                if ( lobjhomeData.type == 1 || lobjhomeData.type == 2 || lobjhomeData.type == 3 || lobjhomeData.type == 4 || lobjhomeData.type == 5 ){
                    let set:NSSet = NSSet.init(objects: lobjhomeData.dialogID)
                    
                    let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
                    
                    QBRequest.deleteDialogsWithIDs(set as! Set<String>, forAllUsers: false, successBlock: { (response:QBResponse, str1:[String]?, str2:[String]?, str3:[String]?) -> Void in
                        
                        print(set)
                        
                        let homeDataobj:Home?=self.homeListItems.objectAtIndex(indexPath.section) as? Home
                        let dialogID:NSString?=homeDataobj?.dialogID
                        
                        let apDelegate:AppDelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        if(!AFNetworkReachabilityManager.sharedManager().reachable)
                        {
                            apDelegate.arrDelete.addObject(dialogID!);
                            cdManager.saveDeleteDiagPlistRecord()
                        }
                        
                        cdManager.childContext.performBlock({ () -> Void in
                            let deletedObject:NSManagedObject=lobjhomeData as NSManagedObject
                            
                            var deleteContext:NSManagedObjectContext
                            deleteContext=deletedObject.managedObjectContext!
                            deleteContext.deleteObject(cdManager.childContext.objectWithID(lobjhomeData.objectID))
                            do { try cdManager.childContext.save()} catch { }
                            
                            //delete from chat table
                            cdManager.deleteChatIncontext(cdManager.childContext, dialogID: lobjhomeData.dialogID )
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                do { try cdManager.parentContext.save()} catch { }
                                self.reterivingDataFromDatabase()
                            })
                        })
                        
                        
                        }, errorBlock: { (response:QBResponse) -> Void in
                            
                    })
                    
                }
                
                
            }
            
            
            return
        })
        deleteButton.backgroundColor = UIColor(red: 240/255.0, green: 85/255.0, blue: 35/255.0, alpha: 1.0)
        
        return [deleteButton]
        
    }
    
    //MARK: Tableview Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (homeListItems.count == 0){
            return
        }
        let lobjhomeData=homeListItems.objectAtIndex(indexPath.section) as! Home
        
        if(lobjhomeData.type==1 ){
            lobjhomeData.unreadMessageCount = 0;
            
            let home: AnyObject = homeListItems.objectAtIndex(indexPath.section) as! Home
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as! Users
            }
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            self.navigationController?.pushViewController(chatViewController, animated: true)
            chatViewController.dialogID = home.dialogID
            chatViewController.chatTypeenum=chatType.LearningCircles
            chatViewController.classDiscussionType=false
            chatViewController.userName=home.name
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            
            ChatService.instance().strCurDlgID = home.dialogID
        }
        else if(lobjhomeData.type.integerValue==2 ){
            lobjhomeData.unreadMessageCount = 0;
            let home: AnyObject = homeListItems.objectAtIndex(indexPath.section) as! Home
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as! Users
            }
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            chatViewController.dialogID = home.dialogID
            chatViewController.classDiscussionType=false
            chatViewController.chatTypeenum=chatType.GroupChat
            chatViewController.userName=home.name
            
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            
            //to show participants
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            ChatService.instance().strCurDlgID = home.dialogID
            self.navigationController?.pushViewController(chatViewController, animated: true)
            
        }
            
        else if( lobjhomeData.type==5){
            lobjhomeData.unreadMessageCount = 0;
            let home: AnyObject = homeListItems.objectAtIndex(indexPath.section) as! Home
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as! Users
            }
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            
            chatViewController.dialogID = home.dialogID
            chatViewController.pollDiscussionType=true
            chatViewController.chatTypeenum=chatType.GroupChat
            chatViewController.userName=home.name
            
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            
            //to show participants
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            ChatService.instance().strCurDlgID = home.dialogID
            self.navigationController?.pushViewController(chatViewController, animated: true)
        }
            
        else if(lobjhomeData.type.integerValue==3)
        {
            lobjhomeData.unreadMessageCount = 0;
            let home: AnyObject = homeListItems.objectAtIndex(indexPath.section)
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as! Users
            }
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            self.navigationController?.pushViewController(chatViewController, animated: true)
            chatViewController.dialogID = home.dialogID
            chatViewController.classDiscussionType=false
            chatViewController.chatTypeenum=chatType.oneTOOneChat
            chatViewController.recId = home.recepientID
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            if(filtered.count == 0)
            {
                chatViewController.userName=""
            }
            else
            {
                chatViewController.userName=name.firstname
            }
            ChatService.instance().strCurDlgID = home.dialogID
        }
            
        else if(lobjhomeData.type.integerValue==4){
            lobjhomeData.unreadMessageCount = 0;
            
            let home: AnyObject = homeListItems.objectAtIndex(indexPath.section) as! Home
            let filtered = userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
            for AnyObject in filtered{
                
                name = AnyObject as! Users
            }
            let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            self.navigationController?.pushViewController(chatViewController, animated: true)
            chatViewController.dialogID = home.dialogID
            chatViewController.chatTypeenum=chatType.GroupChat
            chatViewController.userName=home.name
            chatViewController.classDiscussionType=true
            
            chatViewController.chatRoom = home.chatRoom as! QBChatDialog
            //to show participants
            if(!(home.participants==""))
            {
                chatViewController.allLearningCircleParticipants=home.participants
            }
            else
            {
                chatViewController.allLearningCircleParticipants=""
            }
            ChatService.instance().strCurDlgID = home.dialogID
            
        }
        else
        {
            if(lobjhomeData.type.integerValue==6)
            {
                ChatService.instance().strCurDlgID = lobjhomeData.dialogID
                if(lobjhomeData.priority.intValue < 0)
                {
                    let pollresultsViewController = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollResultsViewController") as! PollResultsViewController
                    pollresultsViewController.setId(lobjhomeData.dialogID)
                    self.navigationController?.pushViewController(pollresultsViewController, animated: true)
                }
                else
                {
                    let pollViewControllerObj = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollViewController") as! PollViewController
                    pollViewControllerObj.setId(lobjhomeData.dialogID)
                    self.navigationController?.pushViewController(pollViewControllerObj, animated: true)
                }
            }
        }
    }

    //MARK: Calculating Textsize according to text
    func gettingLabelWithsize(var numberToShow:NSString)->CGSize
    {
        if(numberToShow.length>4)
        {
            numberToShow=numberToShow.substringToIndex(4)
        }
        var textSize:CGSize
        let attributes:NSDictionary=[NSFontAttributeName: UIFont.systemFontOfSize(16)]
        textSize=numberToShow.sizeWithAttributes(attributes as? [String : AnyObject])
        return textSize
    }
    
    func refreshList(notification:NSNotification){
        if notification.name == kHomeTimeLineListVCRefreshKey{
            self.homeListTableView.reloadData()
        }
    }
    
    func removeNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func gotoChatRoom(notification:NSNotification){
        if(self.homeListItems.count==0)
        {
            //self.activityIndicator.stopAnimating()
        }
        else
        {
            for var indexPath = 0; indexPath < self.homeListItems.count; ++indexPath {
                
                let lobjhomeData = self.homeListItems.objectAtIndex(indexPath) as! Home
                let home: AnyObject = self.homeListItems.objectAtIndex(indexPath) as! Home
                
                if home.dialogID != ChatService.instance().strGetedDlgIDFromPush {
                    continue
                }
                
                if(lobjhomeData.type==1 ){
                    let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                    self.navigationController?.pushViewController(chatViewController, animated: true)
                    chatViewController.dialogID = home.dialogID
                    chatViewController.chatTypeenum=chatType.LearningCircles
                    chatViewController.classDiscussionType=false
                    chatViewController.userName=home.name
                    if(!(home.participants==""))
                    {
                        chatViewController.allLearningCircleParticipants=home.participants
                    }
                    else
                    {
                        chatViewController.allLearningCircleParticipants=""
                    }
                    chatViewController.chatRoom = home.chatRoom as! QBChatDialog
                    chatViewController.popToRootVC = true
                    ChatService.instance().strCurDlgID = home.dialogID
                }
                else if(lobjhomeData.type.integerValue==2 ){
                    
                    let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                    
                    chatViewController.dialogID = home.dialogID
                    chatViewController.classDiscussionType=false
                    chatViewController.chatTypeenum=chatType.GroupChat
                    chatViewController.userName=home.name
                    
                    chatViewController.chatRoom = home.chatRoom as! QBChatDialog
                    
                    //to show participants
                    if(!(home.participants==""))
                    {
                        chatViewController.allLearningCircleParticipants=home.participants
                    }
                    else
                    {
                        chatViewController.allLearningCircleParticipants=""
                    }
                    chatViewController.popToRootVC = true
                    ChatService.instance().strCurDlgID = home.dialogID
                    self.navigationController?.pushViewController(chatViewController, animated: true)
                }
                else if( lobjhomeData.type==5){
                    let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                    
                    chatViewController.dialogID = home.dialogID
                    chatViewController.pollDiscussionType=true
                    chatViewController.chatTypeenum=chatType.GroupChat
                    chatViewController.userName=home.name
                    chatViewController.chatRoom = home.chatRoom as! QBChatDialog
                    
                    //to show participants
                    if(!(home.participants==""))
                    {
                        chatViewController.allLearningCircleParticipants=home.participants
                    }
                    else
                    {
                        chatViewController.allLearningCircleParticipants=""
                    }
                    chatViewController.popToRootVC = true
                    ChatService.instance().strCurDlgID = home.dialogID
                    self.navigationController?.pushViewController(chatViewController, animated: true)
                }
                else if(lobjhomeData.type.integerValue==3)
                {
                    let filtered = self.userNames.filteredArrayUsingPredicate( NSPredicate(format: "qbID=%@", lobjhomeData.recepientID))
                    for AnyObject in filtered{
                        
                        self.name = AnyObject as! Users
                    }
                    let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                    self.navigationController?.pushViewController(chatViewController, animated: true)
                    chatViewController.dialogID = home.dialogID
                    chatViewController.classDiscussionType=false
                    chatViewController.chatTypeenum=chatType.oneTOOneChat
                    chatViewController.recId = home.recepientID
                    chatViewController.chatRoom = home.chatRoom as! QBChatDialog
                    if(filtered.count == 0)
                    {
                        chatViewController.userName=""
                    }
                    else
                    {
                        chatViewController.userName=self.name.firstname
                    }
                    chatViewController.popToRootVC = true
                    ChatService.instance().strCurDlgID = home.dialogID
                }
                else if(lobjhomeData.type.integerValue==4){
                    let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                    self.navigationController?.pushViewController(chatViewController, animated: true)
                    chatViewController.dialogID = home.dialogID
                    chatViewController.chatTypeenum=chatType.GroupChat
                    chatViewController.userName=home.name
                    chatViewController.classDiscussionType=true
                    
                    chatViewController.chatRoom = home.chatRoom as! QBChatDialog
                    //to show participants
                    if(!(home.participants==""))
                    {
                        chatViewController.allLearningCircleParticipants=home.participants
                    }
                    else
                    {
                        chatViewController.allLearningCircleParticipants=""
                    }
                    chatViewController.popToRootVC = true
                    ChatService.instance().strCurDlgID = home.dialogID
                }
                else if(lobjhomeData.type.integerValue==6)
                {
                    ChatService.instance().strCurDlgID = lobjhomeData.dialogID
                    if(lobjhomeData.priority.intValue < 0)
                    {
                        let pollresultsViewController = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollResultsViewController") as! PollResultsViewController
                        pollresultsViewController.setId(lobjhomeData.dialogID)
                        self.navigationController?.pushViewController(pollresultsViewController, animated: true)
                    }
                    else
                    {
                        let pollViewControllerObj = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollViewController") as! PollViewController
                        pollViewControllerObj.setId(lobjhomeData.dialogID)
                        self.navigationController?.pushViewController(pollViewControllerObj, animated: true)
                    }
                }
            }
        }
    }
}
