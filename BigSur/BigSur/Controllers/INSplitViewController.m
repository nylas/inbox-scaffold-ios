//
//  INSplitViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INSplitViewController.h"
#import "UIView+FrameAdditions.h"

#define NAV_HEIGHT (44 + 20)

@implementation INSplitViewController

- (id)init
{
	self = [super init];
	if (self) {
		_paneViewControllers = [NSMutableArray array];
		_paneNavigationBars = [NSMutableArray array];
		_paneShadows = [NSMutableArray array];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setViewControllers:(NSArray*)controllers
{
	for (UIViewController * controller in controllers)
		[self pushViewController: controller animated: NO];
}

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated
{
	NSAssert(([_paneViewControllers count] < 3), @"More than three VCs not currently supported.");
	
	UINavigationBar * navBar = [[UINavigationBar alloc] initWithFrame: CGRectZero];
	[navBar setClipsToBounds: NO];
	if (controller.navigationItem) {
		[navBar pushNavigationItem:controller.navigationItem animated:NO];
	} else {
		[navBar setHidden: YES];
	}
	[_paneNavigationBars addObject: navBar];
	[self.view addSubview: navBar];
	
	[self addChildViewController: controller];
	[self.view addSubview: controller.view];
	[_paneViewControllers addObject: controller];
	
	UIView * shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popPane)];
	[shadow setBackgroundColor: [UIColor colorWithWhite:0 alpha:0.15]];
	[shadow addGestureRecognizer: tap];
	[shadow setUserInteractionEnabled: YES];
	UIImageView * shadowImage = [[UIImageView alloc] initWithFrame: CGRectMake(1024-20, 0, 20, 1024)];
	[shadowImage setImage: [UIImage imageNamed: @"frontViewControllerDropShadow.png"]];
	[shadow addSubview: shadowImage];
	[self.view addSubview: shadow];
	[_paneShadows addObject: shadow];
	
	NSArray * paneWidths = [self paneWidths];
	float width = [[paneWidths lastObject] floatValue];
	float x = self.view.bounds.size.width;
	[navBar setFrame: CGRectMake(x, 0, width, NAV_HEIGHT)];
	[controller.view setFrame: CGRectMake(x, NAV_HEIGHT, width, self.view.frame.size.height)];
	[shadow in_setFrameX: x - shadow.frame.size.width];
	
	if (animated) {
		[UIView animateWithDuration:0.3 animations:^{
			[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
			[self recomputeLayout];
		}];
	} else {
		[self recomputeLayout];
	}
}

- (void)popPane
{
	[self popPane: YES];
}

- (void)popPane:(BOOL)animated
{
	UIViewController * last = [_paneViewControllers lastObject];
	UINavigationBar * lastBar = [_paneNavigationBars lastObject];
	UINavigationBar * lastShadow = [_paneShadows lastObject];
	
	[_paneViewControllers removeLastObject];
	[_paneNavigationBars removeLastObject];
	[_paneShadows removeLastObject];
	
	VoidBlock completion = ^{
		[last.view removeFromSuperview];
		[last removeFromParentViewController];
		[lastBar removeFromSuperview];
		[lastShadow removeFromSuperview];
	};
	
	if (animated) {
		[UIView animateWithDuration:0.3 animations:^{
			[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
			[self recomputeLayout];
			[last.view in_setFrameX: self.view.bounds.size.width];
			[lastBar in_setFrameX: self.view.bounds.size.width];
			[lastShadow in_setFrameX: self.view.bounds.size.width - lastShadow.frame.size.width];
			[lastShadow setAlpha: 0];
			
		} completion:^(BOOL finished) {
			completion();
		}];
	} else {
		completion();
	}
}

- (NSArray*)paneWidths
{
	NSUInteger count = [_paneViewControllers count];
	if (count == 2)
		return @[@(256), @(512)];
	if (count == 3)
		return @[@(256), @(512), @(452)];

	return @[@(self.view.bounds.size.width)];
}

- (BOOL)paneOccluded:(int)index
{
	if (index >= [_paneViewControllers count] - 1)
		return NO;
		
	UIViewController * pane = [_paneViewControllers objectAtIndex: index];
	UIViewController * next = [_paneViewControllers objectAtIndex: index + 1];
	return (next.view.frame.origin.x < (pane.view.frame.origin.x + pane.view.frame.size.width));
}

- (void)recomputeLayout
{
	NSArray * paneWidths = [self paneWidths];
	float paneCount = [_paneViewControllers count];
	float lastWidth = [[paneWidths lastObject] floatValue];
	BOOL lastOccluded = NO;
	float x = 0;
	
	for (int ii = 0; ii < paneCount; ii ++) {
		UIViewController * pane = [_paneViewControllers objectAtIndex: ii];
		UINavigationBar * navbar = [_paneNavigationBars objectAtIndex: ii];
		UIImageView * shadow = [_paneShadows objectAtIndex: ii];
		
		float w = [[paneWidths objectAtIndex: ii] floatValue];
		float y = ([navbar isHidden] ? 0 : NAV_HEIGHT);
		[navbar setFrame:CGRectMake(x, 0, w, NAV_HEIGHT)];
		[[pane view] setFrame: CGRectMake(x, y, w, self.view.bounds.size.height-y)];
		[shadow in_setFrameX: x - [shadow frame].size.width];
		[shadow setAlpha: (lastOccluded ? 1.0 : 0.0)];

		float visibleW = fminf(w, ((self.view.bounds.size.width - lastWidth - x) / ([_paneViewControllers count] - 2)));
		if ((paneCount == 3) && (ii == 0))
			visibleW = 60;
			
		x += visibleW;
		lastOccluded = (w != visibleW);
	}
}

- (void)viewDidLayoutSubviews
{
	[self recomputeLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self recomputeLayout];
}

@end
