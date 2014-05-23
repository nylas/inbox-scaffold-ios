//
//  INMessageContentWebView.m
//  BigSur
//
//  Created by Ben Gotow on 5/7/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageContentWebView.h"

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

@implementation INMessageContentWebView

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
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
	if (!_tintColor)
		[self setTintColor: [UIColor blueColor]];

    [self setScalesPageToFit: YES];
	[self setDataDetectorTypes: UIDataDetectorTypeAll];
	[[self scrollView] setScrollEnabled: NO];
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self scrollView] setBackgroundColor:[UIColor whiteColor]];
}

- (void)setMessageMargin:(UIEdgeInsets)margin
{
    _margin = margin;
}

- (void)setMessageHTML:(NSString*)messageHTML
{
    if ([_orginalHTML isEqualToString: messageHTML])
        return;
    
    _orginalHTML = messageHTML;

    [self loadHTMLString:@"" baseURL:nil];

    if ([messageHTML length] > 0){
        float s = 1.0 / [[UIScreen mainScreen] scale];
        int viewportWidth = self.frame.size.width - (_margin.left + _margin.right);
        
        const CGFloat * components = CGColorGetComponents([[self tintColor] CGColor]);
        int tintR = (int)(components[0] * 256);
        int tintG = (int)(components[1] * 256);
        int tintB = (int)(components[2] * 256);
        
        NSString * css = [NSString stringWithFormat: messageCSS, (int)(_margin.top * s), (int)(_margin.left * s), (int)(_margin.bottom * s), (int)(_margin.right * s), viewportWidth, tintR, tintG, tintB];
        NSString * html = [NSString stringWithFormat: @"<style>%@</style><meta name=\"viewport\" content=\"width=%d\">\n%@", css, viewportWidth, messageHTML];
        [html writeToFile:[@"~/Documents/test_email.html" stringByExpandingTildeInPath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [self loadHTMLString:html baseURL:nil];
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL viewportSizeChange = (frame.size.width != self.frame.size.width);
    [super setFrame: frame];
    if (viewportSizeChange)
        [self setMessageHTML: _orginalHTML];
}

- (float)bodyHeight
{
    float height = [[self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue];
	float width = [[self stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue];
    return ceilf(height / (width / self.frame.size.width));
}

@end
