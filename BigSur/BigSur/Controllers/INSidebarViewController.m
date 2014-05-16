//
//  INSidebarViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INSidebarViewController.h"
#import "INSidebarTableViewCell.h"
#import "INAppDelegate.h"



@implementation INSidebarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:BigSurNamespaceChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:INNamespacesChangedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[_tableView setRowHeight: 42];
	[_tableView setSeparatorInset: UIEdgeInsetsMake(0, 8 + 20 + 8, 0, 0)];
	[_tableView setSeparatorColor: [UIColor colorWithWhite:1 alpha:0.1]];
    [_tableView registerClass:[INSidebarTableViewCell class] forCellReuseIdentifier:@"sidebarcell"];
	[_tableView setContentInset: UIEdgeInsetsMake(10, 0, 0, 0)];
	[_tableView setAllowsSelection: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refresh
{
    if (![[_tagProvider namespaceID] isEqualToString: [[[INAppDelegate current] currentNamespace] ID]]) {
        _tagProvider = [[[INAppDelegate current] currentNamespace] newTagProvider];
        [_tagProvider setDelegate: self];
    }
    [_tagProvider refresh];
}

- (IBAction)signOutTapped:(id)sender
{
	[[[INAppDelegate current] slidingViewController] closeSlider:YES completion:^{
        [[INAPIManager shared] signOut];
    }];
}

#pragma mark Table View

- (NSArray *)displayedTags
{
    NSMutableArray * tags = [NSMutableArray array];
	[tags addObject: [INTag instanceWithID: INTagIDInbox]];
	[tags addObject: [INTag instanceWithID: INTagIDFlagged]];
	[tags addObject: [INTag instanceWithID: INTagIDDraft]];
	[tags addObject: [INTag instanceWithID: INTagIDSent]];
	[tags addObject: [INTag instanceWithID: INTagIDArchive]];
    [tags addObjectsFromArray: [_tagProvider items]];
    return tags;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [[[INAPIManager shared] namespaces] count];
    else
        return [[self displayedTags] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 36)];
	[v setBackgroundColor: [_tableView backgroundColor]];
	[[v layer] setShadowColor: [[_tableView backgroundColor] CGColor]];
	[[v layer] setShadowOffset: CGSizeMake(0, 1)];
	[[v layer] setShadowOpacity: 0.2];
	[[v layer] setShadowRadius: 4];
    UILabel * l = [[UILabel alloc] initWithFrame: CGRectMake(8, 12, 300, 24)];
    [l setText: (section == 0) ? @"ACCOUNTS" : @"TAGS"];
	[l setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
	[l setTextColor: [UIColor colorWithRed:112.0/255.0 green:114.0/255.0 blue:116.0/255.0 alpha:1]];
    [v addSubview: l];
    return v;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"sidebarcell"];
        INNamespace * namespace = [[[INAPIManager shared] namespaces] objectAtIndex: [indexPath row]];
        [[cell textLabel] setText: [namespace emailAddress]];
        [[cell detailTextLabel] setText: @""];
        
		if ([namespace isEqual: [[INAppDelegate current] currentNamespace]])
			[[cell imageView] setImage: [UIImage imageNamed: @"sidebar_account_on.png"]];
		else
			[[cell imageView] setImage: [UIImage imageNamed: @"sidebar_account_off.png"]];

        return cell;

    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"sidebarcell"];
        INTag * tag = [[self displayedTags] objectAtIndex: [indexPath row]];
        INNamespace * namespace = [[INAppDelegate current] currentNamespace];
        
        BOOL hasNoUnread = ([[tag ID] isEqualToString: INTagIDDraft] || [[tag ID] isEqualToString: INTagIDArchive] || [[tag ID] isEqualToString: INTagIDSent]);
        if (!hasNoUnread) {
            NSPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                [NSComparisonPredicate predicateWithFormat: @"namespaceID = %@", namespace.ID],
                [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = 'unread'"],
                [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", [tag ID]]
            ]];
            [[INDatabaseManager shared] countModelsOfClass:[INThread class] matching: predicate withCallback:^(long count) {
                [[cell detailTextLabel] setText: [NSString stringWithFormat:@"%ld", count]];
            }];
        }
        
		UIImage * presetImage = [UIImage imageNamed: [NSString stringWithFormat: @"sidebar_icon_%@.png", [[tag name] lowercaseString]]];
		if (presetImage)
			[[cell imageView] setImage: presetImage];
		else
			[[cell imageView] setImage: nil];
			
        [[cell textLabel] setText: [tag name]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0) {
		[tableView deselectRowAtIndexPath: indexPath animated: NO];
		
		INNamespace * namespace = [[[INAPIManager shared] namespaces] objectAtIndex: [indexPath row]];
		[[INAppDelegate current] setCurrentNamespace: namespace];
		[[[INAppDelegate current] mainViewController] setTag: [INTag instanceWithID: INTagIDInbox]];
		
	} else {
        INTag * tag = [[self displayedTags] objectAtIndex: [indexPath row]];
		[[[INAppDelegate current] mainViewController] setTag: tag];
	}
	
	[[[INAppDelegate current] slidingViewController] closeSlider:YES completion:NULL];
}

- (void)providerDataChanged
{
	INTag * tag = [[[INAppDelegate current] mainViewController] tag];
	NSInteger index = [[[self displayedTags] valueForKey: @"ID"] indexOfObject: [tag ID]];

	NSIndexPath * ip = nil;
	if (index != NSNotFound)
		ip = [NSIndexPath indexPathForRow:index inSection:1];

	[_tableView reloadData];
	[_tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
}

@end
