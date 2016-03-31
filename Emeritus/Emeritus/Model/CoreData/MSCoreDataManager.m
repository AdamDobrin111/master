//
//  MSCoreDataManager.m
//  Emeritus
//
//  Created by SB on 19/03/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "MSCoreDataManager.h"
#import "Emeritus-Swift.h"
#import "ChatService.h"
#import <Quickblox/Quickblox.h>

#define kModelName @"Emeritus"
#define kStoreName @"Emeritus"

@interface MSCoreDataManager (Helpers)

/**
 * Creates a new managedObject of the given type and keeps
 * threading into account. If called from the mainThread
 * it uses the parentContext. If called from a background thread
 * it uses the childContext. Here the assumption is made that you
 * only perform coredata calls using the performBlock: functions.
 * If not, another background thread may be used which is not
 * tied to the child context. Therefore, if you have to perform
 * a large operation on the background, always use performBlock:
 * on the childContext
 *
 * @param type Entity of the managedObject to create
 * @result Newly created managedObject
 */
- (NSManagedObject *)newManagedObjectOfType:(NSString *)type;

/**
 * Performs a synchronous fetchRequest. Selects the correct
 * managedObjectContext using the same technique as described in
 * the newManagedObjectOfType: function
 *
 * @param type Entity to fetch
 * @param fetchRequestChangeBlock Here you can make modifications to the
 *fetchRequest (e.g. adding predicates, setting batch sizes, etc)
 * @result Result of the fetchRequest
 */
