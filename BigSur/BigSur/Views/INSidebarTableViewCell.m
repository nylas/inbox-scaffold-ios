//
//  INSidebarTableViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INSidebarTableViewCell.h"

@implementation INSidebarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
