//
//  INChangeQueueViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INChangeQueueViewController.h"

@implementation INChangeQueueViewController


- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(update) name:INChangeQueueChangedNotification object:nil];
    [super viewDidLoad];
    [self update];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    [self.tableView reloadData];
    [_suspendedSwitch setOn: ![[INAPIManager shared] changeQueueSuspended]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[INAPIManager shared] changeQueue] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INModelChange * change = [[[INAPIManager shared] changeQueue] objectAtIndex: [indexPath row]];
    CGRect bounding = [[change description] boundingRectWithSize:CGSizeMake(300, INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    return bounding.size.height + 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INModelChange * change = [[[INAPIManager shared] changeQueue] objectAtIndex: [indexPath row]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    UITextView * text = (UITextView*)[cell viewWithTag: 1];
    [text setText: [change description]];
    return cell;
}

- (IBAction)changeQueueSuspendedToggled:(id)sender
{
    [[INAPIManager shared] setChangeQueueSuspended: ![sender isOn]];
}

@end
