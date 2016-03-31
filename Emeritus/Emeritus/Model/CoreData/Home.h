//
//  Home.h
//  Emeritus
//
//  Created by SB on 08/04/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Home : NSManagedObject

@property(nonatomic, retain) id chatRoom;
@property(nonatomic, retain) NSString *dialogID;
@property(nonatomic, retain) NSNumber *dialogOwner;
@property(nonatomic, retain) NSString *lastMessageText;
@property(nonatomic, retain) NSDate *lastMessageTimeStamp;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) id occupantIDs;
@property(nonatomic, retain) NSString *participantPhotoUrl;
@property(nonatomic, retain) NSNumber *recepientID;
@property(nonatomic, retain) NSString *roomJID;
@property(nonatomic, retain) NSNumber *type;
@property(nonatomic, retain) NSNumber *unreadMessageCount;
@property(nonatomic, retain) NSNumber *priority;
@property(nonatomic, retain) NSString *participants;
@property(nonatomic, retain) NSString *participantImages;

@property(nonatomic, retain) NSString *pollDescription;
@property(nonatomic, retain) NSString *pollTitle;

@end
