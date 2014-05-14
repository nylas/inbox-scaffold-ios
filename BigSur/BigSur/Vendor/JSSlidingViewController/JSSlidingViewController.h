//
//  JSSlidingViewController.h
//  
//
//  Created by Jared Sinclair on 6/19/12.
//  Copyright (c) 2014 Jared Sinclair. All rights reserved.
//

#import <UIKit/UIKit.h>

extern  NSString *   const JSSlidingViewControllerWillOpenNotification;
extern  NSString *   const JSSlidingViewControllerWillCloseNotification;
extern  NSString *   const JSSlidingViewControllerDidOpenNotification;
extern  NSString *   const JSSlidingViewControllerDidCloseNotification;
extern  NSString *   const JSSlidingViewControllerWillBeginDraggingNotification;
extern  CGFloat      const JSSlidingViewControllerDefaultVisibleFrontPortionWhenOpen;
extern  CGFloat      const JSSlidingViewControllerDropShadowImageWidth;


@interface SlidingScrollView : UIScrollView
@end


@protocol JSSlidingViewControllerDelegate;


@interface JSSlidingViewController : UIViewController

// @property (nonatomic, assign) BOOL locked;
// If YES, the slider cannot be opened, either manually or programmatically. The default is NO.
@property (nonatomic, assign) BOOL locked;

// @property (nonatomic, assign) BOOL frontViewControllerHasOpenCloseNavigationBarButton;
// Set this to NO if your front view controller does not have a hamburger button as its left navigation item.
// Defaults to YES.
@property (nonatomic, assign) BOOL frontViewControllerHasOpenCloseNavigationBarButton;

// @property (nonatomic, assign) BOOL allowManualSliding;
// Set this to NO if you only want programmatic opening/closing of the slider
@property (nonatomic, assign) BOOL allowManualSliding;

// @property (nonatomic, assign) BOOL useBouncyAnimations;
// Set this to NO if you don't want to see the inertial bounce style animations when the slider is opened
// or closed programmatically. Defaults to YES. Bouncy animations are not applied to deceleration animations
// after a manual change (only programmatic open/close animations).
@property (nonatomic, assign) BOOL useBouncyAnimations;

// @property (nonatomic, assign) BOOL useParallaxMotionEffect;
// Set this to NO if you don't want the front view controller to move in response to lateral device motion when
// the slider is open. Defaults to YES.
@property (nonatomic, assign) BOOL useParallaxMotionEffect;

// @property (nonatomic, assign) BOOL shouldTemporarilyRemoveBackViewControllerWhenClosed;
// Set this to YES if you want the back view controller to be removed from the view hierarchy when the
// slider is closed. This is generally only necessary for VoiceOver reasons (to prevent VO from speaking
// the content of the back view controller when the slider is closed.
// If the view is not removed, VoiceOver will try to speak items from the back view controller even though
// they are not visible. If your app supports VoiceOver, I strongly recommend setting this property to YES.
// Defaults to NO. Future versions of JSSlidingViewController may enabled this property by default.
@property (nonatomic, assign) BOOL shouldTemporarilyRemoveBackViewControllerWhenClosed;

// @property (nonatomic, assign, readonly) BOOL animating;
// Returns YES if the slider is animating open or shut.
@property (nonatomic, assign, readonly) BOOL animating;

// @property (nonatomic, assign, readonly) BOOL isOpen;
// Returns YES if the slider is open, i.e., the back view controller is visible.
@property (nonatomic, assign, readonly) BOOL isOpen;

// @property (nonatomic, strong, readonly) UIViewController *frontViewController;
// The front view controller (generally, a UINavigationController with a hamburger button).
@property (nonatomic, strong, readonly) UIViewController *frontViewController;

// @property (nonatomic, strong, readonly) UIViewController *backViewController;
// The back view controller (generally, a UITableViewController serving as a main menu).
@property (nonatomic, strong, readonly) UIViewController *backViewController;

// @property (nonatomic, strong, readonly) SlidingScrollView *slidingScrollView;
// A UIScrollView subclass used to contain the front view controller. Secret sauce ingredient.
@property (nonatomic, strong, readonly) SlidingScrollView *slidingScrollView;

// @property (nonatomic, weak) id<JSSlidingViewControllerDelegate> delegate;
// See the protocol desription below. All delegate methods are optional.
@property (nonatomic, weak) id<JSSlidingViewControllerDelegate> delegate;

