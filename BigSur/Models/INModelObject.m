//
//  INModelObject.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"
#import "INModelObject+Uniquing.h"
#import "INAPIManager.h"
#import "INAPIOperation.h"
#import "NSObject+Properties.h"
#import "NSString+FormatConversion.h"
#import "INPredicateConverter.h"
#import "INDatabaseManager.h"


@implementation INModelObject

#pragma Getting Instances

+ (id)instanceWithID:(NSString*)ID
{
	// do we have an instance in memory that matches this ID?
	INModelObject __block * match = [self attachedInstanceMatchingID: ID];

	// do we have an instance in the local cache?
	if (!match) {
		[[INDatabaseManager shared] selectModelsOfClass:self matching:[NSPredicate predicateWithFormat:@"ID = %@", ID] sortedBy:nil limit:1 offset:0 withCallback:^(NSArray *objects) {
			match = [objects firstObject];
		}];
	}
	
	// this object is not available. Return a stub and start loading it. The consumer should
	// subscribe to notifications on this object to update their UI when data is available.
	if (!match) {
		match = [[self alloc] init];
		[match setID: ID];
		[match reload: NULL];
	}
	
	return match;
}

#pragma NSCoding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];

	if (self) {
		NSDictionary * mapping = [[self class] resourceMapping];
		[self setEachPropertyInSet:[mapping allKeys] withValueProvider:^BOOL (id key, NSObject ** value, NSString * type) {
			if (![aDecoder containsValueForKey:key])
				return NO;

			*value = [aDecoder decodeObjectForKey:key];
			return YES;
		}];

		[self setup];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	NSDictionary * mapping = [[self class] resourceMapping];

	[self getEachPropertyInSet:[mapping allKeys] andInvoke:^(id key, NSString * type, id value) {
		BOOL encodable = [value respondsToSelector:@selector(encodeWithCoder:)];

		if (encodable)
			[aCoder encodeObject:value forKey:key];
		else if (value)
			NSLog(@"Value of %@ (%@) does not comply to NSCoding.", key, [value description]);
	}];
}

#pragma mark Resource Representation

- (NSMutableDictionary *)resourceDictionary
{
	NSDictionary * mapping = [[self class] resourceMapping];
	NSMutableDictionary * json = [NSMutableDictionary dictionary];

	[self getEachPropertyInSet:[mapping allKeys] andInvoke:^(id key, NSString * type, id value) {
		if ([value isKindOfClass:[INModelObject class]])
			return;

		if ([value isKindOfClass:[NSDate class]])
			value = [NSString stringWithDate:(NSDate *)value format:API_TIMESTAMP_FORMAT];

		if ([value isKindOfClass:[NSArray class]])
			value = [value componentsJoinedByString:@","];

		NSString * jsonKey = [mapping objectForKey:key];

		if (value)
			[json setObject:value forKey:jsonKey];
		else
			[json setObject:[NSNull null] forKey:jsonKey];
	}];

	return json;
}

- (void)updateWithResourceDictionary:(NSDictionary *)json
{
	NSDictionary * mapping = [[self class] resourceMapping];
	NSArray * properties = [mapping allKeys];

	if ([json isKindOfClass:[NSDictionary class]] == NO) {
		NSLog(@"updateWithResourceDictionary called with json that is not a dictionary");
		return;
	}

	[self setEachPropertyInSet:properties withValueProvider:^BOOL (id key, NSObject ** value, NSString * type) {
		NSString * jsonKey = [mapping objectForKey:key];

		if (![json objectForKey:jsonKey])
			return NO;

		if ([[json objectForKey:jsonKey] isKindOfClass:[NSNull class]]) {
			*value = nil;
			return YES;
		}

		if ([type isEqualToString:@"float"]) {
			*value = [NSNumber numberWithFloat:[[json objectForKey:jsonKey] floatValue]];
		}
		else if ([type isEqualToString:@"int"]) {
			*value = [NSNumber numberWithInt:[[json objectForKey:jsonKey] intValue]];
		}
		else if ([type isEqualToString:@"T@\"NSString\""]) {
			id newValue = [json objectForKey:jsonKey];

			if ([newValue isKindOfClass:[NSNumber class]])
				*value = [newValue stringValue];
			else if ([newValue isKindOfClass:[NSString class]])
				*value = newValue;
			else
				*value = [newValue stringValue];
		}
		else if ([type isEqualToString:@"T@\"NSDate\""]) {
			NSString * newValue = [json objectForKey:jsonKey];

			if ([newValue hasSuffix:@"Z"])
				newValue = [[newValue substringToIndex:[newValue length] - 1] stringByAppendingString:@"-0000"];

			*value = [newValue dateValueWithFormat:API_TIMESTAMP_FORMAT];
		}
		else {
			*value = [json objectForKey:jsonKey];
		}
		return YES;
	}];

	[[NSNotificationCenter defaultCenter] postNotificationName:INModelObjectChangedNotification object:self];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <%p> %@", NSStringFromClass([self class]), self, [self resourceDictionary]];
}


