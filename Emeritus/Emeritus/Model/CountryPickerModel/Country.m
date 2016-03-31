//
//  Country.m
//  Emeritus
//
//  Created by code-inspiration 1 on 8/27/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

#import "Country.h"

@implementation Country

- (id) initCountry: (NSString*)name withId:(NSNumber*)cId
{
    self = [super init];
    if( !self ) return nil;
    
    self.countryId = cId;
    self.countryName = name;
    
    return self;
}

@end
