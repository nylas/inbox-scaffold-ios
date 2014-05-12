//
//  INThemeManager.m
//  BigSur
//
//  Created by Ben Gotow on 5/12/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThemeManager.h"

@implementation INThemeManager

+ (INThemeManager *)shared
{
	static INThemeManager * sharedManager = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedManager = [[INThemeManager alloc] init];
	});
	return sharedManager;
}


- (UIColor*)tintColor
{
	return [UIColor colorWithRed:0 green:153.0/255.0 blue:204.0/255.0 alpha:1];
}

@end
