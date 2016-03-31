//
//  ProfilePhotosViewController.swift
//  Emeritus
//
//  Created by SB on 12/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import Foundation

class ProfilePhotosViewController: UIViewController,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var imageviewOnFullsizeView:UIImageView!
    var plusButton:UIButton!
    var photosArray:NSMutableArray!
    var dummyView:UIView!
    var fullSizeView:UIScrollView!
    var photosAvailableStatus:Bool!
    var directoryPath:String!
    var fileManager:NSFileManager!
    var dictImageCache:NSMutableDictionary!
    var arrPhotosDetails:NSMutableArray!
    var userID:NSString!
    var qbID:NSString!
   
   var imageIdArray:NSMutableArray = NSMutableArray()

    var photosUrlArray:NSMutableArray!
    
    @IBOutlet weak var indicatorBaseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        imageIdArray.removeAllObjects()
      
      let ID:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
      if self.qbID == ID  //If Logged in User profile
      {
         self.addingView()
         self.plusButton.setImage(UIImage(named:"upload_button_normal@2x.png"), forState:.Normal)
      }
      
      loadImages()
        
        indicatorBaseView.layer.masksToBounds=true
        indicatorBaseView.layer.cornerRadius=10.0
        indicatorBaseView.layer.borderWidth=3.0
        indicatorBaseView.layer.borderColor=UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.5).CGColor
        indicatorBaseView.backgroundColor=UIColor(red: 31/255.0, green: 160/255.0, blue: 124/255.0, alpha: 1.0)
        
        self.dictImageCache=NSMutableDictionary()
        self.navigationItem.title="Photos"
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController?.navigationBar .setBackgroundImage(image, forBarMetrics:.Default)
        photosCollectionView!.backgroundColor = UIColor.whiteColor()
        self.navigationItem.setHidesBackButton(true,animated:true)
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        
    }
   
   override func viewWillAppear(animated: Bool) {
      
      //NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateUserDetails:", name: "UserDetailsUpdated", object: nil)
      
   }
   
   func loadImages()
   {
   imageIdArray.removeAllObjects()
   indicatorBaseView.layer.masksToBounds=true
   indicatorBaseView.layer.cornerRadius=10.0
   indicatorBaseView.layer.borderWidth=3.0
   indicatorBaseView.layer.borderColor=UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.5).CGColor
   indicatorBaseView.backgroundColor=UIColor(red: 31/255.0, green: 160/255.0, blue: 124/255.0, alpha: 1.0)
   
      photosUrlArray = NSMutableArray()
      APIServiceSessionManger.GetGalleryWithCompletionBlock(userID, success: { (responseObject) -> Void in
         if let _ = responseObject.objectForKey("status") as? NSString
         {
            self.indicatorBaseView.hidden = true
            if let responce = responseObject.objectForKey("response") as? NSArray
            {
               for( var i = 0; i<responce.count; i++)
               {
                  let dict = responce[i] as! NSDictionary;
                  let userId = (dict.valueForKey("userId") as! NSNumber).stringValue
                  let imageId = (dict.valueForKey("id") as! NSNumber).stringValue
                  self.imageIdArray.addObject(imageId)
                  let urlString = NSString(format: "http://52.22.22.151:8080/api/file/%@/%@?type=3", userId,imageId)
                  self.photosUrlArray.addObject(urlString)
               }
               
               self.photosCollectionView.reloadData()
   
            }
            else
            {
               self.photosCollectionView.reloadData()
            }
         }
         }) { ( error) -> Void in
            //self.indicatorBaseView=nil
            self.indicatorBaseView.hidden = true
      }

   }
   
    // MARK: UnhideIndicatorView
    func unhideIndicatorView()
    {
        self.view.bringSubviewToFront(indicatorBaseView)
        indicatorBaseView.hidden=false
        
    }
    // MARK: hideIndicatorView
    func hideIndicatorView()
    {
        indicatorBaseView.hidden=true
        
    }
    
    func checkAtleastOnePhotoIsthereorNotInDocumentSirectory( lobjphotosArray:NSMutableArray)->Bool
    {
        var status:Bool=true
        for imageString in photosArray
        {
            directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            let getImagePath = directoryPath.stringByAppendingPathComponent(imageString as! String)
            let fileManager = NSFileManager.defaultManager()
            if (fileManager.fileExistsAtPath(getImagePath))
            {
                continue
            }
            else
            {
                status=false
            }
            
        }
        return status
    }
    
    func backAction()
    {
        if((fullSizeView) != nil)
        {
            fullSizeView.removeFromSuperview()
            fullSizeView=nil
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (!(self.photosUrlArray==nil))
        {
            if(self.photosUrlArray.count<6)
            {
                let ID:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
                if self.qbID == ID  //If Logged in User profile
                {
                plusButton.enabled=true
                }
            }
            else
            {
                let ID:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
                if self.qbID == ID  //If Logged in User profile
                {
                plusButton.enabled=false
                }
            }
            return self.photosUrlArray.count
        }
        else
        {
          return  self.photosUrlArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
         
        let cell:ProfileCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionViewCell",forIndexPath:indexPath) as! ProfileCollectionViewCell
      
        cell.backgroundColor=UIColor.whiteColor()
        
        if self.photosUrlArray != nil
        {
         cell.photoImage.tag = self.imageIdArray.objectAtIndex(indexPath.row).integerValue;
         cell.photoImage.contentMode = UIViewContentMode.ScaleAspectFill
            //var dict:NSDictionary=self.arrPhotosDetails.objectAtIndex(indexPath.row) as! NSDictionary
          //  _:NSString=self.photosUrlArray.objectAtIndex(indexPath.row) as! NSString
                
                let strUrl:NSString=self.photosUrlArray.objectAtIndex(indexPath.row) as! NSString
                
                let imageRequest: NSURLRequest = NSURLRequest(URL: NSURL(string:strUrl as String)!)
                NSURLConnection.sendAsynchronousRequest(imageRequest,
                    queue: NSOperationQueue.mainQueue(),
                    completionHandler:{ (urlRequest:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
                       let image=UIImage(data: data!)
                        //self.dictImageCache.setObject(image!, forKey: str)
                        let photoImage = self.view.viewWithTag(self.imageIdArray.objectAtIndex(indexPath.row).integerValue) as? UIImageView
                        photoImage?.image = image
                        cell.photoImage.image = image
                })
      
        }

        let ID:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
        if self.qbID == ID
        {
        let longpressGesture:UILongPressGestureRecognizer=UILongPressGestureRecognizer(target: self, action: "longPressGestureAction:")
        cell.addGestureRecognizer(longpressGesture)
        }
        cell.tag=cell.photoImage.tag + 1000000
        return cell
    }
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let str:NSString=self.photosUrlArray.objectAtIndex(indexPath.row) as! NSString
        let strUrl:NSString=NSString(format: str)
        let imageRequest: NSURLRequest = NSURLRequest(URL: NSURL(string:strUrl as String)!)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{ (urlRequest:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
                self.creatingtheViewAsFullSize(indexPath.row,image: UIImage(data: data!)!)
               
        })
      self.photosCollectionView.hidden = true;
      
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
         
         let deviceSize = UIScreen.mainScreen().bounds.size
            return CGSize(width: deviceSize.width/2, height: deviceSize.width/2)
    }
    
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            return sectionInsets
    }
    
    func addingView()
    {
        
        let plusbuttonImage:UIImage=UIImage(named:"upload_button_normal@2x.png")!
        plusButton=UIButton(frame: CGRectMake(self.view.frame.size.width/2-62/2, self.view.frame.size.height-110-62/2, 62, 62)) as UIButton
        plusButton.setImage(plusbuttonImage, forState:.Normal)
        plusButton.addTarget(self, action:"plusButtonAction", forControlEvents:.TouchUpInside)
        plusButton.setImage(UIImage(named:"upload_button_pressed@2x.png")!, forState: .Highlighted)
        self.view.addSubview(plusButton);
        if let _ = self.arrPhotosDetails
        {
        if(self.arrPhotosDetails.count==6)
        {
            plusButton.enabled=false
        }
        else
        {
            plusButton.enabled=true
        }
        }
        
    }
    
    func plusButtonAction()
    {
        
        plusButton.highlighted=true
        let photoActionSheet = UIActionSheet(title:nil, delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil,otherButtonTitles:"Upload from Camera","Choose from Gallery")
        photoActionSheet.showInView(self.view)
        photoActionSheet.cancelButtonIndex=photoActionSheet.numberOfButtons-1
        plusButton.highlighted=false
        
    }
    
    @IBAction func pangestureAction(sender: AnyObject) {
        
        let ID:NSString=NSUserDefaults.standardUserDefaults().objectForKey("SessionUserId") as! NSString
        if self.qbID == ID  //If Logged in User profile
        {
        let pangesture:UIPanGestureRecognizer=sender as! UIPanGestureRecognizer
        let translation:CGPoint=pangesture.translationInView(self.view)
        let plusButtonFrame:CGRect=plusButton.frame
        var touchLocation:CGPoint=CGPointZero
        touchLocation=pangesture.locationInView(self.view)
        
        switch(pangesture.state)
        { 
        case .Changed:
            
            if((dummyView) != nil)
            {
                let xpos:CGFloat=dummyView.center.x+translation.x
                let ypos:CGFloat=dummyView.center.y+translation.y
                dummyView.center=CGPointMake(xpos,ypos);
                pangesture.setTranslation(CGPointMake(0, 0),inView: self.view)
                touchLocation=CGPointMake(dummyView.center.x, dummyView.center.y+dummyView.frame.size.height/2)
                
            }
            break;
            
        case .Began:
            break;
            
        case .Ended:
            touchLocation=pangesture.locationInView(self.view)

            if(CGRectContainsPoint(plusButtonFrame, touchLocation))
            {
                plusButton.setImage(UIImage(named:"upload_button_normal@2x.png"), forState:.Normal)
                
                if((dummyView) != nil)
                {
                  APIServiceSessionManger.DeletePhotoWithCompletionBlock(String(dummyView.tag - 1002000), success: { (responseObject) -> Void in
                     if let status = responseObject.objectForKey("status") as? NSString
                     {
                        if status == "Success"
                        {
                           self.loadImages()
                        }
                        
                        else
                        {
                           let alert = UIAlertView()
                           alert.title = "Error"
                           alert.message = "Problem while deleting photo"
                           alert.addButtonWithTitle("OK")
                           alert.show()
                        }
                        
                     }
                     }) { ( error) -> Void in
                        let alert = UIAlertView()
                        alert.title = "Error"
                        alert.message = "Problem while deleting photo"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                        self.indicatorBaseView.hidden = true
                  }
                  dummyView.removeFromSuperview()
                    dummyView=nil
                }
                
            }
             else
            {
                
                if((dummyView) != nil)
                {
                    
                    dummyView.removeFromSuperview()
                    dummyView=nil
                }
                
            }
            
            plusButton.setImage(UIImage(named:"upload_button_normal@2x.png"), forState:.Normal)
            
            break;
        default:
            break;
        }
        }
        
    }
    
    func longPressGestureAction(sender:UIGestureRecognizer)
    {
        plusButton.setImage(UIImage(named:"deletebtn@2x.png"), forState:.Normal)
        let longpressgestureRecogniser=sender as! UILongPressGestureRecognizer
        plusButton.enabled=true
        switch(longpressgestureRecogniser.state)
        {
        case .Began:
            
            let photocell=longpressgestureRecogniser.view as! UICollectionViewCell
            //print(photocell.tag)
            //print(photosArray)
            //photosCollectionView.reloadData()
            UIGraphicsBeginImageContext(photocell.contentView.bounds.size);
            photocell.contentView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image:UIImage=UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            let imageview:UIImageView=UIImageView(image:image)
            dummyView=UIView(frame:imageview.frame)
            dummyView.addSubview(imageview)
            dummyView.alpha=0.3;
            dummyView.backgroundColor=UIColor(patternImage: UIImage(named:"photo_album_base@2x.png")!)
            dummyView.center=longpressgestureRecogniser.locationInView(self.view.superview)
            dummyView.tag=(2000+photocell.tag)
            self.view.superview?.addSubview(dummyView)
             break;
        case .Changed:
            
            break;
         case .Ended:
//            if((dummyView) != nil)
//            {
//               APIServiceSessionManger.DeletePhotoWithCompletionBlock(String(dummyView.tag - 2000), success: { (responseObject) -> Void in
//                  if let status = responseObject.objectForKey("status") as? NSString
//                  {
//                     self.indicatorBaseView.hidden = true
//                     if let responce = responseObject.objectForKey("response") as? NSArray
//                     {
//                        
//                     }
//                  }
//                  }) { ( error) -> Void in
//                     //self.indicatorBaseView=nil
//                     self.indicatorBaseView.hidden = true
//               }
//                dummyView.removeFromSuperview()
//                dummyView=nil
//                
//            }
            plusButton.setImage(UIImage(named:"upload_button_normal@2x.png"), forState:.Normal)
            //photosCollectionView.reloadData()
        default:
            break;
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        if(gestureRecognizer.view==plusButton)
        {
            return false
        }
        
        return true
    }
    
    func creatingtheViewAsFullSize( row:Int, image:UIImage)
    {
        
        let photoImage:UIImage=image
        fullSizeView=UIScrollView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height))
        fullSizeView.delegate=self
        self.view.addSubview(fullSizeView)
        self.fullSizeView.minimumZoomScale=0.5;
        self.fullSizeView.maximumZoomScale=6.0;
        //        self.fullSizeView.contentSize=CGSizeMake(320, 960);
        imageviewOnFullsizeView=UIImageView(image:photoImage) as UIImageView
        imageviewOnFullsizeView.frame=CGRectMake(0, 0, fullSizeView.frame.size.width, fullSizeView.frame.size.height)
        imageviewOnFullsizeView.contentMode=UIViewContentMode.ScaleAspectFit
        imageviewOnFullsizeView.clipsToBounds=true
        fullSizeView.addSubview(imageviewOnFullsizeView)
        let tapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: "tapGestureAction")
        fullSizeView.addGestureRecognizer(tapGesture)
        
        let pinchGesture:UIPinchGestureRecognizer=UIPinchGestureRecognizer(target: self, action: "pinchGestureAction:")
        fullSizeView.addGestureRecognizer(pinchGesture)
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return imageviewOnFullsizeView
    }
    
    func pinchGestureAction(sender:UIGestureRecognizer)
    {
        
    }
    
    func tapGestureAction()
    {
        if((fullSizeView) != nil)
        {
            fullSizeView.removeFromSuperview()
            fullSizeView=nil
         
        }
      self.photosCollectionView.hidden = false;
    }
     //MARK: - Actionsheet Delegate Methods
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {

        switch buttonIndex{
            
        case 0:
            //print("Clicked on cancel")
            actionSheet.dismissWithClickedButtonIndex(0, animated: true)
            break
            
        case 1:
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            //print("camera");
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            else
            {
                
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Camera is not available"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
            break
        case 2:
            //print("gallery");
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                
                imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            else  if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
                self.presentViewController(imagePickerController, animated: true, completion: nil)
                
            }
            else
            {
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Photos not available"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
            
            break
         default:
            //print("Default");
            break
            
        }
    }
   
   
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
         let webManager:MSWebManager=MSWebManager.sharedWebInstance() as MSWebManager
         webManager.addToGallery(image) { (response:NSMutableDictionary!) -> Void in
            self.loadImages()
         }

            let imageCount:Int
            if let arr=self.photosArray
            {
                imageCount=arr.count
            }
            else
            {
                imageCount=0
            }
            self.directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
            let imagedata:NSData=UIImageJPEGRepresentation(image, 1.0)!
            let getImagePath = self.directoryPath.stringByAppendingPathComponent(String(format:"%d.png",imageCount+1) as String)
            imagedata.writeToFile(getImagePath, atomically: true)
        })
    }
     }
    