- (NSArray *)entitiesOfType:(NSString *)type
withFetchRequestChangeBlock:
(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock;

/**
 * Does the same as entitiesOfType:withFetchRequestChangeBlock: but also
 * contains a completionBlock because the request is performed asynchronously.
 *
 * @param type Entity to fetch
 * @param fetchRequestChangeBlock Here you can make modifications to the
 *fetchRequest (e.g. adding predicates, setting batch sizes, etc)
 * @param completionBlock Block which is executed after a result has been
 *obtained.
 */
- (void)entitiesOfType:(NSString *)type
withFetchRequestChangeBlock:
(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock
   withCompletionBlock:(void (^)(NSArray *))completionBlock;

/**
 * Makes sure that the array of given managedObjects
 * is tied to the parentManagedObjectContext
 *
 * @param managedObjects Array of NSManagedObjects to convert the the
 *parentContext
 * @result Converted objects
 */
- (NSArray *)convertManagedObjectsToMainContext:(NSArray *)managedObjects;

/**
 * Returns the application its documents directory
 *
 * @return URL
 */
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation MSCoreDataManager (Helpers)

#pragma mark - Applications Documents Directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Generic Object Functions

- (NSManagedObject *)newManagedObjectOfType:(NSString *)type {
    NSManagedObjectContext *managedObjectContext =
    [NSThread isMainThread] ? _parentContext : _childContext;
    
    NSEntityDescription *entityDescription =
    [NSEntityDescription entityForName:type
                inManagedObjectContext:managedObjectContext];
    if (entityDescription == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    Class class = NSClassFromString(type);
    if (class == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"ClassType does not exist"
                                     userInfo:nil];
    
    return [[class alloc] initWithEntity:entityDescription
          insertIntoManagedObjectContext:managedObjectContext];
}

- (NSArray *)entitiesOfType:(NSString *)type
withFetchRequestChangeBlock:
(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock {
    NSManagedObjectContext *managedObjectContext =
    [NSThread isMainThread] ? _parentContext : _childContext;
    
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:type];
    if (fetchRequest == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    if (fetchRequestChangeBlock != nil)
        fetchRequest = fetchRequestChangeBlock(fetchRequest);
    
    __block NSError *error = nil;
    __block NSArray *result = nil;
    [managedObjectContext performBlockAndWait:^{
        result =
        [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    if (error != nil) {
        NSLog(@"Error while fetching results: %@", error);
        return nil;
    }
    
    return result;
}

- (void)entitiesOfType:(NSString *)type
withFetchRequestChangeBlock:
(NSFetchRequest * (^)(NSFetchRequest *))fetchRequestChangeBlock
   withCompletionBlock:(void (^)(NSArray *))completionBlock {
    
    if (completionBlock == nil)
        return;
    
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:type];
    if (fetchRequest == nil)
        @throw [NSException exceptionWithName:@"CoreDataException"
                                       reason:@"EntityType does not exist"
                                     userInfo:nil];
    
    if (fetchRequestChangeBlock != nil)
        fetchRequest = fetchRequestChangeBlock(fetchRequest);
    
    [_childContext performBlock:^{
        NSError *error = nil;
        NSArray *result =
        [_childContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            NSLog(@"Error while fetching background results: %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil);
            });
        }
        
        result = [self convertManagedObjectsToMainContext:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(result);
        });
    }];
}

- (NSArray *)convertManagedObjectsToMainContext:(NSArray *)managedObjects {
    // convert the products to the mainObjectContext
    if ([managedObjects count] > 0) {
        NSMutableArray *mainObjects =
        [NSMutableArray arrayWithCapacity:[managedObjects count]];
        for (NSManagedObject *object in managedObjects) {
            if (![object isKindOfClass:[NSManagedObject class]])
                @throw [NSException
                        exceptionWithName:@"CoreDataException"
                        reason:@"Error while converting objects, must be a "
                        @"NSManagedObject"
                        userInfo:[NSDictionary dictionaryWithObject:object
                                                             forKey:@"Object"]];
            
            NSManagedObjectID *objectId = [object objectID];
            [mainObjects addObject:[_parentContext objectWithID:objectId]];
        }
        
        return [NSArray arrayWithArray:mainObjects];
    }
    
    return managedObjects;
}

@end

@implementation MSCoreDataManager
+ (id)sharedCoreDataInstance {
    static MSCoreDataManager *cdManager = Nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cdManager = [[MSCoreDataManager alloc] init];
        [cdManager coreDataSetupOnce];
    });
    return cdManager;
}
- (void)coreDataSetupOnce {
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //selector:@selector(reachabilityChanged)
    //name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    // Create NSManagedObjectModel and NSPersistentStoreCoordinator
    NSURL *modelURL =
    [[NSBundle mainBundle] URLForResource:kModelName withExtension:@"momd"];
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",
                                                    kStoreName]];
    NSLog(@"store url %@", storeURL);
    
    //    // remove old store if exists
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    if ([fileManager fileExistsAtPath:[storeURL path]])
    //        [fileManager removeItemAtURL:storeURL error:nil];
    
    NSManagedObjectModel *model =
    [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *storeCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:storeURL
                                         options:options
                                           error:nil];
    
    // create the parent NSManagedObjectContext with the concurrency type to
    // NSMainQueueConcurrencyType
    _parentContext = [[NSManagedObjectContext alloc]
                      initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_parentContext setPersistentStoreCoordinator:storeCoordinator];
    
    // creat the child one with concurrency type NSPrivateQueueConcurrenyType
    _childContext = [[NSManagedObjectContext alloc]
                     initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_childContext setParentContext:_parentContext];
}
- (BOOL)deleteDatabase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(
                                                                  NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [directoryPaths objectAtIndex:0];
    NSString *databasePath = [filePath
                              stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",
                                                              kStoreName]];
    if ([fileManager fileExistsAtPath:databasePath] == YES) {
        
        [fileManager removeItemAtPath:databasePath error:nil];
        return YES;
    } else {
        
        return NO;
    }
}

- (void)read {
    // nt using
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K==%@", @"sent", @"1"];
    fr.predicate = predicate;
    NSError *err;
    NSArray *arr = [_parentContext executeFetchRequest:fr error:&err];
    NSLog(@"%@", arr);
}

- (void)deleteChatIncontext:(NSManagedObjectContext *)deleteContext
                   dialogID:(NSString *)strDialogID {
    // not using
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K==%@", @"dialogID", strDialogID];
    fr.predicate = predicate;
    NSError *err;
    NSArray *arr = [deleteContext executeFetchRequest:fr error:&err];
    if (arr.count > 0) {
        NSLog(@"%@", arr);
    }
    [deleteContext performBlock:^{
        for (NSManagedObject *objChat in arr) {
            Chat *objC = (Chat *)objChat;
            NSLog(@"value obj sent::%@", [objC valueForKey:@"sent"]);
            NSLog(@"value obj sent::%@", [objC valueForKey:@"dialogID"]);
            [deleteContext deleteObject:objChat];
            [deleteContext save:nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.parentContext save:nil];
            });
        }
    }];
}

