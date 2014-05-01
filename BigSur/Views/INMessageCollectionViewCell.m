//
//  INMessageCollectionViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageCollectionViewCell.h"
#import "NSObject+AssociatedObjects.h"

#define ASSOCIATED_CACHED_HEIGHT @"cell-message-height"

static NSString * messageCSS = nil;

@implementation INMessageCollectionViewCell

+ (float)cachedHeightForMessage:(INMessage*)message
{
	return [[message associatedValueForKey: ASSOCIATED_CACHED_HEIGHT] floatValue];
}

- (void)awakeFromNib
{
	[self setBackgroundColor: [UIColor whiteColor]];
	[self setClipsToBounds: NO];
	
	[[self layer] setCornerRadius: 2];
	[[self layer] setShadowRadius: 1];
	[[self layer] setShadowOffset: CGSizeMake(0, 1)];
	[[self layer] setShadowOpacity: 0.1];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[[self layer] setShadowPath: CGPathCreateWithRect(self.contentView.bounds, NULL)];
}

- (void)setMessage:(INMessage *)message
{
	_message = message;
	
	if (messageCSS == nil) {
		NSString * messageCSSPath = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"css"];
		messageCSS = [NSString stringWithContentsOfFile:messageCSSPath encoding:NSUTF8StringEncoding error:nil];
	}
	
	NSString * html = [NSString stringWithFormat: @"<style>%@</style>\n%@", messageCSS, [message body]];
	
	[_bodyWebView loadHTMLString:html baseURL:nil];
	[[_bodyWebView scrollView] setScrollEnabled: NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([[self class] cachedHeightForMessage: _message])
		return;
		
	NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
	[_message associateValue:[NSNumber numberWithFloat: [output floatValue] + 44] withKey: ASSOCIATED_CACHED_HEIGHT];

	if (_messageHeightDeterminedBlock)
		_messageHeightDeterminedBlock(self);
}

@end
