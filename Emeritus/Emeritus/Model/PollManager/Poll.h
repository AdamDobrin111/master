//
//  Poll.h
//  Emeritus
//
//  Created by code-inspiration 1 on 9/7/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property(retain, nonatomic) NSString *pollId;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSNumber *circleId;
@property(retain, nonatomic) NSString *pollDescription;
@property(retain, nonatomic) NSString *type;
@property(retain, nonatomic) NSString *imageURL;

@end
