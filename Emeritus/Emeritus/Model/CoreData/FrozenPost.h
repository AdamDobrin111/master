//
//  FrozenPost.h
//  Emeritus
//
//  Created by nikita on 1/11/16.
//  Copyright © 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrozenPost : NSManagedObject

@property(nonatomic, retain) NSNumber *postId;
@property(nonatomic, retain) NSString *shortDesc;
@property(nonatomic, retain) NSString *longDesc;
@property(nonatomic, retain) NSDate *endDate;
@property(nonatomic, retain) NSMutableArray *arrayForzen;

@end
