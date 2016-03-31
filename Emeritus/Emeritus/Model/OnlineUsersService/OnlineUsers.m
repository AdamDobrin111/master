//
//  OnlineUsers.m
//  Emeritus
//
//  Created by code-inspiration 1 on 8/4/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "OnlineUsers.h"

@implementation OnlineUsers

+ (instancetype)sharedInstance {
    static id instance_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
        [instance_ startTimer];
    });
    
    return instance_;
}

- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:60
                                              target:self
                                            selector:@selector(resetData)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)resetData {
    self.onlineDictionary = [[NSMutableDictionary alloc] init];
}

- (NSNumber *)getUserStatus:(NSNumber *)userId {
    if (self.onlineDictionary != nil) {
        NSDictionary *dict = self.onlineDictionary[userId];
        if (dict != nil) {
            return [dict valueForKey:@"status"];
        }
    }
    
    return 0;
}

- (long)getUserLastCheck:(NSNumber *)userId {
    if (self.onlineDictionary != nil) {
        NSDictionary *dict = self.onlineDictionary[userId];
        if (dict != nil) {
            return (long)[dict valueForKey:@"lastCheck"];
        }
    }
    
    return 0;
}

- (void)save:(NSNumber *)userId
      status:(NSNumber *)status
   lastCheck:(NSNumber *)lastCheck {
    if (self.onlineDictionary == nil) {
        self.onlineDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *dict = [[NSDictionary alloc]
                          initWithObjectsAndKeys:status, @"status", lastCheck, @"lastCheck", nil];
    
    [self.onlineDictionary setObject:dict forKey:userId];
}
@end
