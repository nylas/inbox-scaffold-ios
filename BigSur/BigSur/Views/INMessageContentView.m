//
//  INMessageContentView.m
//  BigSur
//
//  Created by Ben Gotow on 5/23/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageContentView.h"
#import "UIView+FrameAdditions.h"

static NSString * messageCSS = @"\
html, body {\
font-family: sans-serif;\
font-size:0.9em;\
margin-top:%dpx;\
margin-left:%dpx;\
margin-bottom:%dpx;\
margin-right:%dpx;\
border:0;\
width:%dpx;\
-webkit-text-size-adjust: auto;\
word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\
}\
a {\
color:rgb(%d,%d,%d);\
}\
div {\
max-width:100%%;\
}\
.gmail_extra {\
display:none;\
}\
blockquote, .gmail_quote {\
display:none;\
}\
img {\
max-width: 100%;\
height:auto;\
}";

@implementation INMessageContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
	[self setClipsToBounds: YES];
    if (!_tintColor)
        [self setTintColor: [UIColor blueColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_webView setFrame: self.bounds];
    [_textView setFrame: self.bounds];
}

- (void)setFrame:(CGRect)frame
{
    BOOL viewportWidthChange = (frame.size.width != self.frame.size.width);
    [super setFrame: frame];
    if (viewportWidthChange)
        [self setContent: _content];
}

- (void)clearContent
{
    [_webView removeFromSuperview];
    [_webView setDelegate: nil];
    _webView = nil;
    
    [_textView setText: @""];
}

- (void)setContent:(NSString*)content
{
    _content = content;
    
    if ([content rangeOfString:@"<[^<]+>" options:NSRegularExpressionSearch].location != NSNotFound)
        [self setContentWebView: content];
    else
        [self setContentTextView: content];
}

- (void)setContentMargin:(UIEdgeInsets)margin
{
    _contentMargin = margin;
}

- (void)setContentWebView:(NSString*)content
{
    [_textView removeFromSuperview];
    _textView = nil;
    
    if (!_webView) {
		/* Note: It's important the web view has a small initial height because it always
		reports it's rendered content size to be at least it's height. We'll make it the
		appropriate size once it's content loads. This height must be > 0 or it won't load 
		at all. */
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, 5)];
        [_webView setDelegate: self];
        [_webView setTintColor: _tintColor];
        [_webView setScalesPageToFit: YES];
        [_webView setDataDetectorTypes: UIDataDetectorTypeAll];
        [[_webView scrollView] setScrollEnabled: NO];
        [_webView setBackgroundColor:[UIColor whiteColor]];
        [[_webView scrollView] setBackgroundColor:[UIColor whiteColor]];
        [self addSubview: _webView];
    }

    float s = 1.0 / [[UIScreen mainScreen] scale];
    int viewportWidth = self.frame.size.width - (_contentMargin.left + _contentMargin.right);
    
    const CGFloat * components = CGColorGetComponents([[self tintColor] CGColor]);
    int tintR = (int)(components[0] * 256);
    int tintG = (int)(components[1] * 256);
    int tintB = (int)(components[2] * 256);
    
	
    NSString * css = [NSString stringWithFormat: messageCSS, (int)(_contentMargin.top * s), (int)(_contentMargin.left * s), (int)(_contentMargin.bottom * s), (int)(_contentMargin.right * s), viewportWidth, tintR, tintG, tintB];
    NSString * html = [NSString stringWithFormat: @"<style>%@</style><meta name=\"viewport\" content=\"width=%d\">\n%@", css, viewportWidth, content];
    [html writeToFile:[@"~/Documents/test_email.html" stringByExpandingTildeInPath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
	
	[_webView setAlpha: 0.01];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)setContentTextView:(NSString*)content
{
    [_webView removeFromSuperview];
    [_webView setDelegate: nil];
    _webView = nil;
    
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.bounds.size.width, 1000)];
        [_textView setEditable: NO];
        [_textView setDataDetectorTypes: UIDataDetectorTypeAll];
        [_textView setTintColor: _tintColor];
        [_textView setFont: [UIFont systemFontOfSize: 13]];
        [_textView setTextContainerInset: _contentMargin];
        [_textView setScrollEnabled: NO];
        [self addSubview: _textView];
    }
    
    [_textView setText: content];
    CGSize size = [_textView sizeThatFits: CGSizeMake(self.bounds.size.width, MAXFLOAT)];
    [_textView setFrame: CGRectMake(0, 0, size.width, size.height)];
    
    if ([self.delegate respondsToSelector: @selector(messageContentViewSizeDetermined:)])
        [self.delegate messageContentViewSizeDetermined: size];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	CGSize s = _webView.scrollView.contentSize;
	[_webView in_setFrameHeight: s.height];
	[_webView setAlpha: 1];

    if ([self.delegate respondsToSelector: @selector(messageContentViewSizeDetermined:)]) {
        [self.delegate messageContentViewSizeDetermined: s];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ((navigationType == UIWebViewNavigationTypeOther) || (navigationType == UIWebViewNavigationTypeReload))
		return YES;
    
	[[UIApplication sharedApplication] openURL: [request URL]];
	return NO;
}

@end