- (void)reachabilityChanged {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LoginStatus"]) {
        
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginStatus"]
              isEqualToString:@"YES"])) {
            
            [[LoginServices sharedLogininstance] fetchFromUserDefaults];
            [[SessionService instance]
             createSession:[LoginServices sharedLogininstance].qbuserName
             AndPassword:[LoginServices sharedLogininstance].password
             withCompletionBlock:^(BOOL status){
                 
                 //
                 //                [[ChatService
                 //                instance]loginWithUser:[LocalStorageService
                 //                shared].currentUser completionBlock:^{
                 //
                 //                    //[self readAndUpdateToServerOnCompletion];
                 //                    [self deleteGrpRecord];
                 //                }];
                 
             }];
        }
    }
}

- (void)insertChatItems:(NSMutableArray *)dialogs {
    if ( dialogs == nil )
    {
        return;
    }
    if (dialogs.count != 0) {
        MSCoreDataManager *cdManagher = [MSCoreDataManager sharedCoreDataInstance];
        [cdManagher.childContext performBlock:^{
            
            for (NSDictionary *lobjDialog in dialogs) {
                
                NSLog(@"dictionary %@", lobjDialog);
                Home *home =
                [Home findOrCreateHomeWithIdentifier:[lobjDialog objectForKey:@"id"]
                                           inContext:cdManagher.childContext];
                [home loadFromDictionaryHome:lobjDialog];
            }
            
            NSError *error;
            [cdManagher.childContext save:&error];
            [cdManagher.parentContext save:&error];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Homefeed"
                                                                object:self
                                                              userInfo:nil];
        }];
        
    } else {
    }
}

- (void)fecthingTheUserProfileDetails:(NSNumber *)userId
                 withresponseCallback:(void (^)(Users *userdetails))callback {
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K==%@", @"userID", userId];
    fr.predicate = predicate;
    NSError *err;
    NSArray *arr = [_parentContext executeFetchRequest:fr error:&err];
    if (arr.count > 0) {
        
        Users *userDetails = (Users *)arr.firstObject;
        callback(userDetails);
    }
}
- (void)fecthingTheUserProfileDetailsWith:(NSNumber *)qbId
                     withresponseCallback:
(void (^)(Users *userdetails))callback {
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"%K==%@", @"qbID", qbId];
    fr.predicate = predicate;
    NSError *err;
    NSArray *arr = [_parentContext executeFetchRequest:fr error:&err];
    if (arr.count > 0) {
        
        Users *userDetails = (Users *)arr.firstObject;
        callback(userDetails);
    }
}

