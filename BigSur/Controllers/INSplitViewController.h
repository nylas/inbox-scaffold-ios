//
//  INSplitViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INSplitViewController : UIViewController

@property (nonatomic, strong) NSMutableArray * paneViewControllers;
@property (nonatomic, strong) NSMutableArray * paneNavigationBars;
@property (nonatomic, strong) NSMutableArray * paneTapRecognizers;
@property (nonatomic, strong) NSMutableArray * paneShadows;

- (void)setViewControllers:(NSArray*)controllers;
- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated;
- (void)popPane:(BOOL)animated;

@end
