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

@implementation INThreadViewController

- (id)initWithThread:(INThread*)thread
{
	self = [super init];
	if (self) {
		_thread = thread;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:INModelObjectChangedNotification object:_thread];
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

	[[_threadHeaderView layer] setShadowOffset: CGSizeMake(0, 1)];
	[[_threadHeaderView layer] setShadowOpacity: 0.1];
	[[_threadHeaderView layer] setShadowRadius: 1];

	[self update];
}

- (void)viewWillAppear:(BOOL)animated
{
	[_collectionView reloadData];
}

- (void)update
{
    [_messageProvider refresh];

    float headerPadding = _threadSubjectLabel.frame.origin.y;
	
    [_threadSubjectLabel setText: [_thread subject]];
    [_threadSubjectLabel sizeToFit];
	[_threadSubjectLabel setFrameWidth: _threadSubjectLabel.frame.size.width + 1]; // fix for rounding error
    
	[_tagsView setAlignment: NSTextAlignmentRight];
	[_tagsView setTags: [_thread tags]];
	[_tagsView setFrameY: [_threadSubjectLabel bottomLeft].y + headerPadding / 2];
    [_threadHeaderView setFrameHeight: [_tagsView bottomLeft].y + headerPadding];
    
	[_collectionView setContentInset: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, 0, 0)];
	[_collectionView setScrollIndicatorInsets: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, 0, 0)];

    UIBarButtonItem * archive = nil;
    if ([_thread hasTagWithID: INTagIDArchive])
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_unarchive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(unarchiveTapped:)];
    else
        archive = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_archive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(archiveTapped:)];
    
	UIBarButtonItem * reply = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_reply.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(replyTapped:)];
	[self.navigationItem setRightBarButtonItems:@[reply, archive] animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
	[self.messageProvider setDelegate: nil];
}

- (IBAction)replyTapped:(id)sender
{
    INMessage * reply = [[INMessage alloc] initAsDraftIn:[_thread namespace] inReplyTo:_thread];
	INComposeViewController * composer = [[INComposeViewController alloc] initWithDraft: reply];
	UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: composer];
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
	[[_thread currentDraft] delete];
}

- (IBAction)editDraftTapped:(id)sender
{
    // for now, assume there's only one draft. just find it
    INComposeViewController * composer = [[INComposeViewController alloc] initWithDraft: [_thread currentDraft]];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: composer];
    [self presentViewController:nav animated:YES completion:NULL];
}

#pragma Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [[_messageProvider items] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	INMessageCollectionViewCell * cell = (INMessageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"message" forIndexPath: indexPath];
	INMessage * message = [[_messageProvider items] objectAtIndex: [indexPath row]];
	[cell setMessage: message];
    [[cell draftDeleteButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftDeleteButton] addTarget:self action:@selector(deleteDraftTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[cell draftEditButton] removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    [[cell draftEditButton] addTarget:self action:@selector(editDraftTapped:) forControlEvents:UIControlEventTouchUpInside];

	UICollectionView __weak * __collectionView = collectionView;
	[cell setMessageHeightDeterminedBlock: ^() {
		[[__collectionView collectionViewLayout] invalidateLayout];
	}];

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	INMessage * message = [[_messageProvider items] objectAtIndex: [indexPath row]];
	float height = [INMessageCollectionViewCell cachedHeightForMessage: message];
	if (height == 0)
		height = 100;
		
	return CGSizeMake(300, height);
}

#pragma Provider Delegate

- (void)providerDataAltered:(INModelProviderChangeSet *)changeSet
{
	[_collectionView performBatchUpdates:^{
		[_collectionView deleteItemsAtIndexPaths: [changeSet indexPathsFor: INModelProviderChangeRemove]];
		[_collectionView insertItemsAtIndexPaths: [changeSet indexPathsFor: INModelProviderChangeAdd]];
	} completion: NULL];
	[_collectionView reloadItemsAtIndexPaths: [changeSet indexPathsFor: INModelProviderChangeUpdate]];
}

- (void)providerDataFetchFailed:(NSError *)error
{
	if ([[_messageProvider items] count] == 0) {
		[_errorView setHidden: NO];
		[_errorLabel setText: [NSString stringWithFormat:@"Sorry, messages could not be loaded. %@", [error localizedDescription]]];
	}
}

- (void)providerDataChanged
{
	[[self collectionView] reloadData];
	if ([[_messageProvider items] count] > 0)
		[_errorView setHidden: YES];
}

@end
