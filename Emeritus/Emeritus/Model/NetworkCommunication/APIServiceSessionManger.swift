//
//  ViewController.swift
//  AFNetworkingTest
//
//  Created by Arun S on 14/01/15.
//  Copyright (c) 2015 Arun S. All rights reserved.
//

import Foundation

let sharedSessionService = APIServiceSessionManger(baseURL: NSURL(string :"http://52.22.22.151:8080/api"
))

class APIServiceSessionManger : AFHTTPSessionManager {
    
     init(baseURL url: NSURL!)  {
        super.init(baseURL: url, sessionConfiguration: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleGlobalNetworkingEvents:", name: AFNetworkingOperationDidFinishNotification, object: nil)
        
        setup()
        self.addDefaultHeaders()
        
        self.reachabilityManager.startMonitoring()
        
        self.reachabilityManager.setReachabilityStatusChangeBlock({ status in
            if status == AFNetworkReachabilityStatus.ReachableViaWiFi || status == AFNetworkReachabilityStatus.ReachableViaWWAN {
                //print("APIServiceSessionManger ************* NETWORK REACHABLE")
            }
            else {
                print("APIServiceSessionManger ************** NETWORK OFFLINE")                
            }
        })
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    func setup() {
        self.requestSerializer = AFJSONRequestSerializer() as AFHTTPRequestSerializer
        self.responseSerializer = AFJSONResponseSerializer () as AFHTTPResponseSerializer
        responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript","text/plain") as Set<NSObject>
    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)!
    }
    
    //Handle the global networking events here.
    func handleGlobalNetworkingEvents(notification : NSNotification) {
        
    }
    
    func addDefaultHeaders() {
      let lgService=LoginServices.sharedLogininstance();
        requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestSerializer.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
    }
    
    /**
    loginWithCompletionBlock
    
    :param: userName userName user name entered by the user.
    :param: passWord passWord password enterted by the user.
    :param: success  success User is authenticated.
    :param: failure  failure User is not authenticated
    */
    class func loginWithCompletionBlock(userName : NSString,passWord : NSString,success: (task: NSURLSessionDataTask, responseObject: AnyObject) -> Void,failure: (task: NSURLSessionDataTask, error: NSError) -> Void){
      
      var deviceTokenString:String = ""
      
      if let token =  NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? NSData
      {
      let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
      
      deviceTokenString = ( token.description as NSString )
         .stringByTrimmingCharactersInSet( characterSet )
         .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
      }
      
      else
      {
         deviceTokenString = "simulator"
      }
        let parameters:Dictionary<String,AnyObject> = ["username" : userName,
            "password" : passWord,"deviceUUID":deviceTokenString,"deviceType":"1"]
      
        sharedSessionService.POST(baseUrl+loginEndPoint, parameters: parameters, success: {(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
            if ((responseObject) != nil) {
                success(task: task, responseObject: responseObject)
            }
            }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
                if (error != nil) {
                    failure(task: task, error: error)
                }
        })
         
    }
   
   class func IsUserOnlineWithCompletionBlock(userId : NSNumber,success: (task: NSURLSessionDataTask, responseObject: AnyObject) -> Void,failure: (task: NSURLSessionDataTask, error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      let authToken = lgService.authToken;
      sharedSessionService.GET(baseUrl + "/general/isUserOnline?authToken=\(authToken)&qbId=\(userId)"  , parameters: nil, success: {(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
         if ((responseObject) != nil) {
            success(task: task, responseObject: responseObject)
         }
         }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
            if (error != nil) {
               failure(task: task, error: error)
            }
      })
      
      
      
   }
   
    class func ConfirmationCodeWithCompletionBlock(confirmationCode : NSString,success: (task: NSURLSessionDataTask, responseObject: AnyObject) -> Void,failure: (task: NSURLSessionDataTask, error: NSError) -> Void){
      var deviceTokenString:String = ""
      
      if let token =  NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? NSData
      {
         let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
         
         deviceTokenString = ( token.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
      }
         
      else
      {
         deviceTokenString = "simulator"
      }
      
      let parameters:Dictionary<String,AnyObject> = ["code":confirmationCode,"deviceUUID":deviceTokenString,"deviceType":"1"]
      //var parameters:Dictionary<String,AnyObject> = ["code":confirmationCode]
        print(parameters)
        print(baseLocalUrl+confirmationCodeEndPoint)
        
        sharedSessionService.POST(baseLocalUrl+confirmationCodeEndPoint, parameters: parameters, success: {(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
            if ((responseObject) != nil) {
                success(task: task, responseObject: responseObject)
            }
            }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
                if (error != nil) {
                    failure(task: task, error: error)
                }
        })
         
    }
   
   class func SetPollAnswersWithCompletionBlock(surveyId : NSString, answerId : NSNumber ,success: (responseObject: AnyObject) -> Void,failure: ( error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/setPollAnswer?pollOptionId=\(answerId)")
    
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "GET"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   class func GetPollWithCompletionBlock(surveyId : NSString, success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/getPoll")
      //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: nil)
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "GET"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   class func GetSupportInfoWithCompletionBlock(infoType : NSString, success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/supportInfo?infoType=\(infoType)&languageId=1&platform=1")
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "GET"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   class func GetGalleryWithCompletionBlock(userId : NSString, success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/getGallery?userId=" + (userId as String))
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//      
//      var dict = NSDictionary(object: userId, forKey: "userId")
//      var jsonData = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: nil);
//      
//      request.HTTPBody = jsonData;
      
      //var paramString = "userId=" + (userId as String)
      //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
      request.HTTPMethod = "GET"

      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   class func DeletePhotoWithCompletionBlock(photoId : String, success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/deleteGalleryPhoto?photoId=" + photoId)
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "GET"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   class func AddToGalleryWithCompletionBlock(image : UIImage, success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/addToGallery")
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "POST"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   
   
   class func forgotPasswordWithCompletionBlock(email : NSString,success: (task: NSURLSessionDataTask, responseObject: AnyObject) -> Void,failure: (task: NSURLSessionDataTask, error: NSError) -> Void){
      
      let parameters:Dictionary<String,AnyObject> = ["email": email]
      print(parameters)
      sharedSessionService.POST(baseUrl + "/general/passwordRecovery", parameters: parameters, success: {(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
         if ((responseObject) != nil) {
            success(task: task, responseObject: responseObject)
         }
         }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
            if (error != nil) {
               failure(task: task, error: error)
            }
      })
      
   }
   
   class func searchWithCompletionBlock(searchString : NSString, searchType : NSNumber,success: (responseObject: AnyObject) -> Void,failure: (error: NSError) -> Void){
      
      let parameters:Dictionary<String,AnyObject> = ["searchWord": searchString,"searchType": searchType ]
      print(parameters)
      let lgService=LoginServices.sharedLogininstance();
      
      let request:NSMutableURLRequest = NSMutableURLRequest()
      request.URL = NSURL(string: baseUrl + "/general/search")
      let options = NSJSONWritingOptions(rawValue: 0)
      do { try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: options)} catch { }
      request.setValue(lgService.authToken, forHTTPHeaderField: "authToken")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.HTTPMethod = "POST"
      
      let operation:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
      operation.responseSerializer = sharedSessionService.responseSerializer
      operation.setCompletionBlockWithSuccess(
         { (operation : AFHTTPRequestOperation!, responseObject) in
            success(responseObject: responseObject)
         },
         failure: { (operation, error) in
            failure(error: error)
         }
      )
      operation.start()
      
   }
   
   
    /**
    getProfileInfoWithCompletionBlock
    
    :param: success success user's profile information
    :param: failure failure error description
    */
    class  func getProfileInfoWithCompletionBlock(success: (task: NSURLSessionDataTask, responseObject: AnyObject) -> Void,
        failure: (task: NSURLSessionDataTask, error: NSError) -> Void) {
            
            sharedSessionService.GET(baseUrl+getProfileEndPoint, parameters: nil, success: {(task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                if ((responseObject) != nil) {
                    success(task: task, responseObject: responseObject)
                }
                }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
                    if (error != nil) {
                        failure(task: task, error: error)
                    }
            })
    }
    class func loginUserWithDetails(details:Dictionary<String, AnyObject>,success : ((AnyObject) -> Void)?,failure : ((NSError) -> Void)?) {
        
        sharedSessionService.POST("/api/login", parameters: details, success: { (sessionDataTask, response) -> Void in
            if success != nil {
                success!(response)
            }
        }) { (sessionDataTask, error) -> Void in
            if failure != nil {
                failure!(error)
            }
        }
    }
}