//
//  Country.h
//  Emeritus
//
//  Created by code-inspiration 1 on 8/27/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject

- (id) initCountry: (NSString*)name withId:(NSNumber*)cId;

@property (strong, nonatomic) NSNumber * countryId;
@property (strong, nonatomic) NSString *countryName;

@end
