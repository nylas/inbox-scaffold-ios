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
#import "UIImageView+AFNetworking.h"
#import "INConvenienceCategories.h"
#import "INThemeManager.h"

#define INSETS UIEdgeInsetsMake(8, 10, 8, 10)

@implementation INThreadTableViewCell

- (id)initWithReuseIdentifier:(NSString*)identifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		_participantsLabel = [[INRecipientsLabel alloc] initWithFrame: CGRectZero];
		[_participantsLabel setTextColor: [UIColor colorWithWhite:0.2 alpha:1]];
		[_participantsLabel setTextFont: [UIFont systemFontOfSize: 13]];
		[self addSubview: _participantsLabel];
		
		_unreadDot = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 14, 14)];
		[_unreadDot setBackgroundColor: [[INThemeManager shared] tintColor]];
		[[_unreadDot layer] setCornerRadius: _unreadDot.frame.size.width / 2];
		[self addSubview: _unreadDot];
		
		_dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_dateLabel setFont: [UIFont systemFontOfSize: 13]];
		[_dateLabel setTextColor: [UIColor grayColor]];
		[_dateLabel setTextAlignment: NSTextAlignmentRight];
		[self addSubview: _dateLabel];
		
		_threadCountLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_threadCountLabel setFont: [UIFont systemFontOfSize: 13]];
		[_threadCountLabel setTextColor: [UIColor grayColor]];
		[_threadCountLabel setTextAlignment: NSTextAlignmentCenter];
		[[_threadCountLabel layer] setBorderWidth: 1];
		[[_threadCountLabel layer] setCornerRadius: 3];
		[[_threadCountLabel layer] setBorderColor: [[UIColor colorWithWhite:0.7 alpha:1] CGColor]];
		[self addSubview: _threadCountLabel];
		
		_bodyLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_bodyLabel setLineBreakMode: NSLineBreakByWordWrapping];
		_subjectLabel = [self textLabel];
		[_subjectLabel setFont: [UIFont boldSystemFontOfSize: 15]];
		[_subjectLabel setContentMode: UIViewContentModeCenter];
		
		[_bodyLabel setTextColor: [UIColor grayColor]];
		[_bodyLabel setFont: [UIFont systemFontOfSize: 13]];
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
	
	float textX = 40;
	float textW = f.size.width - textX - INSETS.right;
	
	if ([[_threadCountLabel text] length]){
		CGSize s = [[_threadCountLabel text] sizeWithAttributes: @{NSFontAttributeName: [_threadCountLabel font]}];
		s.width += 8;
		s.height += 4;
		[_threadCountLabel setFrame: CGRectMake(f.size.width - INSETS.right - s.width, (f.size.height - s.height) / 2, s.width, s.height)];
		[_threadCountLabel setHidden: NO];
		textW -= s.width + INSETS.right;

	} else {
		[_threadCountLabel setHidden: YES];
	}
	
	[_participantsLabel setFrame: CGRectMake(textX, INSETS.top, _dateLabel.frame.origin.x - textX, 16)];
	[_subjectLabel setFrame: CGRectMake(textX, [_participantsLabel bottomRight].y, textW, 20)];
	[_unreadDot setFrameCenter: CGPointMake(20, _subjectLabel.center.y)];
	[_bodyLabel setFrame: CGRectMake(textX, [_subjectLabel bottomRight].y, textW, 35)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setThread:(INThread *)thread
{
	_thread = thread;
	
	NSArray * youAddresses = [[INAPIManager shared] namespaceEmailAddresses];
	NSString * otherEmail = nil;
	for (NSDictionary * recipient in _thread.participants) {
		if ([youAddresses containsObject: recipient[@"email"]])
			continue;
		otherEmail = recipient[@"email"];
		break;
	}

	BOOL includeMe = (([[_thread messageIDs] count] > 1) || ([[_thread participants] count] > 2));
	[_participantsLabel setPrefixString: @"" andRecipients:[_thread participants] includeMe: includeMe];
	[_dateLabel setText: [NSString stringForMessageDate: [_thread lastMessageDate]]];
	[_subjectLabel setText: [_thread subject]];
	
	if ([[_thread messageIDs] count] > 1)
		[_threadCountLabel setText: [NSString stringWithFormat:@"%d", [[_thread messageIDs] count]]];
	else
		[_threadCountLabel setText: @""];
		
	NSString * cleanSnippet = [[_thread snippet] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[_bodyLabel setText: cleanSnippet];
}

@end
