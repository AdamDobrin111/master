//
//  FrozenPostViewController.swift
//  Emeritus
//
//  Created by nikita on 11/13/15.
//  Copyright © 2015 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
}

class FrozenPostViewController: UIViewController {
    
    
    @IBOutlet weak var tableViewList: UITableView!
    @IBOutlet weak var noFrozenView: UIView!
    @IBOutlet weak var noFrozenCons: NSLayoutConstraint!
    
    var customFrozenCell:FrozenPostCellV!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewList.userInteractionEnabled = true
        
        let cellNib:UINib = UINib(nibName:"FrozenPostCellV", bundle: nil) as UINib
        self.tableViewList.registerNib(cellNib, forCellReuseIdentifier: "FrozenPostCellV")
        customFrozenCell = cellNib.instantiateWithOwner(nil, options:  nil)[0]as! FrozenPostCellV
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFrozenPosts:", name:kFrozenPostsRefresh, object: nil)
        FrozenPostManager.sharedDispatchInstance.didFrozenPostsAppear = true
        
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        FrozenPostManager.sharedDispatchInstance.didFrozenPostsAppear = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kFrozenPostsRefresh , object: nil)
    }
    
    func backAction(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func refreshFrozenPosts(notification:NSNotification){
        self.tableViewList.reloadData()
    }
    
    func showNoFrozenPosts(){
        noFrozenView.hidden = false
        noFrozenCons.constant = 50
    }
    
    func hideNoFrozenPosts(){
        noFrozenView.hidden = true
        noFrozenCons.constant = 5
    }
    
    
    //MARK: - tableview delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        let count:Int = FrozenPostManager.sharedDispatchInstance.frozenPostsCounts
        if count != 0{
            hideNoFrozenPosts()
        }
        else{
            showNoFrozenPosts()
        }
        return count
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        
        let count:Int = FrozenPostManager.sharedDispatchInstance.arrayFrozen.count
        
        if count != 0{
            
            for var indexFrozen:Int = 0; indexFrozen < count; ++indexFrozen{
                
                if indexFrozen == indexPath.section
                {
                    let cellData:FrozenPost?=FrozenPostManager.sharedDispatchInstance.arrayFrozen.objectAtIndex(indexFrozen) as? FrozenPost
                    customFrozenCell.layoutSubviews()
                    
                    let width:CGFloat  = self.view.frame.size.width - 20
                    let heightHeader = cellData?.shortDesc.heightWithConstrainedWidth(width, font: UIFont(name: "HelveticaNeue", size: 20)!)
                    let heightDesc = cellData?.longDesc.heightWithConstrainedWidth(width, font: UIFont(name: "HelveticaNeue", size: 16)!)
                    let heightTotal:CGFloat = heightHeader! + heightDesc! + 40
                    
                    return heightTotal
                }
            }
            
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let count:Int = FrozenPostManager.sharedDispatchInstance.arrayFrozen.count
        
        if count != 0{
            
            for var indexFrozen:Int = 0; indexFrozen < count; ++indexFrozen{
                
                if indexFrozen == indexPath.section
                {
                    let cellData:FrozenPost?=FrozenPostManager.sharedDispatchInstance.arrayFrozen.objectAtIndex(indexFrozen) as? FrozenPost
                    let cell:FrozenPostCellV = tableView.dequeueReusableCellWithIdentifier("FrozenPostCellV", forIndexPath: indexPath) as! FrozenPostCellV
                    cell.labHeader.sizeToFit()
                    cell.labDesc.sizeToFit()
                    cell.labDesc.text = cellData?.longDesc
                    cell.labHeader.text = cellData?.shortDesc
                    let celllayer:CALayer=cell.layer as CALayer
                    celllayer.cornerRadius=5.0
                    
                    return cell
                }
            }
            
        }
        return UITableViewCell()
    }
    
    
}
