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
	[_signInButton setEnabled: NO];
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

	// Check email validity
	if ([[_emailField text] length] == 0)
		msg = @"Type an email address to add an account to Inbox.";

	else if ([addresses count] == 0)
		msg = @"Please provide a valid email address.";
		
	if (msg) {
		[[[UIAlertView alloc] initWithTitle:@"Inbox" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		return;
	}
	
	// Update the UI
	MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[HUD setLabelText: @"Signing In..."];
	[_signInButton setUserInteractionEnabled: NO];

	// Start authentication
	[[INAPIManager shared] authenticateWithEmail:[addresses firstObject] andCompletionBlock:^(BOOL success, NSError *error) {
		[HUD hide:YES];
		[_signInButton setUserInteractionEnabled: YES];
		
		if (error)
			[[[UIAlertView alloc] initWithTitle:@"Sign In Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		
		if (success)
			[self dismissViewControllerAnimated:YES completion:NULL];
	}];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString * newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
	[_signInButton setEnabled: ([[newValue arrayOfValidEmailAddresses] count] > 0)];
	
	if ([string isEqualToString:@"\n"])
		[self signInTapped:nil];
		
	return YES;
}

@end
