//
//  FrozenPost+Extentions.m
//  Emeritus
//
//  Created by nikita on 1/11/16.
//  Copyright © 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

#import "FrozenPost+Extentions.h"

@implementation FrozenPost (Extentions)

- (void)loadFromDictionaryHome:(NSDictionary *)dictionary {
    
}

+ (FrozenPost *)findOrCreateUsersWithIdentifier:(NSNumber *)identifier
                                 inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"postId = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        FrozenPost *post = [self insertNewObjectIntoContext:context];
        post.postId = identifier;
        return post;
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