- (void)updateUserDetails:(NSDictionary *)userDetails {
    
    [self.childContext performBlock:^{
        //            Users *usr=[Users findOrCreateUsersWithIdentifier:[NSNumber
        //            numberWithInteger:[[dict objectForKey:@"qb_ID"] integerValue]]
        //            inContext:self.childContext];
        
        NSDictionary *dict = userDetails;
        // NSString *dateString = [dict objectForKey:@"dob"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSFetchRequest *fetchRequest =
        [NSFetchRequest fetchRequestWithEntityName:@"Users"];
        fetchRequest.predicate = [NSPredicate
                                  predicateWithFormat:
                                  @"userID = %@",
                                  [NSNumber
                                   numberWithInteger:[[dict objectForKey:@"id"] integerValue]]];
        NSError *error = nil;
        NSArray *result =
        [self.childContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        NSManagedObject *obj;
        if (result.lastObject) {
            obj = result.lastObject;
        } else {
            obj = [[NSManagedObject
                    alloc] initWithEntity:
                   [NSEntityDescription entityForName:@"Users"
                               inManagedObjectContext:self.childContext]
                   insertIntoManagedObjectContext:self.childContext];
        }
        
        if ([NSNull null] != [dict objectForKey:@"qbId"]) {
            
            [obj setValue:[NSNumber numberWithInteger:
                           [[dict objectForKey:@"qbId"] integerValue]]
                   forKey:@"qbID"];
        }
        if ([dict objectForKey:@"address1"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"address1"] forKey:@"address1"];
        }
        if ([dict objectForKey:@"countryId"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"countryId"] forKey:@"country"];
        }
        if ([dict objectForKey:@"address2"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"address2"] forKey:@"address2"];
        }
        if ([dict objectForKey:@"company"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"company"] forKey:@"company"];
        }
        if ([dict objectForKey:@"designation"] == [NSNull null]) {
            [obj setValue:@"" forKey:@"designation"];
        } else {
            [obj setValue:[dict objectForKey:@"designation"] forKey:@"designation"];
        }
        if ([dict objectForKey:@"industry"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"industry"] forKey:@"industry"];
        }
        if ([dict objectForKey:@"education"] == [NSNull null]) {
            [obj setValue:@"" forKey:@"education"];
        } else {
            [obj setValue:[dict objectForKey:@"education"] forKey:@"education"];
        }
        [obj setValue:[dict objectForKey:@"firstName"] forKey:@"firstname"];
        if ([dict objectForKey:@"gender"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"gender"] forKey:@"gender"];
        }
        if ([dict objectForKey:@"hobbies"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"hobbies"] forKey:@"hobbies"];
        }
        if ([dict objectForKey:@"language"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"language"] forKey:@"language"];
        }
        if ([dict objectForKey:@"lastName"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"lastName"] forKey:@"lastName"];
        }
        if ([dict objectForKey:@"pg"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"pg"] forKey:@"pg"];
        }
        if ([dict objectForKey:@"phd"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"phd"] forKey:@"phd"];
        }
        if ([dict objectForKey:@"plus2"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"plus2"] forKey:@"plus2"];
        }
        if ([dict objectForKey:@"school"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"school"] forKey:@"school"];
        }
        if ([dict objectForKey:@"city"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"city"] forKey:@"city"];
        }
        if ([dict objectForKey:@"ug"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"ug"] forKey:@"ug"];
        }
        if ([dict objectForKey:@"universityName"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"universityName"]
                   forKey:@"universityName"];
        }
        if ([dict objectForKey:@"universityId"] != [NSNull null]) {
            [obj setValue:[NSNumber
                           numberWithInteger:
                           [[dict objectForKey:@"universityId"] integerValue]]
                   forKey:@"universityID"];
        }
        if ([dict objectForKey:@"id"] != [NSNull null]) {
            [obj setValue:[NSNumber numberWithInteger:
                           [[dict objectForKey:@"id"] integerValue]]
                   forKey:@"userID"];
        }
        if ([dict objectForKey:@"username"] != [NSNull null]) {
            [obj setValue:[dict objectForKey:@"username"] forKey:@"userName"];
        }
        if ([dict objectForKey:@"profilePhotoId"]) {
            [obj setValue:[NSString
                           stringWithFormat:@"http://52.22.22.151:8080/"
                           @"api/file/%@/%@?type=2",
                           [dict objectForKey:@"id"],
                           [dict objectForKey:@"profilePhotoId"]]
                   forKey:@"profileUrl"];
        }
        if ([dict objectForKey:@"coverPhotoId"]) {
            [obj setValue:[NSString
                           stringWithFormat:@"http://52.22.22.151:8080/"
                           @"api/file/%@/%@?type=1",
                           [dict objectForKey:@"id"],
                           [dict objectForKey:@"coverPhotoId"]]
                   forKey:@"coverUrl"];
        }
        NSLog(@"%@", [obj valueForKey:@"firstname"]);
        
        [self.childContext save:nil];
        [self.parentContext save:nil];
    }];
    //    [self.parentContext performBlock:^{
    //        [self.parentContext save:nil];
    //    }];
}
- (NSMutableArray *)getParticipantsInfo {
    NSMutableArray *arrDetail = [NSMutableArray array];
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSError *error = nil;
    NSArray *result =
    [self.childContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result) {
        arrDetail = [NSMutableArray arrayWithArray:result];
    }
    
    NSFetchRequest *fetchRequestForSeldId =
    [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    fetchRequestForSeldId.predicate = [NSPredicate
                                       predicateWithFormat:@"qbID == %@", [[NSUserDefaults standardUserDefaults]
                                                                           objectForKey:@"SessionUserId"]];
    NSError *error1 = nil;
    NSArray *resultSelf =
    [self.childContext executeFetchRequest:fetchRequestForSeldId
                                     error:&error1];
    if (error1) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (resultSelf) {
        if ([arrDetail containsObject:resultSelf.lastObject]) {
            [arrDetail removeObject:resultSelf.lastObject];
        }
    }
    return arrDetail;
}
- (void)insertParticipants:(NSDictionary *)dictParticipants {
    
    NSArray *arr = [dictParticipants objectForKey:@"response"];
    
    if (arr != [NSNull null]) {
        //    for (NSDictionary *dict in arr) {
        [self.childContext performBlock:^{
            for (int i = 0; i < [arr count]; i++) {
                //            Users *usr=[Users
                //            findOrCreateUsersWithIdentifier:[NSNumber
                //            numberWithInteger:[[dict objectForKey:@"qb_ID"]
                //            integerValue]] inContext:self.childContext];
                
                NSDictionary *dict = [arr objectAtIndex:i];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                // NSDate * dateFromString = [dateFormatter dateFromString:dateString];
                
                NSFetchRequest *fetchRequest =
                [NSFetchRequest fetchRequestWithEntityName:@"Users"];
                fetchRequest.predicate = [NSPredicate
                                          predicateWithFormat:
                                          @"userID = %@",
                                          [NSNumber numberWithInteger:
                                           [[dict objectForKey:@"id"] integerValue]]];
                NSError *error = nil;
                NSArray *result =
                [self.childContext executeFetchRequest:fetchRequest error:&error];
                
                if (error) {
                    NSLog(@"error: %@", error.localizedDescription);
                }
                NSManagedObject *obj;
                if (result.lastObject) {
                    obj = result.lastObject;
                } else {
                    obj = [[NSManagedObject alloc]
                           initWithEntity:
                           [NSEntityDescription
                            entityForName:@"Users"
                            inManagedObjectContext:self.childContext]
                           insertIntoManagedObjectContext:self.childContext];
                }
                
                if ([NSNull null] != [dict objectForKey:@"qbId"]) {
                    
                    [obj
                     setValue:[NSNumber numberWithInteger:
                               [[dict objectForKey:@"qbId"] integerValue]]
                     forKey:@"qbID"];
                }
                
                if ([dict objectForKey:@"email"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"email"] forKey:@"emailID"];
                }
                if ([dict objectForKey:@"address1"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"address1"] forKey:@"address1"];
                }
                if ([dict objectForKey:@"countryId"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"countryId"] forKey:@"country"];
                }
                if ([dict objectForKey:@"address2"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"address2"] forKey:@"address2"];
                }
                if ([dict objectForKey:@"company"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"company"] forKey:@"company"];
                }
                if ([dict objectForKey:@"designation"] == [NSNull null]) {
                    [obj setValue:@"" forKey:@"designation"];
                } else {
                    [obj setValue:[dict objectForKey:@"designation"]
                           forKey:@"designation"];
                }
                if ([dict objectForKey:@"industry"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"industry"] forKey:@"industry"];
                }
                if ([dict objectForKey:@"education"] == [NSNull null]) {
                    [obj setValue:@"" forKey:@"education"];
                } else {
                    [obj setValue:[dict objectForKey:@"education"] forKey:@"education"];
                }
                [obj setValue:[dict objectForKey:@"firstName"] forKey:@"firstname"];
                if ([dict objectForKey:@"gender"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"gender"] forKey:@"gender"];
                }
                if ([dict objectForKey:@"hobbies"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"hobbies"] forKey:@"hobbies"];
                }
                if ([dict objectForKey:@"language"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"language"] forKey:@"language"];
                }
                if ([dict objectForKey:@"lastName"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"lastName"] forKey:@"lastName"];
                }
                if ([dict objectForKey:@"pg"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"pg"] forKey:@"pg"];
                }
                if ([dict objectForKey:@"phd"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"phd"] forKey:@"phd"];
                }
                if ([dict objectForKey:@"plus2"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"plus2"] forKey:@"plus2"];
                }
                if ([dict objectForKey:@"school"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"school"] forKey:@"school"];
                }
                if ([dict objectForKey:@"city"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"city"] forKey:@"city"];
                }
                if ([dict objectForKey:@"ug"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"ug"] forKey:@"ug"];
                }
                if ([dict objectForKey:@"universityName"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"universityName"]
                           forKey:@"universityName"];
                }
                if ([dict objectForKey:@"universityId"] != [NSNull null]) {
                    [obj setValue:
                     [NSNumber
                      numberWithInteger:
                      [[dict objectForKey:@"universityId"] integerValue]]
                           forKey:@"universityID"];
                }
                if ([dict objectForKey:@"id"] != [NSNull null]) {
                    [obj setValue:[NSNumber numberWithInteger:
                                   [[dict objectForKey:@"id"] integerValue]]
                           forKey:@"userID"];
                }
                if ([dict objectForKey:@"username"] != [NSNull null]) {
                    [obj setValue:[dict objectForKey:@"username"] forKey:@"userName"];
                }
                if ([dict objectForKey:@"profilePhotoId"]) {
                    [obj setValue:[NSString stringWithFormat:
                                   @"http://52.22.22.151:8080/"
                                   @"api/file/%@/%@?type=2",
                                   [dict objectForKey:@"id"],
                                   [dict objectForKey:@"profilePhotoId"]]
                           forKey:@"profileUrl"];
                }
                if ([dict objectForKey:@"coverPhotoId"]) {
                    [obj setValue:[NSString stringWithFormat:
                                   @"http://52.22.22.151:8080/"
                                   @"api/file/%@/%@?type=1",
                                   [dict objectForKey:@"id"],
                                   [dict objectForKey:@"coverPhotoId"]]
                           forKey:@"coverUrl"];
                }
                [obj setValue:[NSNumber numberWithInteger:
                               [[dict objectForKey:@"role"] integerValue]]
                       forKey:@"role"];
                
                //               if([QBSession currentSession].sessionDetails.userID ==
                //               [[dict objectForKey:@"qb_ID"] integerValue])
                //               {
                //
                //               }
            }
            
            [self.childContext save:nil];
            [self.parentContext save:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserDetailsUpdated"
             object:self
             userInfo:nil];
        }];
    }
    // self.userID = [NSNumber numberWithInteger:dictionary.ID];
    //    self.userName = [NSString stringWithFormat:@"%d",dictionary.ID];
    //    self.emailID =
}

