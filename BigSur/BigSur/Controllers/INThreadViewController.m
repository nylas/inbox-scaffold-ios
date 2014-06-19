//
//  INThreadViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThreadViewController.h"
#import "INComposeViewController.h"
#import "INMessageCollectionViewCell.h"
#import "UIView+FrameAdditions.h"
#import "NSObject+AssociatedObjects.h"
#import "INPluginManager.h"
#import "INThemeManager.h"
#import "BPopdownMenu.h"

#define SECTION_INSET 10

@implementation INThreadViewController

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
	
	[_collectionView registerNib:[UINib nibWithNibName:@"INMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"message"];

	_messageProvider = [_thread newMessageProvider];
	[_messageProvider setItemSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
	[_messageProvider setDelegate: self];

    _messagesCollapsedState = [NSMutableDictionary dictionary];
    
    _draftProvider = [_thread newDraftProvider];
    [_draftProvider setItemSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
	[_draftProvider setDelegate: self];

	[[_threadHeaderView layer] setShadowOffset: CGSizeMake(0, 1)];
	[[_threadHeaderView layer] setShadowOpacity: 0.1];
	[[_threadHeaderView layer] setShadowRadius: 1];
}

- (void)viewWillAppear:(BOOL)animated
{
	if ([_thread isDataAvailable] == NO) {
        [_thread reload:^(BOOL success, NSError *error) {
            [self update];
        }];
    } else {
        [self update];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Only mark the thread as read if messages actaully loaded and displayed
    if ([_messages count] > 0) {
        [_thread markAsRead];
    }
}
- (void)update
{
    [_messageProvider refresh];

    float headerPadding = _threadSubjectLabel.frame.origin.y;
	
    [_threadSubjectLabel setText: [_thread subject]];
    [_threadSubjectLabel sizeToFit];
	[_threadSubjectLabel in_setFrameWidth: _threadSubjectLabel.frame.size.width + 1]; // fix for rounding error
    
	[_tagsView setAlignment: NSTextAlignmentRight];
	[_tagsView setTags: [_thread tags]];
	[_tagsView in_setFrameY: [_threadSubjectLabel in_bottomLeft].y + headerPadding / 2];
    [_threadHeaderView in_setFrameHeight: [_tagsView in_bottomLeft].y + headerPadding];
    
	[_collectionView setContentInset: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, SECTION_INSET, 0)];
	[_collectionView setScrollIndicatorInsets: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, SECTION_INSET, 0)];

    UIBarButtonItem * archive = nil;
    if ([_thread hasTagWithID: INTagIDArchive])
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_unarchive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleArchiveTapped:)];
    else
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_archive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleArchiveTapped:)];

    UIBarButtonItem * star = nil;
    if ([_thread hasTagWithID: INTagIDStarred])
        star = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_unstar.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleStarredTapped:)];
    else
        star = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_star.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleStarredTapped:)];

    
    _actions = [NSMutableArray array];
    NSMutableArray * actionTitles = [NSMutableArray array];
    
    for (NSString * name in [[INPluginManager shared] pluginNamesForRole: @"message-action"]) {
        JSContext * context = [[INPluginManager shared] contextForPluginWithName:name];
        context[@"thread"] = self.thread;
        BOOL available = [[context evaluateScript:@"plugin.isAvailableForThread(thread);"] toBool];
        if (available) {
            NSString * title = [[context evaluateScript:@"plugin.actionTitleForThread(thread);"] toString];
            if (title != nil) {
                [_actions addObject: context];
                [actionTitles addObject: title];
            }
        }
    }
    _actionsButton = [[BPopdownButton alloc] initWithFrame: CGRectMake(0, 0, 30, 20)];

    UIBarButtonItem * reply = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_reply.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(replyTapped:)];
	UIBarButtonItem * actions = [[UIBarButtonItem alloc] initWithCustomView: _actionsButton];
	[self.navigationItem setRightBarButtonItems:@[actions, star, reply, archive] animated:NO];

    [_actionsButton setTitle:@"•••" forState:UIControlStateNormal];
    [_actionsButton setTitleColor:[[INThemeManager shared] tintColor] forState:UIControlStateNormal];
    [_actionsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_actionsButton setMenuOptions: actionTitles];
    [_actionsButton setMenuDelegate: self];
}

- (void)dealloc
{
	[self.messageProvider setDelegate: nil];
}

- (IBAction)replyTapped:(id)sender
{
    INDraft * reply = [[INDraft alloc] initInNamespace:[_thread namespace] inReplyTo:_thread];
	INComposeViewController * composer = [[INComposeViewController alloc] initWithDraft: reply];
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: composer];
	[nav setModalPresentationStyle: UIModalPresentationFormSheet];
	[nav setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
	[self presentViewController: nav animated:YES completion:NULL];
}

