//
//  INViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INViewController.h"
#import "INThreadViewController.h"
#import "INContactsViewController.h"
#import "INComposeViewController.h"
#import "INThreadTableViewCell.h"
#import "UIView+FrameAdditions.h"
#import "INThemeManager.h"
#import "INAppDelegate.h"

@implementation INViewController

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareForDisplay) name:BigSurNamespaceChanged object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self setTitle: @"Inbox"];
	[self prepareForDisplay];

    _titleView = [[INInboxNavTitleView alloc] initWithFrame: CGRectZero];
    [_titleView setTitle: [self title] andUnreadCount: NSNotFound];
    [self.navigationItem setTitleView: _titleView];
    
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	[_tableView setSeparatorInset: UIEdgeInsetsMake(0, 0, 0, 0)];
	
	UIBarButtonItem * compose = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_compose.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(composeTapped:)];
	[self.navigationItem setRightBarButtonItem: compose];
}

- (void)prepareForDisplay
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
	
	self.threadProvider = [namespace newThreadProvider];
	[_threadProvider setItemSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];
	[_threadProvider setDelegate:self];
	[_threadProvider setItemFilterPredicate: _threadPredicate];
	[_threadProvider setItemRange: NSMakeRange(0, 20)];
	[_threadProvider refresh];
}

- (void)setThreadPredicate:(NSPredicate *)threadPredicate
{
    _threadPredicate = threadPredicate;
    [self prepareForDisplay];
}

#pragma Actions

- (IBAction)composeTapped:(id)sender
{
	INComposeViewController * compose = [[INComposeViewController alloc] initWithThread: nil];
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: compose];
	[self presentViewController:nav animated:YES completion:NULL];
}

#pragma Refreshing & Thread Ppovider

- (void)refresh
{
	[_threadProvider refresh];
}

- (void)providerDataChanged
{
	[_tableView reloadData];
    [_threadProvider countUnreadItemsWithCallback:^(long count) {
        [_titleView setTitle: [self title] andUnreadCount: count];
    }];
}

- (void)providerDataAltered:(INModelProviderChangeSet *)changeSet
{
	[_tableView beginUpdates];
	[_tableView deleteRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeRemove] withRowAnimation:UITableViewRowAnimationLeft];
	[_tableView insertRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeAdd] withRowAnimation:UITableViewRowAnimationTop];
	[_tableView endUpdates];
	[_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeUpdate] withRowAnimation:UITableViewRowAnimationLeft];

    [_threadProvider countUnreadItemsWithCallback:^(long count) {
        [_titleView setTitle: [self title] andUnreadCount: count];
    }];
}

- (void)providerDataFetchFailed:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	[_refreshControl endRefreshing];
}

- (void)providerDataFetchCompleted
{
	[_refreshControl endRefreshing];
}

#pragma mark Search

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSPredicate * predicate = [NSComparisonPredicate predicateWithFormat:@"subject CONTAINS[cd] %@", searchText];
	[_threadProvider setItemFilterPredicate:predicate];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_threadProvider items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	INThreadTableViewCell * cell = (INThreadTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) cell = [[INThreadTableViewCell alloc] initWithReuseIdentifier:@"cell"];

	INThread * thread = [[_threadProvider items] objectAtIndex:[indexPath row]];
	[cell setThread: thread];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	INThread * thread = [[_threadProvider items] objectAtIndex:[indexPath row]];
	
	INThreadViewController * threadVC = [[INThreadViewController alloc] initWithThread: thread];
	[self.navigationController pushViewController:threadVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y > _scrollViewPrevOffset)
		if ([_searchBar isFirstResponder])
			[_searchBar resignFirstResponder];
			
	_scrollViewPrevOffset = scrollView.contentOffset.y;
}

@end
