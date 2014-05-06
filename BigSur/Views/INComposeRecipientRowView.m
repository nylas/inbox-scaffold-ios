//
//  INComposeRecipientsView.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRecipientRowView.h"
#import "INLeftJustifiedFlowLayout.h"

@implementation INComposeRecipientRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self.actionButton setTitle:@"+" forState:UIControlStateNormal];
		
		UICollectionViewFlowLayout * layout = [[INLeftJustifiedFlowLayout alloc] init];
		[layout setScrollDirection: UICollectionViewScrollDirectionVertical];
		[layout setSectionInset: UIEdgeInsetsMake(1,2,1,2)];
		[layout setMinimumInteritemSpacing: 5];
		[layout setMinimumLineSpacing: 5];
		
		_recipientsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		[_recipientsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
		[_recipientsCollectionView setDelegate: self];
		[_recipientsCollectionView setDataSource: self];
		[_recipientsCollectionView setScrollEnabled: NO];
		[_recipientsCollectionView setBackgroundColor: [UIColor whiteColor]];
		_recipientsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview: _recipientsCollectionView];

		self.bodyView = _recipientsCollectionView;
    }
    return self;
}


- (void)updateConstraints
{
	float height = [[_recipientsCollectionView collectionViewLayout] collectionViewContentSize].height;
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(7)-[body(>=contentheight)]-(7)-|" options:0 metrics:@{@"contentheight": @(height)} views: @{@"body": _recipientsCollectionView}]];
	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(14)-[label]" options:0 metrics:nil views: @{@"label": self.rowLabel}]];
	[super updateConstraints];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 3;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	[cell setBackgroundColor: [UIColor purpleColor]];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(100, 32);
}

@end
