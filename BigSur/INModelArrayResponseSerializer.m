//
//  INModelArrayResponseSerializer.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelArrayResponseSerializer.h"
#import "INModelObject.h"
#import "INModelObject+DatabaseCache.h"
#import "INModelObject+Uniquing.h"
#import "NSObject+AssociatedObjects.h"
#import "INDatabaseManager.h"

#define ALREADY_PARSED_RESPONSE @"model-response-parsed"

@implementation INModelArrayResponseSerializer

- (id)initWithModelClass:(Class)klass
{
	self = [super init];

	if (self) {
		_modelClass = klass;
		self.readingOptions = NSJSONReadingAllowFragments;
	}
	return self;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error
{
	if (![super validateResponse:response data:data error:error])
		return NO;

	id responseObject = [super responseObjectForResponse:response data:data error:error];

	if (!responseObject)
		return NO;

	[response associateValue:responseObject withKey:ALREADY_PARSED_RESPONSE];

	BOOL wrongJSONClass = ([responseObject isKindOfClass:[NSArray class]] == NO);

	if (wrongJSONClass) {
		*error = [NSError errorWithDomain:@"IN" code:100 userInfo:@{NSLocalizedDescriptionKey: @"The JSON object returned was not an NSArray"}];
		return NO;
	}

	return YES;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error
{
	NSArray * responseObject = [response associatedValueForKey:ALREADY_PARSED_RESPONSE];

	if (!responseObject) responseObject = [super responseObjectForResponse:response data:data error:error];

	NSMutableArray * models = [NSMutableArray array];

	for (NSDictionary * modelDictionary in responseObject) {
		INModelObject * object = [_modelClass instanceWithResourceDictionary:modelDictionary];

		if (object)
			[models addObject:object];
	}

	[[INDatabaseManager shared] persistModels:models];
	return models;
}

@end
