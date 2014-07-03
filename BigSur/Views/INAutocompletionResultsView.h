//
//  INAutocompletionResultsView.h
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol INAutocompletionResultsViewDelegate <NSObject>
@optional
- (void)autocompletionResultPicked:(id)item;

@end

@interface INAutocompletionResultsView : UIView <INModelProviderDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) NSObject<INAutocompletionResultsViewDelegate> * delegate;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) INModelProvider * provider;

- (void)setProvider:(INModelProvider *)provider;

@end
