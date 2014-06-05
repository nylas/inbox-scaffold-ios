//
//  INThreadViewController.h
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTagsView.h"
#import "BPopdownButton.h"

@interface INThreadViewController : UIViewController <INModelProviderDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, BPopdownMenuDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView * collectionView;
@property (weak, nonatomic) IBOutlet UILabel * threadSubjectLabel;
@property (weak, nonatomic) IBOutlet UIView *threadHeaderView;
@property (weak, nonatomic) IBOutlet INTagsView *tagsView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) INModelProvider * messageProvider;
@property (nonatomic, strong) INModelProvider * draftProvider;

@property (nonatomic, strong) INThread * thread;
@property (nonatomic, strong) NSArray * messages;
@property (nonatomic, strong) NSMutableDictionary * messagesCollapsedState;
@property (nonatomic, strong) NSArray * drafts;

@property (nonatomic, strong) NSMutableArray * actions;
@property (nonatomic, strong) BPopdownButton * actionsButton;

- (id)initWithThread:(INThread*)thread;

@end
