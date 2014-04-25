//
//  INModelObject.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"
#import "NSObject+Properties.h"
#import "NSString+FormatConversion.h"

static NSMapTable * modelInstanceTable;

@implementation INModelObject


#pragma Globally Unique Instances

+ (id)attachedInstanceMatching:(INModelObject*)obj
{
    return [[obj class] attachedInstanceWithID:[obj ID]];
}

+ (id)attachedInstanceWithID:(id)ID
{
    if (!modelInstanceTable) {
        modelInstanceTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory capacity:1000];
    }
    
    return [modelInstanceTable objectForKey: [INModelObject attachedInstanceKeyForClass: self ID: ID]];
}

+ (id)attachedInstanceForResourceDictionary:(NSDictionary*)dict
{
    INModelObject * object = [self attachedInstanceWithID:dict[@"id"]];
    if (object)
        return object;
    
    
    Class klass = self;
    object = [[klass alloc] initWithResourceDictionary: dict];
    [klass attachInstance: object];
    return object;
}

+ (void)attachInstance:(INModelObject*)obj
{
    if (!obj)
        return;

    if (![obj isKindOfClass: [INModelObject class]])
        @throw @"Attempting to attach an object that is not an INModelObject";
    
    if ([INModelObject attachedInstanceMatching: obj] != nil)
        @throw @"Attempting to attach an instance when another instance is already in the data model for this class+ID combination.";
    [modelInstanceTable setObject: obj forKey: [INModelObject attachedInstanceKeyForClass: [obj class] ID: [obj ID]]];
}

+ (NSString*)attachedInstanceKeyForClass:(Class)klass ID:(id)ID
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
    id copy = [[klass alloc] initWithResourceDictionary: [self resourceDictionary]];
    return copy;
}

- (BOOL)isDetatched
{
    return ([INModelObject attachedInstanceMatching: self] != self);
}

- (NSString*)description
{
    return [NSString stringWithFormat: @"%@ <%p> %@", NSStringFromClass([self class]), self, [self resourceDictionary]];
}

#pragma NSCoding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self){
        NSDictionary * mapping = [[self class] resourceMapping];
        [self setEachPropertyInSet:[mapping allKeys] withValueProvider:^BOOL(id key, NSObject ** value, NSString * type) {
            if (![aDecoder containsValueForKey: key])
                return NO;
            *value = [aDecoder decodeObjectForKey: key];
            return YES;
        }];

        [self setup];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSDictionary * mapping = [[self class] resourceMapping];
    [self getEachPropertyInSet:[mapping allKeys] andInvoke:^(id key, NSString *type, id value) {
        BOOL encodable = [value respondsToSelector: @selector(encodeWithCoder:)];
        if (encodable) {
            [aCoder encodeObject:value forKey:key];
        } else if (value) {
            NSLog(@"Value of %@ (%@) does not comply to NSCoding.", key, [value description]);
        }
    }];
}

#pragma mark Resource Representation

- (id)initWithResourceDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        [self updateWithResourceDictionary: dict];
        [self setup];
    }
    return self;
}

