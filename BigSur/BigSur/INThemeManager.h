//
//  INThemeManager.h
//  BigSur
//
//  Created by Ben Gotow on 5/12/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INThemeManager : NSObject

+ (INThemeManager *)shared;

- (UIColor*)tintColor;

@end
