//
//  INViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INViewController.h"


@implementation INViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSPredicate * predicate = [NSComparisonPredicate predicateWithFormat:@"name LIKE 'Ben G'"];
    NSSortDescriptor * nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    _contactsProvider = [INModelProvider providerForClass: [INContact class]];
    [_contactsProvider setPredicate: predicate];
    [_contactsProvider setSortDescriptors: @[nameSortDescriptor]];
    [_contactsProvider setDelegate: self];
    [_contactsProvider refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)providerDataRefreshed
{
    [_tableView reloadData];
}

- (void)providerDataAltered:(NSArray*)changes
{
    [_tableView reloadData];
}

#pragma mark Table View Data Source

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_contactsProvider items] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    INContact * contact = [[_contactsProvider items] objectAtIndex: [indexPath row]];
    NSString * label = [contact name];
    [[cell textLabel] setText: label];
    
    return cell;
}

@end
