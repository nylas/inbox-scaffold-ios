//
//  INChangeQueueViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INTaskQueueViewController.h"

@implementation INTaskQueueViewController


- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(update) name:INTaskQueueChangedNotification object:nil];
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
    [_suspendedSwitch setOn: ![[INAPIManager shared] taskQueueSuspended]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[INAPIManager shared] taskQueue] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INAPITask * change = [[[INAPIManager shared] taskQueue] objectAtIndex: [indexPath row]];
    CGRect bounding = [[change description] boundingRectWithSize:CGSizeMake(300, INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    return bounding.size.height + 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INAPITask * change = [[[INAPIManager shared] taskQueue] objectAtIndex: [indexPath row]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    UITextView * text = (UITextView*)[cell viewWithTag: 1];
    [text setText: [change description]];
    return cell;
}

- (IBAction)taskQueueSuspendedToggled:(id)sender
{
    [[INAPIManager shared] setTaskQueueSuspended: ![sender isOn]];
}

@end
