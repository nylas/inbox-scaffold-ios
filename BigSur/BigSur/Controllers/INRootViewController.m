//
//  INRootViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/12/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INRootViewController.h"

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

- (IBAction)sidebarTapped:(id)sender
{
	
}

@end
