//
//  INMessageCollectionViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageCollectionViewCell.h"
#import "NSObject+AssociatedObjects.h"
#import "UIButton+AFNetworking.h"
#import "NSString+FormatConversion.h"
#import "UIView+FrameAdditions.h"
#import "INConvenienceCategories.h"
#import "INThemeManager.h"

#define ASSOCIATED_CACHED_HEIGHT @"cell-message-height"

static NSString * messageCSS = nil;
static NSString * messageJS = nil;

@implementation INMessageCollectionViewCell

+ (float)cachedHeightForMessage:(INMessage*)message
{
	return [[message associatedValueForKey: ASSOCIATED_CACHED_HEIGHT] floatValue];
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
	
	[[self layer] setShadowPath: CGPathCreateWithRect(self.contentView.bounds, NULL)];
    [_headerBorderLayer setFrame: CGRectMake(0, _headerContainerView.frame.size.height - 0.5, _headerContainerView.frame.size.width, 0.5)];
    [_bodyWebView setFrameY: [_headerContainerView bottomLeft].y + 10];
    
    if ([_draftOptionsView isHidden]) {
        [_bodyWebView setFrameHeight: self.frame.size.height - _bodyWebView.frame.origin.y];
    } else {
        [_bodyWebView setFrameHeight: self.frame.size.height - _bodyWebView.frame.origin.y - (_draftOptionsView.frame.size.height + 5)];
        [_draftOptionsView setFrameY: [_bodyWebView bottomLeft].y + 5];
    }
}

- (void)setMessage:(INMessage *)message
{
	_message = message;
	
	NSString * email = [[_message.from firstObject] objectForKey: @"email"];
	[_fromProfileButton setImageForState:UIControlStateNormal withURL:[NSURL URLForGravatar: email] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"]];
	[_fromField setPrefixString: @"" andRecipients: [message from] includeMe: YES];
	[_toField setPrefixString:@"To: " andRecipients: [message to] includeMe: YES];
	[_dateField setText: [NSString stringForMessageDate: [_message date]]];
    
    [_bodyWebView setMessageHTML: [_message body]];
    [_bodyWebView setDelegate: self];

    [_draftOptionsView setHidden: ![_message isDraft]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([[self class] cachedHeightForMessage: _message])
		return;
    
    float headerHeight = 78;
    if ([_message isDraft])
        headerHeight += 44;

	[_message associateValue:@([_bodyWebView bodyHeight] + headerHeight) withKey: ASSOCIATED_CACHED_HEIGHT];
    
	if (_messageHeightDeterminedBlock)
		_messageHeightDeterminedBlock(self);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ((navigationType == UIWebViewNavigationTypeOther) || (navigationType == UIWebViewNavigationTypeReload))
		return YES;
    
	[[UIApplication sharedApplication] openURL: [request URL]];
	return NO;
}

@end
