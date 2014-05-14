//
//  INAppDelegate.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSSlidingViewController.h"
#import "INSidebarViewController.h"

static NSString * BigSurNamespaceChanged = @"BigSurNamespaceChanged";

@interface INAppDelegate : UIResponder <UIApplicationDelegate, JSSlidingViewControllerDelegate>

@property (strong, nonatomic) JSSlidingViewController * slidingViewController;
@property (strong, nonatomic) INSidebarViewController * sidebarViewController;

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) INNamespace * currentNamespace;

+ (INAppDelegate*)current;

@end
