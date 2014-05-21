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
#import "INStupidFullSyncEngine.h"

@implementation INViewController

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareThreadProvider) name:BigSurNamespaceChanged object:nil];
        [self prepareThreadProvider];
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
    _titleView = [[INInboxNavTitleView alloc] initWithFrame: CGRectZero];
    [self.navigationItem setTitleView: _titleView];

	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	[_tableView setSeparatorInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    
	UIBarButtonItem * compose = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_compose.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(composeTapped:)];
	[self.navigationItem setRightBarButtonItem: compose];
}

- (void)prepareThreadProvider
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
	
	INThreadProvider * provider = [namespace newThreadProvider];
	[provider setItemSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];
	[provider setDelegate:self];
	[provider setItemFilterPredicate: _threadProvider.itemFilterPredicate];
	[provider setItemRange: NSMakeRange(0, 20)];
	[provider refresh];
	
	_threadProvider = provider;
}

- (void)setTag:(INTag*)tag
{
	_tag = tag;
	
	[_threadProvider setItemFilterPredicate: [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", [tag ID]]];
    [_threadProvider refresh];

	[self setTitle: [tag name]];
    [_titleView setTitle: [self title] andUnreadCount: NSNotFound];
}


#pragma Actions

- (IBAction)composeTapped:(id)sender
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    INMessage * draft = [[INMessage alloc] initAsDraftIn: namespace];
	INComposeViewController * compose = [[INComposeViewController alloc] initWithDraft: draft];
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: compose];
	[self presentViewController:nav animated:YES completion:NULL];
}

#pragma Refreshing & Thread Ppovider

- (void)refresh
{
    INStupidFullSyncEngine * syncEngine = (INStupidFullSyncEngine*)[[INAPIManager shared] syncEngine];
    [syncEngine syncClass:[INThread class] callback:^(NSError *error) {
        if ([_refreshControl isRefreshing])
            [[[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [_refreshControl endRefreshing];
    }];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    INThread * thread = [[_threadProvider items] objectAtIndex:[indexPath row]];
	
    if ([_tag isEqual: [INTag tagWithID: INTagIDDraft]]) {
        INDeleteDraftChange * delete = [INDeleteDraftChange operationForModel: [thread currentDraft]];
        [[INAPIManager shared] queueChange: delete];

    } else {
        INAddRemoveTagsChange * archive = [INAddRemoveTagsChange operationForModel: thread];
        [[archive tagIDsToAdd] addObject: INTagIDArchive];
        [[INAPIManager shared] queueChange: archive];
    }
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[INAppDelegate current] slidingViewController] setLocked:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[INAppDelegate current] slidingViewController] setLocked:NO];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_tag isEqual: [INTag tagWithID: INTagIDDraft]])
        return @"Delete Draft";
    else
        return @"Archive";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y > _scrollViewPrevOffset)
		if ([_searchBar isFirstResponder])
			[_searchBar resignFirstResponder];
			
	_scrollViewPrevOffset = scrollView.contentOffset.y;
}

@end
