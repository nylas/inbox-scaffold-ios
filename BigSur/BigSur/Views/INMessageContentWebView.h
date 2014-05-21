//
//  INMessageContentWebView.h
//  BigSur
//
//  Created by Ben Gotow on 5/7/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INMessageContentWebView : UIWebView
{
    NSString * _orginalHTML;
    UIEdgeInsets _margin;
}

@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, strong) UIColor * tintColor;

- (void)setMessageHTML:(NSString*)messageHTML;
- (float)bodyHeight;

@end
