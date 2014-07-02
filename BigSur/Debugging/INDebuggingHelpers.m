//
//  INDebuggingHelpers.m
//  BigSur
//
//  Created by Ben Gotow on 6/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//


void scrollLikeACrazyMan(UITableView* tableView)
{
    [tableView setContentOffset: CGPointMake(0,1000) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView setContentOffset: CGPointMake(0,0) animated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        scrollLikeACrazyMan(tableView);
    });
}
