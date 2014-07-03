//
//  ViewController.m
//  TinderPaging
//
//  Created by Ben Gotow on 6/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    UIColor * lightGreen = [UIColor colorWithRed:0.5 green:1 blue:0.5 alpha:1];
    NSAssert([self.view.backgroundColor isEqual: lightGreen] == NO, @"Already fired willAppear!");
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
        [UIView setAnimationBeginsFromCurrentState: YES];
        [self.view setBackgroundColor: lightGreen];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSAssert([self.view.backgroundColor isEqual: [UIColor greenColor]] == NO, @"Already fired didAppear!");
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
        [UIView setAnimationBeginsFromCurrentState: YES];
        [self.view setBackgroundColor: [UIColor greenColor]];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIColor * lightRed = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
    NSAssert([self.view.backgroundColor isEqual: lightRed] == NO, @"Already fired willDisppear!");
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
        [UIView setAnimationBeginsFromCurrentState: YES];
        [self.view setBackgroundColor: lightRed];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSAssert([self.view.backgroundColor isEqual: [UIColor redColor]] == NO, @"Already fired didDisappear!");
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
        [UIView setAnimationBeginsFromCurrentState: YES];
        [self.view setBackgroundColor: [UIColor redColor]];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareHeaderViews:(INPagingContainerViewController*)controller
{
    UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 20)];
    [label setText: @"Label Here!"];

    [controller declareHeaderView:label withName:@"label"];
}

@end