- (NSMutableDictionary*)resourceDictionary
{
    NSDictionary * mapping = [[self class] resourceMapping];
    NSMutableDictionary * json = [NSMutableDictionary dictionary];
    
    [self getEachPropertyInSet:[mapping allKeys] andInvoke: ^(id key, NSString * type, id value) {
        if ([value isKindOfClass: [INModelObject class]])
            return;
        
        if ([value isKindOfClass: [NSDate class]])
            value = [NSString stringWithDate: (NSDate*)value format: API_TIMESTAMP_FORMAT];
        
        if ([value isKindOfClass: [NSArray class]])
            value = [value componentsJoinedByString: @","];
        
        NSString * jsonKey = [mapping objectForKey: key];
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
    
    if ([json isKindOfClass: [NSDictionary class]] == NO) {
        NSLog(@"updateWithResourceDictionary called with json that is not a dictionary");
        return;
    }
    
    [self setEachPropertyInSet: properties withValueProvider:^BOOL(id key, NSObject ** value, NSString * type) {
        NSString * jsonKey = [mapping objectForKey: key];
        if (![json objectForKey: jsonKey])
            return NO;
        
        if ([[json objectForKey: jsonKey] isKindOfClass: [NSNull class]]) {
            *value = nil;
            return YES;
        }
     
        if ([type isEqualToString: @"float"]) {
            *value = [NSNumber numberWithFloat: [[json objectForKey: jsonKey] floatValue]];
            
        } else if ([type isEqualToString: @"int"]) {
            *value = [NSNumber numberWithInt: [[json objectForKey: jsonKey] intValue]];

        } else if ([type isEqualToString: @"T@\"NSString\""]) {
            id newValue = [json objectForKey: jsonKey];
            if ([newValue isKindOfClass: [NSNumber class]])
                *value = [newValue stringValue];
            else if ([newValue isKindOfClass: [NSString class]])
                *value = newValue;
            else
                *value = [newValue stringValue];

        } else if ([type isEqualToString: @"T@\"NSDate\""]) {
            NSString * newValue = [json objectForKey: jsonKey];
            if ([newValue hasSuffix: @"Z"])
                newValue = [[newValue substringToIndex:[newValue length] - 1] stringByAppendingString:@"-0000"];
            
            *value = [newValue dateValueWithFormat: API_TIMESTAMP_FORMAT];
            
        } else {
            *value = [json objectForKey: jsonKey];
        }
        return YES;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:INModelObjectChangedNotification object:self];
}

#pragma Override Points & Subclassing Support

+ (NSMutableDictionary *)resourceMapping
{
    return [@{ @"ID": @"id", @"createdAt": @"created_at", @"updatedAt": @"updated_at" } mutableCopy];
}

- (void)setup
{
    // override point for subclasses
}

# pragma mark Getting and Setting Resource Properties

- (void)getEachPropertyInSet:(NSArray*)properties andInvoke:(void (^)(id key, NSString * type, id value))block
{
    for (NSString * key in properties) {
        if (![self hasPropertyNamed: key]) {
            NSLog(@"No getter available for property %@", key);
            return;
        }
        
        NSString * type = [NSString stringWithCString:[self typeOfPropertyNamed: key] encoding: NSUTF8StringEncoding];
        id val = [self valueForKey: key];
        
        block(key, type, val);
    }
}

- (void)setEachPropertyInSet:(NSArray*)properties withValueProvider:(BOOL (^)(id key, NSObject ** value, NSString * type))block
{
    for (NSString * key in properties) {
        SEL setter = [self setterForPropertyNamed: key];
        if (setter == NULL) {
            NSLog(@"No setter available for property %@", key);
            continue;
        }
        NSString * type = [NSString stringWithCString:[self typeOfPropertyNamed: key] encoding: NSUTF8StringEncoding];
        NSObject * value = [self valueForKey: key];
        
        if (block(key, &value, type)) {
            if ([value isKindOfClass: [NSNull class]]) {
                if ([type isEqualToString:@"Ti"] || [type isEqualToString:@"Tf"])
                    [self setValue:[NSNumber numberWithInt: 0] forKey:key];
                else if ([type isEqualToString: @"Tc"])
                    value = [NSNumber numberWithBool: NO];
                else
                    [self setValue:nil forKey:key];
            } else {
                if ([type isEqualToString: @"T@\"NSString\""] && [value isKindOfClass: [NSNumber class]])
                    value = [(NSNumber*)value stringValue];
                if ([type isEqualToString: @"Tc"]) {
                    if ([value isKindOfClass: [NSString class]])
                        value = [NSNumber numberWithChar: [(NSString*)value characterAtIndex: 0]];
                }
                [self setValue:value forKey:key];
            }
        }
    }
}


@end
