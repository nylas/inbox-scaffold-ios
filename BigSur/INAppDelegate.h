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
#import "INMailViewController.h"
#import "INSplitViewController.h"

static NSString * BigSurNamespaceChanged = @"BigSurNamespaceChanged";

@interface INAppDelegate : UIResponder <UIApplicationDelegate, JSSlidingViewControllerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) NSString * runtimeLogPath;

@property (strong, nonatomic) JSSlidingViewController * slidingViewController; // iPhone
@property (strong, nonatomic) INSplitViewController * splitViewController; // iPad
@property (strong, nonatomic) INSidebarViewController * sidebarViewController;
@property (strong, nonatomic) INMailViewController * mainViewController;

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) INNamespace * currentNamespace;

+ (INAppDelegate*)current;

#pragma mark Showing Content

- (void)showDrafts;
- (void)showThreadsWithTag:(INTag*)tag;

@end
