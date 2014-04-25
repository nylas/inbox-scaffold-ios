//
//  INAPICall.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAPIAction.h"
#import "INModelObject.h"


@implementation INAPIAction

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _detatchedObjects = [aDecoder decodeObjectForKey: @"detatchedObjects"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_detatchedObjects forKey:@"detatchedObjects"];
}

- (void)setObjects:(NSArray*)objects
{
    NSMutableArray * detatchedObjects = [NSMutableArray array];
    for (INModelObject * object in objects) {
        INModelObject * detatched = [object detatchedCopy];
        [detatchedObjects addObject: detatched];
    }
    _detatchedObjects = detatchedObjects;
}

- (void)perform
{
    // do something with the objects
}

@end
