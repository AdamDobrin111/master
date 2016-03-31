//
//  OnlineUsers.h
//  Emeritus
//
//  Created by code-inspiration 1 on 8/4/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

@interface OnlineUsers : NSObject

+ (instancetype)sharedInstance;

@property(strong, nonatomic) NSMutableDictionary *onlineDictionary;
@property(strong, nonatomic) NSTimer *timer;

- (NSNumber *)getUserStatus:(NSNumber *)userId;

- (long)getUserLastCheck:(NSNumber *)userId;

- (void)save:(NSNumber *)userId
      status:(NSNumber *)status
   lastCheck:(NSNumber *)lastCheck;

@end
