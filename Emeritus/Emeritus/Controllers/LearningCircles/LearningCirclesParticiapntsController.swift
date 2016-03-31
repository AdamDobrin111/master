//
//  LearningCirclesParticiapntsController.swift
//  Emeritus
//
///  Created by SB on 10/02/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
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

class LearningCirclesParticiapntsController: UIViewController {
    
    var allParticpants:String!
    @IBOutlet weak var BuddiesTableView: UITableView!
    //     var profilePhotos:NSMutableArray=["1.jpeg","2.jpeg","3.jpeg","4.jpeg","5.jpeg","6.jpeg","1.jpeg","2.jpeg","4.jpeg"]
    //    var profileNames:NSMutableArray=["Alek","Deepak","Srikanth","Taneesh","Parnika","Sunny","Aleka","Sam","Puneesh"]
    var allParticipantsArray:NSArray=NSArray()
    var allUserDetails:NSArray=NSArray()
    var updatedIndex:Int=0
    var record:NSMutableArray=NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(),
            forBarMetrics:.Default)
        //        self.navigationController?.navigationBar.backgroundColor=UIColor(red: 240/255.0, green: 85/255.0, blue: 35/255.0, alpha: 1.0)
        let nav = self.navigationController?.navigationBar
        //                if UINavigationBar.conformsToProtocol(UIAppearanceContainer) {
        //
        //                    UINavigationBar.appearance().translucent = true
        //                }
        
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.title="Participants"
        self.navigationItem.setHidesBackButton(true,animated:true)
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
        BuddiesTableView.separatorColor=UIColor.clearColor()
        BuddiesTableView.separatorStyle=UITableViewCellSeparatorStyle.None
        BuddiesTableView.backgroundColor=UIColor.clearColor()
        
        self.navigationController?.navigationBar.hideBottomHairline()
        //        print(allParticipantsArray)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        self.fetchUserDetails()
    }
    override func viewDidAppear(animated: Bool) {
        self.calculateParticipantsData()
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.showBottomHairline()
    }
    
    func preparingData()
    {
        print(allParticpants)
        if(!(allParticpants==""))
        {
            let participants: String = allParticpants
            allParticipantsArray=participants.componentsSeparatedByString(",") as NSArray
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
    
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        if((allParticipantsArray.count%3)==0)
        {
            return (allParticipantsArray.count)/3
        }
        else
        {
            return (allParticipantsArray.count/3)+1
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 130
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let identifier = "ParticipantsCellForLearningCircles"
        var cell:ParticpantsCellForLearningCircles!=tableView.dequeueReusableCellWithIdentifier(identifier) as? ParticpantsCellForLearningCircles
        if cell == nil
        {
            tableView.registerNib(UINib(nibName: "ParticipantsCellForLearningCircles", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ParticpantsCellForLearningCircles
        }
        cell.firstProfileIamge.hidden=true
        cell.firstprofileName.hidden=true
        cell.secondProfileIamge.hidden=true
        cell.secondprofileName.hidden=true
        cell.thirdProfileImage.hidden=true
        cell.thirdprofileName.hidden=true
        
        if record.count>0
        {
            if(indexPath.row<allParticipantsArray.count)
            {
                if updatedIndex<record.count
                {
                    var userDetail:Users!
                    userDetail=record.objectAtIndex(updatedIndex) as! Users
                    if let _ = userDetail
                    {
                        if let _ = userDetail.profileUrl
                        {
                            let photourl = NSURL(string:userDetail.profileUrl)
                            cell.firstProfileIamge.sd_setImageWithURL(photourl, placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
                        }
                        else
                        {
                            cell.firstProfileIamge.image=UIImage(named:"avatar_profile_info@2x.png")
                            cell.firstProfileIamge.layer.cornerRadius=0.0
                            cell.firstProfileIamge.layer.borderWidth=0.0
                        }
                        cell.firstprofileName.text=userDetail.firstname
                        updatedIndex++
                        cell.firstProfileIamge.hidden=false
                        cell.firstprofileName.hidden=false
                    }
                }
                else
                {
                    cell.firstProfileIamge.hidden=true
                    cell.firstprofileName.hidden=true
                }
            }
            if(indexPath.row+1<allParticipantsArray.count)
            {
                if updatedIndex<record.count
                {
                    var userDetail:Users!
                    userDetail=record.objectAtIndex(updatedIndex) as! Users
                    if let _ = userDetail
                    {
                        if let _ = userDetail.profileUrl
                        {
                            let photourl = NSURL(string:userDetail.profileUrl)
                            cell.secondProfileIamge.sd_setImageWithURL(photourl, placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
                        }
                        else
                        {
                            cell.secondProfileIamge.image=UIImage(named:"avatar_profile_info@2x.png")
                            cell.secondProfileIamge.layer.cornerRadius=0.0
                            cell.secondProfileIamge.layer.borderWidth=0.0
                        }
                        cell.secondprofileName.text=userDetail.firstname
                        cell.secondProfileIamge.hidden=false
                        cell.secondprofileName.hidden=false
                        
                        updatedIndex++
                    }
                }
                else
                {
                    cell.secondProfileIamge.hidden=true
                    cell.secondprofileName.hidden=true
                }
            }
            if(indexPath.row+2<allParticipantsArray.count)
            {
                if updatedIndex<record.count
                {
                    var userDetail:Users!
                    userDetail=record.objectAtIndex(updatedIndex) as! Users
                    if let _ = userDetail
                    {
                        if let _ = userDetail.profileUrl
                        {
                            let photourl = NSURL(string:userDetail.profileUrl)
                            cell.thirdProfileImage.sd_setImageWithURL(photourl, placeholderImage:UIImage(named:"avatar_profile_info@2x.png"))
                        }
                        else
                        {
                            cell.thirdProfileImage.image=UIImage(named:"avatar_profile_info@2x.png")
                            cell.thirdProfileImage.layer.cornerRadius=0.0
                            cell.thirdProfileImage.layer.borderWidth=0.0
                        }
                        cell.thirdprofileName.text=userDetail.firstname
                        cell.thirdProfileImage.hidden=false
                        cell.thirdprofileName.hidden=false
                        updatedIndex++
                    }
                }
                else
                {
                    cell.thirdProfileImage.hidden=true
                    cell.thirdprofileName.hidden=true
                }
            }
        }
        cell.backgroundColor=UIColor.clearColor()
        return cell
    }
    
    func calculateParticipantsData()
    {
        
        for var index=0; index<allParticipantsArray.count; ++index{
            var userDetail:Users!
            let occupantIdInString:NSString=allParticipantsArray.objectAtIndex(index) as! NSString
            let QbIDFromParticipants=NSNumber(integer:occupantIdInString.integerValue)
            let filtered = allUserDetails.filteredArrayUsingPredicate(NSPredicate(format:"qbID=%@",QbIDFromParticipants))
            if filtered.last != nil
            {
                userDetail = filtered.last as! Users
            }
            if let userDet = userDetail
            {
                //record[r][c]=userDet
                record.addObject(userDet)
            }
        }
        self.BuddiesTableView.reloadData()
        
    }
    
    func createUserNameFetchRequest() -> NSFetchRequest{
        let fReq: NSFetchRequest = NSFetchRequest(entityName: Users.entityName() as! NSString as String)
        fReq.returnsObjectsAsFaults = false
        return fReq
    }
    
    func fetchUserDetails(){
        
        let fetchRequest = createUserNameFetchRequest()
        
        //CD DBmayur
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        cdManager.parentContext.performBlock({ () -> Void in
            do {
                let list = try cdManager.childContext.executeFetchRequest(fetchRequest)
                self.allUserDetails = list
                self.preparingData()
                self.BuddiesTableView.reloadData()
            }
            catch {
            }
         })
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
