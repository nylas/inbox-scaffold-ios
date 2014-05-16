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
#import "NSString+FormatConversion.h"
#import "INAppDelegate.h"

@implementation INComposeViewController

- (id)initWithNewDraft
{
    self = [super init];
	if (self) {
        _draft = [[INMessage alloc] init];

		[self setTitle: @"New Message"];
    }
    return self;
}

- (id)initWithNewDraftInReplyTo:(INThread*)thread
{
	self = [super init];
	if (self) {
        _draft = [[INMessage alloc] init];
        [_draft setThreadID: thread.ID];
        
        NSMutableArray * recipients = [NSMutableArray array];
		for (NSDictionary * recipient in [thread participants])
			if (![[[INAPIManager shared] namespaceEmailAddresses] containsObject: recipient[@"email"]])
				[recipients addObject: recipient];
        
        [_draft setTo: recipients];
        [_draft setSubject: thread.subject];
        
        [self setTitle:@"New Reply"];
	}
	return self;
}

- (id)initWithExistingDraft:(INMessage*)draft
{
    self = [super init];
	if (self) {
        _draft = draft;
        
		[self setTitle: @"Edit Draft"];
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
    [_toRecipientsView addRecipients: [_draft to]];
    
	_ccBccRecipientsView = [[INComposeRecipientRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_ccBccRecipientsView.rowLabel setText: @"Cc/Bcc:"];
    
	_subjectView = [[INComposeSubjectRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
    [[_subjectView actionButton] addTarget:self action:@selector(addAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[_subjectView subjectField] setText: _draft.subject];
    
    _attachmentsView = [[INComposeAttachmentsRowView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
    
	_bodyTextView = [[INPlaceholderTextView alloc] initWithFrame: CGRectMake(0, 0, 320, 0)];
	[_bodyTextView setPlaceholder: @"Compose a message..."];
	[_bodyTextView setFont: [UIFont systemFontOfSize: 15]];
	[_bodyTextView setTextContainerInset: UIEdgeInsetsMake(5,4,5,4)];
	[_bodyTextView setScrollEnabled: NO];
    [_bodyTextView setText: [_draft body]];
    
    [self arrangeContentViews];
    
	// listen for taps on the scroll view beneath the text view to activate the text view
	UITapGestureRecognizer * recognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusBodyTextView:)];
	[recognzier setDelegate: self];
	[_scrollView addGestureRecognizer: recognzier];

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
    [_draft beginUpdates];
    [self applyChangesToDraft];
    
    
    INAPIOperation * save = [INAPIOperation operationForSavingDraft: _draft];
    INAPIOperation * send = [INAPIOperation operationForSendingDraft: _draft];
    [send addDependency: save];
    [[INAPIManager shared] queueAPIOperation: save];
    [[INAPIManager shared] queueAPIOperation: send];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelTapped:(id)sender
{
    BOOL hasSubject = ([[[_subjectView subjectField] text] length] > 0);
    BOOL hasBody = ([[_bodyTextView text] length] > 0);
    BOOL hasAttachments = ([[_attachmentsView attachments] count] > 0);
    
    if (hasSubject || hasBody || hasAttachments) {
        [UIActionSheet showInView:self.view withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Draft" otherButtonTitles:@[@"Save Draft"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == [actionSheet cancelButtonIndex])
                return;
            else if (buttonIndex == [actionSheet destructiveButtonIndex])
                [self dismissViewControllerAnimated:YES completion:NULL];
            else {
                [_draft beginUpdates];
                [self applyChangesToDraft];
                [_draft commitUpdates];
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
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
    [_draft setNamespaceID: [[INAppDelegate current] currentNamespace].ID];
    [_draft setTo: [_toRecipientsView recipients]];
    [_draft setSubject: [[_subjectView subjectField] text]];
    [_draft setBody: [_bodyTextView text]];
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

@end
