//
//  INContact.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INContact.h"

@implementation INContact

+ (NSMutableDictionary *)resourceMapping
{
	NSMutableDictionary * mapping = [super resourceMapping];

	[mapping addEntriesFromDictionary:@{
		@"source": @"source",
		@"name": @"name",
		@"providerName": @"provider_name",
		@"emailAddress": @"email_address",
		@"accountId": @"account_id",
		@"uid": @"uid"
	}];
	return mapping;
}

+ (NSArray *)databaseIndexProperties
{
	return @[@"name", @"emailAddress", @"accountId"];
}

- (void)setup
{}

- (NSString *)APIPath
{
	NSString * ID = self.ID ? self.ID : @"";

	return [NSString stringWithFormat:@"/n/%@/contacts/%@", self.namespaceID, ID];
}

@end
