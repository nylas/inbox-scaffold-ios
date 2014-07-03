//
//  INDeleteDetectingTextField.h
//  Pods
//
//  Created by Ben Gotow on 5/6/14.
//
//

#import <UIKit/UIKit.h>

@interface INDeleteDetectingTextField : UITextField

@property (nonatomic, strong) VoidBlock didDeleteBlock;

- (void)hideInsertionPoint;
- (void)showInsertionPoint;

@end
