//
//  CountryPickerModel.h
//  Emeritus
//
//  Created by code-inspiration 1 on 8/27/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import <Foundation/Foundation.h>

@interface CountryPickerModel : NSObject

@property(strong, nonatomic) NSMutableArray *countryArray;
@property(strong, nonatomic) NSMutableDictionary *countryDict;

- (void)initData;

- (void)addCountryFromDictionary:(NSDictionary *)dictionary;

- (NSString *)countryNameFromId:(NSString *)countryId;

+ (instancetype)sharedInstance;

@end
