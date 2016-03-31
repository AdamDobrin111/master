//
//  ChatCaptionViewController.swift
//  Emeritus
//
//  Created by SB on 10/02/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

@objc protocol passingImageAndTextToChatPageDelegate{
    
    optional  func sendingImageAndCaptiontextbackToChatPage(attachedImage:UIImage,captionText:NSString,imageNameToupload:NSString,imageCompletePath:NSURL,typeofTheImage:NSString)
    optional  func sendingvideoAndCaptiontextbackToChatPage(attachedUrl:NSURL,captionText:NSString,nameOfTheVideo:NSString!)
    
    optional func sendingAudioAndCaptiontextbackToChatPage(attachedUrl:NSURL,captionText:NSString,nameOfTheAudio:NSString!)
}

class ChatCaptionViewController: UIViewController,AVAudioPlayerDelegate {
    @IBOutlet weak var constraintsY: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var imageViewTosend: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeHolderForCaptionTextview: UILabel!
    var imageToSend:UIImage!
    var kbsize:CGSize=CGSizeZero
    var videoUrl:NSURL!
    @IBOutlet weak var playPauseButton: UIButton!
    var previousRect:CGRect=CGRectZero
    let maximumheightOfTextView:CGFloat=90
    var moved:Bool=false
    var sendTouserName:String!
    var moviePlayercontroller: MPMoviePlayerViewController!
    var messageDialogId:NSInteger!
    var delegate:passingImageAndTextToChatPageDelegate! = nil
    var imageName:NSString!
    var videoName:NSString!
    var imageRefURl:NSURL!
    var imageType:NSString?
    var titleLabel:UILabel!
    var audioUrl:NSURL!
    var audioName:NSString!
    var audioPlayer:AVAudioPlayer!
    var timer:NSTimer!
    var flagSwitch:Bool=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image:UIImage = UIImage(named: "nav_bar@2x.png")!
        self.navigationController!.navigationBar.setBackgroundImage(image,
            forBarMetrics: .Default)
        self.navigationItem.setHidesBackButton(true,animated:true)
        let nav = self.navigationController?.navigationBar
        let backButton = UIBarButtonItem (image:UIImage(named:"back_icon.png"), style: .Plain, target: self,action: "backAction")
        navigationItem.leftBarButtonItem = backButton
        backButton.tintColor=UIColor.whiteColor()
        //        var sendButton:UIButton  = UIButton(frame:CGRectMake(10,0,50.0,30.0))
        //        sendButton.contentHorizontalAlignment=UIControlContentHorizontalAlignment.Left
        //        sendButton.contentEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 0);
        //        sendButton.setTitle("Send", forState: .Normal)
        //        sendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //        sendButton.addTarget(self, action: "sendAction", forControlEvents: .TouchUpInside)
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        let attributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Avenir", size: 19)!
        ]
        nav?.titleTextAttributes = attributes
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 14)!], forState: UIControlState.Normal)
        
        titleLabel=UILabel(frame:CGRectMake(10,30, UIScreen.mainScreen().bounds.size.width-20,25))
        titleLabel.text="Send To "+sendTouserName
        titleLabel.textColor=UIColor.whiteColor()
        titleLabel.backgroundColor=UIColor.redColor()
        titleLabel.font=UIFont(name: "Avenir", size:19)
        titleLabel.hidden=true
        nav?.addSubview(titleLabel)
        self.imageViewTosend.image=imageToSend
        captionTextView.layer.masksToBounds=true
        captionTextView.layer.borderColor=UIColor(red: 54/255.0, green: 54/255.0, blue: 54/255.0, alpha: 0.57).CGColor
        captionTextView.layer.borderWidth=0.5
        
        self.title="Send To "+sendTouserName
        self.progressBar.hidden=true
        if(!(audioUrl==nil))
        {
            self.progressBar.hidden=false
            playPauseButton.hidden=false
            do{
                self.audioPlayer = try AVAudioPlayer(contentsOfURL: audioUrl)
            }
            catch
            {
                
            }
        }
        else
        {
            
            if(videoUrl==nil)
            {
                playPauseButton.hidden=true
            }
            else
            {
                generatingThmbnalImageFromVideoUrl(videoUrl)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func updateProgress()
    {
        let timeLeft:Float=(Float)(self.audioPlayer.currentTime/self.audioPlayer.duration);
        self.progressBar.progress=timeLeft;
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag
        {
            flagSwitch=true
            self.playPauseButton.setImage(UIImage(named: "ic_playbttn.png"), forState: UIControlState.Normal)
            self.timer.invalidate()
            self.progressBar.progress=0.0
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyPressed:", name: UITextViewTextDidChangeNotification, object: nil)
        
    }
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self,name:UIKeyboardWillShowNotification,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:UITextViewTextDidChangeNotification,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name:MPMoviePlayerPlaybackDidFinishNotification,object:nil)
        
    }
    
    func generatingThmbnalImageFromVideoUrl(url:NSURL)
    {
        
        let asset:AVAsset=AVAsset(URL: url)
        let imagegenerator:AVAssetImageGenerator=AVAssetImageGenerator(asset: asset) as AVAssetImageGenerator
        imagegenerator.appliesPreferredTrackTransform=true
        var time:CMTime=asset.duration
        var _:CMTime
        time.value=3
        do
        {
            let imageRef:CGImageRef = try imagegenerator.copyCGImageAtTime(time, actualTime:nil)
            let thumbnailImage:UIImage=UIImage(CGImage:imageRef)
            imageViewTosend.image=thumbnailImage
        }
        catch
        {
            
        }
    }
    @IBAction func sendAction()
    {
        if(!(audioUrl==nil))
        {
            if (NSFileManager.defaultManager().fileExistsAtPath(audioUrl.path!))
            {
                self.audioPlayer.stop()
                delegate.sendingAudioAndCaptiontextbackToChatPage!(audioUrl, captionText: captionTextView.text, nameOfTheAudio: audioName)
            }
            else
            {
                let alert = UIAlertView()
                alert.title = "Alert"
                alert.message = "Please check the setting to record audio"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        if(videoUrl==nil)
        {
            
            delegate.sendingImageAndCaptiontextbackToChatPage!(imageToSend, captionText: captionTextView.text, imageNameToupload:imageName, imageCompletePath: imageRefURl,typeofTheImage:imageType!)
        }
        else
        {
            delegate.sendingvideoAndCaptiontextbackToChatPage!(videoUrl, captionText: captionTextView.text, nameOfTheVideo: videoName)
            
        }
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func backAction()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func playAndPauseAction(sender: AnyObject) {
        if flagSwitch
        {
            flagSwitch=false
            if(!(audioUrl==nil))
            {
                if let btn = sender as? UIButton
                {
                    btn.setImage(UIImage(named: "moviePause@2x.png"), forState: UIControlState.Normal)
                }
                self.audioPlayer.play()
                self.timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
            }
            else
            {
                flagSwitch=true
                //        NSString *urlAddress = @"assets-library://asset/asset.m4v?id=100&ext=m4v";
                //        NSURL *theURL = [NSURL URLWithString:urlAddress];
                let urlString:NSString=videoUrl.absoluteString
                let lobjvideourl:NSURL=NSURL(string: urlString as String)!
                moviePlayercontroller = MPMoviePlayerViewController(contentURL:lobjvideourl)
                if let player = moviePlayercontroller{
                    
                    NSNotificationCenter.defaultCenter().addObserver(self,selector: "videoHasFinishedPlaying:",name: MPMoviePlayerPlaybackDidFinishNotification,
                        object: player.moviePlayer)
                    moviePlayercontroller.moviePlayer.scalingMode = .AspectFit
                }
                //            self.presentMoviePlayerViewControllerAnimated(moviePlayercontroller)
                self.presentViewController(moviePlayercontroller, animated: true, completion: { () -> Void in
                    //_:CGFloat = -self.kbsize.height; // tweak as needed
                    let  movementDuration:NSTimeInterval = 0.3; // tweak as needed
                    UIView.beginAnimations("animateTextField",context: nil)
                    UIView.setAnimationBeginsFromCurrentState(true)
                    UIView.setAnimationDuration(movementDuration)
                    self.bottomViewbottomConstraint.constant=0
                    self.view.layoutIfNeeded()
                    UIView.commitAnimations()
                    self.constraintsY.constant=0.0
                    self.moved = false
                })
                moviePlayercontroller.moviePlayer.play()
            }
        }
        else
        {
            flagSwitch=true
            if let btn = sender as? UIButton
            {
                
                if(!(audioUrl==nil))
                {
                    btn.setImage(UIImage(named: "ic_playbttn.png"), forState: UIControlState.Normal)
                    self.audioPlayer.stop()
                    self.timer.invalidate()
                }
            }
        }
        
    }
    @IBAction func tapGestureAction(sender: AnyObject) {
        
    }
    
    func keyPressed(notification: NSNotification)
    {
        if(captionTextView.hasText())
        {
            let position:UITextPosition=captionTextView.endOfDocument
            let currentRect=captionTextView.caretRectForPosition(position)
            
            if ((currentRect.origin.y > previousRect.origin.y)&&(currentRect.origin.y > 7)){
                
                if(currentRect.origin.y>=maximumheightOfTextView)
                {
                    captionTextView.scrollEnabled=true
                }
                else
                {
                    print("new line reached")
                    //For new line increasing height to 12 to existing one
                    //                    textViewHeightConstraint.constant=textViewHeightConstraint.constant+12
                    bottomViewheightConstraint.constant=bottomViewheightConstraint.constant+12
                }
            }
            previousRect = currentRect;
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let info = notification.userInfo {
            kbsize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        
        self.bottomView.center = CGPointMake(self.bottomView.center.x, self.bottomView.center.y+kbsize.height);
        self.constraintsY.constant=100.0
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText lobjtext: String) -> Bool
    {
        
        if(textView.text.characters.count + (lobjtext.characters.count - range.length)==0)
        {
            placeHolderForCaptionTextview.hidden=false
            
        }
        else
        {
            placeHolderForCaptionTextview.hidden=true
            
        }
        if(textView.text.characters.count==160)
        {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if(!moved) {
            
            animateViewToPosition(bottomView, direction:true)
            moved = true
        }
    }
    
    func animateViewToPosition( viewToMove:UIView, direction:Bool)
    {
        self.view.layoutIfNeeded()
        //_:CGFloat = -kbsize.height; // tweak as needed
        let  movementDuration:NSTimeInterval = 0.3; // tweak as needed
        UIView.beginAnimations("animateTextField",context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        bottomViewbottomConstraint.constant=0-(250)
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
        
    }
    
    func videoHasFinishedPlaying(notification: NSNotification){
        
        //        print("Video finished playing")
        
        /* Find out what the reason was for the player to stop */
        let reason =
        notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
            as! NSNumber?
        
        if let _ = reason{
            stopPlayingVideo()
        }
        
    }
    
    func stopPlayingVideo() {
        
        if let player = moviePlayercontroller{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            moviePlayercontroller.moviePlayer.stop()
            player.view.removeFromSuperview()
            NSNotificationCenter.defaultCenter().removeObserver(self,name:MPMoviePlayerPlaybackDidFinishNotification,object:nil)
        }
        
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
