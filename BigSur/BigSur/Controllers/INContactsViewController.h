//
//  INContactsViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ ContactSelectionBlock)(INContact * object);

@interface INContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, INModelProviderDelegate>

@property (nonatomic, strong) INModelProvider * contactsProvider;
@property (nonatomic, strong) ContactSelectionBlock contactSelectionCallback;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

- (id)initForSelectingContactWithCallback:(ContactSelectionBlock)block;

@end
