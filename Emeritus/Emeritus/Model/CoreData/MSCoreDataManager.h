//
//  MSCoreDataManager.h
//  Emeritus
//
//  Created by SB  on 19/03/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "Chat+Extension.h"
#import "Users+Extentions.h"

@interface MSCoreDataManager : NSObject {
  NSManagedObjectContext *_parentContext; // parent managedObjectContext tied to
                                          // the persistent store coordinator
  NSManagedObjectContext *_childContext;  // child managedObjectContext whichs
                                          // runs in a background thread
}

@property(strong, nonatomic) NSManagedObjectContext *parentContext;
@property(strong, nonatomic) NSManagedObjectContext *childContext;

+ (id)sharedCoreDataInstance;
- (void)coreDataSetupOnce;
- (BOOL)deleteDatabase;
- (void)deleteChatIncontext:(NSManagedObjectContext *)deleteContext
                   dialogID:(NSString *)strDialogID;

- (NSMutableArray *)getParticipantsInfo;
- (void)insertParticipants:(NSDictionary *)dictParticipants;
- (Users *)viewProfile:(NSNumber *)qbID;
- (void)insertChatItems:(NSMutableArray *)chatItems;
- (void)updateUserDetails:(NSDictionary *)userDetails;
- (void)fecthingTheUserProfileDetails:(NSNumber *)userId
                 withresponseCallback:(void (^)(Users *userdetails))callback;
- (void)fecthingTheUserProfileDetailsWith:(NSNumber *)qbId
                     withresponseCallback:
                         (void (^)(Users *userdetails))callback;
- (void)saveDeleteDiagPlistRecord;
- (void)deleteGrpRecord;
- (void)reachabilityChanged;

@end
