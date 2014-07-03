//
//  INRootViewController.h
//  BigSur
//
//  Created by Ben Gotow on 5/12/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INRootViewController : UIViewController

- (void)smartPushViewController:(UIViewController*)vc animated:(BOOL)animated;
- (void)smartPresentViewController:(UIViewController*)vc animated:(BOOL)animated;

@end
