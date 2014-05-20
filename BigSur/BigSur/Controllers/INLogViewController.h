//
//  INLogViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INLogViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView * appLog;
@property (nonatomic, strong) NSTimer * updateTimer;

- (IBAction)emailLog:(id)sender;
- (IBAction)clearLog:(id)sender;

@end
