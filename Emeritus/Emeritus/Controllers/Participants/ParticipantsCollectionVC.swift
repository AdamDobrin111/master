//
//  ParticipantsCollectionVC.swift
//  Emeritus
//
//  Created by SB on 06/07/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func hideBottomHairlineN() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairlineN() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews )
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}

let reuseIdentifier = "ParticipantsCollectionViewCell"

class ParticipantsCollectionVC: UICollectionViewController, UIActionSheetDelegate, chatCreatProtocol {
    
    var arrParticipants = Array<String>()  //To store complete User Info as Swift Dictionary
    var strParticipants:String = ""
    var arrUser = [Users]()
    var selectedRow:Int=0
    var selectedSection:Int=0
    var chatDialogCreate:QBChatDialog!
    var lblEmptyMessage : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!(strParticipants==""))
        {
            let participants: String = strParticipants
            arrParticipants=participants.componentsSeparatedByString(",") as Array<String>
            
            let cdManager:MSCoreDataManager = MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
            for element in arrParticipants
            {
                if(!(element==""))
                {
                    cdManager.fecthingTheUserProfileDetailsWith(NSNumber(integer: Int(element)!), withresponseCallback: { (usr:Users!) -> Void in
                        self.arrUser.append(usr)
                    })
                }
            }
            self.collectionView?.reloadData()
        }
    }
    override func viewWillAppear(animated: Bool) {
        
        let image:UIImage = UIImage(named: "participantBar.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        let nav = self.navigationController?.navigationBar
        
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.title="Participants"
        self.navigationItem.setHidesBackButton(true,animated:true)
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        self.navigationController?.navigationBar.hideBottomHairlineN()
        
        if self.arrUser.isEmpty
        {
            self.lblEmptyMessage = UILabel(frame: CGRectMake(10, 60, 260, 100))
            self.lblEmptyMessage?.text="There are no participants!"
            self.lblEmptyMessage?.textColor = UIColor.whiteColor()
            self.lblEmptyMessage?.center=CGPointMake(self.collectionView!.center.x, self.collectionView!.center.y-40)
            self.lblEmptyMessage?.textAlignment=NSTextAlignment.Center
            self.collectionView!.addSubview(self.lblEmptyMessage!)
        }
    }
    
    func backAction()
    {
        //        UINavigationBar.appearance().translucent=true
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.navigationBar.backgroundColor=UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.arrUser.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ParticipantsCollectionViewCell
        
        // Configure the cell
        let usr = arrUser[indexPath.row] as Users
        cell.lblFirstProfileName.text = usr.firstname
        cell.imgPhotoView.layer.cornerRadius=32.0
        
        let imgURL = usr.profileUrl
        cell.imgPhotoView.sd_setImageWithURL(NSURL(string: imgURL), placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
        return cell
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        let popup = UIActionSheet(title:nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle:nil , otherButtonTitles: "Start Chat", "View Profile")
        popup.showInView(self.view)
        var newIndexPath: NSIndexPath = NSIndexPath();
        newIndexPath = self.collectionView!.indexPathForCell(cell!)!
        selectedSection=newIndexPath.section
        selectedRow=newIndexPath.row
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        
        switch buttonIndex{
            
        case 0:
            //print("Clicked on cancel")
            actionSheet.dismissWithClickedButtonIndex(0, animated: true)
            break
            
        case 2:
            
            let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileDetailsViewController") as! ProfileDetailsViewController
            profileViewController.selfProfileStatus=false
            profileViewController.userProfileDetails=self.arrUser[selectedRow]
            profileViewController.fromParticipants = true
            self.navigationController?.pushViewController(profileViewController, animated: true)
            
            break
        case 1:
            let usr = self.arrUser[selectedRow]
            actionSheet.dismissWithClickedButtonIndex(0, animated: true)
            let chatDialog:QBChatDialog=QBChatDialog(dialogID: nil, type: QBChatDialogType.Private)
            
                chatDialog.name=usr.firstname
            
            var occupantId:NSNumber
            if let qbId=usr.qbID
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
                            
                            if let name=usr.firstname
                            {
                                chatViewController.userName=name
                            }
                            //                chatViewController.userName=username
                            chatViewController.chatTypeenum=chatType.oneTOOneChat
                            chatViewController.dialogID = temp.dialogID
                            chatViewController.recId = occupantId
                            self.navigationController?.pushViewController(chatViewController, animated: true)
                            //chatViewController.popToRootVC=true
                            
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
                            chatViewController.userName=usr.firstname
                            self.navigationController?.pushViewController(chatViewController, animated: true)
                            
                            }) { (error) -> Void in
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
            break
            
        case 3:
            break
            
        default:
            print("Default");
            break
            
        }
        
    }
    
    func createChatThread(obj: ChatViewController){
        //QBChat.createDialog(chatDialogCreate, delegate: obj)
    }
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
