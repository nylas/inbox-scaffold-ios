//
//  INViewController.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INModelProvider.h"
#import "INContact.h"

@interface INViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, INModelProviderDelegate>
{
	INModelProvider * _contactsProvider;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
