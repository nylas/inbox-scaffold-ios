//
//  FMResultSet+INModelQueries.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "FMResultSet+INModelQueries.h"

@implementation FMResultSet (INModelQueries)

- (INModelObject*)nextModelOfClass:(Class)klass
{
    if ([klass isSubclassOfClass: [INModelObject class]] == NO)
        @throw @"Can only be used with subclasses of INModelObject";
    
    [self next];
    
    if (![self hasAnotherRow])
        return nil;
    
    NSDictionary * row = [self resultDictionary];
    if (row)
        return [klass attachedInstanceForResourceDictionary: row];
    else
        return nil;
}

@end
