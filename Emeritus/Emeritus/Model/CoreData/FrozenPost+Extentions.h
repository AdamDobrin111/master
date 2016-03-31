//
//  FrozenPost+Extentions.h
//  Emeritus
//
//  Created by nikita on 1/11/16.
//  Copyright © 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

#import "FrozenPost.h"

@interface FrozenPost (Extentions)

- (void)loadFromDictionaryHome:(NSDictionary *)dictionary;

+ (FrozenPost *)findOrCreateUsersWithIdentifier:(NSNumber *)identifier
                                      inContext:(NSManagedObjectContext *)context;

+ (id)entityName;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end
