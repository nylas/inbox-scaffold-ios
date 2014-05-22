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
		return [NSString stringWithDate:date format:@"MMM d, YYYY"];
}

+ (NSString *)stringByCleaningWhitespaceInString:(NSString*)snippet
{
	unichar * cleaned = calloc([snippet length], sizeof(unichar));
	int cleanedLength = 0;
    
	NSCharacterSet * punctuationSet = [NSCharacterSet punctuationCharacterSet];
	NSCharacterSet * whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	BOOL hasSpace = YES;
	for (int ii = 0; ii < [snippet length]; ii ++) {
		unichar c = [snippet characterAtIndex: ii];
		BOOL isWhitespace = [whitespaceSet characterIsMember: c];
		
		if (isWhitespace) {
			// If this character is whitespace, only add it to our string if we don't
			// already have a whitespace character.
			if (!hasSpace)
				cleaned[cleanedLength++] = ' ';
			hasSpace = YES;
		} else {
			// If this character is punctuation and our trailing character is a whitespace
			// character, place the punctutation where the whitespace is. Otherwise just
			// append the character.
			if (hasSpace && [punctuationSet characterIsMember: c])
				cleanedLength --;
			cleaned[cleanedLength++] = c;
			hasSpace = NO;
		}
	}
	return [[NSString alloc] initWithCharacters:cleaned length:cleanedLength];
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
