//
//  INComposeRecipientCollectionViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/6/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRecipientCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "INConvenienceCategories.h"
#import "INThemeManager.h"

@implementation INComposeRecipientCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_insetView = [[UIView alloc] initWithFrame: CGRectZero];
		[[self contentView] addSubview: _insetView];
		
		_nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_nameLabel setTextAlignment: NSTextAlignmentCenter];
		[_nameLabel setFont: INComposeRecipientFont];
		[_insetView addSubview: _nameLabel];
		
		_profileImage = [[UIImageView alloc] initWithFrame: CGRectZero];
		[_insetView addSubview: _profileImage];

		[[_insetView layer] setBorderWidth: 1.0 / [[UIScreen mainScreen] scale]];
		[[_insetView layer] setBorderColor: [[UIColor colorWithWhite:215.0/255.0 alpha:1] CGColor]];
		[[_insetView layer] setCornerRadius: 4];

		[_insetView setClipsToBounds: YES];
		[_insetView setBackgroundColor: [UIColor colorWithWhite:244.0/255.0 alpha:1]];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect f = CGRectMake(0, INComposeRecipientVPadding, self.frame.size.width, self.frame.size.height - INComposeRecipientVPadding * 2);
	[_insetView setFrame: f];
	
	float imageWidth = _insetView.frame.size.height;
	[_nameLabel setFrame: CGRectMake(imageWidth, 0, _insetView.frame.size.width - imageWidth, _insetView.frame.size.height)];
	[_profileImage setFrame: CGRectMake(0, 0, imageWidth, _insetView.frame.size.height)];

	[super layoutSubviews];
}

- (void)setRecipient:(NSDictionary*)recipient
{
	[[self nameLabel] setText: recipient[@"name"]];
	[[self profileImage] setImageWithURL:[NSURL URLForGravatar: recipient[@"email"]] placeholderImage:[UIImage imageNamed: @"profile_placeholder.png"]];
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected: selected];
	
	if (selected) {
		[_insetView setBackgroundColor: [[INThemeManager shared] tintColor]];
		[[[self contentView] layer] setBorderColor: [[UIColor colorWithRed:0 green:0.42 blue:0.56 alpha:1] CGColor]];
	} else {
		[_insetView setBackgroundColor: [UIColor colorWithWhite:244.0/255.0 alpha:1]];
		[[[self contentView] layer] setBorderColor: [[UIColor colorWithWhite:215.0/255.0 alpha:1] CGColor]];
	}
}


@end
