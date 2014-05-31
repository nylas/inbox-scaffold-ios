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
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_unarchive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(unarchiveTapped:)];
    else
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_archive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(archiveTapped:)];
    
	UIBarButtonItem * reply = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_reply.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(replyTapped:)];
	[self.navigationItem setRightBarButtonItems:@[reply, archive] animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction)archiveTapped:(id)sender
{
	[_thread archive];
}

- (IBAction)unarchiveTapped:(id)sender
{
	[_thread unarchive];
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

	UICollectionView __weak * __collectionView = collectionView;
	[cell setMessageHeightDeterminedBlock: ^() {
		[[__collectionView collectionViewLayout] invalidateLayout];
	}];
	
	[cell setMessage: message];
    [[cell draftDeleteButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftDeleteButton] addTarget:self action:@selector(deleteDraftTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[cell draftEditButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftEditButton] addTarget:self action:@selector(editDraftTapped:) forControlEvents:UIControlEventTouchUpInside];

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INMessage * message = [self messageForIndexPath: indexPath];
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
	if (([_messages count] == 0) && ([_drafts count] == 0)) {
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
    
	[_errorView setHidden: (([_messages count] > 0) || ([_drafts count] > 0))];
}

@end
