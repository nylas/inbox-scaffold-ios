//
//  INMessageCollectionViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageCollectionViewCell.h"
#import "UIButton+AFNetworking.h"
#import "NSString+FormatConversion.h"
#import "UIView+FrameAdditions.h"
#import "INConvenienceCategories.h"
#import "INThemeManager.h"

#define ASSOCIATED_CACHED_HEIGHT @"cell-message-height"

static NSString * messageCSS = nil;
static NSString * messageJS = nil;

static NSMutableDictionary * cachedMessageHeights;


@implementation INMessageCollectionViewCell

+ (float)cachedHeightForMessage:(INMessage*)message
{
    return [[cachedMessageHeights objectForKey: [[message body] md5Value]] floatValue];
}

+ (void)setCachedHeight:(float)height forMessage:(INMessage*)message
{
    if (!cachedMessageHeights)
        cachedMessageHeights = [NSMutableDictionary dictionary];
    [cachedMessageHeights setObject:@(height) forKey: [[message body] md5Value]];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self setBackgroundColor: [UIColor whiteColor]];
	[self setClipsToBounds: NO];

	[_fromField setTextColor: [[INThemeManager shared] tintColor]];
	[_fromField setTextFont: [UIFont boldSystemFontOfSize: 15]];
	[_fromField setRecipientsClickable: YES];
	
	[_toField setTextColor: [UIColor grayColor]];
	[_toField setTextFont: [UIFont systemFontOfSize: 14]];
	[_toField setRecipientsClickable: NO];

    [_bodyView setTintColor: [[INThemeManager shared] tintColor]];
    
	[[self layer] setCornerRadius: 2];
	[[self layer] setShadowRadius: 1];
	[[self layer] setShadowOffset: CGSizeMake(0, 1)];
	[[self layer] setShadowOpacity: 0.1];
	[[self layer] setBorderWidth: 1.0 / [[UIScreen mainScreen] scale]];
	[[self layer] setBorderColor: [[UIColor colorWithWhite:0.8 alpha:1] CGColor]];
	
	_headerBorderLayer = [CALayer layer];
	[_headerBorderLayer setBackgroundColor: [[UIColor colorWithWhite:0.8 alpha:1] CGColor]];
	[[_headerContainerView layer] addSublayer: _headerBorderLayer];
	
    CALayer * draftBorderLayer = [CALayer layer];
	[draftBorderLayer setBackgroundColor: [[UIColor colorWithWhite:0.8 alpha:1] CGColor]];
    [draftBorderLayer setFrame: CGRectMake(0, 0, 3000, 0.5)];
	[[_draftOptionsView layer] addSublayer: draftBorderLayer];
	[[_draftOptionsView layer] setMasksToBounds: YES];
    
	[[_fromProfileButton layer] setCornerRadius: 3];
	[[_fromProfileButton layer] setMasksToBounds:YES];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    float contentWidth = _headerContainerView.frame.size.width;
    
	[[self layer] setShadowPath: CGPathCreateWithRect(self.contentView.bounds, NULL)];
    [_headerBorderLayer setFrame: CGRectMake(0, _headerContainerView.frame.size.height - 0.5, contentWidth, 0.5)];
    [_bodyView setFrameY: [_headerContainerView bottomLeft].y + 10];

    if ([_draftOptionsView isHidden]) {
        [_bodyView setFrameSize: CGSizeMake(contentWidth, self.frame.size.height - _bodyView.frame.origin.y)];
    } else {
        [_bodyView setFrameSize: CGSizeMake(contentWidth, self.frame.size.height - _bodyView.frame.origin.y - (_draftOptionsView.frame.size.height + 5))];
        [_draftOptionsView setFrameY: [_bodyView bottomLeft].y + 5];
    }
}

- (void)setMessage:(INMessage *)message
{
    BOOL newMessage = (message != _message);
    
	_message = message;
    
    if (newMessage) {
        NSString * email = [[_message.from firstObject] objectForKey: @"email"];
        [_fromProfileButton setImageForState:UIControlStateNormal withURL:[NSURL URLForGravatar: email] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"]];
        [_bodyView clearContent];
    }
    
	[_fromField setPrefixString: @"" andRecipients: [message from] includeMe: YES];
	[_toField setPrefixString:@"To: " andRecipients: [message to] includeMe: YES];
	[_dateField setText: [NSString stringForMessageDate: [_message date]]];

    [_bodyView setContent: [message body]];
    [_draftOptionsView setHidden: ![_message isKindOfClass: [INDraft class]]];
}


- (void)messageContentViewSizeDetermined:(CGSize)size
{
    float height = 0;
    
    height += 82;
    height += size.height;
    if ([_message isKindOfClass: [INDraft class]])
        height += 44;
    
	if (![[self class] cachedHeightForMessage: _message]) {
        [[self class] setCachedHeight:height forMessage:_message];

        if (_messageHeightDeterminedBlock)
            _messageHeightDeterminedBlock(self);
    }
}

@end
