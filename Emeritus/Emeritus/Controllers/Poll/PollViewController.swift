//
//  PollViewController.swift
//  Emeritus
//
//  Created by SB on 11/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//
//

import Foundation
import UIKit


class PollViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,PollDetailsTableViewCellDelegate
{
    
    @IBOutlet weak var pollTableView: UITableView!
    var inputDic: NSMutableDictionary = ["0":false,"1":false,"2":false,"3":false,"4":false]
    var answerChoices:NSMutableArray=[]
    var answerIDs:NSMutableArray=[]
    var answerCounts:NSMutableArray=[]
    var HeaderView:PollTableViewHeaderView!
    var confirmButton:UIButton = UIButton()
    var oldIndexPath:NSIndexPath = NSIndexPath()
    var tempIndexPathupdated:Bool! = false
    var questionData:String!="For the 3 AM phone call exercise how many people could you list down as folks you could call for help?"
    var pollInfoDetails:NSMutableArray=NSMutableArray()
    var pollAnswerDetails:NSMutableArray=NSMutableArray()
    var ImagePath:String!=""
    var sizeOfTheString:CGSize=CGSize()
    var lobjHeaderView:UIView!
    var flagToResult:Bool = false
    var pollManager:PollManager!
    var headerTitle:String = ""
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var pollId:String = ""
    var isConfirmArray:NSMutableArray = []
   
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    var confirmIndexPath:NSIndexPath = NSIndexPath(forRow: 1897, inSection: 5)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pollTableView.delegate = self
        pollManager = PollManager.instance()
        let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
        let answerArray = PollAnswer.getAnswersBySurveyId(pollId, inContext: cdManager.childContext) as NSArray
      for (_,pollAnswer) in answerArray.enumerate()
      {
         answerChoices.addObject(pollAnswer.valueForKey("text")!)
         answerIDs.addObject(pollAnswer.valueForKey("answerId")!)
         answerCounts.addObject(pollAnswer.valueForKey("count")!)
      }
         let poll = Poll.getPollById(pollId, inContext: cdManager.parentContext) as Poll
      
         self.headerTitle = poll.pollDescription
      
