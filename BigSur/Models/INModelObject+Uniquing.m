//
//  INModelObject+Uniquing.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject+Uniquing.h"

static NSMapTable * modelInstanceTable;

@implementation INModelObject (Uniquing)

+ (id)instanceMatching:(INModelObject*)obj
{
    return [[obj class] instanceMatchingID:[obj ID]];
}

+ (id)instanceMatchingID:(id)ID
{
    if (!modelInstanceTable) {
        modelInstanceTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory capacity:1000];
    }
    
    return [modelInstanceTable objectForKey: [INModelObject attachmentKeyForClass: self ID: ID]];
}

+ (id)instanceWithResourceDictionary:(NSDictionary*)dict
{
    INModelObject * object = [self instanceMatchingID:dict[@"id"]];
    if (object) {
        [object updateWithResourceDictionary: dict];
        return object;
        
    } else {
        Class klass = self;
        object = [[klass alloc] init];
        [object updateWithResourceDictionary: dict];
        [object setup];
        [klass attachInstance: object];
        return object;
    }
}

+ (void)attachInstance:(INModelObject*)obj
{
    if (!obj)
        return;
    
    NSAssert([obj isKindOfClass: [INModelObject class]], @"Only subclasses of INModelObject can be attached.");
    
    id existing = [INModelObject instanceMatching: obj];
    if (!existing) {
        [modelInstanceTable setObject: obj forKey: [INModelObject attachmentKeyForClass: [obj class] ID: [obj ID]]];
    } else if (existing == obj) {
        return;
    } else {
        NSAssert(false, @"Attaching an instance when another instance is already in memory for this class+ID combination. Where did this object come from?");
    }
}

+ (NSString*)attachmentKeyForClass:(Class)klass ID:(id)ID
{
    if ([ID isKindOfClass: [NSNumber class]])
        ID = [ID stringValue];
    
    char cString[255];
    sprintf (cString, "%p-%s", (__bridge void*)klass, [ID cStringUsingEncoding: NSUTF8StringEncoding]);
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
}


- (id)detatchedCopy
{
    Class klass = [self class];
    id copy = [[klass alloc] init];
    [copy updateWithResourceDictionary: [self resourceDictionary]];
    return copy;
}

- (BOOL)isDetatched
{
    return ([INModelObject instanceMatching: self] != self);
}


@end
