
//
//  ParticipantsViewController.swift
//  Emeritus
//
//  Created by SB on 07/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
class ParticipantsViewController: UIViewController, ParticipantsTableViewCellDelegate
{
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var tableviewTopConstraint: NSLayoutConstraint!
    
    var indexbar: GDIIndexBar!
    var dataModel:GDIMockDataModel!
    var test:NSString!
    var sections:NSArray!
    var rows:NSArray!
    var usersFromHomePage:NSMutableArray!
    var selectedRow:Int=0
    var selectedSection:Int=0
    var homeData : NSArray = NSArray()
    var userList:NSArray = NSArray()
    var userName : NSString!
    var searchedUserList:NSArray = NSArray()
    var mainSearchedData:NSArray = NSArray()
    var chatDialogCreate:QBChatDialog!
    var sectionLetterList=NSArray()
    
    var participantsIDs=NSArray()
    var participantsArray=NSMutableArray()
    var searchString:NSString = ""
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        self.participantsTableView.separatorStyle=UITableViewCellSeparatorStyle.None
        
        dataModel = GDIMockDataModel.init()
        //        print(usersFromHomePage)
        dataModel.intialisingData()
        //        print(dataModel)
        //        print(self.dataModel.arrMainData)
        print("participantsCount:\(self.dataModel.arrMainData.count)")
        
