//
//  PollAnswer.h
//  Emeritus
//
//  Created by code-inspiration 1 on 8/14/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

@interface PollAnswer : NSObject

@property(retain, nonatomic) NSString *answerId;
@property(retain, nonatomic) NSString *text;
@property(retain, nonatomic) NSString *surveyId;
@property(retain, nonatomic) NSNumber *count;

@end
