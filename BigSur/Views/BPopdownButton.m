//
//  BPopdownButton.m
//  Bloganizer
//
//  Created by Ben Gotow on 7/11/13.
//  Copyright (c) 2013 Bloganizer Inc. All rights reserved.
//

#import "BPopdownButton.h"
#import "UIView+FrameAdditions.h"

@implementation BPopdownButton

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
    [self setup];
}

- (void)setup
{
    _menu = [[BPopdownMenu alloc] init];
    _menuBackground = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1000, 1000)];
    [_menuBackground setBackgroundColor: [UIColor colorWithWhite:0 alpha:0.1]];
    [_menuBackground addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)]];
    [self addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setMenuOptions:(NSArray*)options
{
    [_menu setOptions: options];
    [self setEnabled: [options count] > 0];
}

- (void)setMenuDelegate:(NSObject<BPopdownMenuDelegate>*)delegate
{
    [_menu setDelegate: delegate];
}

- (void)toggleMenu:(id)sender
{
    if ([_menu superview])
        [self dismissMenu];
    else
        [self presentMenu];
}

- (void)presentMenu
{
    if ([_menu.options count] == 0)
        return;
    
    UIView * v = self;
    while ([[v superview] isKindOfClass: [UIWindow class]] == NO)
        v = [v superview];
    
    CGRect root = [self convertRect:self.bounds toView:v];
    float menuWidth = [_menu frame].size.width;
    float menuY = root.origin.y + root.size.height + 10;
    
    if (root.origin.x + menuWidth > v.frame.size.width) {
        float menuX = fminf(v.frame.size.width - 5 - menuWidth, root.origin.x + root.size.width - menuWidth);
        [[_menu layer] setAnchorPoint: CGPointMake((menuWidth - self.bounds.size.width/2 + 5)/menuWidth, 0)];
        [_menu in_setFrameOrigin: CGPointMake(menuX, menuY)];
    } else {
        [[_menu layer] setAnchorPoint: CGPointMake((self.bounds.size.width/2)/menuWidth, 0)];
        [_menu in_setFrameOrigin: CGPointMake(root.origin.x, menuY)];
    }

    [_menuBackground setAlpha: 0];
    [v addSubview: _menuBackground];
    
    [_menu setAlpha: 0];
    [_menu setTransform: CGAffineTransformMakeScale(0.9, 0.9)];
    [v addSubview: _menu];
    
    [UIView animateWithDuration:0.25 animations:^{
        [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
        [_menu setAlpha: 1];
        [_menuBackground setAlpha: 1];
        [_menu setTransform: CGAffineTransformMakeScale(1.05, 1.05)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [_menu setTransform: CGAffineTransformIdentity];
        }];
    }];
}

- (void)dismissMenu
{
    [UIView animateWithDuration:0.08 animations:^{
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [_menu setTransform: CGAffineTransformMakeScale(1.05, 1.05)];
        [_menuBackground setAlpha: 0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [_menu setTransform: CGAffineTransformMakeScale(0.7, 0.7)];
            [_menu setAlpha: 0];
            [_menu in_shiftFrame: CGPointMake(0, -15)];
        } completion:^(BOOL finished) {
            [_menu setTransform: CGAffineTransformIdentity];
            [_menu removeFromSuperview];
            [_menuBackground removeFromSuperview];
        }];
    }];
}

@end
