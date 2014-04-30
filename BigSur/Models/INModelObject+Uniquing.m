//
//  INModelObject+Uniquing.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject+Uniquing.h"
#import "INDatabaseManager.h"

static NSMapTable * modelInstanceTable;

@implementation INModelObject (Uniquing)

+ (id)attachedInstanceMatching:(INModelObject *)obj
{
	return [[obj class] attachedInstanceMatchingID:[obj ID]];
}

+ (id)attachedInstanceMatchingID:(id)ID
{
	if (!modelInstanceTable)
		modelInstanceTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:1000];
	
	return [modelInstanceTable objectForKey:[INModelObject attachmentKeyForClass:self ID:ID]];
}

+ (id)attachedInstanceWithResourceDictionary:(NSDictionary *)dict
{
	INModelObject * object = [self attachedInstanceMatchingID:dict[@"id"]];
	
	if (object) {
		[object updateWithResourceDictionary:dict];
		return object;
	}
	else {
		Class klass = self;
		object = [[klass alloc] init];
		[object updateWithResourceDictionary:dict];
		[object setup];
		[klass attachInstance:object];
		return object;
	}
}

+ (void)attachInstance:(INModelObject *)obj
{
	if (!obj)
		return;

	NSAssert([obj isKindOfClass:[INModelObject class]], @"Only subclasses of INModelObject can be attached.");

	id existing = [INModelObject attachedInstanceMatching:obj];

	if (!existing)
		[modelInstanceTable setObject:obj forKey:[INModelObject attachmentKeyForClass:[obj class] ID:[obj ID]]];
	else if (existing == obj)
		return;
	else
		NSAssert(false, @"Attaching an instance when another instance is already in memory for this class+ID combination. Where did this object come from?");
}

+ (NSString *)attachmentKeyForClass:(Class)klass ID:(id)ID
{
	if ([ID isKindOfClass:[NSNumber class]])
		ID = [ID stringValue];

	char cString[255];
	sprintf(cString, "%p-%s", (__bridge void *)klass, [ID cStringUsingEncoding:NSUTF8StringEncoding]);
	return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
}

- (id)detatchedCopy
{
	Class klass = [self class];
	id copy = [[klass alloc] init];

	[copy updateWithResourceDictionary:[self resourceDictionary]];
	return copy;
}

- (BOOL)isDetatched
{
	return [INModelObject attachedInstanceMatching:self] != self;
}

@end
