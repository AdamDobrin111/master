//
//  GDIAppModel.m
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import "GDIMockDataModel.h"

#import "Users.h"
#import "Users+Extentions.h"
#import "Emeritus-Swift.h"
#import <Quickblox/Quickblox.h>

@interface GDIMockDataModel () {

  NSMutableDictionary *dictMainData;
  //    NSMutableDictionary *dictSections;
  // NSMutableDictionary *dictTableDataSource;
}
@end

@implementation GDIMockDataModel

- (id)init {
  self = [super init];
  if (self) {
    self.namesFromDb = [[NSMutableArray alloc] init];
  }
  return self;
}
- (void)intialisingData {
  self.namesFromDb = [NSMutableArray array];
  self.usenamesDictionary = [NSMutableDictionary dictionary];
  self.ImageUrls = [NSMutableArray array];
  self.designations = [NSMutableDictionary dictionary];
  [self fetchingUserDetails];
  //    [self createMockData];
}
- (void)resetData {
  self.namesFromDb = [NSMutableArray array];
  self.usenamesDictionary = [NSMutableDictionary dictionary];
  self.ImageUrls = [NSMutableArray array];
  self.designations = [NSMutableDictionary dictionary];
  self.sectionNames = [NSMutableArray array];
}
- (void)createMockData {
  self.namesFromHomePage = [NSMutableArray array];
  self.data = [NSMutableDictionary dictionary];
  self.sectionNames = [NSMutableArray array];
  self.Names = [NSMutableArray array];
  NSLog(@" name  %@", self.namesFromDb);
  // self.Names = [names mutableCopy];
  // break the names into alphabetical groups
  [self.namesFromDb enumerateObjectsUsingBlock:^(NSString *lobjname,
                                                 NSUInteger idx, BOOL *stop) {
    NSString *firstLetter = [lobjname substringToIndex:1];
    NSMutableArray *namesByFirstLetter;

    if ([self.data objectForKey:firstLetter] == nil) {
      namesByFirstLetter = [NSMutableArray array];
      [self.data setObject:namesByFirstLetter forKey:firstLetter];
      [self.sectionNames addObject:firstLetter];
    } else {
      namesByFirstLetter = [self.data objectForKey:firstLetter];
    }

    [namesByFirstLetter addObject:lobjname];
    //[self.Names addObject:name];
  }];

  // sort the groups
  NSArray *nameLists = [self.data allValues];
  [nameLists enumerateObjectsUsingBlock:^(NSMutableArray *namesByFirstLetter,
                                          NSUInteger idx, BOOL *stop) {
    [namesByFirstLetter
        sortUsingComparator:^NSComparisonResult(NSString *name1,
                                                NSString *name2) {
          return [name1 compare:name2];
        }];
  }];
  NSLog(@"array %@", self.Names);
  self.Names = [nameLists mutableCopy];
  // sort the names
  [self.sectionNames sortUsingComparator:^NSComparisonResult(NSString *name1,
                                                             NSString *name2) {
    return [name1 compare:name2];
  }];

  //    [self.Names
  //    sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  //     NSLog(@"array %@",self.Names);
  //    [self.Names sortUsingComparator:^NSComparisonResult(NSString *name1,
  //    NSString *name2) {
  //        return [name1 compare:name2];
  //    }];

  self.dictSections = [NSMutableDictionary dictionary];
  [dictMainData enumerateKeysAndObjectsUsingBlock:^(id key, id obj,
                                                    BOOL *stop) {
    NSString *firstLetter =
        [[[obj objectForKey:@"firstname"] substringToIndex:1] uppercaseString];
    NSMutableArray *namesByFirstLetter;
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithObject:obj forKey:key];
    if ([self.dictSections objectForKey:firstLetter] == nil) {
      namesByFirstLetter = [NSMutableArray array];
      [self.dictSections setObject:namesByFirstLetter forKey:firstLetter];
    } else {
      namesByFirstLetter = [self.dictSections objectForKey:firstLetter];
    }

    [namesByFirstLetter addObject:dict];
  }];

  _arrMainData = [NSMutableArray array];
  NSArray *sortedKeys = [[self.dictSections allKeys]
      sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (NSString *str in sortedKeys) {
    [_arrMainData addObject:[self.dictSections objectForKey:str]];
  }
}

