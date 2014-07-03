//
//  INChangeQueueViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INTaskQueueViewController : UITableViewController <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *suspendedSwitch;

@end
