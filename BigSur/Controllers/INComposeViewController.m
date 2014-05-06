//
//  INComposeViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeViewController.h"
#import "UIView+FrameAdditions.h"

@implementation INComposeViewController

- (id)initWithThread:(INThread*)thread
{
	self = [super init];
	if (self) {
		_thread = thread;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
	// create our views
	_toRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
	[_toRecipientsView.rowLabel setText: @"To:"];
	
	_ccBccRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
	[_ccBccRecipientsView.rowLabel setText: @"Cc/Bcc:"];
	
	_subjectView = [[INComposeSubjectRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
	[_subjectView.rowLabel setText: @"Subject:"];

	_bodyTextView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_bodyTextView setFont: [UIFont systemFontOfSize: 15]];
	[_bodyTextView setTextContainerInset: UIEdgeInsetsMake(5,5,5,5)];
	[_bodyTextView setScrollEnabled: NO];

	// create our constraints
	NSMutableArray * rows = [NSMutableArray array];
	[rows addObject: _toRecipientsView];
	[rows addObject: _ccBccRecipientsView];
	[rows addObject: _subjectView];
	[rows addObject: _bodyTextView];
	
	for (UIView * view in rows) {
		view.translatesAutoresizingMaskIntoConstraints = NO;
		[self.scrollView addSubview: view];
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view(==320)]|" options:0 metrics:nil views:@{@"view":view}]];
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(>=30)]" options:0 metrics:nil views:@{@"view":view}]];
	}

	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:@{@"first": [rows firstObject]}]];
	for (int ii = 1; ii < [rows count]; ii ++)
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev][current]" options:0 metrics:nil views:@{@"prev": [rows objectAtIndex: ii-1], @"current": [rows objectAtIndex: ii]}]];
	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:@{@"last": [rows lastObject]}]];

	// create the nav item
	UIBarButtonItem * x = [[UIBarButtonItem alloc] initWithTitle:@"x" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped:)];
	[self.navigationItem setLeftBarButtonItem: x];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)keyboardWillShow:(NSNotification*)notif
{
	CGRect keyboardFrame = [[[notif userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[self.scrollView setFrameHeight: self.view.frame.size.height - keyboardFrame.size.height];
}

- (void)keyboardWillHide:(NSNotification*)notif
{
	[self.scrollView setFrameHeight: self.view.frame.size.height];
}

- (void)cancelTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
