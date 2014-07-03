//
//  INPagingContainerViewController.m
//  TinderPaging
//
//  Created by Ben Gotow on 6/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INPagingContainerViewController.h"


@implementation INPagingContainerViewController

- (id)init
{
    self = [super init];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
        [_scrollView setBackgroundColor: [UIColor grayColor]];
        [_scrollView setDelegate: self];
        [_scrollView setBounces: NO];
        [_scrollView setClipsToBounds: NO];
        [_scrollView setPagingEnabled: YES];

        _headerViews = [NSMutableDictionary dictionary];
        _headerRules = [NSMutableDictionary dictionary];
        
        _headerContainerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 66)];
        [_headerContainerView setBackgroundColor: [UIColor whiteColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview: _scrollView];
    [self.view addSubview: _headerContainerView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_scrollView setFrame: self.view.bounds];
    CGSize s = _scrollView.frame.size;
    float x = 0;
    for (UIViewController * vc in _viewControllers) {
        [vc.view setFrame: CGRectMake(x, 0, s.width, s.height)];
        x += s.width;
    }
    [_scrollView setContentSize: CGSizeMake(x, s.height)];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self detatchViewControllers];
    
    _viewControllers = viewControllers;
    _visibility = [NSMutableDictionary dictionary];
    
    for (UIViewController<INPagingChildViewController> * vc in _viewControllers) {
        [self addChildViewController: vc];
        [_scrollView addSubview: vc.view];
        [vc prepareHeaderViews: self];
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    [self declareCenter:CGPointMake(280,50) of:@"label" forController:_viewControllers[0]];
    [self declareCenter:CGPointMake(160,50) of:@"label" forController:_viewControllers[1]];

    [self showViewControllerAtIndex: 1 animated: NO];
}

- (void)detatchViewControllers
{
    for (UIViewController * vc in _viewControllers) {
        [vc viewWillDisappear: NO];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
        [vc viewDidDisappear: NO];
    }
}

- (void)showViewControllerAtIndex:(int)index animated:(BOOL)animated
{
    CGSize s = _scrollView.frame.size;
    float x = index * s.width;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, s.width, s.height) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect r = [_scrollView bounds];
    r.origin.x = [_scrollView contentOffset].x;
    
    for (int ii = 0; ii < _viewControllers.count; ii ++) {
        UIViewController * vc = _viewControllers[ii];
        BOOL visible = CGRectIntersectsRect(r, vc.view.frame);
        BOOL fullscreen = CGRectEqualToRect(r, vc.view.frame);

        NSString * key = [NSString stringWithFormat:@"%p", vc];
        VisibilityState state = [_visibility[key] intValue];
        
        if (visible && state == Hidden) {
            [vc viewWillAppear: YES];
            state = Appearing;
        }
        
        if (!visible && state == Appearing) {
            [vc viewDidAppear: NO];
            [vc viewWillDisappear:YES];
            state = Disappearing;
        }
        
        if (!fullscreen && state == Visible) {
            [vc viewWillDisappear: YES];
            state = Disappearing;
        }

        _visibility[key] = @(state);
    }

    for (NSString * key in _headerRules) {
        NSArray * rules = _headerRules[key];
        
        CGPoint center = CGPointZero;
        BOOL first = YES;
        float alpha = 0;
        for (NSDictionary * rule in rules) {
            float vcDist = fabsf([rule[@"controller"] view].center.x - (r.origin.x + r.size.width / 2)) / r.size.width;
            float ruleWeight = fmaxf(0, fminf(1, 1 - vcDist));
            CGPoint ruleCenter = [rule[@"center"] CGPointValue];
            
            alpha += ruleWeight;
            
            if (ruleWeight == 0)
                continue;
            
            if (first) {
                center = ruleCenter;
                first = NO;
            } else {
                center.x = center.x * (1-ruleWeight) + ruleCenter.x * ruleWeight;
                center.y = center.y * (1-ruleWeight) + ruleCenter.y * ruleWeight;
            }
        }
        [_headerViews[key] setAlpha: alpha];
        [_headerViews[key] setCenter: center];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self finalizeScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self finalizeScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self finalizeScroll];
}

- (void)finalizeScroll
{
    [self scrollViewDidScroll: _scrollView];

    CGRect r = [_scrollView bounds];

    for (UIViewController * vc in _viewControllers) {
        BOOL visible = CGRectIntersectsRect(r, vc.view.frame);
        NSString * key = [NSString stringWithFormat:@"%p", vc];
        VisibilityState state = [_visibility[key] intValue];
        
        if (visible) {
            if (state == Appearing) {
                [vc viewDidAppear: YES];
            } else if (state == Disappearing){
                [vc viewDidDisappear: NO];
                [vc viewWillAppear: YES];
                [vc viewDidAppear: YES];
            }
            state = Visible;
        
        } else {
            if (state == Disappearing) {
                [vc viewDidDisappear: YES];
            } else if (state == Appearing){
                [vc viewDidAppear: NO];
                [vc viewWillDisappear: NO];
                [vc viewDidDisappear: NO];
            }
            state = Hidden;
        }

        _visibility[key] = @(state);
    }
}


#pragma mark Header Views

- (void)declareHeaderView:(UIView*)v withName:(NSString*)name
{
    if (_headerViews[name] != nil) {
        NSLog(@"Ignoring duplicate declaration of %@", name);
        return;
    }
   
    [_headerContainerView addSubview: v];
    [_headerViews setObject:v forKey:name];
}

- (void)declareCenter:(CGPoint)p of:(NSString*)name forController:(UIViewController*)controller
{
    NSMutableArray * rules = [_headerRules objectForKey: name];
    if (!rules) rules = [NSMutableArray array];
    [rules addObject: @{@"center": [NSValue valueWithCGPoint: p], @"controller": controller}];
    [_headerRules setObject:rules forKey:name];
}


@end