#pragma Loading and Saving

- (NSString *)APIPath
{
	NSAssert(false, @"This class does not provide an APIPath. Subclasses should provide /collection/:id to enable -reload: and -save:");
	return nil;
}

- (void)reload:(ErrorBlock)callback
{
	[[INAPIManager shared] GET:[self APIPath] parameters:[self resourceDictionary] success:^(AFHTTPRequestOperation * operation, id responseObject) {
		[self updateWithResourceDictionary:responseObject];
		[[INDatabaseManager shared] persistModel:self];
		if (callback)
			callback(nil);
	} failure:^(AFHTTPRequestOperation * operation, NSError * error) {
		if (callback)
			callback(error);
	}];
}

- (void)beginUpdates
{
	_precommitResourceDictionary = [self resourceDictionary];
}

- (INAPIOperation *)commitUpdates
{
	NSAssert(_precommitResourceDictionary, @"You need to call -beginUpdates before calling -commitUpdates to save a model.");
	INAPIOperation * operation = [INAPIOperation operationWithMethod:@"PUT" forModel:self];
	[operation setModelRollbackDictionary: _precommitResourceDictionary];
	[[INAPIManager shared] queueAPIOperation:operation];
	[[INDatabaseManager shared] persistModel:self];
	_precommitResourceDictionary = nil;
	return operation;
}

- (INAPIOperation *)save
{
	if ([self ID])
		return [self commitUpdates];
		
	INAPIOperation * operation = [INAPIOperation operationWithMethod:@"POST" forModel:self];
	[[INAPIManager shared] queueAPIOperation:operation];
	[[INDatabaseManager shared] persistModel:self];
	return operation;
}

- (INAPIOperation *)delete
{
	INAPIOperation * operation = [INAPIOperation operationWithMethod:@"DELETE" forModel:self];
	[[INAPIManager shared] queueAPIOperation:operation];
	[[INDatabaseManager shared] unpersistModel:self];
	
	return operation;
}

#pragma Override Points & Subclassing Support

+ (NSMutableDictionary *)resourceMapping
{
	return [@{@"ID": @"id", @"namespaceID": @"namespace_id", @"createdAt": @"created_at", @"updatedAt": @"updated_at"} mutableCopy];
}

+ (NSString *)databaseTableName
{
	return NSStringFromClass(self);
}

+ (NSArray *)databaseIndexProperties
{
	return @[@"namespaceID"];
}

- (void)setup
{
	// override point for subclasses
}

#pragma mark Getting and Setting Resource Properties

- (void)getEachPropertyInSet:(NSArray *)properties andInvoke:(void (^)(id key, NSString * type, id value))block
{
	for (NSString * key in properties) {
		if (![self hasPropertyNamed:key]) {
			NSLog(@"No getter available for property %@", key);
			return;
		}

		NSString * type = [NSString stringWithCString:[self typeOfPropertyNamed:key] encoding:NSUTF8StringEncoding];
		id val = [self valueForKey:key];

		block(key, type, val);
	}
}

- (void)setEachPropertyInSet:(NSArray *)properties withValueProvider:(BOOL (^)(id key, NSObject ** value, NSString * type))block
{
	for (NSString * key in properties) {
		SEL setter = [self setterForPropertyNamed:key];

		if (setter == NULL) {
			NSLog(@"No setter available for property %@", key);
			continue;
		}
		NSString * type = [NSString stringWithCString:[self typeOfPropertyNamed:key] encoding:NSUTF8StringEncoding];
		NSObject * value = [self valueForKey:key];

		if (block(key, &value, type)) {
			if ([value isKindOfClass:[NSNull class]]) {
				if ([type isEqualToString:@"Ti"] || [type isEqualToString:@"Tf"])
					[self setValue:[NSNumber numberWithInt:0] forKey:key];
				else if ([type isEqualToString:@"Tc"])
					value = [NSNumber numberWithBool:NO];
				else
					[self setValue:nil forKey:key];
			}
			else {
				if ([type isEqualToString:@"T@\"NSString\""] && [value isKindOfClass:[NSNumber class]])
					value = [(NSNumber *)value stringValue];

				if ([type isEqualToString:@"Tc"])
					if ([value isKindOfClass:[NSString class]])
						value = [NSNumber numberWithChar:[(NSString *)value characterAtIndex : 0]];
				[self setValue:value forKey:key];
			}
		}
	}
}

@end
