//
//  Users.h
//  Emeritus
//
//  Created by Krishna Kamath on 07/07/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

@class Chat;

@interface Users : NSManagedObject

@property(nonatomic, retain) NSString *address1;
@property(nonatomic, retain) NSString *address2;
@property(nonatomic, retain) NSString *city;
@property(nonatomic, retain) NSString *company;
@property(nonatomic, retain) NSNumber *country;
@property(nonatomic, retain) NSString *coverUrl;
@property(nonatomic, retain) NSString *designation;
@property(nonatomic, retain) NSDate *dob;
@property(nonatomic, retain) NSString *education;
@property(nonatomic, retain) NSString *emailID;
@property(nonatomic, retain) NSString *firstname;
@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSString *hobbies;
@property(nonatomic, retain) NSString *industry;
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, retain) NSString *pg;
@property(nonatomic, retain) NSString *phd;
@property(nonatomic, retain) NSString *plus2;
@property(nonatomic, retain) NSString *profileUrl;
@property(nonatomic, retain) NSNumber *qbID;
@property(nonatomic, retain) NSNumber *role;
@property(nonatomic, retain) NSString *school;
@property(nonatomic, retain) NSString *ug;
@property(nonatomic, retain) NSNumber *universityID;
@property(nonatomic, retain) NSString *universityName;
@property(nonatomic, retain) NSNumber *userID;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) Chat *chats;

@end
