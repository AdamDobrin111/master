//
//  Dialog+Extention.m
//  Emeritus
//
//  Created by SB on 21/01/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "Dialog+Extention.h"

@implementation Dialog (Extention)

- (void)loadFromDictionaryHome:(QBChatMessage *)dictionary {

  self.dialogID = dictionary.dialogID;
  self.read = [NSNumber numberWithInteger:dictionary.read];
}

+ (Dialog *)findOrCreateDialogWithIdentifier:(NSString *)identifier
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
    Dialog *dialog = [self insertNewObjectIntoContext:context];
    dialog.dialogID = identifier;
    return dialog;
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
