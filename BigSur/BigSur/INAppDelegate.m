//
//  INAppDelegate.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAppDelegate.h"
#import "INMailViewController.h"
#import "INThemeManager.h"
#import "INAuthViewController.h"
#import "INStupidFullSyncEngine.h"
#import "INDeltaSyncEngine.h"
#import "INThreadViewController.h"

@implementation INAppDelegate

+ (INAppDelegate*)current
{
    return (INAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _runtimeLogPath = [@"~/Documents/console.log" stringByExpandingTildeInPath];
#if !DEBUG
    // locally save our own console output. This prevents it from appearing in the Xcode debugger console,
	// but allows the app to display it's own log in the INLogViewController.
    [[NSFileManager defaultManager] removeItemAtPath:_runtimeLogPath error:NULL];
    freopen([_runtimeLogPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
#endif
    // apply appearance overrides
	[[UINavigationBar appearance] setBarTintColor: [UIColor colorWithWhite:0.956 alpha:1]];
	[[UINavigationBar appearance] setTintColor: [[INThemeManager shared] tintColor]];
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.29 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]}];
	[[UIProgressView appearance] setTintColor: [[INThemeManager shared] tintColor]];
	[[UISwitch appearance] setOnTintColor: [[INThemeManager shared] tintColor]];
    [[UIButton appearance] setTintColor: [[INThemeManager shared] tintColor]];

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
	_mainViewController = [[INMailViewController alloc] init];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([[[UIDevice currentDevice] model] hasPrefix: @"iPad"]) {
		_splitViewController = [[INSplitViewController alloc] init];
		_splitViewController.viewControllers = @[_sidebarViewController, _mainViewController];
		[_splitViewController.view setBackgroundColor: [_sidebarViewController.view backgroundColor]];
		self.window.rootViewController = _splitViewController;
		
	} else {
		// wrap the main view in a navigation controller
		UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: _mainViewController];
		[[nav navigationBar] setTranslucent: NO];

		// initialize the controller that manages the sliding of the sidebar tray
		_slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController: nav backViewController: _sidebarViewController];
		_slidingViewController.useBouncyAnimations = NO;
		_slidingViewController.delegate = self;
		self.window.rootViewController = _slidingViewController;
	}
	[self.window makeKeyAndVisible];

    [self showThreadsWithTag: [INTag tagWithID: INTagIDInbox]];

    // monitor inbox for notifications that we need to authenticate or that
    // our access to namespaces (email accounts) has changed.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxCheckAuthentication:) name:INAuthenticationChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxNamespacesChanged:) name:INNamespacesChangedNotification object:nil];
    [self inboxCheckAuthentication: nil];
    
    // background fetch? Sign me up! Let's fetch new mail every five minutes at minimum
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:5 * 60.0];
    
    NSDictionary * notifUserInfo = nil;
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey])
        notifUserInfo = [launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo];
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
        notifUserInfo = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] userInfo];

    if (notifUserInfo)
        [self showViewForNotification: notifUserInfo];
    
	return YES;
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // only perform the action associated with this noitification if we're being brought to the foreground
    // by the user swiping the notification or otherwise triggering it's action.
    if ([application applicationState] != UIApplicationStateActive) {
        [self showViewForNotification: userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // only perform the action associated with this noitification if we're being brought to the foreground
    // by the user swiping the notification or otherwise triggering it's action.
    if ([application applicationState] != UIApplicationStateActive) {
        [self showViewForNotification: [notification userInfo]];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    INDeltaSyncEngine * engine = (INDeltaSyncEngine*)[[INAPIManager shared] syncEngine];
    BOOL __block calledCompletionHandler = NO;
    
    [engine syncWithCallback:^(BOOL success, NSError *error) {
        if (calledCompletionHandler) return;
        calledCompletionHandler = YES;
        if (error)
            completionHandler(UIBackgroundFetchResultFailed);
        else
            completionHandler(UIBackgroundFetchResultNewData);
    }];
    
    // IMPORTANT. We only have 30 seconds to fetch data or our application will be terminated.
    // If 30 seconds pass and our sync is still in progress for some reason, return with the "failed"
    // state so we don't get terminated. Who knows what happened to our sync - who cares. We
    // want to avoid being killed here.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(29.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!calledCompletionHandler)
            calledCompletionHandler = YES;
        completionHandler(UIBackgroundFetchResultFailed);
    });
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return [[INAPIManager shared] handleURL: url];
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

#pragma mark Updates from Inbox Framework

- (void)inboxCheckAuthentication:(NSNotification*)notification
{
    if ([[INAPIManager shared] isAuthenticated]) {
        // we're good.
    } else {
//        INAuthViewController * auth = [[INAuthViewController alloc] init];
//        [_slidingViewController presentViewController:auth animated:YES completion:NULL];
        
        [[INAPIManager shared] authenticateWithAuthToken:@"bla" andCompletionBlock:^(BOOL success, NSError *error) {
            
        }];
    }
}

- (void)inboxNamespacesChanged:(NSNotification*)notification
{
    if ((!_currentNamespace) || ([[[INAPIManager shared] namespaces] containsObject: _currentNamespace] == NO)){
        [self setCurrentNamespace: [[[INAPIManager shared] namespaces] firstObject]];
    }
}


#pragma mark Showing Content

- (void)setCurrentNamespace:(INNamespace *)namespace
{
	_currentNamespace = namespace;
	[[NSNotificationCenter defaultCenter] postNotificationName:BigSurNamespaceChanged object:nil];
    [self showThreadsWithTag: [INTag tagWithID: INTagIDInbox]];
}

- (void)showDrafts
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    INModelProvider * provider = [namespace newDraftsProvider];
    
    [_mainViewController setProvider: provider andTitle:@"Drafts"];
    [_sidebarViewController selectItemWithName: @"Drafts"];
}

- (void)showThreadsWithTag:(INTag*)tag
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    INThreadProvider * provider = [namespace newThreadProvider];
	[provider setItemSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];
	[provider setItemFilterPredicate: [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", [tag ID]]];
	[provider setItemRange: NSMakeRange(0, 20)];
    
    [_mainViewController setProvider: provider andTitle:[tag name]];
    [_sidebarViewController selectItemWithName: [tag name]];
}
    
- (void)showViewForNotification:(NSDictionary*)userInfo
{
    if (userInfo[@"thread_id"]) {
        INThread * thread = [INThread instanceWithID:userInfo[@"thread_id"] inNamespaceID:userInfo[@"namespace_id"]];
        INThreadViewController * vc = [[INThreadViewController alloc] initWithThread: thread];
        [[_mainViewController navigationController] popToRootViewControllerAnimated: NO];
        [[_mainViewController navigationController] pushViewController:vc animated:NO];
    }
}


@end
