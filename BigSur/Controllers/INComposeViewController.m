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
	_toRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_toRecipientsView.rowLabel setText: @"To:"];
	
	_ccBccRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_ccBccRecipientsView.rowLabel setText: @"Cc/Bcc:"];
	
	_subjectView = [[INComposeSubjectRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];

	_bodyTextView = [[INPlaceholderTextView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_bodyTextView setPlaceholder: @"Compose a message..."];
	[_bodyTextView setFont: [UIFont systemFontOfSize: 15]];
	[_bodyTextView setTextContainerInset: UIEdgeInsetsMake(5,4,5,4)];
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
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(>=40)]" options:0 metrics:nil views:@{@"view":view}]];
	}

	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:@{@"first": [rows firstObject]}]];
	for (int ii = 1; ii < [rows count]; ii ++)
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev][current]" options:0 metrics:nil views:@{@"prev": [rows objectAtIndex: ii-1], @"current": [rows objectAtIndex: ii]}]];
	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:@{@"last": [rows lastObject]}]];

	// create the nav item
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"icon_cancel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped:)];
	[self.navigationItem setLeftBarButtonItem: cancel];

	UIBarButtonItem * send = [[UIBarButtonItem alloc] initWithTitle: @"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendTapped:)];
	[self.navigationItem setRightBarButtonItem: send];
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
	[self.scrollView scrollRectToVisible: _bodyTextView.frame animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notif
{
	[self.scrollView setFrameHeight: self.view.frame.size.height];
}

- (void)sendTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
