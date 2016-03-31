//
//  Chat+Extension.m
//  Emeritus
//
//  Created by SB on 21/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Chat+Extension.h"

@implementation Chat (Extension)

- (void)loadFromDictionaryHome:(QBChatMessage *)dictionary {
    self.chatID = dictionary.ID;
    self.chatText = dictionary.text;
    self.recipientID = [NSNumber numberWithInteger:dictionary.recipientID];
    self.senderID = [NSNumber numberWithInteger:dictionary.senderID];
    self.dateTime = dictionary.dateSent;
    self.customParameter = dictionary.customParameters;
    self.dialogID = dictionary.dialogID;
    
    for (id object in dictionary.attachments) {
        QBChatAttachment *attachment = (QBChatAttachment *)object;
        self.attachmentID = attachment.ID;
        self.attachmentUrl = attachment.url;
        self.attachmentType = attachment.type;
    }
}

- (void)storeMessage:(QBChatMessage *)message forDialogId:(NSString *)dialogID {
    self.chatID = message.ID;
    self.chatText = message.text;
    self.recipientID = [NSNumber numberWithInteger:message.recipientID];
    self.senderID = [NSNumber numberWithInteger:message.senderID];
    self.dateTime = message.dateSent;
    self.customParameter = message.customParameters;
    self.dialogID = dialogID;
    
    for (id object in message.attachments) {
        QBChatAttachment *attachment = (QBChatAttachment *)object;
        self.attachmentID = attachment.ID;
        self.attachmentUrl = attachment.url;
        self.attachmentType = attachment.type;
    }
}

- (void)updateFileName:(NSString *)fileName {
    self.fileName = fileName;
}
- (void)updateAssetPath:(NSString *)assetPath {
    self.assetPath = assetPath;
}

- (void)updateIsAttachmentFlag:(BOOL)isAttached {
    
    self.isAttachmentExists = [NSNumber numberWithInteger:isAttached];
}

- (void)updateThumnail:(NSData *)ImageData {
    
    self.thumbNail = ImageData;
}

- (void)updateSendStatus:(BOOL)status {
    self.sent = [NSNumber numberWithInteger:status];
}

+ (Chat *)findOrCreateChatWithIdentifier:(NSString *)identifier
                               inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"chatID = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Chat *chat = [self insertNewObjectIntoContext:context];
        chat.chatID = identifier;
        return chat;
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
