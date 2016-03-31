//
//  Poll+Extensions.m
//  Emeritus
//
//  Created by code-inspiration 1 on 9/9/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Poll+Extensions.h"

@implementation Poll (Extensions)

+ (id)entityName {
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (Poll *)findOrCreatePollWithIdentifier:(NSString *)identifier
                               inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"pollId = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Poll *poll = [self insertNewObjectIntoContext:context];
        poll.pollId = identifier;
        return poll;
    }
}

+ (Poll *)getPollById:(NSString *)surveyId
            inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"pollId = %@", surveyId];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        return nil;
    }
}

@end
