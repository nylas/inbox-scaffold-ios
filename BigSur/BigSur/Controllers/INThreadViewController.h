//
//  INThreadViewController.h
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INThreadViewController : UIViewController <INModelProviderDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;
@property (weak, nonatomic) IBOutlet UILabel * threadSubjectLabel;
@property (weak, nonatomic) IBOutlet UIView *threadHeaderView;

@property (nonatomic, strong) INThread * thread;
@property (nonatomic, strong) INModelProvider * messageProvider;

- (id)initWithThread:(INThread*)thread;

@end
