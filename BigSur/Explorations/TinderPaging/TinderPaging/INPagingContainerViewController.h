//
//  INPagingContainerViewController.h
//  TinderPaging
//
//  Created by Ben Gotow on 6/19/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Hidden,
    Appearing,
    Visible,
    Disappearing
} VisibilityState;

@class INPagingContainerViewController;

@protocol INPagingChildViewController <NSObject>

- (void)prepareHeaderViews:(INPagingContainerViewController*)controller;

@end

@interface INPagingContainerViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableDictionary * _visibility;
}

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * headerContainerView;
@property (nonatomic, strong) NSMutableDictionary * headerViews;
@property (nonatomic, strong) NSMutableDictionary * headerRules;

@property (nonatomic, strong) NSArray * viewControllers;


#pragma mark Header Views

- (void)declareHeaderView:(UIView*)v withName:(NSString*)name;
- (void)declareCenter:(CGPoint)p of:(NSString*)name forController:(UIViewController*)controller;


@end
