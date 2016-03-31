//
//  Home+Extensions.m
//  Emeritus
//
//  Created by SB on 16/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Home+Extensions.h"
#import "MSWebManager.h"

#define kHomeTimeLineListVCRefreshKey  @"k_hometimelinelist_VC_refresh"

@implementation Home (Extensions)

- (void)loadFromDictionaryHome:(NSDictionary *)dictionary {
  MSWebManager *manager = [MSWebManager sharedWebInstance];

  // need to add the code here..
  NSString *allParticiPants = [[NSString alloc] init];
  NSString *allParticiPantsImagesUrls = [[NSString alloc] init];
  self.dialogOwner = [NSNumber
      numberWithInteger:[[dictionary objectForKey:@"userId"] integerValue]];
  self.priority = [NSNumber
      numberWithInteger:[[dictionary objectForKey:@"priority"] integerValue]];
  if ([dictionary objectForKey:@"lastMessage"] != [NSNull null]) {
    self.lastMessageText = [dictionary objectForKey:@"lastMessage"];
  }
  if ([dictionary objectForKey:@"roomJid"] != [NSNull null]) {
    QBChatDialog *roomObj =
        [[QBChatDialog alloc] initWithDialogID:[dictionary objectForKey:@"id"]
                                          type:QBChatDialogTypeGroup];
    self.roomJID = [dictionary objectForKey:@"roomJid"];
    self.chatRoom = roomObj;
  } else {
    QBChatDialog *roomObj =
        [[QBChatDialog alloc] initWithDialogID:[dictionary objectForKey:@"id"]
                                          type:QBChatDialogTypePrivate];
    // self.roomJID=[dictionary objectForKey:@"roomJid"];
    self.chatRoom = roomObj;
  }
  if ([dictionary objectForKey:@"photo"] != [NSNull null]) {
    self.participantPhotoUrl = [dictionary objectForKey:@"photo"];
  }
  if ([dictionary objectForKey:@"name"] != [NSNull null]) {
    self.name = [dictionary objectForKey:@"name"];
  }
  if ([[dictionary objectForKey:@"type"] integerValue] ==
      3) // type=3 Means one to one chat
  {
    if ([dictionary objectForKey:@"participants"] != [NSNull null]) {
      NSArray *participants = [dictionary objectForKey:@"participants"];
      for (NSNumber *participant in participants) {
        if (participant.integerValue !=
            [NSNumber numberWithInteger:[QBSession currentSession]
                                            .sessionDetails.userID]
                .integerValue) {
          self.recepientID =
              [NSNumber numberWithInteger:[participant integerValue]];
          NSLog(@"receipt id %@", self.recepientID);
        }
      }
    }

  } else {
    if ([dictionary objectForKey:@"participants"] != [NSNull null]) {
      int index = 0;

      NSArray *participants = [dictionary objectForKey:@"participants"];
      for (NSNumber *participant in participants) {
        index = index + 1;
        if (index == participants.count) {

          if (participant.integerValue !=
              [NSNumber numberWithInteger:[QBSession currentSession]
                                              .sessionDetails.userID]
                  .integerValue) {
            allParticiPants = [allParticiPants
                stringByAppendingString:
                    [NSString stringWithFormat:@"%ld",
                                               (long)participant.integerValue]];
          }

        } else {
          if (participant.integerValue !=
              [NSNumber numberWithInteger:[QBSession currentSession]
                                              .sessionDetails.userID]
                  .integerValue) {
            allParticiPants = [allParticiPants
                stringByAppendingString:
                    [NSString stringWithFormat:@"%ld%@",
                                               (long)participant.integerValue,
                                               @","]];
          }
        }
      }
    }

    if ([dictionary objectForKey:@"participantsImages"] != [NSNull null]) {
      int index = 0;

      NSArray *participantImages =
          [dictionary objectForKey:@"participantsImages"];
      for (NSString *participantImageurl in participantImages) {
        index = index + 1;

        if (index == participantImages.count) {

          if ([participantImageurl isEqualToString:@""]) {

            allParticiPantsImagesUrls = [allParticiPantsImagesUrls
                stringByAppendingString:
                    [NSString stringWithFormat:@"%@", participantImageurl]];

          } else {
            allParticiPantsImagesUrls = [allParticiPantsImagesUrls
                stringByAppendingString:
                    [NSString stringWithFormat:@"%@%@",
                                               manager.baseUrlForImages,
                                               participantImageurl]];
          }

        } else {
          if ([participantImageurl isEqualToString:@""]) {

            allParticiPantsImagesUrls = [allParticiPantsImagesUrls
                stringByAppendingString:
                    [NSString
                        stringWithFormat:@"%@%@", participantImageurl, @","]];

          } else {
            allParticiPantsImagesUrls = [allParticiPantsImagesUrls
                stringByAppendingString:
                    [NSString stringWithFormat:@"%@%@%@",
                                               manager.baseUrlForImages,
                                               participantImageurl, @","]];
          }
        }
      }
    }
  }
  self.participants = allParticiPants;
  self.participantImages = allParticiPantsImagesUrls;
  self.dialogID = [dictionary objectForKey:@"id"];
    
    NSLog(@"home extension dialog ID is %@", self.dialogID);
    NSSet* dialogIDs = [NSSet setWithObject:self.dialogID];
    [QBRequest totalUnreadMessageCountForDialogsWithIDs:dialogIDs successBlock:^(QBResponse * _Nonnull response, NSUInteger count, NSDictionary<NSString *,id> * _Nullable dialogs) {
       
        NSLog(@"Success, total count of messages:%lu", (unsigned long)count);
        NSDictionary *dict = (NSDictionary *)response.data;
        NSNumber *n = [dict valueForKey:self.dialogID];
        self.unreadMessageCount = n;
        
        NSLog(@"%@", [dict description]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeTimeLineListVCRefreshKey object:nil];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        NSLog(@"unread msg erro!!!");
        
    }];
    
//
//    [QBRequest countOfMessagesForDialogID:self.dialogID
//                          extendedRequest:NULL successBlock:^(QBResponse * _Nonnull response, NSUInteger count) {
//        
//        NSLog(@"Success, total count of messages:%lu", (unsigned long)count);
//        self.unreadMessageCount = [NSNumber numberWithInteger:count];
//        
//    } errorBlock:^(QBResponse * _Nonnull response) {
//        
//        NSLog(@"unread msg erro!!!");
//        
//    }];
    
//    self.unreadMessageCount = [NSNumber numberWithInteger:[[dictionary objectForKey:@"unread"] integerValue]];
    
  self.type = [NSNumber
      numberWithInteger:[[dictionary objectForKey:@"type"] integerValue]];

  if ([dictionary objectForKey:@"lastMessageDate"] != [NSNull null]) {

    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateStyle:NSDateFormatterFullStyle];

    NSDate *lastMessagedate =
        [NSDate dateWithTimeIntervalSince1970:
                    [[dictionary objectForKey:@"lastMessageDate"] doubleValue]];
    self.lastMessageTimeStamp = lastMessagedate;
  }
}

- (void)storeMessage:(QBChatMessage *)message {
  self.lastMessageText = message.text;
  self.lastMessageTimeStamp = message.dateSent;
}

+ (Home *)findOrCreateHomeWithIdentifier:(NSString *)identifier
                               inContext:(NSManagedObjectContext *)context {
  NSFetchRequest *fetchRequest =
      [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
  fetchRequest.predicate =
      [NSPredicate predicateWithFormat:@"dialogID = %@", identifier];
  NSError *error = nil;
  NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
  if (error) {
    NSLog(@"error: %@", error.localizedDescription);
  }
  if (result.lastObject) {
    return result.lastObject;
  } else {
    Home *home = [self insertNewObjectIntoContext:context];
    home.dialogID = identifier;
    return home;
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
