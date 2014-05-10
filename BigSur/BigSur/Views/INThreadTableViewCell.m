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

#define INSETS UIEdgeInsetsMake(8, 10, 8, 12)

@implementation INThreadTableViewCell

- (id)initWithReuseIdentifier:(NSString*)identifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		[[[self imageView] layer] setCornerRadius: 3];
		[[[self imageView] layer] setMasksToBounds:YES];
		
		_participantsLabel = [[INRecipientsLabel alloc] initWithFrame: CGRectZero];
		[_participantsLabel setTextColor: [UIColor colorWithWhite:0.2 alpha:1]];
		[_participantsLabel setTextFont: [UIFont systemFontOfSize: 13]];
		[self addSubview: _participantsLabel];
		
		_dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_dateLabel setFont: [UIFont systemFontOfSize: 13]];
		[_dateLabel setTextColor: [UIColor grayColor]];
		[self addSubview: _dateLabel];
		
		_bodyLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		_subjectLabel = [self textLabel];
		[_subjectLabel setFont: [UIFont boldSystemFontOfSize: 15]];
		
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
	
	[[self imageView] setFrame: CGRectMake(INSETS.left, INSETS.top, 40, 40)];
	
	float textX = INSETS.left + 40 + INSETS.left;
	float textW = f.size.width - textX - INSETS.right;
	[_participantsLabel setFrame: CGRectMake(textX, INSETS.top, _dateLabel.frame.origin.x - textX, 16)];
	[_subjectLabel setFrame: CGRectMake(textX, [_participantsLabel bottomRight].y, textW, 20)];
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
			
	[[self imageView] setImageWithURL:[NSURL URLForGravatar: otherEmail] placeholderImage:[UIImage imageNamed: @"profile_placeholder.png"]];

	BOOL includeMe = (([[_thread messageIDs] count] > 1) || ([[_thread participants] count] > 2));
	[_participantsLabel setPrefixString: @"" andRecipients:[_thread participants] includeMe: includeMe];
	[_subjectLabel setText: [_thread subject]];

	NSString * cleanSnippet = [[_thread snippet] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[_bodyLabel setText: cleanSnippet];
	
	[_dateLabel setText: [NSString stringForMessageDate: [_thread lastMessageDate]]];
}

@end
