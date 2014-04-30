//
//  INViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INViewController.h"
#import "INAPIOperation.h"

@implementation INViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	NSPredicate * predicate = [NSComparisonPredicate predicateWithFormat:@"name CONTAINS 'Ben'"];
	NSSortDescriptor * nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

	_contactsProvider = [INModelProvider providerForClass:[INContact class]];
	[_contactsProvider setPredicate:predicate];
	[_contactsProvider setSortDescriptors:@[nameSortDescriptor]];
	[_contactsProvider setDelegate:self];
	[_contactsProvider refresh];
}

- (void)providerDataRefreshed
{
	[_tableView reloadData];
}

- (void)providerDataAltered:(NSArray *)changes
{
	NSMutableArray * removedIndexPaths = [NSMutableArray array];
	NSMutableArray * insertIndexPaths = [NSMutableArray array];
	NSMutableArray * reloadIndexPaths = [NSMutableArray array];

	for (INModelProviderChange * change in changes) {
		switch (change.type) {
			case INModelProviderChangeRemove:
				[removedIndexPaths addObject: [NSIndexPath indexPathForItem:change.index inSection:0]];
				break;
			case INModelProviderChangeAdd:
				[insertIndexPaths addObject: [NSIndexPath indexPathForItem:change.index inSection:0]];
				break;
			case INModelProviderChangeUpdate:
				[reloadIndexPaths addObject: [NSIndexPath indexPathForItem:change.index inSection:0]];
				break;
			default:
				break;
		}
	}

	[_tableView beginUpdates];
	[_tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
	[_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
	[_tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
	[_tableView endUpdates];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_contactsProvider items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

	INContact * contact = [[_contactsProvider items] objectAtIndex:[indexPath row]];
	NSString * label = [contact name];
	[[cell textLabel] setText:label];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	INContact * contact = [[_contactsProvider items] objectAtIndex:[indexPath row]];

	[contact beginUpdates];
	[contact setName: @"Whoa Name Changed!"];
	INAPIOperation * operation = [contact commitUpdates];

	[operation setCompletionBlockWithSuccess: NULL failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[[[UIAlertView alloc] initWithTitle:@"Failed!" message:@"Oh man, what we did must have been illegial." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	}];

}

@end