        sectionLetterList=self.dataModel.dictSections.allKeys
        sectionLetterList=sectionLetterList.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:")
        
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor=UIColor.whiteColor()
        self.activityIndicatorView.hidden=true
        self.view.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha:1.0)
        participantsTableView.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha:1.0)
        
    }
    override func viewWillAppear(animated: Bool) {
        self.participantsTableView.reloadData()
        
        if let _:ParticipantSearchBar=self.view.viewWithTag(1111) as? ParticipantSearchBar
        {
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    func popupButtonClickedOnell(cell: ParticipantsTableViewCell)
    {
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.participantsTableView.indexPathForCell(cell)!
        selectedSection=newIndexPath.section
        selectedRow=newIndexPath.row
        
        let strSectionTitle=self.sectionLetterList.objectAtIndex(selectedSection) as! String
        let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        let dict=arrSubList.objectAtIndex(selectedRow) as! NSDictionary
        let key=dict.allKeys
        let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
        
        var isUserBlocked:Bool = false
        
        if let qbId=dicNme.objectForKey("qbID") as? NSNumber
        {
            isUserBlocked = BlockedUserManager.isUserBlockedWithId(qbId)
        }
        
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let startChatAction = UIAlertAction(title: "Start Chat", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.startChat()
        })
        
        let viewProfileAction = UIAlertAction(title: "View Profile", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.openProfile()
        })
        
        alertSheet.addAction(viewProfileAction)
        
        alertSheet.addAction(startChatAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        })
        
        alertSheet.addAction(cancelAction)
        
        self.presentViewController(alertSheet, animated: true) {
            
        }
        
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- TableView DataSource  Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionLetterList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let strSectionTitle=self.sectionLetterList.objectAtIndex(section) as! String
        let arrRows=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        return arrRows.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 109
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let identifier = "ParticipantsTableViewCell"
        var cell: ParticipantsTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? ParticipantsTableViewCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "ParticipantsTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ParticipantsTableViewCell
        }
        
        if self.dataModel.arrMainData.count>0
        {
            
            let strSectionTitle=self.sectionLetterList.objectAtIndex(indexPath.section) as! String
            let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
            let dict=arrSubList.objectAtIndex(indexPath.row) as! NSDictionary
            print (dict)
            let key=dict.allKeys
            let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
            if(dicNme.objectForKey("imgUrl") as! String=="")
            {
                cell.participantImage.image=UIImage(named:"avatar_big_base@2x.png")
            }
            else
            {
                let fileUrl = NSURL(string: dicNme.objectForKey("imgUrl") as! String)
                cell.participantImage.sd_setImageWithURL(fileUrl, placeholderImage: UIImage(named:"avatar_big_base@2x.png"))
            }
            if let name=dicNme.objectForKey("firstname") as? String
            {
                cell.participantName.text = name
            }
            
            if let name=dicNme.objectForKey("lastName") as? String
            {
                let firstname = cell.participantName.text
                cell.participantName.text = firstname! + " " + name
            }
            
            if let design=dicNme.objectForKey("designation") as? String
            {
                cell.participantDesignation.text=design
            }
            
            if let company=dicNme.objectForKey("company") as? String
            {
                let designation = cell.participantDesignation.text
                if(company != "")
                {
                    cell.participantDesignation.text = designation! + " at " + company
                }
            }
            
            if let _=dicNme.objectForKey("designation") as? String
            {
                
            }
            else
            {
                if let _=dicNme.objectForKey("company") as? String
                {
                    
                }
                else
                {
                    cell.participantDesignation.text = ""
                }
            }
            
            if let city=dicNme.objectForKey("city") as? String
            {
                cell.locationLabel.text = city
            }
            
            if let country=dicNme.objectForKey("country") as? NSNumber
            {
                let city = cell.locationLabel.text
                cell.locationLabel.text = city! + ", " + CountryPickerModel.sharedInstance().countryNameFromId(country.stringValue)
            }
            
            if let qbId=dicNme.objectForKey("qbID") as? NSNumber
            {
                if( BlockedUserManager.isUserBlockedWithId(qbId) == false)
                {
                    cell.blockedImageView.hidden = true;
                    cell.blockedMessage.hidden = true;
                }
                else
                {
                    cell.blockedImageView.hidden = false;
                    cell.blockedMessage.hidden = false;
                }
            }
        }
        
        
        
        cell.participantsButton.tag=indexPath.row+1
        cell.backgroundColor=UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
        
        cell.delegate=self
        return cell
    }
    //MARK:- TableView Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let strSectionTitle=self.sectionLetterList.objectAtIndex(indexPath.section) as! String
        let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        let dict=arrSubList.objectAtIndex(indexPath.row) as! NSDictionary
        let key=dict.allKeys
        let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let chatDialog:QBChatDialog=QBChatDialog(dialogID: nil, type: QBChatDialogType.Private)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let name=dicNme.objectForKey("firstname") as? String
        {
            chatDialog.name=name
        }
        var occupantId:NSNumber
        if let qbId=dicNme.objectForKey("qbID") as? NSNumber
        {
            occupantId=qbId
            if(QBSession.currentSession().sessionDetails!.userID == occupantId){
                return;
            }
            chatDialog.occupantIDs=[occupantId, QBSession.currentSession().sessionDetails!.userID]
            
            let fReq: NSFetchRequest = NSFetchRequest(entityName: Home.entityName() as! NSString as String)
            fReq.returnsObjectsAsFaults = false
            fReq.predicate = NSPredicate(format: "recepientID == %@", occupantId)
            
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            do {
                let list = try cdManager.childContext.executeFetchRequest(fReq)
                
                if(list.count >= 1){
                    var array:NSArray = NSArray()
                    array = list
                    //for AnyObject in array{
                    if let AnyObject: AnyObject = array.lastObject{
                        let temp = AnyObject as! Home
                        let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                        
                        if let name=dicNme.objectForKey("firstname") as? String
                        {
                            chatViewController.userName=name
                        }
                        chatViewController.chatTypeenum=chatType.oneTOOneChat
                        chatViewController.dialogID = temp.dialogID
                        chatViewController.recId = occupantId
                        self.navigationController?.pushViewController(chatViewController, animated: true)
                        
                        self.navigationController?.navigationBarHidden = false
                        
                    }
                }
                else{
                    
                    QBRequest.createDialog(chatDialog, successBlock: { ( responseObject:QBResponse,  dialog:QBChatDialog?) -> Void in
                        self.chatDialogCreate=chatDialog
                        occupantId=qbId as NSNumber
                        let newChatDialog = dialog! as QBChatDialog
                        let chatViewController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                        chatViewController.recId = occupantId
                        chatViewController.dialogID = newChatDialog.ID
                        chatViewController.chatRoom = newChatDialog
                        chatViewController.userName=dicNme.objectForKey("firstname") as! String
                        self.navigationController?.pushViewController(chatViewController, animated: true)
                        
                        }) { (error) -> Void in
                            self.view.userInteractionEnabled = true
                            self.activityIndicator.stopAnimating()
                            print(error)
                            let alert = UIAlertView()
                            alert.title = "Alert"
                            alert.message = "Problem while creating new dialog"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                    }
                }
            }
            catch
            {
                
            }
            
        }
        
    }
    
    func openProfile()
    {
        self.navigationController?.navigationBarHidden = false
        let strSectionTitle=self.sectionLetterList.objectAtIndex(selectedSection) as! String
        let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        let dict=arrSubList.objectAtIndex(selectedRow) as! NSDictionary
        let key=dict.allKeys
        let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
        
        var occupantId:NSNumber
        if let qbId=dicNme.objectForKey("qbID") as? NSNumber
        {
            occupantId=qbId as NSNumber
            
            let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            let selectedUser:Users=cdManager.viewProfile(occupantId) as Users
            NSLog("d:%@", selectedUser)
            let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
            profileViewController.fromParticipants = true;
            profileViewController.selfProfileStatus=false
            self.navigationController?.pushViewController(profileViewController, animated: true)
            profileViewController.userProfileDetails=selectedUser
        }
        
    }
    
    func startChat()
    {
        self.tableView(self.participantsTableView, didSelectRowAtIndexPath: NSIndexPath(forRow: selectedRow, inSection: selectedSection))
    }
    
    func blockUser()
    {
        self.navigationController?.navigationBarHidden = false
        let strSectionTitle=self.sectionLetterList.objectAtIndex(selectedSection) as! String
        let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        let dict=arrSubList.objectAtIndex(selectedRow) as! NSDictionary
        let key=dict.allKeys
        let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
        
        if let qbId=dicNme.objectForKey("qbID") as? NSNumber
        {
            BlockedUserManager.blockUserWithId(qbId)
        }
        self.participantsTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:selectedRow, inSection: selectedSection)], withRowAnimation: .Automatic)
    }
    
    func unblockUser()
    {
        self.navigationController?.navigationBarHidden = false
        let strSectionTitle=self.sectionLetterList.objectAtIndex(selectedSection) as! String
        let arrSubList=self.dataModel.dictSections.objectForKey(strSectionTitle) as! NSArray
        let dict=arrSubList.objectAtIndex(selectedRow) as! NSDictionary
        let key=dict.allKeys
        let dicNme=dict.objectForKey(key.last as! String) as! NSDictionary
        
        if let qbId=dicNme.objectForKey("qbID") as? NSNumber
        {
            BlockedUserManager.unBlockUserWithId(qbId)
        }
        
        self.participantsTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:selectedRow, inSection: selectedSection)], withRowAnimation: .Automatic)
    }
    
}
