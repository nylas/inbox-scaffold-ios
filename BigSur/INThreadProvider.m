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

@implementation INThreadProvider

- (id)initWithNamespace:(INNamespace *)namespace
{
	self = [super init];

	if (self) {
		[self setModelClass:[INThread class]];
		[self setNamespace:namespace];
	}
	return self;
}

- (NSDictionary *)fetchQueryParamsForPredicate
{
	// TODO
	return @{};
}

- (void)fetchFromAPI
{
	NSString * path = [[_namespace APIPath] stringByAppendingPathComponent:@"threads"];
	NSDictionary * params = [self fetchQueryParamsForPredicate];

	AFHTTPRequestOperation * operation = [[INAPIManager shared] GET:path parameters:params success:^(AFHTTPRequestOperation * operation, NSArray * threads) {
		self.items = [threads sortedArrayUsingDescriptors:self.sortDescriptors];

		if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)])
			[self.delegate providerDataRefreshed];

	} failure:^(AFHTTPRequestOperation * operation, NSError * error) {
		if ([self.delegate respondsToSelector:@selector(providerDataFetchFailed:)])
			[self.delegate providerDataFetchFailed:error];
	}];

	INModelArrayResponseSerializer * serializer = [[INModelArrayResponseSerializer alloc] initWithModelClass:self.modelClass];
	[operation setResponseSerializer:serializer];
}

@end
