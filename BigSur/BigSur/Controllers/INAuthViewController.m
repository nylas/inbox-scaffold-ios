//
//  INAuthViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/15/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAuthViewController.h"
#import "UIImage+BlurEffects.h"
#import "INAppDelegate.h"
#import "INThemeManager.h"
#import "MBProgressHUD.h"
#import "INConvenienceCategories.h"

@implementation INAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	UIColor * themeColor = [[INThemeManager shared] tintColor];
	[_signInButton setBackgroundImage: [UIImage imageWithColor: themeColor] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
	[_emailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signInTapped:(id)sender
{
	NSString * msg = nil;
	NSArray * addresses = [[_emailField text] arrayOfValidEmailAddresses];

	if ([[_emailField text] length] == 0)
		msg = @"Type an email address to add an account to Inbox.";

	else if ([addresses count] == 0)
		msg = @"Please provide a valid email address.";
		
	if (msg) {
		[[[UIAlertView alloc] initWithTitle:@"Inbox" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		return;
	}
	
	MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[HUD setLabelText: @"Signing In..."];
	
	[_signInButton setUserInteractionEnabled: NO];
	[[INAPIManager shared] authenticateWithEmail:[addresses firstObject] andCompletionBlock:^(NSError *error) {

		[HUD hide:YES];
		[_signInButton setUserInteractionEnabled: YES];
		
		if (error) {
			[[[UIAlertView alloc] initWithTitle:@"Sign In Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		} else {
			[self dismissViewControllerAnimated:YES completion:NULL];
		}
	}];
}

@end
