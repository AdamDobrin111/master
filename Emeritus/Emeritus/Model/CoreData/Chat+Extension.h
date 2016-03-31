//
//  Chat+Extension.h
//  Emeritus
//
//  Created by SB on 21/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Chat.h"
#import <Quickblox/Quickblox.h>

@interface Chat (Extension)

- (void)loadFromDictionaryHome:(QBChatMessage *)dictionary;
- (void)storeMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogID;
- (void)updateSendStatus:(BOOL)status;
- (void)updateThumnail:(NSData *)ImageData;

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (Chat *)findOrCreateChatWithIdentifier:(NSString *)identifier
                               inContext:(NSManagedObjectContext *)context;
+ (id)entityName;
- (void)updateIsAttachmentFlag:(BOOL)isAttached;
- (void)updateFileName:(NSString *)fileName;
- (void)updateAssetPath:(NSString *)assetPath;

@end
