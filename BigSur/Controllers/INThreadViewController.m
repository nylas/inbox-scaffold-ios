//
//  INThreadViewController.m
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INThreadViewController.h"
#import "INMessageCollectionViewCell.h"
#import "UIView+FrameAdditions.h"
#import "NSObject+AssociatedObjects.h"
#import "INMessage.h"

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
	
	// give us messages!
	_messageProvider = [_thread newMessageProvider];
	[_messageProvider setItemSortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
	[_messageProvider setDelegate: self];
	[_messageProvider refresh];
	
	[[_threadHeaderView layer] setShadowOffset: CGSizeMake(0, 1)];
	[[_threadHeaderView layer] setShadowOpacity: 0.1];
	[[_threadHeaderView layer] setShadowRadius: 1];
	[_threadSubjectLabel setText: [_thread subject]];

	[_threadSubjectLabel sizeToFit];
	[_threadHeaderView setFrameHeight: _threadSubjectLabel.frame.size.height + _threadSubjectLabel.frame.origin.y * 2];
	[_collectionView setContentInset: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, 0, 0)];
	[_collectionView setScrollIndicatorInsets: UIEdgeInsetsMake(_threadHeaderView.frame.size.height, 0, 0, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
	[[[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)providerDataChanged
{
	[[self collectionView] reloadData];
}

@end
