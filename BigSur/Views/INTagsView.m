//
//  INTagsView.m
//  BigSur
//
//  Created by Ben Gotow on 5/14/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INTagsView.h"
#import "UIView+FrameAdditions.h"

@implementation INTagsView

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
	_tagViews = [NSMutableArray array];
}

- (void)setTags:(NSArray*)tags
{
    [self setTags:tags withOmmittedTagIDs:@[]];
}

- (void)setTags:(NSArray*)tags withOmmittedTagIDs:(NSArray*)omitted
{
    [_tagViews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	[_tagViews removeAllObjects];
	
	for (INTag * tag in tags) {
        if ([omitted containsObject: [tag ID]])
            continue;
        
		UILabel * tagLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[tagLabel setTextColor: [UIColor whiteColor]];
		[tagLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:9]];
		[tagLabel setBackgroundColor: [tag color]];
		[[tagLabel layer] setCornerRadius: 3];
		[tagLabel setClipsToBounds: YES];
		[tagLabel setText: [[tag name] uppercaseString]];
		[tagLabel setTextAlignment: NSTextAlignmentCenter];
		
		CGSize textSize = [[tagLabel text] sizeWithAttributes: @{NSFontAttributeName: [tagLabel font]}];
		[tagLabel in_setFrameSize: CGSizeMake(textSize.width + 8, 13)];
		[self addSubview: tagLabel];
		[_tagViews addObject: tagLabel];
	}
	
	[self setNeedsLayout];
	[self layoutIfNeeded];
}

- (void)layoutSubviews
{
	NSAssert((_alignment == NSTextAlignmentLeft) || (_alignment == NSTextAlignmentRight), @"Sorry, only left and right alignment supported.");
	
	float x = 0;
	float y = 0;

	for (UIView * tagView in _tagViews) {

		if (_alignment == NSTextAlignmentLeft)
			[tagView in_setFrameOrigin: CGPointMake(x, y)];
		else
			[tagView in_setFrameOrigin: CGPointMake(self.frame.size.width - x - tagView.frame.size.width, y)];
		
		x += [tagView frame].size.width + 5;
		if (x >= self.frame.size.width)
			y += [tagView frame].size.height + 5;
	}
	
	[self in_setFrameHeight: y + [[_tagViews lastObject] frame].size.height];
}

@end
