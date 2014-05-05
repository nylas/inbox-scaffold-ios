//
//  INMessage.m
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessage.h"
#import "NSString+FormatConversion.h"

@implementation INMessage


+ (NSMutableDictionary *)resourceMapping
{
	NSMutableDictionary * mapping = [super resourceMapping];
	[mapping addEntriesFromDictionary:@{
 	 @"subject": @"subject",
 	 @"body": @"body",
	 @"threadID": @"thread",
	 @"date": @"date",
	 @"from": @"from",
	 @"to": @"to"
	}];
	return mapping;
}

+ (NSString *)resourceAPIName
{
	return @"messages";
}

+ (NSArray *)databaseIndexProperties
{
	return [[super databaseIndexProperties] arrayByAddingObjectsFromArray: @[@"threadID", @"subject", @"date"]];
}

- (NSURL*)fromGravatarURL
{
	NSString * email = [[_from firstObject] objectForKey: @"email"];
    email = [[email stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSString * p = [NSString stringWithFormat: @"http://www.gravatar.com/avatar/%@?s=184", [email md5Value]];
	return [NSURL URLWithString: p];
}


@end