- (void)popdownMenu:(BPopdownMenu*)menu optionSelected:(NSInteger)index
{
    JSContext * context = [_actions objectAtIndex: index];
    [context evaluateScript:@"plugin.performForThread(thread);"];
    [_actionsButton dismissMenu];
    
    if (context.exception) {
        [[[UIAlertView alloc] initWithTitle:@"Plugin Error" message:[context.exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (IBAction)toggleArchiveTapped:(id)sender
{
    if ([_thread hasTagWithID: INTagIDArchive])
        [_thread unarchive];
    else
        [_thread archive];
}

- (IBAction)toggleStarredTapped:(id)sender
{
    if ([_thread hasTagWithID: INTagIDStarred])
        [_thread unstar];
    else
        [_thread star];
}

- (IBAction)deleteDraftTapped:(id)sender
{
    UICollectionViewCell * cell = [sender viewAncestorOfClass: [UICollectionViewCell class]];
    NSIndexPath * ip = [_collectionView indexPathForCell: cell];
    INDraft * draft = [_drafts objectAtIndex: [ip row]];

    [draft delete];
}

- (IBAction)editDraftTapped:(id)sender
{
    UICollectionViewCell * cell = [sender viewAncestorOfClass: [UICollectionViewCell class]];
    NSIndexPath * ip = [_collectionView indexPathForCell: cell];
    INDraft * draft = [_drafts objectAtIndex: [ip row]];

    INComposeViewController * composer = [[INComposeViewController alloc] initWithDraft: draft];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: composer];
	[nav setModalPresentationStyle: UIModalPresentationFormSheet];
	[nav setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)toggleMessageCollapse:(UITapGestureRecognizer*)recognizer
{
    INMessageCollectionViewCell * cell = [[recognizer view] viewAncestorOfClass: [INMessageCollectionViewCell class]];
    if (!cell) return;
    
    NSString * key = [[cell message] ID];
    BOOL collapsed = [[_messagesCollapsedState objectForKey: key] boolValue];

    collapsed = !collapsed;
    
    [cell setCollapsed: collapsed];
    [_messagesCollapsedState setObject:@(collapsed) forKey:key];
    [[_collectionView collectionViewLayout] invalidateLayout];
}

#pragma Collection View Data Source

- (INMessage *)messageForIndexPath:(NSIndexPath*)indexPath
{
    if ([indexPath section] == 0)
        return [_drafts objectAtIndex: [indexPath row]];
    else
        return [_messages objectAtIndex: [indexPath row]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return [_drafts count];
    else
        return [_messages count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	INMessageCollectionViewCell * cell = (INMessageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"message" forIndexPath: indexPath];
    INMessage * message = [self messageForIndexPath: indexPath];
    BOOL collapsed = [_messagesCollapsedState[[message ID]] boolValue];
    
	UICollectionView __weak * __collectionView = collectionView;
	[cell setMessageHeightDeterminedBlock: ^() {
		[[__collectionView collectionViewLayout] invalidateLayout];
	}];
    
	[cell setMessage: message];
    [cell setCollapsed: collapsed];
    
    if ([[[cell headerContainerView] gestureRecognizers] count] == 0) {
        UITapGestureRecognizer * tapRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMessageCollapse:)];
        [[cell headerContainerView] addGestureRecognizer: tapRecognzier];
    }
    
    [[cell draftDeleteButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftDeleteButton] addTarget:self action:@selector(deleteDraftTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[cell draftEditButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftEditButton] addTarget:self action:@selector(editDraftTapped:) forControlEvents:UIControlEventTouchUpInside];

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INMessage * message = [self messageForIndexPath: indexPath];

    if ([[_messagesCollapsedState objectForKey: [message ID]] boolValue] == YES)
        return CGSizeMake(300, 66);
    
    float height = [INMessageCollectionViewCell cachedHeightForMessage: message];
	if (height == 0)
		height = 100;
		
	return CGSizeMake(_collectionView.frame.size.width - SECTION_INSET * 2, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([((section == 0) ? _drafts : _messages) count] == 0)
        return UIEdgeInsetsMake(0, 0, 0, 0);
    return UIEdgeInsetsMake(SECTION_INSET, SECTION_INSET, 0, SECTION_INSET);
}

#pragma Provider Delegate

- (void)provider:(INModelProvider*)provider dataAltered:(INModelProviderChangeSet *)changeSet
{
    int __block section = 0;
    
	[_collectionView performBatchUpdates:^{
        if (provider == _draftProvider) {
            _drafts = [provider items];
            section = 0;
        }
        if (provider == _messageProvider) {
            _messages = [provider items];
            section = 1;
        }
        [_collectionView deleteItemsAtIndexPaths: [changeSet indexPathsFor: INModelProviderChangeRemove assumingSection:section]];
		[_collectionView insertItemsAtIndexPaths: [changeSet indexPathsFor: INModelProviderChangeAdd assumingSection:section]];
	} completion: NULL];

	[_errorView setHidden: (([_messages count] > 0) || ([_drafts count] > 0))];
}

- (void)provider:(INModelProvider*)provider dataFetchFailed:(NSError *)error
{
	if (([_messages count] == 0) && ([_drafts count] == 0) && error) {
		[_errorView setHidden: NO];
		[_errorLabel setText: [NSString stringWithFormat:@"Sorry, messages could not be loaded. %@", [error localizedDescription]]];
	}
}

- (void)providerDataChanged:(INModelProvider*)provider
{
    if (provider == _draftProvider)
        _drafts = [provider items];
    if (provider == _messageProvider)
        _messages = [provider items];

	[[self collectionView] reloadData];
	[_errorView setHidden: YES];
}

@end
