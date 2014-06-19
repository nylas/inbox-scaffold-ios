//
//  INThreadTableViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INRecipientsLabel.h"

#define INSETS UIEdgeInsetsMake(8, 10, 8, 10)

@class INMailItemTableViewCell;

typedef void (^ DetatchBlock)(INMailItemTableViewCell * cell);

@interface INMailItemTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * bodyLabel;
@property (nonatomic, strong) UILabel * subjectLabel;
@property (nonatomic, strong) INRecipientsLabel * participantsLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
