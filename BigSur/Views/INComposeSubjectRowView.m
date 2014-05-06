//
//  INComposeSubjectRowView.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeSubjectRowView.h"

@implementation INComposeSubjectRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_subjectField = [[UITextView alloc] initWithFrame: CGRectZero];
		[_subjectField setText: @"Bla"];
		[_subjectField setScrollEnabled: NO];
		[_subjectField setTextContainerInset: UIEdgeInsetsZero];
		[_subjectField setTranslatesAutoresizingMaskIntoConstraints: NO];
		[_subjectField setFont: [UIFont systemFontOfSize: 15]];
		[_subjectField setBackgroundColor: [UIColor clearColor]];
		[self addSubview: _subjectField];
		
		self.bodyView = _subjectField;
    }
    return self;
}

- (void)updateConstraints
{
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(12)-[body]-(16)-|" options:0 metrics:nil views: @{@"body":self.bodyView}]];
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(12)-[label]" options:0 metrics:nil views: @{@"label": self.rowLabel}]];
	[super updateConstraints];
}


@end
