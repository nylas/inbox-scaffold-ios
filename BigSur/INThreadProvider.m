//
//  INThreadProvider.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThreadProvider.h"
#import "INAPIManager.h"
#import "INThread.h"
#import "INModelArrayResponseSerializer.h"
#import "INPredicateToQueryParamConverter.h"

@implementation INThreadProvider

- (id)initWithNamespaceID:(NSString *)namespaceID
{
	self = [super initWithClass:[INThread class] andNamespaceID:namespaceID andUnderlyingPredicate:nil];
	if (self) {
	}
	return self;
}

- (NSDictionary *)queryParamsForPredicate:(NSPredicate*)predicate
{
	INPredicateToQueryParamConverter * converter = [[INPredicateToQueryParamConverter alloc] init];
	[converter setKeysToParamsTable: @{@"to": @"to", @"from": @"from", @"cc": @"cc", @"bcc": @"bcc", @"threadID": @"thread", @"label": @"label"}];
	[converter setKeysToLIKEParamsTable: @{@"subject": @"subject"}];

	NSMutableDictionary * params = [[converter paramsForPredicate: predicate] mutableCopy];
	[params setObject:@(20) forKey:@"limit"];
	
	return params;
}

@end
