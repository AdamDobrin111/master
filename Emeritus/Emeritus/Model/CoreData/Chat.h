//
//  Chat.h
//  Emeritus
//
//  Created by SB on 25/02/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dialog, Users;

@interface Chat : NSManagedObject

@property(nonatomic, retain) NSString *assetPath;
@property(nonatomic, retain) NSString *attachmentID;
@property(nonatomic, retain) NSString *attachmentType;
@property(nonatomic, retain) NSString *attachmentUrl;
@property(nonatomic, retain) NSString *chatID;
@property(nonatomic, retain) NSString *chatText;
@property(nonatomic, retain) id customParameter;
@property(nonatomic, retain) NSDate *dateTime;
@property(nonatomic, retain) NSString *dialogID;
@property(nonatomic, retain) NSString *fileContentType;
@property(nonatomic, retain) NSString *fileName;
@property(nonatomic, retain) NSNumber *isAttachmentExists;
@property(nonatomic, retain) NSNumber *recipientID;
@property(nonatomic, retain) NSNumber *senderID;
@property(nonatomic, retain) NSNumber *sent;
@property(nonatomic, retain) NSData *thumbNail;
@property(nonatomic, retain) NSString *mediaType;
@property(nonatomic, retain) Dialog *dialogs;
@property(nonatomic, retain) Users *users;

@end
