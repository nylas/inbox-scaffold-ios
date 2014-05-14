//
//  INInboxNavTitleView.h
//  BigSur
//
//  Created by Ben Gotow on 5/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INInboxNavTitleView : UIView

@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * titleUnreadLabel;

- (void)setTitle:(NSString*)title andUnreadCount:(long)count;

@end
