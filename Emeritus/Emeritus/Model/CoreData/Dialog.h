//
//  Dialog.h
//  Emeritus
//
//  Created by SB on 21/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Dialog : NSManagedObject

@property(nonatomic, retain) NSString *dialogID;
@property(nonatomic, retain) NSNumber *read;
@property(nonatomic, retain) NSManagedObject *chat;

@end
