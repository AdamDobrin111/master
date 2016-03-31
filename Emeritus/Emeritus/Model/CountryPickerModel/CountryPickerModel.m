//
//  CountryPickerModel.m
//  Emeritus
//
//  Created by code-inspiration 1 on 8/27/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "CountryPickerModel.h"
#import "Country.h"

@implementation CountryPickerModel

+ (instancetype)sharedInstance {
    static id instance_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
        [instance_ initData];
    });
    
    return instance_;
}

- (void)initData {
    self.countryArray = [[NSMutableArray alloc] init];
}

- (void)addCountryFromDictionary:(NSDictionary *)dictionary {
    [self.countryArray addObject:[[Country alloc] initCountry:dictionary[@"name"] withId:dictionary[@"id"]]];
}

- (NSString *)countryNameFromId:(NSString *)countryId {
    for (int i = 0; i < self.countryArray.count; i++) {
        Country *country = self.countryArray[i];
        
        if ([country.countryId.stringValue isEqualToString:countryId]) {
            return country.countryName;
        }
    }
    return @"";
}

@end
