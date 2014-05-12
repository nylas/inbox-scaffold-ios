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
	UIView * _bottomBorder;
}
@property (nonatomic, strong) UILabel * rowLabel;
@property (nonatomic, strong) UIView * bodyView;
@property (nonatomic, strong) UIButton * actionButton;
@property (nonatomic, assign) BOOL animatesBottomBorder;

- (void)positionBottomBorder;

@end
