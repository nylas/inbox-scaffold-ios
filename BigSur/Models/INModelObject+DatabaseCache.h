//
//  INModelObject+DatabaseCache.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"

@interface INModelObject (DatabaseCache)

#pragma Database Representation

+ (NSString *)databaseTableName;
+ (NSArray *)databaseIndexProperties;

+ (void)persistedInstancesMatching:(NSPredicate *)wherePredicate sortedBy:(NSArray *)sortDescriptors limit:(int)limit offset:(int)offset withCallback:(ResultsBlock)callback;
+ (void)persistedInstancesForQuery:(NSString *)query withParameters:(NSDictionary *)arguments andCallback:(ResultsBlock)callback;

- (void)persist;

@end
