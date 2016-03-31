//
//  PollResultsViewController.swift
//  Emeritus
//
//  Created by SB on 12/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation

class PollResultsViewController: UIViewController {
     @IBOutlet weak var pollResultTableView: UITableView!
   
   @IBOutlet weak var headerLabel: UILabel!
   var answerChoices:NSMutableArray=[]
   var answerIDs:NSMutableArray=[]
   var answerCounts:NSMutableArray=[]
   
    var percentages=[Float]()
    var arrResults = []
    var sum:NSNumber = 0.0
    var pollManager:PollManager!
    var pollId:String = ""
    var answeredId:NSNumber = 999
   
    override func viewDidLoad() {
        super.viewDidLoad()
      pollManager = PollManager.instance()
      
      let cdManager:MSCoreDataManager=MSCoreDataManager.sharedCoreDataInstance() as! MSCoreDataManager
      let answerArray = PollAnswer.getAnswersBySurveyId(pollId, inContext: cdManager.childContext) as NSArray
      for (_,pollAnswer) in answerArray.enumerate()
      {
         if((pollAnswer.valueForKey("answerId") as! NSNumber) == answeredId)
         {
            let numberValue = pollAnswer.valueForKey("count") as! NSNumber
            var intValue = numberValue.intValue
            intValue = intValue + 1
            let newNumberValue = NSNumber(int: intValue)
            answerCounts.addObject(newNumberValue)
         }
         else
         {
            answerCounts.addObject(pollAnswer.valueForKey("count")!)
         }
         answerChoices.addObject(pollAnswer.valueForKey("text")!)
         answerIDs.addObject(pollAnswer.valueForKey("answerId")!)
      }
      
      let poll = Poll.getPollById(pollId, inContext: cdManager.parentContext) as Poll
      
      self.headerLabel.text = poll.pollDescription
        self.headerLabel.sizeToFit()
      for var i = 0; i < self.answerCounts.count; i++
         {
            self.sum = NSNumber(float: (self.sum.floatValue + answerCounts[i].floatValue))
         }
   
            self.pollResultTableView.reloadData()
         
           let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.whiteColor()
        self.navigationItem.title="Poll Results"
        self.navigationItem.setHidesBackButton(true,animated:true)

        self.navigationItem.setHidesBackButton(true,animated:true)
      
        let closeButton:UIButton  = UIButton(frame:CGRectMake(10,0,50.0,30.0))
        closeButton.contentHorizontalAlignment=UIControlContentHorizontalAlignment.Left
        closeButton.contentEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 0);
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: "CloseAction:", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)

        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 19)!
        ]
        nav?.titleTextAttributes = attributes
  
    navigationController?.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 14)!], forState: UIControlState.Normal)
        self.pollResultTableView.tableFooterView = UIView(frame: CGRectZero)
        self.pollResultTableView.separatorColor = UIColor(patternImage: UIImage(named:"separator_grey1@2x.png")!)

            }
    //MARK:- BackButton Action
    func CloseAction(sender:UIBarButtonItem!)
    {
        //print("Button tapped")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
   
    //MARK: - TableView DataSource Methods
    func numberOfSections() -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
         return self.answerIDs.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
       
            return 85
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let identifier = "PollResultTableViewCell"
        var cell: PollResultTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? PollResultTableViewCell
        
        if cell == nil {
            
            tableView.registerNib(UINib(nibName: "PollResultTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PollResultTableViewCell
                
        }
      //var poll_answer:PollAnswer = (pollManager.answers.objectAtIndex(indexPath.row) as? PollAnswer)!
        let numberToShow = self.answerChoices[indexPath.row] as! NSString
       //var percentText:String = String(poll_answer.count)
        cell.givingAllValuesToLabels(numberToShow, percent: self.answerCounts[indexPath.row].floatValue, sum: self.sum.floatValue)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         
        // Dispose of any resources that can be recreated.
    }
    
   func setId(pollId:NSString)
   {
      self.pollId = pollId as String
   }
   
   func setAnswer(answeredId:NSNumber)
   {
      self.answeredId = answeredId
   }
}