        self.pollTableView.reloadData()
        self.pollTableView.hidden = false
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
      
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "popVC:")
        backButton.tintColor=UIColor.whiteColor()
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
      
      
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 19)!
        ]
        nav?.titleTextAttributes = attributes
        
        navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 14)!], forState: UIControlState.Normal)
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 14)!], forState: UIControlState.Normal)
        
        let resultButton:UIButton  = UIButton(frame:CGRectMake(10,0,80.0,30.0))
        resultButton.contentHorizontalAlignment=UIControlContentHorizontalAlignment.Right
        resultButton.contentEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 0);
        resultButton.setTitle("Results", forState: .Normal)
        resultButton.addTarget(self, action: "ResultAction", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resultButton)
        
      
        self.headerLabel.text = self.headerTitle;
        let fileUrl = NSURL(string: poll.imageURL);
        self.headerImageView.sd_setImageWithURL(fileUrl, placeholderImage:UIImage(named:"profile-bg@3x.png"))
        
    }
    
    func ResultAction()
    {
        flagToResult = true
        let pollresultsViewController = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollResultsViewController") as! PollResultsViewController
        pollresultsViewController.setId(self.pollId)
        self.navigationController?.pushViewController(pollresultsViewController, animated: true)
    }
    override func viewWillAppear(animated: Bool) {

    }
    
        func calculatingHeightOfTheString( contentString:String, font:UIFont)->CGSize
    {
        return contentString.boundingRectWithSize(CGSize(width:300, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil).size
        
    }
    //MARK:- BackButton Action
    func popVC(sender:UIBarButtonItem!)
    {
        //print("Button tapped")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK:- TableView datasource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
      return self.answerIDs.count;
    }
   
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 78
        
    }
    
    //MARK:- Cell for row method
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        print(inputDic)
        let identifier = "PollDetailsTableViewCell"
        var cell: PollDetailsTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? PollDetailsTableViewCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "PollDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PollDetailsTableViewCell
        }
        cell.pollAnswerLabel.text = self.answerChoices[indexPath.row] as? String
      
        if(confirmIndexPath.row==indexPath.row)//(self.inputDic[indexPath.row+1]==false)
        {
         cell.confirmButton.hidden=false
         cell.selectButton.hidden=true
        }
        else
        {
         cell.confirmButton.hidden=true
         cell.selectButton.hidden=false
        }
      
        cell!.selectButton.tag = indexPath.row+1
        cell!.confirmButton.tag=(2000+(indexPath.row+1))
        cell!.delegate = self;
        return cell
     }
     //MARK:- TableView Did select method
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)->Void
    {
        
    }
    @IBAction func displayingPollResults(sender: AnyObject)
    {
        
        self.performSegueWithIdentifier("pollResultsSegue", sender: self)
    }
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
   
    func startIndicator()
    {
      activityIndicator = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
      activityIndicator.color = UIColor .grayColor()
      activityIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
      activityIndicator.center = self.view.center
      activityIndicator.hidesWhenStopped = true
      self.view.addSubview(activityIndicator)
      activityIndicator.bringSubviewToFront(self.view)
      activityIndicator.startAnimating()
    }
   
    func selectButtonClicked(cell: PollDetailsTableViewCell,button:UIButton){
            confirmIndexPath = pollTableView.indexPathForCell(cell)!
            self.pollTableView.reloadData()
    }
    
    func confirmButtonClicked(cell: PollDetailsTableViewCell,button:UIButton){
      
      self.view.userInteractionEnabled = false;
      startIndicator();
      var newIndexPath: NSIndexPath = NSIndexPath();
      newIndexPath = pollTableView.indexPathForCell(cell)!
      APIServiceSessionManger.SetPollAnswersWithCompletionBlock(pollId, answerId: self.answerIDs[newIndexPath.row] as! NSNumber , success: { ( responseObject) -> Void in
         self.activityIndicator.stopAnimating()
         if let status = responseObject.objectForKey("status") as? NSString
         {
            if(status == "Success")
            {
               self.view.userInteractionEnabled = true;
               let pollresultsViewController = UIStoryboard(name: "Poll", bundle: nil).instantiateViewControllerWithIdentifier("PollResultsViewController") as! PollResultsViewController
               pollresultsViewController.setId(self.pollId)
               pollresultsViewController.setAnswer(self.answerIDs[newIndexPath.row] as! NSNumber)
               //charleself.navigationController?.pushViewController(pollresultsViewController, animated: true)
               let vcMutArray = NSMutableArray(array: (self.navigationController?.viewControllers)!)
               vcMutArray.replaceObjectAtIndex(vcMutArray.count-1, withObject: pollresultsViewController)
               self.navigationController?.viewControllers = (NSArray(array: vcMutArray)) as! [UIViewController]
            }
            else
            {
               self.view.userInteractionEnabled = true;
               self.ResultAction()
               
               self.activityIndicator.stopAnimating()
               self.view.userInteractionEnabled = true;
               let alert = UIAlertView()
               alert.title = "Alert"
               alert.message = "Problem while submitting your answer"
               alert.addButtonWithTitle("OK")
               alert.show()

            }
         }
         
         }) { ( error) -> Void in
            self.activityIndicator.stopAnimating()
            self.view.userInteractionEnabled = true;
            print(error)
            let alert = UIAlertView()
            alert.title = "Alert"
            alert.message = "Problem while submitting your answer"
            alert.addButtonWithTitle("OK")
            alert.show()
      }
      self.pollTableView.reloadData()
      
    }
   
   func setId(pollId:NSString)
   {
      self.pollId = pollId as String
   }

}

