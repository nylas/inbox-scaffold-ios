//
//  INContactsViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INContactsViewController.h"
#import "INAPIManager.h"
#import "INNamespace.h"
#import "INContact.h"
#import "INAccount.h"

@implementation INContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setTitle: @"Contacts"];

	UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped:)];
	[[self navigationItem] setLeftBarButtonItem: left];

	INAccount * account = [[INAPIManager shared] account];
	INNamespace * namespace = [[account namespaces] firstObject];
	
	self.contactsProvider = [namespace newContactsProvider];
	[_contactsProvider setDelegate:self];
	[_contactsProvider refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma Provider Delegate

- (void)providerDataAltered:(INModelProviderChangeSet *)changeSet
{
	[_tableView beginUpdates];
	[_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeRemove] withRowAnimation:UITableViewRowAnimationTop];
	[_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeAdd] withRowAnimation:UITableViewRowAnimationRight];
	[_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeUpdate] withRowAnimation:UITableViewRowAnimationFade];
	[_tableView endUpdates];
}

- (void)providerDataFetchFailed:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)providerDataChanged
{
	[_tableView reloadData];
}


#pragma mark Table View Data

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_contactsProvider items] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"contact"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contact"];
	
	INContact * contact = [[_contactsProvider items] objectAtIndex: [indexPath row]];
	[[cell textLabel] setText: [contact name]];
	
	return cell;
}

@end
