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

@implementation NSURL (INConvenienceCategories)

+ (NSURL*)URLForGravatar:(NSString*)email
{
	email = [[email stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] lowercaseString];
	NSString * p = [NSString stringWithFormat: @"http://www.gravatar.com/avatar/%@?s=184", [email md5Value]];
	return [NSURL URLWithString: p];
}

@end
