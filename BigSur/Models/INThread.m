//
//  INThread.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThread.h"

@implementation INThread

+ (NSMutableDictionary *)resourceMapping
{
    NSMutableDictionary * mapping = [super resourceMapping];
    [mapping addEntriesFromDictionary: @{
     @"subject": @"subject",
     @"participants": @"participants",
     @"lastMessageDate": @"last_message_timestamp"
    }];
    return mapping;
}

+ (NSArray*)databaseIndexProperties
{
    return @[@"lastMessageDate"];
}


@end
