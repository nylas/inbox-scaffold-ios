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
		[[self textLabel] setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
		[[self textLabel] setTextColor: [UIColor whiteColor]];
		[[self detailTextLabel] setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
		[[self detailTextLabel] setTextColor: [UIColor colorWithWhite:1 alpha:0.5]];
        [[self detailTextLabel] setTextAlignment: NSTextAlignmentRight];
		[self setBackgroundColor: [UIColor colorWithWhite:0 alpha:0.05]];
		
		[self setSelectedBackgroundView: [[UIView alloc] init]];
		[[self selectedBackgroundView] setBackgroundColor: [UIColor colorWithWhite:0 alpha:0.3]];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[[self imageView] setContentMode: UIViewContentModeCenter];
	
	float h = self.frame.size.height;
	[[self imageView] setFrame: CGRectMake(8, (h-20)/2 + 1, 20, 20)];
	[[self textLabel] setFrame: CGRectMake(8 + 20 + 8, 0, self.frame.size.width, h-1)];
	[[self detailTextLabel] setFrame: CGRectMake(self.frame.size.width - 66, 0, 50, h)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
