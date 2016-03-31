//
//  Users+Extentions.m
//  Emeritus
//
//  Created by SB on 22/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Users+Extentions.h"

@implementation Users (Extentions)

- (void)loadFromDictionaryHome:(QBUUser *)dictionary {
    self.userID = [NSNumber numberWithInteger:dictionary.ID];
    self.userName = [NSString stringWithFormat:@"%lu", (unsigned long)dictionary.ID];
    self.emailID = dictionary.email;
}

+ (Users *)findOrCreateUsersWithIdentifier:(NSNumber *)identifier
                                 inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"userID = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Users *user = [self insertNewObjectIntoContext:context];
        user.userID = identifier;
        return user;
    }
}

+ (id)entityName {
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

@end
