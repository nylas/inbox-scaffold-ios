//
//  INComposeViewController.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeViewController.h"
#import "INContactsViewController.h"
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
	[[_toRecipientsView actionButton] addTarget:self action:@selector(addToRecipientTapped:) forControlEvents:UIControlEventTouchUpInside];
    
	_ccBccRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_ccBccRecipientsView.rowLabel setText: @"Cc/Bcc:"];
	
	_subjectView = [[INComposeSubjectRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
    [[_subjectView actionButton] addTarget:self action:@selector(addAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _attachmentsView = [[INComposeAttachmentsRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
    
	_bodyTextView = [[INPlaceholderTextView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_bodyTextView setPlaceholder: @"Compose a message..."];
	[_bodyTextView setFont: [UIFont systemFontOfSize: 15]];
	[_bodyTextView setTextContainerInset: UIEdgeInsetsMake(5,4,5,4)];
	[_bodyTextView setScrollEnabled: NO];

    [self arrangeContentViews];
    
	// create the nav item
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"icon_cancel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped:)];
	[self.navigationItem setLeftBarButtonItem: cancel];

	UIBarButtonItem * send = [[UIBarButtonItem alloc] initWithTitle: @"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendTapped:)];
	[self.navigationItem setRightBarButtonItem: send];
}

- (void)arrangeContentViews
{
    // create our constraints
	NSMutableArray * rows = [NSMutableArray array];
	[rows addObject: _toRecipientsView];
	[rows addObject: _ccBccRecipientsView];
	[rows addObject: _subjectView];
    [rows addObject: _attachmentsView];
	[rows addObject: _bodyTextView];
    
    [self.scrollView removeConstraints: self.scrollView.constraints];
	
	for (UIView * view in rows) {
		view.translatesAutoresizingMaskIntoConstraints = NO;
		[self.scrollView addSubview: view];
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view(==containerWidth)]|" options:0 metrics:@{@"containerWidth": @(self.scrollView.frame.size.width)} views:@{@"view":view}]];
	}
    
	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[first]" options:0 metrics:nil views:@{@"first": [rows firstObject]}]];
	for (int ii = 1; ii < [rows count]; ii ++)
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev][current]" options:0 metrics:nil views:@{@"prev": [rows objectAtIndex: ii-1], @"current": [rows objectAtIndex: ii]}]];
	[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]|" options:0 metrics:nil views:@{@"last": [rows lastObject]}]];

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

    // find our first responder and make it visible
    NSMutableArray * search = [NSMutableArray array];
    [search addObjectsFromArray: self.scrollView.subviews];
    UIView * responder = nil;
    while ([search count] > 0) {
        UIView * view = [search lastObject];
        if ([view isFirstResponder]) {
            responder = view;
            break;
        } else {
            [search removeLastObject];
            [search addObjectsFromArray: view.subviews];
        }
    }

    if (responder)
        [self.scrollView scrollRectToVisible: responder.frame animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notif
{
	[self.scrollView setFrameHeight: self.view.frame.size.height];
}

- (IBAction)sendTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addToRecipientTapped:(id)sender
{
    INContactsViewController * vc = [[INContactsViewController alloc] initForSelectingContactWithCallback:^(INContact * contact) {
        if (contact)
            [_toRecipientsView addRecipientFromContact: contact];
    }];
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: vc];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (IBAction)addAttachmentTapped:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    [picker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setDelegate: self];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated: YES completion:^{
        [_attachmentsView addAttachment: [info objectForKey: UIImagePickerControllerOriginalImage]];
        [self arrangeContentViews];
    }];
}

@end
