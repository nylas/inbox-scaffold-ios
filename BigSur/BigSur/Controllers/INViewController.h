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

@interface INViewController : INRootViewController <UITableViewDataSource, UITableViewDelegate, INModelProviderDelegate, UISearchBarDelegate>
{
	float _scrollViewPrevOffset;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIRefreshControl * refreshControl;
@property (strong, nonatomic) IBOutlet INInboxNavTitleView * titleView;

@property (strong, nonatomic) NSPredicate * threadPredicate;
@property (strong, nonatomic) INThreadProvider * threadProvider;


@end
