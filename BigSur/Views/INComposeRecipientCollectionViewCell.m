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

		[[[self contentView] layer] setBorderWidth: 1.0 / [[UIScreen mainScreen] scale]];
		[[[self contentView] layer] setBorderColor: [[UIColor colorWithWhite:215.0/255.0 alpha:1] CGColor]];
		[[[self contentView] layer] setShadowOffset: CGSizeMake(0, 1)];
		[[[self contentView] layer] setShadowOpacity: 0.2];
		[[[self contentView] layer] setShadowRadius: 1];
		[[[self contentView] layer] setCornerRadius: 4];
		[_insetView setClipsToBounds: YES];
		[[_insetView layer] setCornerRadius: 4];

		[_insetView setBackgroundColor: [UIColor colorWithWhite:244.0/255.0 alpha:1]];
    }
    return self;
}

- (void)layoutSubviews
{
	
	[[self contentView] setFrame: CGRectMake(0, INComposeRecipientVPadding, self.frame.size.width, self.frame.size.height - INComposeRecipientVPadding * 2)];
	[_insetView setFrame: self.contentView.bounds];
	
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
		[_insetView setBackgroundColor: [UIColor colorWithRed:0 green:153.0/255.0 blue:204.0/255.0 alpha:1]];
	} else {
		[_insetView setBackgroundColor: [UIColor colorWithWhite:244.0/255.0 alpha:1]];
	}
}


@end
