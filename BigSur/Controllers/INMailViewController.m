//
//  INViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMailViewController.h"
#import "INThreadViewController.h"
#import "INContactsViewController.h"
#import "INComposeViewController.h"
#import "INMailItemTableViewCell.h"
#import "UIView+FrameAdditions.h"
#import "INThemeManager.h"
#import "INAppDelegate.h"
#import "INDeltaSyncEngine.h"
#import "INThreadTableViewCell.h"
#import "INMessageTableViewCell.h"

@implementation INMailViewController

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentNamespaceChanged:) name:BigSurNamespaceChanged object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCount) name:INSyncFinishedNotification object:nil];
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
    [_tableView registerClass:[INThreadTableViewCell class] forCellReuseIdentifier:@"INThreadTableViewCell"];
    [_tableView registerClass:[INMessageTableViewCell class] forCellReuseIdentifier:@"INMessageTableViewCell"];
	[_tableView setSeparatorInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    
	UIBarButtonItem * compose = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_compose.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(composeTapped:)];
	[self.navigationItem setRightBarButtonItem: compose];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
}

- (void)currentNamespaceChanged:(NSNotification*)notif
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
	[_provider setNamespaceID: [namespace ID]];
    [_provider refresh];
}

#pragma Actions

- (IBAction)composeTapped:(id)sender
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    INDraft * draft = [[INDraft alloc] initInNamespace: namespace];
	INComposeViewController * compose = [[INComposeViewController alloc] initWithDraft: draft];
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: compose];
	[nav setModalPresentationStyle: UIModalPresentationFormSheet];
	[nav setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
	
	[self presentViewController:nav animated:YES completion:NULL];
}

#pragma Refreshing & Thread Provider

- (void)refresh
{
    INDeltaSyncEngine * syncEngine = (INDeltaSyncEngine*)[[INAPIManager shared] syncEngine];
    [syncEngine syncWithCallback: ^(BOOL success, NSError *error) {
		// in some circumnstances, i.e. when an existing sync is already in progress,
		// this method returns (NO, nil).
		if (error)
			[[[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        if (success && [_refreshControl isRefreshing])
			[_refreshControl endRefreshing];
    }];
}

- (void)refreshCount
{
	if ([_provider isKindOfClass:[INThreadProvider class]]) {
        [(INThreadProvider*)_provider countUnreadItemsWithCallback:^(long count) {
            [_titleView setTitle: [self title] andUnreadCount: count];
        }];
    }
}

- (void)setProvider:(INModelProvider*)provider
{
    [_provider setDelegate: nil];
    _provider = provider;
    [_provider setDelegate: self];

	[_tableView reloadData];
    [_provider refresh];
    
	[self refreshCount];
}

- (void)setProvider:(INModelProvider *)provider andTitle:(NSString*)title
{
    [self setProvider: provider];
    
    [self setTitle: title];
    [_titleView setTitle: title andUnreadCount: 0];
    
	[self refreshCount];
}

- (void)providerDataChanged:(id)provider
{
	[_tableView reloadData];
	[self refreshCount];
}

- (void)provider:(id)provider dataAltered:(INModelProviderChangeSet *)changeSet
{
	[_tableView beginUpdates];
	[_tableView deleteRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeRemove] withRowAnimation:UITableViewRowAnimationLeft];
	[_tableView insertRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeAdd] withRowAnimation:UITableViewRowAnimationTop];
	[_tableView endUpdates];
	[_tableView reloadRowsAtIndexPaths:[changeSet indexPathsFor: INModelProviderChangeUpdate] withRowAnimation:UITableViewRowAnimationNone];

	[self refreshCount];
}

#pragma mark Search

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSPredicate * predicate = [NSComparisonPredicate predicateWithFormat:@"subject CONTAINS[cd] %@", searchText];
	[_provider setItemFilterPredicate:predicate];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_provider items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	INModelObject * model = [[_provider items] objectAtIndex:[indexPath row]];

    if ([model isKindOfClass: [INThread class]]) {
        INThreadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"INThreadTableViewCell" forIndexPath:indexPath];
        [cell setThread: (INThread*)model];
        return cell;
        
    } else if ([model isKindOfClass: [INMessage class]]) {
        INMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"INMessageTableViewCell" forIndexPath:indexPath];
        [cell setMessage: (INMessage*)model];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	INModelObject * model = [[_provider items] objectAtIndex:[indexPath row]];
    
    if ([model isKindOfClass: [INThread class]]) {
        INThreadViewController * threadVC = [[INThreadViewController alloc] initWithThread: (INThread*)model];
		[self smartPushViewController: threadVC animated: YES];
    }

    if ([model isKindOfClass: [INDraft class]]) {
        INComposeViewController * composeVC = [[INComposeViewController alloc] initWithDraft: (INDraft*)model];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: composeVC];
		[nav setModalPresentationStyle: UIModalPresentationFormSheet];
		[nav setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
		[self smartPresentViewController: nav animated: YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INModelObject * model = [[_provider items] objectAtIndex:[indexPath row]];
    if ([model isKindOfClass: [INThread class]])
        return @"Archive";
    
    if ([model isKindOfClass: [INDraft class]])
        return @"Delete Draft";
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    INModelObject * model = [[_provider items] objectAtIndex:[indexPath row]];
    if ([model isKindOfClass: [INThread class]])
        [(INThread*)model archive];
    
    if ([model isKindOfClass: [INDraft class]])
        [(INDraft*)model delete];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL isShowingAll = ([[_provider items] count] < [_provider itemRange].length);
    BOOL isNearBottom = (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) - 100);

    if (!isShowingAll && isNearBottom)
        [_provider extendItemRange: 40];
}

@end
