//
//  BPopdownButton.h
//  Bloganizer
//
//  Created by Ben Gotow on 7/11/13.
//  Copyright (c) 2013 Bloganizer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPopdownMenu.h"

@interface BPopdownButton : UIButton
{
    UIView * _menuBackground;
}
@property (nonatomic, strong) BPopdownMenu * menu;

- (void)setMenuOptions:(NSArray*)options;
- (void)setMenuDelegate:(NSObject<BPopdownMenuDelegate>*)delegate;

- (void)presentMenu;
- (void)dismissMenu;

@end
