//
//  Users+Extentions.h
//  Emeritus
//
//  Created by SB on 22/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Users.h"
#import <Quickblox/Quickblox.h>

@interface Users (Extentions)

- (void)loadFromDictionaryHome:(QBUUser *)dictionary;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (Users *)findOrCreateUsersWithIdentifier:(NSNumber *)identifier
                                 inContext:(NSManagedObjectContext *)context;
+ (id)entityName;

@end
