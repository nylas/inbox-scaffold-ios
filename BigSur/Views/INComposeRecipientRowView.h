//
//  INComposeRecipientsView.h
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INComposeRowView.h"

@interface INComposeRecipientRowView : INComposeRowView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView * recipientsCollectionView;

@end