- (void)fetchingUserDetails {

  dictMainData = [NSMutableDictionary dictionary];
  NSString *entityName = Users.entityName;
  NSFetchRequest *request =
      [[NSFetchRequest alloc] initWithEntityName:entityName];
  NSError *error = nil;

  MSCoreDataManager *cdManager = [MSCoreDataManager sharedCoreDataInstance];
  //    arryOfUsers=(NSMutableArray *)[delegate.backgroundContext
  //    executeFetchRequest:request error:&error];
  NSMutableArray *arryOfUsers = (NSMutableArray *)
      [cdManager.childContext executeFetchRequest:request error:&error];

  //    for (Users *lobjuser in arryOfUsers) {
  for (int index = 0; index < arryOfUsers.count; index++) {
    Users *lobjuser = [arryOfUsers objectAtIndex:index];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSLog(@"user id %@", lobjuser.qbID);
    NSLog(@"current session id %@",
          [NSNumber numberWithInteger:[QBSession currentSession]
                                          .sessionDetails.userID]);

    if (lobjuser.qbID.integerValue !=
        [NSNumber
            numberWithInteger:[QBSession currentSession].sessionDetails.userID]
            .integerValue) {
      if (lobjuser.firstname != nil) {
        [self.namesFromDb addObject:lobjuser.firstname];
        [self.usenamesDictionary setObject:lobjuser.qbID
                                    forKey:lobjuser.firstname];
        [self.designations setObject:lobjuser.designation
                              forKey:lobjuser.firstname];

        [dict setObject:lobjuser.firstname forKey:@"firstname"];
        [dict setObject:lobjuser.qbID forKey:@"qbID"];
        [dict setObject:lobjuser.designation forKey:@"designation"];
          if (lobjuser.company != nil)
          {
              [dict setObject:lobjuser.company forKey:@"company"];
          }
          if (lobjuser.lastName != nil)
          {
              [dict setObject:lobjuser.lastName forKey:@"lastName"];
          }
          if (lobjuser.country != nil)
          {
              [dict setObject:lobjuser.country forKey:@"country"];
          }
          if (lobjuser.city != nil)
          {
              [dict setObject:lobjuser.city forKey:@"city"];
          }
      }
      if ((lobjuser.profileUrl != nil)) {

        [self.ImageUrls addObject:lobjuser.profileUrl];
        [dict setObject:lobjuser.profileUrl forKey:@"imgUrl"];
      } else {
        [self.ImageUrls addObject:@""];
        [dict setObject:@"" forKey:@"imgUrl"];
      }
      if (lobjuser.firstname != nil) {
        [dictMainData setObject:dict forKey:lobjuser.firstname];
      }
      //            [arrMainData addObject:dict];
    }
  }

  [self createMockData];
}
- (void)searchedFetch:(NSString *)string {
  dictMainData = [NSMutableDictionary dictionary];
  NSString *entityName = Users.entityName;
  NSFetchRequest *request =
      [[NSFetchRequest alloc] initWithEntityName:entityName];
  NSPredicate *predi =
      [NSPredicate predicateWithFormat:@"firstname==%@", string];
  [request setPredicate:predi];
  NSError *error = nil;

  MSCoreDataManager *cdManager = [MSCoreDataManager sharedCoreDataInstance];
  //    arryOfUsers=(NSMutableArray *)[delegate.backgroundContext
  //    executeFetchRequest:request error:&error];
  NSMutableArray *arryOfUsers = (NSMutableArray *)
      [cdManager.childContext executeFetchRequest:request error:&error];

  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  for (Users *lobjuser in arryOfUsers) {

    NSLog(@"user id %@", lobjuser.qbID);
    NSLog(@"current session id %@",
          [NSNumber numberWithInteger:[QBSession currentSession]
                                          .sessionDetails.userID]);

    if (lobjuser.qbID.integerValue !=
        [NSNumber
            numberWithInteger:[QBSession currentSession].sessionDetails.userID]
            .integerValue) {
      if (lobjuser.firstname != nil) {
        [self.namesFromDb addObject:lobjuser.firstname];
        [self.usenamesDictionary setObject:lobjuser.qbID
                                    forKey:lobjuser.firstname];
        [self.designations setObject:lobjuser.designation
                              forKey:lobjuser.firstname];

        [dict setObject:lobjuser.firstname forKey:@"firstname"];
        [dict setObject:lobjuser.qbID forKey:@"qbID"];
        [dict setObject:lobjuser.designation forKey:@"designation"];
          if (lobjuser.company != nil)
          {
              [dict setObject:lobjuser.company forKey:@"company"];
          }
          if (lobjuser.lastName != nil)
          {
              [dict setObject:lobjuser.lastName forKey:@"lastName"];
          }
          if (lobjuser.country != nil)
          {
              [dict setObject:lobjuser.country forKey:@"country"];
          }
          if (lobjuser.city != nil)
          {
              [dict setObject:lobjuser.city forKey:@"city"];
          }
      }
      if ((lobjuser.profileUrl != nil)) {

        [self.ImageUrls addObject:lobjuser.profileUrl];
        [dict setObject:lobjuser.profileUrl forKey:@"imgUrl"];
      } else {
        [self.ImageUrls addObject:@""];
        [dict setObject:@"" forKey:@"imgUrl"];
      }
      if (lobjuser.firstname != nil) {
        [dictMainData setObject:dict forKey:lobjuser.firstname];
      }
    }
  }
  [self createMockData];
}

- (void)fetchDataBasedOnfunctionfilter:(NSString *)functionName {
  NSLog(@"Fetch the users based on Function");
}
- (void)fetchDataBasedOncountryfilter:(NSString *)countryName {
  NSLog(@"Fetch the users based on country");
}
- (void)fetchDataBasedOnindustryfilter:(NSString *)industryName {
  NSLog(@"Fetch the users based on industry");
}

@end