- (Users *)viewProfile:(NSNumber *)qbID {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"qbID = %@", qbID];
    NSError *error = nil;
    NSArray *result =
    [self.childContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    NSLog(@"kek %@", result.lastObject);
    return result.lastObject;
}

- (void)saveDeleteDiagPlistRecord {
    AppDelegate *appDelegate =
    (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.arrDelete.count > 0) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *plistPath =
        [documentsDirectory stringByAppendingPathComponent:@"delete.plist"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath =
            [documentsDirectory stringByAppendingPathComponent:@"delete.plist"];
        }
        
        NSMutableArray *arrData;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            arrData = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
            [appDelegate.arrDelete addObjectsFromArray:arrData];
        } else {
            // If the file doesn’t exist, create an empty dictionary
            arrData = [[NSMutableArray alloc] init];
        }
        
        // To insert the data into the plist
        
        [appDelegate.arrDelete writeToFile:plistPath atomically:YES];
        
        // To reterive the data from the plist
        //        NSMutableDictionary *savedValue = [[NSMutableDictionary alloc]
        //        initWithContentsOfFile: path];
        //        NSString *value = [savedValue objectForKey:@"value"];
        //        NSLog(@"%@",value);
    }
}
- (void)deleteGrpRecord {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *plistPath =
    [documentsDirectory stringByAppendingPathComponent:@"delete.plist"];
    // To reterive the data from the plist
    NSArray *savedValue = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    for (int i = 0; i < savedValue.count; i++) {
        NSString *strDiagID = [savedValue objectAtIndex:i];
        NSLog(@"%@", strDiagID);
        //[QBChat deleteDialogWithID:strDiagID delegate:self];
        
        //        NSFetchRequest *fr = [NSFetchRequest
        //        fetchRequestWithEntityName:@"Home"];
        //        NSPredicate *predicate=[NSPredicate
        //        predicateWithFormat:@"%K==%@",@"dialogID",strDiagID];
        //        fr.predicate=predicate;
        //        NSError *err;
        //        NSArray *arr=[_parentContext executeFetchRequest:fr error:&err];
        //        if (arr.count>0) {
        //            NSLog(@"%@",arr);
        //        }
        //
        //        for (NSManagedObject *objChat in arr) {
        //            Chat *objC=(Chat*)objChat;
        //            [self.parentContext performBlock:^{
        //                [self.parentContext deleteObject:objC];
        //                [self.parentContext save:nil];
        //            }];
        //        }
        // delete plist
    }
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
}

//#pragma MarK- QBAction Delegate Methods
//-(void)completedWithResult:(QBResult *)result
//{
//    if (result.success) {
//
//        NSLog(@"Deleted");
//        [[NSNotificationCenter
//        defaultCenter]postNotificationName:@"KDeleteReload" object:nil];
//    }
//}

@end
