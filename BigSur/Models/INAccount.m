//
//  INUser.m
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAccount.h"
#import "INNamespace.h"

@implementation INAccount


+ (NSMutableDictionary *)resourceMapping
{
	NSMutableDictionary * mapping = [super resourceMapping];
	[mapping addEntriesFromDictionary:@{
	 @"namespaceIDs": @"namespaces",
	 @"name": @"name",
	 @"authToken": @"auth_token"
	}];
	return mapping;
}

+ (NSArray *)databaseIndexProperties
{
	return @[];
}

- (NSArray*)namespaces
{
	NSMutableArray * namespaces = [NSMutableArray array];
	for (NSString * ID in _namespaceIDs) {
		[namespaces addObject: [INNamespace instanceWithID: ID]];
	}
	return namespaces;
}
@end
