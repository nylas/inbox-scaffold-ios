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
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "NSString+FormatConversion.h"
#import "INAppDelegate.h"

@implementation INComposeViewController


- (id)initWithDraft:(INDraft*)draft
{
    self = [super init];
	if (self) {
        _draft = draft;
        
        NSString * action = @"New";
        if ([_draft createdAt])
            action = @"Edit";
        
        if ([_draft threadID])
            [self setTitle: [NSString stringWithFormat: @"%@ Reply", action]];
        else
            [self setTitle: [NSString stringWithFormat: @"%@ Draft", action]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	float w = [self.view frame].size.width;
	
	// create our views
	_toRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, w, 0)];
	[_toRecipientsView.rowLabel setText: @"To:"];
	[[_toRecipientsView actionButton] addTarget:self action:@selector(addToRecipientTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_toRecipientsView addRecipients: [_draft to]];
    
	_ccBccRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, w, 0)];
	[_ccBccRecipientsView.rowLabel setText: @"Cc/Bcc:"];
    
	_subjectView = [[INComposeSubjectRowView alloc] initWithFrame: CGRectMake(0, 0, w, 0)];
    [[_subjectView actionButton] addTarget:self action:@selector(addAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[_subjectView subjectField] setText: _draft.subject];
    
    _attachmentsView = [[INComposeAttachmentsRowView alloc] initWithFrame: CGRectMake(0, 0, w, 0)];
	[_attachmentsView setDelegate: self];
		
	_bodyTextView = [[INPlaceholderTextView alloc] initWithFrame: CGRectMake(0, 0, w, 0)];
	[_bodyTextView setPlaceholder: @"Compose a message..."];
	[_bodyTextView setFont: [UIFont systemFontOfSize: 15]];
	[_bodyTextView setTextContainerInset: UIEdgeInsetsMake(5,4,5,4)];
	[_bodyTextView setScrollEnabled: NO];
    
    if ([_draft body])
        [_bodyTextView setText: [_draft body]];
    else
        [_bodyTextView setText: @"\n\nSent from Inbox"];

    [self arrangeContentViews];
    
	// listen for taps on the scroll view beneath the text view to activate the text view
	UITapGestureRecognizer * recognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusBodyTextView:)];
	[recognzier setDelegate: self];
	[_scrollView addGestureRecognizer: recognzier];

	// create the nav item
	UIBarButtonItem * cancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"icon_cancel.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelTapped:)];
	[self.navigationItem setLeftBarButtonItem: cancel];

	UIBarButtonItem * send = [[UIBarButtonItem alloc] initWithTitle: @"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendAfterVerifyingTapped:)];
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
		
		NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0];
		[self.scrollView addConstraints: @[widthConstraint]];
		[self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":view}]];
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
    
    if ([[_toRecipientsView recipients] count] > 0) {
        [_bodyTextView setSelectedRange: NSMakeRange(0, 0)];
        [_bodyTextView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
    [_bodyTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)sendAfterVerifyingTapped:(id)sender
{
	NSMutableArray * checks = [NSMutableArray array];
	
	VoidBlock next = ^{
		VoidBlock check = [checks lastObject];
		[checks removeLastObject];

		if (check)
			check();
		else
			[self sendTapped: nil];
	};
	
	[checks addObject: ^{
		if ([[[_subjectView subjectField] text] length] > 0)
			return next();
			
        [UIAlertView showWithTitle:@"No Subject" message:@"Send your message without a subject?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Send Anyway"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != [alertView cancelButtonIndex])
				return next();
        }];
	}];
	
	[checks addObject: ^{
		if ([[_bodyTextView text] length] > 0)
			return next();
        
        [UIAlertView showWithTitle:@"No Message Body" message:@"Send your message without any contents?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Send Anyway"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != [alertView cancelButtonIndex])
				return next();
        }];
	}];
	
	[checks addObject: ^{
		if (![_toRecipientsView containsInvalidRecipients])
			return next();

		[UIAlertView showWithTitle:@"Invalid Recipients" message:@"One or more of the recipients you provided doesn't have a valid email address. If you continue, your message will not be sent to these recipients." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Send Anyway"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
			if (buttonIndex != [alertView cancelButtonIndex])
				return next();
		}];
	}];
		
	[checks addObject: ^{
		if ([[_toRecipientsView recipients] count] > 0)
			return next();
			
		[[[UIAlertView alloc] initWithTitle:@"No Recipients" message:@"Add one or more recipients before sending your message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	}];
	
	next();
}

- (IBAction)sendTapped:(id)sender
{
	[self applyChangesToDraft];
    [_draft save];
	[_draft send];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelTapped:(id)sender
{
    BOOL hasSubject = ([[[_subjectView subjectField] text] length] > 0);
    BOOL hasBody = ([[_bodyTextView text] length] > 0);
    BOOL hasAttachments = ([[_draft attachments] count] > 0);
    
    if (hasSubject || hasBody || hasAttachments) {
        [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Draft" otherButtonTitles:@[@"Save Draft"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == [actionSheet cancelButtonIndex]) {
                return;
            } else if (buttonIndex == [actionSheet destructiveButtonIndex]) {
                [_draft delete];
            } else {
                [self applyChangesToDraft];
                [_draft save];
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)cancelWithoutSaving
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)applyChangesToDraft
{
    [_draft setCreatedAt: [NSDate date]];
    [_draft setNamespaceID: [[INAppDelegate current] currentNamespace].ID];
    [_draft setTo: [_toRecipientsView recipients]];
    [_draft setSubject: [[_subjectView subjectField] text]];
    [_draft setBody: [_bodyTextView text]];
}

- (IBAction)addToRecipientTapped:(id)sender
{
	INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    INContactsViewController * vc = [[INContactsViewController alloc] initForSelectingContactInNamespace:namespace withCallback:^(INContact * contact) {
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
	
	if ([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]) {
		_attachmentsPopover = [[UIPopoverController alloc] initWithContentViewController: picker];
		[_attachmentsPopover presentPopoverFromRect: [sender frame] inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	} else {
		[self presentViewController:picker animated:YES completion:NULL];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	VoidBlock ready = ^{
		UIImage * image = [info objectForKey: UIImagePickerControllerOriginalImage];
		[_attachmentsView animateAttachmentAdditionAtIndex:0 withBlock:^{
			INFile * attachment = [[INFile alloc] initWithImage: image inNamespace: [_draft namespace]];
			[_draft addAttachment: attachment atIndex: 0];
		}];
		
        [self arrangeContentViews];
	};
	
	if (_attachmentsPopover) {
		[_attachmentsPopover dismissPopoverAnimated:YES];
		ready();
	} else {
		[picker dismissViewControllerAnimated: YES completion: ready];
	}
}

#pragma mark Attachments View Delegate

- (NSArray*)attachmentsForAttachmentsView:(INComposeAttachmentsRowView*)view
{
	return [_draft attachments];
}

- (void)attachmentsView:(INComposeAttachmentsRowView*)view confirmRemoveAttachmentAtIndex:(NSInteger)index
{
	[view animateAttachmentRemovalAtIndex:index withBlock:^{
		[_draft removeAttachmentAtIndex: index];
	}];
}

#pragma mark Collecting Touches beneath Body

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// Touching anywhere below the body text view should activate the body text view,
	// but don't screw with touches to valid elements of our compose sheet.
	if ([touch locationInView: self.scrollView].y > _bodyTextView.frame.origin.y + _bodyTextView.frame.size.height)
		return YES;
	return NO;
}

- (void)focusBodyTextView:(UITapGestureRecognizer*)recognizer
{
	[_bodyTextView becomeFirstResponder];
}

#pragma mark Showing and Hiding Keyboard

- (void)keyboardWillShow:(NSNotification*)notif
{
	CGRect keyboardFrame = [[[notif userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];

	UIEdgeInsets insets = self.scrollView.contentInset;
	insets.bottom = keyboardFrame.size.height;
	[self.scrollView setContentInset: insets];
	[self.scrollView setScrollIndicatorInsets: insets];

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
	UIEdgeInsets insets = self.scrollView.contentInset;
	insets.bottom = 0;
	[self.scrollView setContentInset: insets];
	[self.scrollView setScrollIndicatorInsets: insets];
}

@end
