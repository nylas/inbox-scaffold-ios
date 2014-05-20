//
//  INAppDelegate.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAppDelegate.h"
#import "INViewController.h"
#import "INThemeManager.h"
#import "INAuthViewController.h"
#import "INStupidFullSyncEngine.h"

@implementation INAppDelegate

+ (INAppDelegate*)current
{
    return (INAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // locally save our own console output
    _runtimeLogPath = [@"~/Documents/console.log" stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] removeItemAtPath:_runtimeLogPath error:NULL];
    freopen([_runtimeLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    // apply appearance overrides
	[[UINavigationBar appearance] setBarTintColor: [UIColor colorWithWhite:0.956 alpha:1]];
	[[UINavigationBar appearance] setTintColor: [[INThemeManager shared] tintColor]];
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.29 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]}];
	[[UIProgressView appearance] setTintColor: [[INThemeManager shared] tintColor]];
	[[UISwitch appearance] setOnTintColor: [[INThemeManager shared] tintColor]];
    
    // load previous app state
    NSArray * namespaces = [[INAPIManager shared] namespaces];
    [self setCurrentNamespace: [namespaces firstObject]];
    
    // tell Inbox we want to delegate all data syncing to a sync engine and not
    // have data loaded for each of the displayed by INModelProviders (which would be
    // be preferred if our app only ever loaded a specific view of attachments, or
    // something like that...)
    INStupidFullSyncEngine * engine = [[INStupidFullSyncEngine alloc] initWithConfiguration: @{}];
    [[INAPIManager shared] setSyncEngine: engine];
    
    // initialize the sidebar controller
    _sidebarViewController = [[INSidebarViewController alloc] init];
    
    // initialze content view controllers
	_mainViewController = [[INViewController alloc] init];
	[_mainViewController setTag: [INTag tagWithID: INTagIDInbox]];
	
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: _mainViewController];
	[[nav navigationBar] setTranslucent: NO];
	
    // initialize the controller that manages the sliding of the sidebar tray
    _slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController: nav backViewController: _sidebarViewController];
    _slidingViewController.useBouncyAnimations = NO;
    _slidingViewController.delegate = self;
    
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = _slidingViewController;
	[self.window makeKeyAndVisible];

    // monitor inbox for notifications that we need to authenticate or that
    // our access to namespaces (email accounts) has changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxCheckAuthentication:) name:INAuthenticationChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxNamespacesChanged:) name:INNamespacesChangedNotification object:nil];
    [self inboxCheckAuthentication: nil];
    
	return YES;
}

- (void)setCurrentNamespace:(INNamespace *)namespace
{
	_currentNamespace = namespace;
	[[NSNotificationCenter defaultCenter] postNotificationName:BigSurNamespaceChanged object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)slidingViewControllerWillOpen:(JSSlidingViewController *)viewController
{
    [_sidebarViewController refresh];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)slidingViewControllerWillClose:(JSSlidingViewController *)viewController
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)inboxCheckAuthentication:(NSNotification*)notification
{
    if ([[INAPIManager shared] isSignedIn]) {
        // we're good.
    } else {
        INAuthViewController * auth = [[INAuthViewController alloc] init];
        [_slidingViewController presentViewController:auth animated:YES completion:NULL];
    }
}

- (void)inboxNamespacesChanged:(NSNotification*)notification
{
    if ((!_currentNamespace) || ([[[INAPIManager shared] namespaces] containsObject: _currentNamespace] == NO)){
        [self setCurrentNamespace: [[[INAPIManager shared] namespaces] firstObject]];
    }
}

@end
