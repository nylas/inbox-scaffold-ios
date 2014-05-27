//
//  INRootViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/12/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INRootViewController.h"
#import "JSSlidingViewController.h"
#import "INAppDelegate.h"

@implementation INRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIImage * sidebarIcon = [[UIImage imageNamed: @"icon_sidebar.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem * sidebar = [[UIBarButtonItem alloc] initWithImage:sidebarIcon style:UIBarButtonItemStyleBordered target:self action:@selector(sidebarTapped:)];
	[sidebar setTintColor: [UIColor darkGrayColor]];
	[self.navigationItem setLeftBarButtonItem: sidebar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
	[[[INAppDelegate current] slidingViewController] setLocked:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[[INAppDelegate current] slidingViewController] setLocked:YES];
}

- (JSSlidingViewController*)parentSlidingViewController
{
    JSSlidingViewController * js = (JSSlidingViewController *)[self parentViewController];
    if ([js isKindOfClass: [JSSlidingViewController class]] == NO)
        js = (JSSlidingViewController *)[js parentViewController];
    return js;
}

- (IBAction)sidebarTapped:(id)sender
{
	JSSlidingViewController * js = [self parentSlidingViewController];
    if ([js isOpen])
        [js closeSlider:YES completion:nil];
    else
        [js openSlider:YES completion:nil];
}

@end
