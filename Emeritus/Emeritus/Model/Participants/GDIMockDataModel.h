//
//  GDIAppModel.h
//  GDIIndexBarDemo
//
//  Created by Grant Davis on 1/1/14.
//  Copyright (c) 2014 Grant Davis Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDIMockDataModel : NSObject {
  NSManagedObjectContext *_backgroundManagedObjectContext;
}
@property(nonatomic, strong) NSMutableDictionary *dictSections;
@property(nonatomic, strong) NSMutableArray *arrMainData;
@property(nonatomic, retain) NSMutableArray *namesFromHomePage;

@property(nonatomic, retain) NSMutableArray *namesFromDb;

/*!
 * Stores an array of strings under a section name as the key
 */
@property(strong, nonatomic) NSMutableDictionary *data;

/*!
 * Stores the strings used to create sections and provides the string used by
 * the index bar.
 */
@property(strong, nonatomic) NSMutableArray *sectionNames;

/*!
 * Stores the strings used to create sections and provides the string used by
 * the index bar.
 */
@property(strong, nonatomic) NSMutableArray *Names;
/*!
 * Stores the strings used to create sections and provides the string used by
 * the index bar.
 */
@property(strong, nonatomic) NSMutableArray *ImageUrls;

@property(nonatomic, retain) NSMutableDictionary *usenamesDictionary;

@property(nonatomic, retain) NSMutableDictionary *designations;

- (void)intialisingData;
- (void)fetchDataBasedOnfunctionfilter:(NSString *)functionName;
- (void)fetchDataBasedOncountryfilter:(NSString *)countryName;
- (void)fetchDataBasedOnindustryfilter:(NSString *)industryName;

- (void)searchedFetch:(NSString *)string;
- (void)resetData;

@end
