//
//  Poll+Extensions.h
//  Emeritus
//
//  Created by code-inspiration 1 on 9/9/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Poll.h"

@interface Poll (Extensions)

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (id)entityName;
+ (Poll *)findOrCreatePollWithIdentifier:(NSNumber *)identifier
                               inContext:(NSManagedObjectContext *)context;
+ (Poll *)getPollById:(NSString *)surveyId
            inContext:(NSManagedObjectContext *)context;
@end
