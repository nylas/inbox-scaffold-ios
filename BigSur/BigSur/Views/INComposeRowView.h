//
//  INComposeRowView.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INComposeRowView : UIView
{
	CALayer * _bottomBorder;
}
@property (nonatomic, strong) UILabel * rowLabel;
@property (nonatomic, strong) UIView * bodyView;
@property (nonatomic, strong) UIButton * actionButton;

@end
