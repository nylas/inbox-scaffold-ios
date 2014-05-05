//
//  NSString+INConvenienceCategories.m
//  BigSur
//
//  Created by Ben Gotow on 5/2/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INConvenienceCategories.h"
#import "NSString+FormatConversion.h"

@implementation NSString (INConvenienceCategories)

+ (NSString *)stringForMessageDate:(NSDate*)date
{
	NSTimeInterval twelveHours = -60 * 60 * 12;
	if ([date timeIntervalSinceNow] > twelveHours)
		return [NSString stringWithDate:date format:@"h:mm aa"];
	else
		return [NSString stringWithDate:date format:@"MM/dd/YY"];
}

@end
