//
//  INThreadTableViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INRecipientsLabel.h"

@interface INThreadTableViewCell : UITableViewCell

@property (nonatomic, strong) INThread * thread;
@property (nonatomic, strong) UILabel * threadCountLabel;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * bodyLabel;
@property (nonatomic, strong) UIView * unreadDot;
@property (nonatomic, strong) UILabel * subjectLabel;
@property (nonatomic, strong) INRecipientsLabel * participantsLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
