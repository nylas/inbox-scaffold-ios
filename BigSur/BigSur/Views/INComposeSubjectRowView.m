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
		_subjectField = [[INPlaceholderTextView alloc] initWithFrame: CGRectZero];
		[_subjectField setText: @""];
		[_subjectField setPlaceholder: @"Subject"];
        [_subjectField setDelegate: self];
        [_subjectField setReturnKeyType: UIReturnKeyNext];
		[_subjectField setScrollEnabled: NO];
		[_subjectField setTextContainerInset: UIEdgeInsetsZero];
		[_subjectField setTranslatesAutoresizingMaskIntoConstraints: NO];
		[_subjectField setFont: [UIFont systemFontOfSize: 15]];
		[_subjectField setBackgroundColor: [UIColor clearColor]];
		[self addSubview: _subjectField];
		
		[self.actionButton setImage: [UIImage imageNamed: @"icon_add_attachment.png"] forState:UIControlStateNormal];
		[self.rowLabel setText: @""];
		
		self.bodyView = _subjectField;
    }
    return self;
}

- (void)updateConstraints
{
	NSDictionary * views = @{@"body":self.bodyView, @"label": self.rowLabel, @"action": self.actionButton};
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(12)-[body]-(16)-|" options:0 metrics:nil views: views]];
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[action]" options:0 metrics:nil views: views]];
	
	[super updateConstraints];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * newText = [[textView text] stringByReplacingCharactersInRange:range withString:text];

    // if the user has inserted a tab or return, reject the change and move to the next text field.
    // Unfortunately iOS doesn't expose any equivalent to Mac OS X's nextKeyResponder, so we have
    // to do it ourselves. The simplest way is to look at our sibling views and find the next one
    // that can become first responder.
    if (([newText rangeOfString: @"\n"].location != NSNotFound) || ([newText rangeOfString: @"\t"].location != NSNotFound)) {

        NSArray * siblings = [[self superview] subviews];
        int ii = [siblings indexOfObject: self];
        for (int x = ii; x < [siblings count]; x++){
            UIView * v = [siblings objectAtIndex: x];
            if ([v canBecomeFirstResponder]) {
                [v becomeFirstResponder];
                break;
            }
        }
        return NO;
    }
    return YES;
}

@end
