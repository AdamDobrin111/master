//
//  PollAnswer+Extensions.h
//  Emeritus
//
//  Created by code-inspiration 1 on 9/9/15.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights
//  reserved.
//

#import "PollAnswer.h"

@interface PollAnswer (Extensions)

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;
+ (id)entityName;
+ (PollAnswer *)findOrCreatePollAnswerWithIdentifier:(NSString *)identifier
                                           inContext:(NSManagedObjectContext *)
                                                         context;
+ (NSArray *)getAnswersBySurveyId:(NSString *)surveyId
                        inContext:(NSManagedObjectContext *)context;
+ (void)incrementCountOfAnsweredById:(NSInteger)answerId
                           inContext:(NSManagedObjectContext *)context;

@end
