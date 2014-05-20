//
//  INDismissSegue.m
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INDismissSegue.h"

@implementation INDismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
