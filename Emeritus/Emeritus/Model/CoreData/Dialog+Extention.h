//
//  Dialog+Extention.h
//  Emeritus
//
//  Created by SB on 21/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Dialog.h"
#import <Quickblox/Quickblox.h>

@interface Dialog (Extention)

- (void)loadFromDictionaryHome:(QBChatMessage *)dictionary;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (Dialog *)findOrCreateDialogWithIdentifier:(NSString *)identifier
                                   inContext:(NSManagedObjectContext *)context;
+ (id)entityName;

@end
