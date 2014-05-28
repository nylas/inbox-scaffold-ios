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
#import "UIImage+BlurEffects.h"
#import "UIView+FrameAdditions.h"

#define BUILT_IN_TAGS @[INTagIDInbox, INTagIDStarred, INTagIDSent, INTagIDArchive]

static NSString * INSidebarItemTypeDrafts = @"drafts";
static NSString * INSidebarItemTypeTag = @"tag";
static NSString * INSidebarItemTypeNamespace = @"namespace";

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

- (void)refresh
{
    if (![[_tagProvider namespaceID] isEqualToString: [[[INAppDelegate current] currentNamespace] ID]]) {
        _tagProvider = [[[INAppDelegate current] currentNamespace] newTagProvider];
        [_tagProvider setDelegate: self];
    }
    [_tagProvider refresh];
}

- (IBAction)unauthenticateTapped:(id)sender
{
	[[[INAppDelegate current] slidingViewController] closeSlider:YES completion:^{
        [[INAPIManager shared] unauthenticate];
    }];
}

- (IBAction)syncStatusTapped:(id)sender
{
	[[[INAppDelegate current] slidingViewController] closeSlider:YES completion:^{
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"INInternalInfoStoryboard" bundle:nil];
        [self.parentViewController presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:NULL];

    }];
}

#pragma mark Table View

- (void)selectItemWithName:(NSString*)name
{
    _tableViewSelectedItemName = name;
    
    for (int s = 0; s < [[self tableSectionData] count]; s++) {
        NSArray * items = [[[self tableSectionData] objectAtIndex: s] objectForKey:@"items"];
        for (int r = 0; r < [items count]; r ++) {
            if ([[items objectAtIndex: r][@"name"] isEqualToString: _tableViewSelectedItemName]) {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow: r inSection: s] animated:NO scrollPosition:UITableViewScrollPositionNone];
                return;
            }
        }
    }
}

- (NSArray *)tableSectionData
{
    if (!_tableSectionData) {
        NSMutableArray * namespaces = [NSMutableArray array];
        for (INNamespace * namespace in [[INAPIManager shared] namespaces])
            [namespaces addObject: @{@"type": INSidebarItemTypeNamespace, @"name": [namespace emailAddress], @"namespace": namespace}];
        
        NSMutableArray * builtin = [NSMutableArray array];
        for (NSString * ID in BUILT_IN_TAGS) {
            INTag * tag = [INTag tagWithID: ID];
            [builtin addObject: @{@"type": INSidebarItemTypeTag, @"name": [tag name], @"tag": tag}];
        }
        [builtin addObject: @{@"type": INSidebarItemTypeDrafts, @"name": @"Drafts"}];
        
        NSMutableArray * usertags = [NSMutableArray array];
        for (INTag * tag in [_tagProvider items]) {
            if ([BUILT_IN_TAGS containsObject: [tag ID]])
                continue;
            [usertags addObject: @{@"type": INSidebarItemTypeTag, @"name": [tag ID], @"tag": tag}];
        }
        
        _tableSectionData =  @[@{@"label":@"ACCOUNTS", @"items": namespaces},
                             @{@"label": @"", @"items": builtin},
                             @{@"label": @"TAGS", @"items": usertags}];
    }

    return _tableSectionData;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self tableSectionData] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSDictionary * section = [[self tableSectionData] objectAtIndex: sectionIndex];
    return [section[@"items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 36;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    UIView * v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 36)];
	[v setBackgroundColor: [_tableView backgroundColor]];
	[[v layer] setShadowColor: [[_tableView backgroundColor] CGColor]];
	[[v layer] setShadowOffset: CGSizeMake(0, 1)];
	[[v layer] setShadowOpacity: 0.2];
	[[v layer] setShadowRadius: 4];
    UILabel * l = [[UILabel alloc] initWithFrame: CGRectMake(8, 12, 300, 24)];
	[l setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
	[l setTextColor: [UIColor colorWithRed:112.0/255.0 green:114.0/255.0 blue:116.0/255.0 alpha:1]];
    [v addSubview: l];
    
    NSDictionary * section = [[self tableSectionData] objectAtIndex: sectionIndex];
    [l setText: section[@"label"]];

    return v;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"sidebarcell"];
    NSDictionary * section = [[self tableSectionData] objectAtIndex: [indexPath section]];
    NSDictionary * item = [section[@"items"] objectAtIndex: [indexPath row]];
    
    [[cell textLabel] setText: item[@"name"]];

    if (item[@"type"] == INSidebarItemTypeNamespace) {
        [[cell detailTextLabel] setText: @""];
		if ([item[@"namespace"] isEqual: [[INAppDelegate current] currentNamespace]])
			[[cell imageView] setImage: [UIImage imageNamed: @"sidebar_account_on.png"]];
		else
			[[cell imageView] setImage: [UIImage imageNamed: @"sidebar_account_off.png"]];

        
    } else if (item[@"type"] == INSidebarItemTypeDrafts){
        [[cell imageView] setImage: [UIImage imageNamed:@"sidebar_icon_draft.png"]];
        
        
    } else if (item[@"type"] == INSidebarItemTypeTag){
        INTag * tag = item[@"tag"];
        INNamespace * namespace = [[INAppDelegate current] currentNamespace];
        
        BOOL hasNoUnread = ([[tag ID] isEqualToString: INTagIDArchive] || [[tag ID] isEqualToString: INTagIDSent]);
        if (!hasNoUnread) {
            NSPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                [NSComparisonPredicate predicateWithFormat: @"namespaceID = %@", namespace.ID],
                [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", INTagIDUnread],
                [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", [tag ID]]
            ]];
            [[INDatabaseManager shared] countModelsOfClass:[INThread class] matching: predicate withCallback:^(long count) {
                [[cell detailTextLabel] setText: [NSString stringWithFormat:@"%ld", count]];
            }];
        }
        
		UIImage * presetImage = [UIImage imageNamed: [NSString stringWithFormat: @"sidebar_icon_%@.png", [[tag name] lowercaseString]]];
		if (presetImage)
			[[cell imageView] setImage: presetImage];
		else {
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, [[UIScreen mainScreen] scale]);
			CGContextRef c = UIGraphicsGetCurrentContext();
			CGContextSetFillColorWithColor(c, [[tag color] CGColor]);
			CGContextFillEllipseInRect(c, CGRectMake(3, 3, 14, 14));
			UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			[[cell imageView] setImage: image];
		}
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * section = [[self tableSectionData] objectAtIndex: [indexPath section]];
    NSDictionary * item = [section[@"items"] objectAtIndex: [indexPath row]];

    _tableViewSelectedItemName = item[@"name"];

    if (item[@"type"] == INSidebarItemTypeNamespace) {
		[tableView deselectRowAtIndexPath: indexPath animated: NO];
		[[INAppDelegate current] setCurrentNamespace: item[@"namespace"]];

    } else if (item[@"type"] == INSidebarItemTypeTag){
        [[INAppDelegate current] showThreadsWithTag: item[@"tag"]];
		
    } else if (item[@"type"] == INSidebarItemTypeDrafts){
        [[INAppDelegate current] showDrafts];
    }
    
	[[[INAppDelegate current] slidingViewController] closeSlider:YES completion:NULL];
}

#pragma mark Tag Provider

- (void)providerDataChanged:(INModelProvider*)provider
{
    _tableSectionData = nil;
	[_tableView reloadData];

    [self selectItemWithName: _tableViewSelectedItemName];
}

@end
