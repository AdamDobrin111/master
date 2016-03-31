//
//  FrozenPostManager.swift
//  Emeritus
//
//  Created by osc_mac on 2/12/16.
//  Copyright © 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

let kFrozenPostsRefresh:String = "kFrozenPostsRefresh"

import Foundation

private let sharedInstance = FrozenPostManager()
class FrozenPostManager: NSObject {

    static let sharedInstance = FrozenPostManager()
    let arrayFrozen:NSMutableArray = NSMutableArray()
    var frozenPostsCounts:Int = 0
    var fronzenPostsPreCounts:Int = 0
    var didFrozenPostsAppear:Bool = false
    
    class var sharedDispatchInstance: FrozenPostManager {
        struct Static {
            static var once_token:dispatch_once_t = 0
            static var instance:FrozenPostManager? = nil
        }
        dispatch_once(&Static.once_token){
            Static.instance = FrozenPostManager()
        }
        return Static.instance!
    }
    
    private override init() {
    }
    
    deinit{
        arrayFrozen.removeAllObjects()
    }
    
    func getFrozenPostsCount()->Int{
        frozenPostsCounts = arrayFrozen.count
        return frozenPostsCounts
    }
    
    func removeFrozenArray(){
        arrayFrozen.removeAllObjects()
    }
    
    func refreshForzenPosts(){
        NSNotificationCenter.defaultCenter().postNotificationName(kFrozenPostsRefresh, object: self, userInfo: nil)
    }
}
