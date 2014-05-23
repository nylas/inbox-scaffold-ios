//
//  INThreadTableViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThreadTableViewCell.h"
#import "UIView+FrameAdditions.h"
#import "INConvenienceCategories.h"
#import "INThemeManager.h"

@implementation INThreadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier: reuseIdentifier];
    if (self) {
		_unreadDot = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 14, 14)];
		[_unreadDot setBackgroundColor: [[INThemeManager shared] tintColor]];
		[[_unreadDot layer] setCornerRadius: _unreadDot.frame.size.width / 2];
		[self addSubview: _unreadDot];
	
        _threadCountLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		[_threadCountLabel setFont: [UIFont systemFontOfSize: 13]];
		[_threadCountLabel setTextColor: [UIColor grayColor]];
		[_threadCountLabel setTextAlignment: NSTextAlignmentCenter];
		[[_threadCountLabel layer] setBorderWidth: 1];
		[[_threadCountLabel layer] setCornerRadius: 3];
		[[_threadCountLabel layer] setBorderColor: [[UIColor colorWithWhite:0.7 alpha:1] CGColor]];
		[self addSubview: _threadCountLabel];
    }
    return self;
}

- (float)textLeftInset
{
    return 40;
}

- (void)layoutSubviews
{
    CGRect f = self.frame;
    
    [super layoutSubviews];
    
    float textW = [self.subjectLabel frame].size.width;
    
    if ([[_threadCountLabel text] length]){
        CGSize s = [[_threadCountLabel text] sizeWithAttributes: @{NSFontAttributeName: [_threadCountLabel font]}];
        s.width += 8;
        s.height += 4;
        [_threadCountLabel setFrame: CGRectMake(f.size.width - INSETS.right - s.width, (f.size.height - s.height) / 2, s.width, s.height)];
        [_threadCountLabel setHidden: NO];
        
        textW -= s.width + INSETS.right;
        [self.subjectLabel setFrameWidth: textW];
        [self.bodyLabel setFrameSize: CGSizeMake(textW, 1000)];
        [self.bodyLabel sizeToFit];
        
    } else {
        [_threadCountLabel setHidden: YES];
    }
    
    [_unreadDot setFrameCenter: CGPointMake(20, self.subjectLabel.center.y)];
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
	[self.participantsLabel setPrefixString: @"" andRecipients:[_thread participants] includeMe: includeMe];
	[self.dateLabel setText: [NSString stringForMessageDate: [_thread lastMessageDate]]];
	[self.subjectLabel setText: [_thread subject]];
    [self.bodyLabel setText: [NSString stringByCleaningWhitespaceInString: [_thread snippet]]];
    [_unreadDot setHidden: (![_thread hasTagWithID: INTagIDUnread])];
    
	if ([[_thread messageIDs] count] > 1)
		[_threadCountLabel setText: [NSString stringWithFormat:@"%d", (int)[[_thread messageIDs] count]]];
	else
		[_threadCountLabel setText: @""];
}

@end
