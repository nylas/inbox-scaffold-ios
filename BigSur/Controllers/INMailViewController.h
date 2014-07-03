//
//  INViewController.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INRootViewController.h"
#import "INInboxNavTitleView.h"


@interface INMailViewController : INRootViewController <UITableViewDataSource, UITableViewDelegate, INModelProviderDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIRefreshControl * refreshControl;
@property (strong, nonatomic) IBOutlet INInboxNavTitleView * titleView;

@property (strong, nonatomic) INModelProvider * provider;

#pragma Actions

- (IBAction)composeTapped:(id)sender;

#pragma Refreshing & Thread Ppovider

- (void)setProvider:(INModelProvider*)provider;
- (void)setProvider:(INModelProvider *)provider andTitle:(NSString*)title;

@end
