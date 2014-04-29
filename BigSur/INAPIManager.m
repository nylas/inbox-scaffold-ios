//
//  INAPIManager.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAPIManager.h"
#import "INAPIOperation.h"
#import "NSObject+AssociatedObjects.h"

#if DEBUG
  #define API_URL		[NSURL URLWithString:@"http://localhost/"]
#else
  #define API_URL		[NSURL URLWithString:@"http://localhost/"]
#endif

#define OPERATIONS_FILE [@"~/cache/operations.plist" stringByExpandingTildeInPath]

@implementation INAPIManager

+ (INAPIManager *)shared
{
	static INAPIManager * sharedManager = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedManager = [[INAPIManager alloc] initWithBaseURL:API_URL];
		[sharedManager setResponseSerializer:[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments]];
		[sharedManager setRequestSerializer:[AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted]];
		[sharedManager loadOperations];
	});
	return sharedManager;
}

- (void)loadOperations
{
	NSArray * operations = [NSKeyedUnarchiver unarchiveObjectWithFile:OPERATIONS_FILE];

	// restore only INAPIOperations
	for (AFHTTPRequestOperation * operation in operations)
		if ([operation isKindOfClass:[INAPIOperation class]])
			[self.operationQueue addOperation:operation];
}

- (void)saveOperations
{
	NSArray * operations = self.operationQueue.operations;

	if (![NSKeyedArchiver archiveRootObject:operations toFile:OPERATIONS_FILE])
		NSLog(@"Writing operations to disk failed?");
}

- (void)queueAPIOperation:(INAPIOperation *)operation
{
	operation.responseSerializer = self.responseSerializer;
	operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
	operation.credential = self.credential;
	operation.securityPolicy = self.securityPolicy;

	NSOperationQueue * queue = self.operationQueue;

	for (int ii = [queue operationCount] - 1; ii >= 0; ii--) {
		AFHTTPRequestOperation * existing = [[queue operations] objectAtIndex:ii];

		if ([operation invalidatesPreviousQueuedOperation:existing])
			[existing cancel];
	}

	[self.operationQueue addOperation:operation];
	[self performSelectorOnMainThreadOnce:@selector(saveOperations)];
}

@end
