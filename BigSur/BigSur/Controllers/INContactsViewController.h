//
//  INContactsViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, INModelProviderDelegate>

@property (nonatomic, strong) INModelProvider * contactsProvider;

@property (nonatomic, weak) IBOutlet UITableView * tableView;

@end