// @property (strong, nonatomic) UIImage *leftShadowImage;
// The shadow that appears on the lefthand edge of the front view controller.
// This image will be flipped horizontally and re-used as the right shadow (which is
// only visible if bouncing is enabled, and even then only very briefly).
@property (strong, nonatomic) UIImage *leftShadowImage;

// @property (assign, nonatomic) CGFloat leftShadowWidth;
// This is the width of the shadow on the lefthand edge of the front view controller.
@property (assign, nonatomic) CGFloat leftShadowWidth;

// @property (assign, nonatomic) BOOL showsDropShadows;
// Set this to NO if you want no shadow at all on either side of the front view controller.
// Defaults to YES.
@property (assign, nonatomic) BOOL showsDropShadows;

// - (id)initWithFrontViewController:(UIViewController *)frontVC backViewController:(UIViewController *)backVC;
// The designated initializer. Both front and back view controllers are required or an exception will be thrown.
- (id)initWithFrontViewController:(UIViewController *)frontVC backViewController:(UIViewController *)backVC;

// - (void)closeSlider:(BOOL)animated completion:(void (^)(void))completion;
// Closes the slider, with optional animation and a completion block.
- (void)closeSlider:(BOOL)animated completion:(void (^)(void))completion;

// - (void)openSlider:(BOOL)animated completion:(void (^)(void))completion;
// Opens the slider, with optional animation and a completion block.
- (void)openSlider:(BOOL)animated completion:(void (^)(void))completion;

// - (void)setFrontViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
// Sets the front view controller with optional crossfade animation and a completion block.
// viewController cannot be nil.
- (void)setFrontViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

// - (void)setBackViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
// Sets the back view controller with optional crossfade animation and a completion block.
// viewController cannot be nil.
- (void)setBackViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

// - (void)setWidthOfVisiblePortionOfFrontViewControllerWhenSliderIsOpen:(CGFloat)width;
// Sets the width of the visible portion of the front view controller when the slider is in the open position.
// Setting this value will not change the currently visible portion of the slider if it is already open. It will be
// applied the next time the slider comes to rest in the open position. You probably only need to call this once,
// or never if you are happy with the default portion (58.0f).
- (void)setWidthOfVisiblePortionOfFrontViewControllerWhenSliderIsOpen:(CGFloat)width;

@end


@protocol JSSlidingViewControllerDelegate <NSObject>

// Note: The will/did open/close methods are called *after* any completion blocks have been performed.

@optional

// - (void)slidingViewControllerWillOpen:(JSSlidingViewController *)viewController;
// Called before the slider is opened (programmatically or manually)
- (void)slidingViewControllerWillOpen:(JSSlidingViewController *)viewController;

// - (void)slidingViewControllerWillClose:(JSSlidingViewController *)viewController;
// Called before the slider is closed (programmatically or manually)
- (void)slidingViewControllerWillClose:(JSSlidingViewController *)viewController;

// - (void)slidingViewControllerDidOpen:(JSSlidingViewController *)viewController;
// Called after the slider is opened (programmatically or manually)
- (void)slidingViewControllerDidOpen:(JSSlidingViewController *)viewController;

// - (void)slidingViewControllerDidClose:(JSSlidingViewController *)viewController;
// Called after the slider is closed (programmatically or manually)
- (void)slidingViewControllerDidClose:(JSSlidingViewController *)viewController;

// - (NSUInteger)supportedInterfaceOrientationsForSlidingViewController:(JSSlidingViewController *)viewController;
// Unless you override, JSSlidingViewController uses UIInterfaceOrientationMaskPortrait for iPhone and all 4 orientations for iPad.
- (NSUInteger)supportedInterfaceOrientationsForSlidingViewController:(JSSlidingViewController *)viewController;

// - (NSUInteger)supportedInterfaceOrientationsForSlidingViewController:(JSSlidingViewController *)viewController;
// Unless you override, JSSlidingViewController uses YES for portrait on iPhone and YES for all 4 orientations for iPad.
- (BOOL)slidingViewController:(JSSlidingViewController *)viewController shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

// - (NSString *)localizedAccessibilityLabelForInvisibleCloseSliderButton:(JSSlidingViewController *)
// The "invisible button" is the clear button overlaid on the visible edge of the front view controller
// when the slider is open. For a better experience when using voice over, override this method to
// return a localized label for this button. If you don't override, "Visible Edge of Main Content" will be used.
- (NSString *)localizedAccessibilityLabelForInvisibleCloseSliderButton:(JSSlidingViewController *)viewController;

@end









