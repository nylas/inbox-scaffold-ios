//
//  BPopdownMenu.h
//  Bloganizer
//
//  Created by Ben Gotow on 7/10/13.
//  Copyright (c) 2013 Bloganizer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPopdownMenu;

@protocol BPopdownMenuDelegate <NSObject>

- (void)popdownMenu:(BPopdownMenu*)menu optionSelected:(int)index;

@end

@interface BPopdownMenu : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UIImageView * _arrow;
    UITableView * _tableView;
    int _optionChecked;
}

@property (nonatomic, assign) NSObject<BPopdownMenuDelegate>* delegate;
@property (nonatomic, retain) NSArray * options;

- (id)init;

- (void)setCheckedItemIndex:(int)index;

@end
