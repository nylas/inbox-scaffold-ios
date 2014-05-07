//
//  INDeleteDetectingTextField.h
//  Pods
//
//  Created by Ben Gotow on 5/6/14.
//
//

#import <UIKit/UIKit.h>
#import "INAPIManager.h"

@interface INDeleteDetectingTextField : UITextField

@property (nonatomic, strong) VoidBlock didDeleteBlock;

- (void)hideInsertionPoint;
- (void)showInsertionPoint;

@end
