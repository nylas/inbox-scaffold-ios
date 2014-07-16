//
//  NSString+INConvenienceCategories.h
//  BigSur
//
//  Created by Ben Gotow on 5/2/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (INConvenienceCategories)

+ (NSString *)stringForMessageDate:(NSDate*)date;
+ (NSString *)stringForMessageDate:(NSDate*)date withStyle:(NSDateFormatterStyle)style;

+ (NSString *)stringByCleaningWhitespaceInString:(NSString*)snippet;

- (NSArray *)arrayOfValidEmailAddresses;

@end

@interface NSURL (INConvenienceCategories)

+ (NSURL*)URLForGravatar:(NSString*)email;

@end
