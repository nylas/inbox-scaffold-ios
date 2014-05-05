//
//  INRecipientsLabel.m
//  BigSur
//
//  Created by Ben Gotow on 5/2/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INRecipientsLabel.h"
#import "UIView+FrameAdditions.h"

@implementation INRecipientsLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
	[self setup];
}

- (void)setup
{
	_moreButton = [UIButton buttonWithType: UIButtonTypeCustom];
	[self addSubview: _moreButton];
}

- (void)setRecipients:(NSArray*)recipients
{
	[_buttons makeObjectsPerformSelector: @selector(removeFromSuperview)];
	_buttons = [[NSMutableArray alloc] init];
	
	[_moreButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
	[[_moreButton titleLabel] setFont: _textFont];

	BOOL firstNamesOnly = ([recipients count] > 2);
	
	for (int ii = 0; ii < [recipients count]; ii ++) {
		NSString * name = [[recipients objectAtIndex: ii] objectForKey: @"name"];
		if (firstNamesOnly && ([name rangeOfString:@" "].location != NSNotFound))
			name = [name substringToIndex: [name rangeOfString: @" "].location];
		if ([name length] == 0)
			name = [[recipients objectAtIndex: ii] objectForKey: @"email"];
	
		if (ii == [recipients count] - 2)
			name = [name stringByAppendingString: @" and "];
		else if (ii < (int)[recipients count] - 2)
			name = [name stringByAppendingString: @", "];
		
		UIButton * b = [UIButton buttonWithType: UIButtonTypeCustom];
		[b setTitle:name forState:UIControlStateNormal];
		[[b titleLabel] setFont: _textFont];
		[b setTitleColor: _textColor forState:UIControlStateNormal];
		[_buttons addObject: b];
		[self addSubview: b];
	}
	
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	float x = 0;
	BOOL hide = NO;
	int hidden = 0;
	
	for (UIButton * b in _buttons) {
		[b setFrame: CGRectMake(x, 0, 1000, self.frame.size.height)];
		[b sizeToFit];
		[b setFrameHeight: self.frame.size.height];
		
		if (x + [b frame].size.width > self.frame.size.width - 50)
			hide = YES;
		
		if (hide) {
			[b setHidden:YES];
			hidden ++;
			continue;
		} else {
			x += [b frame].size.width;
		}
	}
	
	NSString * moreLabel = [NSString stringWithFormat: @"%d more...", hidden];
	[_moreButton setTitle:moreLabel forState:UIControlStateNormal];
	[_moreButton sizeToFit];
	[_moreButton setFrameHeight: self.frame.size.height];
	[_moreButton setFrameX: x];
	[_moreButton setHidden: (hidden == 0)];
}
@end
