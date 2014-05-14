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

#define DISPLAYED_SYSTEM_TAGS @[[INTag instanceWithID: INTagIDInbox], [INTag instanceWithID: INTagIDArchive]]

@implementation INSidebarViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:BigSurNamespaceChanged object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_tableView registerClass:[INSidebarTableViewCell class] forCellReuseIdentifier:@"sidebarcell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refresh
{
    [_tableView reloadData];

    if (![[_tagProvider namespaceID] isEqualToString: [[[INAppDelegate current] currentNamespace] ID]]) {
        _tagProvider = [[[INAppDelegate current] currentNamespace] newTagProvider];
        [_tagProvider setDelegate: self];
    }
    [_tagProvider refresh];
}

#pragma mark Table View

- (NSArray *)displayedTags
{
    NSMutableArray * tags = [NSMutableArray arrayWithArray: DISPLAYED_SYSTEM_TAGS];
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
    return 50;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 50)];
    UILabel * l = [[UILabel alloc] initWithFrame: CGRectMake(0, 30, 300, 20)];
    [l setText: (section == 0) ? @"ACCOUNT" : @"TAGS"];
    [v addSubview: l];
    return v;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"sidebarcell"];
        INNamespace * namespace = [[[INAPIManager shared] namespaces] objectAtIndex: [indexPath row]];
        [[cell textLabel] setText: [namespace emailAddress]];
        return cell;

    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"sidebarcell"];
        INTag * tag = [[self displayedTags] objectAtIndex: [indexPath row]];
        INNamespace * namespace = [[INAppDelegate current] currentNamespace];
        
        NSPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
            [NSComparisonPredicate predicateWithFormat: @"namespaceID = %@", namespace.ID],
            [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = 'unread'"],
            [NSComparisonPredicate predicateWithFormat: @"ANY tagIDs = %@", [tag ID]]
        ]];
        [[INDatabaseManager shared] countModelsOfClass:[INThread class] matching: predicate withCallback:^(long count) {
            [[cell detailTextLabel] setText: [NSString stringWithFormat:@"%ld", count]];
        }];
        
        [[cell textLabel] setText: [tag name]];
        return cell;
    }
}

- (void)providerDataChanged
{
    [_tableView reloadData];
}

@end
