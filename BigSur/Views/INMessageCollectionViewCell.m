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
#import "INConvenienceCategories.h"

#define ASSOCIATED_CACHED_HEIGHT @"cell-message-height"
#define MESSAGE_HEADER_HEIGHT 65

static NSString * messageCSS = nil;
static NSString * messageJS = nil;

@implementation INMessageCollectionViewCell

+ (float)cachedHeightForMessage:(INMessage*)message
{
	return [[message associatedValueForKey: ASSOCIATED_CACHED_HEIGHT] floatValue];
}

- (void)awakeFromNib
{
	[self setBackgroundColor: [UIColor whiteColor]];
	[self setClipsToBounds: NO];
	
	[_fromField setTextColor: [UIColor blueColor]];
	[_fromField setTextFont: [UIFont boldSystemFontOfSize: 15]];
	[_fromField setRecipientsClickable: YES];
	
	[_toField setTextColor: [UIColor grayColor]];
	[_toField setTextFont: [UIFont systemFontOfSize: 14]];
	[_toField setRecipientsClickable: NO];

	[[self layer] setCornerRadius: 2];
	[[self layer] setShadowRadius: 1];
	[[self layer] setShadowOffset: CGSizeMake(0, 1)];
	[[self layer] setShadowOpacity: 0.1];

	[[_fromProfileButton layer] setCornerRadius: 3];
	[[_fromProfileButton layer] setMasksToBounds:YES];
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
		NSString * messageJSPath = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"js"];
		messageJS = [NSString stringWithContentsOfFile:messageJSPath encoding:NSUTF8StringEncoding error:nil];
	}
	
	NSString * email = [[_message.from firstObject] objectForKey: @"email"];
	[_fromProfileButton setImageForState:UIControlStateNormal withURL:[NSURL URLForGravatar: email] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"]];
	[_fromField setRecipients: [message from] includeMe: YES];
	[_toField setRecipients: [message to] includeMe: YES];
	[_dateField setText: [NSString stringForMessageDate: [_message date]]];
	
	NSString * html = [NSString stringWithFormat: @"<style>%@</style>\n%@", messageCSS, [message body]];
	NSRange endHead = [html rangeOfString: @"</head>"];
	if (endHead.location != NSNotFound) {
		html = [NSString stringWithFormat:@"%@<meta name=\"viewport\" content=\"width=300\">%@", [html substringToIndex: endHead.location], [html substringFromIndex: endHead.location]];
		[_bodyWebView setScalesPageToFit: YES];
	} else {
		[_bodyWebView setScalesPageToFit: NO];
	}

	[_bodyWebView loadHTMLString:html baseURL:nil];
	[_bodyWebView setDataDetectorTypes: UIDataDetectorTypeAll];
	[[_bodyWebView scrollView] setScrollEnabled: NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([[self class] cachedHeightForMessage: _message])
		return;
		
//	[_bodyWebView stringByEvaluatingJavaScriptFromString: messageJS];

	float height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue];
	float width = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue];
	if ([_bodyWebView scalesPageToFit] == NO)
		width = 300;
		
	[_message associateValue:[NSNumber numberWithFloat: height / (width / 300.0) + MESSAGE_HEADER_HEIGHT] withKey: ASSOCIATED_CACHED_HEIGHT];

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
