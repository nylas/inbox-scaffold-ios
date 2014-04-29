//
//  INAPICall.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAPIOperation.h"
#import "INAPIManager.h"
#import "INModelObject.h"
#import "INModelObject+Uniquing.h"

@implementation INAPIOperation

+ (INAPIOperation *)operationWithMethod:(NSString *)method forModel:(INModelObject *)model
{
	NSString * url = [[NSURL URLWithString:[model APIPath] relativeToURL:[INAPIManager shared].baseURL] absoluteString];
	NSError * error = nil;
	NSURLRequest * request = [[[INAPIManager shared] requestSerializer] requestWithMethod:method URLString:url parameters:[model resourceDictionary] error:&error];

	if (!error) {
		return [[INAPIOperation alloc] initWithRequest:request];
	}
	else {
		NSLog(@"Unable to create INAPIOperation for saving %@. %@", [model description], [error localizedDescription]);
		return nil;
	}
}

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
	self = [super initWithRequest:urlRequest];

	if (self)
		[self setupCallbacks];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self)
		[self setupCallbacks];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
}

- (void)setupCallbacks
{
	INAPIOperation * __weak __weakSelf = self;

	[self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
		[[NSNotificationCenter defaultCenter] postNotificationName:INAPIOperationCompleteNotification object:__weakSelf userInfo:@{@"success": @(YES)}];
	} failure:^(AFHTTPRequestOperation * operation, NSError * error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:INAPIOperationCompleteNotification object:__weakSelf userInfo:@{@"success": @(NO), @"error": error}];
	}];
}

- (BOOL)invalidatesPreviousQueuedOperation:(AFHTTPRequestOperation *)other
{
	BOOL bothPut = ([[[other request] HTTPMethod] isEqualToString:@"PUT"] && [[[self request] HTTPMethod] isEqualToString:@"PUT"]);
	BOOL bothSamePath = [[[other request] URL] isEqual:[[self request] URL]];

	if (bothPut && bothSamePath)
		return YES;

	return NO;
}

@end
