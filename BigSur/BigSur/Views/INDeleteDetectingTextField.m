//
//  INDeleteDetectingTextField.m
//  Pods
//
//  Created by Ben Gotow on 5/6/14.
//
//

#import "INDeleteDetectingTextField.h"

@implementation INDeleteDetectingTextField

- (void)deleteBackward
{
    BOOL noTextToDelete = (self.text.length == 0);
	BOOL noInsertionPoint = [[self tintColor] isEqual: [UIColor clearColor]];
	
	if ((noTextToDelete || noInsertionPoint) && _didDeleteBlock)
		_didDeleteBlock();
	else
	    [super deleteBackward];
}

- (void)hideInsertionPoint
{
	[self setTintColor: [UIColor clearColor]];
}

- (void)showInsertionPoint
{
	[self setTintColor: [UIColor blueColor]];
}

@end
