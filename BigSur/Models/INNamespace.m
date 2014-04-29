//
//  INNamespace.m
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INNamespace.h"

@implementation INNamespace

- (NSString*)APIPath
{
    NSString * ID = self.ID ? self.ID : @"";
    return [NSString stringWithFormat: @"/n/%@", ID];
}

@end
