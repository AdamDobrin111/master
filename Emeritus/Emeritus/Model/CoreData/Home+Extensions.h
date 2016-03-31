//
//  Home+Extensions.h
//  Emeritus
//
//  Created by SB on 16/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Home.h"
#import <Quickblox/Quickblox.h>

@interface Home (Extensions)

//- (void)loadFromDictionaryHome:(QBChatDialog *)dictionary;
- (void)loadFromDictionaryHome:(NSDictionary *)dictionary;

- (void)storeMessage:(QBChatMessage *)message;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (Home *)findOrCreateHomeWithIdentifier:(NSString *)identifier
                               inContext:(NSManagedObjectContext *)context;
+ (id)entityName;

@end
