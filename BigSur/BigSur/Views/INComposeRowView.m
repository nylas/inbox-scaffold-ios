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
		[_rowLabel setTextColor: [UIColor colorWithWhite:0.7 alpha:1]];
		[_rowLabel setFont: [UIFont systemFontOfSize: 15]];
		[_rowLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		[self addSubview: _rowLabel];
		
		_actionButton = [UIButton buttonWithType: UIButtonTypeCustom];
		[_actionButton setTranslatesAutoresizingMaskIntoConstraints: NO];
		[_actionButton setTitleColor: [_rowLabel textColor] forState:UIControlStateNormal];
		[[_actionButton titleLabel] setFont: [UIFont boldSystemFontOfSize: 35]];
		[_actionButton setFrame: CGRectMake(0, 0, 40, 40)];
        [_actionButton setHidden: YES];
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

	[CATransaction begin];
	[CATransaction setDisableActions: !_animatesBottomBorder];
	[_bottomBorder setFrame: CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height)];
	[CATransaction commit];
}

- (UIButton*)actionButton
{
    [_actionButton setHidden: NO];
    return _actionButton;
}

- (void)updateConstraints
{
	NSDictionary * views = @{@"label":_rowLabel, @"body": _bodyView, @"action": _actionButton};
    BOOL hasLabel = [[_rowLabel text] length];
    BOOL hasAction = ![_actionButton isHidden];
    
    // todo: this is a little silly
    
	if (hasLabel && hasAction) {
		[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(9)-[label]-(2)-[body]-[action(==40)]-(0)-|" options:0 metrics:nil views: views]];
    } else if (hasLabel && !hasAction) {
		[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(9)-[label]-(2)-[body]-(4)-|" options:0 metrics:nil views: views]];
    } else if (!hasLabel && hasAction) {
		[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[body]-[action(==40)]-(0)-|" options:0 metrics:nil views: views]];
    } else {
		[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[body]-(4)-|" options:0 metrics:nil views: views]];
	}

	[self addConstraint: [NSLayoutConstraint constraintWithItem:_rowLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:_actionButton attribute:NSLayoutAttributeBaseline multiplier:1 constant:-4]];
	[super updateConstraints];
}

@end
