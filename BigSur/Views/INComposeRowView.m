//
//  INComposeRowView.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRowView.h"

@implementation INComposeRowView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_rowLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		_rowLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[_rowLabel setTextColor: [UIColor colorWithWhite:0.65 alpha:1]];
		[_rowLabel setFont: [UIFont systemFontOfSize: 15]];
		[_rowLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		[self addSubview: _rowLabel];
		
		_actionButton = [UIButton buttonWithType: UIButtonTypeCustom];
		[_actionButton setTranslatesAutoresizingMaskIntoConstraints: NO];
		[_actionButton setTitleColor: [_rowLabel textColor] forState:UIControlStateNormal];
		[[_actionButton titleLabel] setFont: [UIFont boldSystemFontOfSize: 35]];
		[_actionButton setFrame: CGRectMake(0, 0, 30, 30)];
		[self addSubview: _actionButton];
		
		_bottomBorder = [[CALayer alloc] init];
		[_bottomBorder setBorderColor: [[UIColor colorWithWhite:0.84 alpha:1] CGColor]];
		[_bottomBorder setBorderWidth: 1.0 / [[UIScreen mainScreen] scale]];
		[[self layer] addSublayer: _bottomBorder];

		[self setClipsToBounds: YES];
		[self setBackgroundColor: [UIColor whiteColor]];
    }
    return self;
}

- (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	[self setNeedsUpdateConstraints];

	[_bottomBorder setFrame: CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height)];
}

- (void)updateConstraints
{
	NSDictionary * views = @{@"label":_rowLabel, @"body": _bodyView, @"action": _actionButton};
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(7)-[label]-(2)-[body]-[action(==30)]-(5)-|" options:0 metrics:nil views: views]];
	[self addConstraint: [NSLayoutConstraint constraintWithItem:_rowLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:_actionButton attribute:NSLayoutAttributeBaseline multiplier:1 constant:-4]];
	[super updateConstraints];
}

@end
