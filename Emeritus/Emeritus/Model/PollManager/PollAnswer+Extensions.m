//
//  PollAnswer+Extensions.m
//  Emeritus
//
//  Created by code-inspiration 1 on 9/9/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "PollAnswer+Extensions.h"

@implementation PollAnswer (Extensions)

+ (id)entityName {
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (PollAnswer *)findOrCreatePollAnswerWithIdentifier:(NSString *)identifier
                                           inContext:(NSManagedObjectContext *)
context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"answerId = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        PollAnswer *pollAnswer = [self insertNewObjectIntoContext:context];
        pollAnswer.answerId = identifier;
        return pollAnswer;
    }
}

+ (NSArray *)getAnswersBySurveyId:(NSString *)surveyId
                        inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"surveyId = %@", surveyId];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result) {
        
        NSArray *sortedArray =
        [result sortedArrayUsingComparator:^NSComparisonResult(PollAnswer *p1,
                                                               PollAnswer *p2) {
            
            return [p1.answerId compare:p2.answerId];
            
        }];
        
        return sortedArray;
    } else {
        return nil;
    }
}

+ (void)incrementCountOfAnsweredById:(NSInteger)answerId
                           inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate
                              predicateWithFormat:@"answerId = %@", [NSNumber numberWithInt:answerId]];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    PollAnswer *answer = result.lastObject;
    int value = [answer.count intValue];
    answer.count = [NSNumber numberWithInt:value + 1];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
}

@end
