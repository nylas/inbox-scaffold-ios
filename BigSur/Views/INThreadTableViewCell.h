//
//  INThreadTableViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMailItemTableViewCell.h"

@interface INThreadTableViewCell : INMailItemTableViewCell

@property (nonatomic, strong) INThread * thread;

@property (nonatomic, strong) UILabel * threadCountLabel;
@property (nonatomic, strong) UIView * unreadDot;

@end
