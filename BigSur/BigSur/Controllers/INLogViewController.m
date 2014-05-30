//
//  INLogViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INLogViewController.h"
#import "INAppDelegate.h"

#define MAX_CHARS 20000

@implementation INLogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self update];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_updateTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    NSString * text = [NSString stringWithContentsOfFile:[[INAppDelegate current] runtimeLogPath] encoding:NSUTF8StringEncoding error:nil];
#if DEBUG
text = @"The app log is printed to the system console for DEBUG builds.";
#endif
    
    if ([text length] > MAX_CHARS)
        text = [text substringFromIndex: [text length] - MAX_CHARS];
    [_appLog setText: text];
    [_appLog scrollRangeToVisible:NSMakeRange([_appLog.text length], 0)];

    // see http://stackoverflow.com/questions/19124037/scroll-to-bottom-of-uitextview-erratic-in-ios-7
    [_appLog setScrollEnabled:NO];
    [_appLog setScrollEnabled:YES];
}

- (IBAction)emailLog:(id)sender
{
}

- (IBAction)clearLog:(id)sender
{
    NSString * path = [[INAppDelegate current] runtimeLogPath];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    freopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    [self update];
}

@end
