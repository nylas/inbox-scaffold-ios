//
//  INAuthViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/15/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAuthViewController.h"


@implementation INAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signInTapped:(id)sender
{
    [[INAPIManager shared] signIn:^(NSError *error) {
        if (error)
            [[[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        else
            [self dismissViewControllerAnimated: YES completion:NULL];
    }];
}

@end
