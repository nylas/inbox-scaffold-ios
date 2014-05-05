//
//  INThreadTableViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThreadTableViewCell.h"
#import "NSString+FormatConversion.h"
#import "UIView+FrameAdditions.h"
#import "INConvenienceCategories.h"

#define INSETS UIEdgeInsetsMake(8, 10, 8, 12)

@implementation INThreadTableViewCell

- (id)initWithReuseIdentifier:(NSString*)identifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		[[[self imageView] layer] setCornerRadius: 3];
		[[[self imageView] layer] setMasksToBounds:YES];
		
		_dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_dateLabel setFont: [UIFont systemFontOfSize: 13]];
		[_dateLabel setTextColor: [UIColor grayColor]];
		[self addSubview: _dateLabel];
		
		_participantsLabel = [[INRecipientsLabel alloc] initWithFrame: CGRectZero];
		[_participantsLabel setTextColor: [UIColor colorWithWhite:0.2 alpha:1]];
		[_participantsLabel setTextFont: [UIFont systemFontOfSize: 13]];
		[self addSubview: _participantsLabel];
		
		_bodyLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		_subjectLabel = [self textLabel];
		[_subjectLabel setFont: [UIFont boldSystemFontOfSize: 15]];
		
		[_bodyLabel setTextColor: [UIColor grayColor]];
		[_bodyLabel setFont: [UIFont systemFontOfSize: 14]];
		[_bodyLabel setNumberOfLines: 2];
		[self addSubview: _bodyLabel];
	}
	return self;
}

- (void)layoutSubviews
{
	CGRect f = self.frame;
	
	[super layoutSubviews];
	
	[_dateLabel sizeToFit];
	[_dateLabel setFrameOrigin: CGPointMake(f.size.width - INSETS.right - _dateLabel.frame.size.width, INSETS.top)];
	
	[[self imageView] setFrame: CGRectMake(INSETS.left, INSETS.top, 40, 40)];
	
	float textX = INSETS.left + 40 + INSETS.left;
	float textW = f.size.width - textX - INSETS.right;
	[_participantsLabel setFrame: CGRectMake(textX, INSETS.top, _dateLabel.frame.origin.x - textX, 16)];
	[_subjectLabel setFrame: CGRectMake(textX, [_participantsLabel bottomRight].y, textW, 20)];
	[_bodyLabel setFrame: CGRectMake(textX, [_subjectLabel bottomRight].y, textW, 36)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setThread:(INThread *)thread
{
	_thread = thread;
	
	[[self imageView] setImage: [UIImage imageNamed: @"profile_placeholder.png"]];

	[_participantsLabel setRecipients:[_thread participants]];
	[_subjectLabel setText: [_thread subject]];
	[_bodyLabel setText: @"So glad to hear you guys will makei t to the BBQ this year! It looks like it'll be a great time but this is too much text."];
	
	[[self dateLabel] setText: [NSString stringForMessageDate: [_thread lastMessageDate]]];
}

@end
