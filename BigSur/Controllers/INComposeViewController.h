//
//  INComposeViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INThread.h"

@interface INComposeViewController : UIViewController

@property (nonatomic, strong) INThread * thread;

- (id)initWithThread:(INThread*)thread;

@end
