//
//  INMessageCollectionViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INRecipientsLabel.h"
#import "INMessageContentView.h"

@class INMessageCollectionViewCell;

typedef void (^ CellBlock)();

@interface INMessageCollectionViewCell : UICollectionViewCell <UIWebViewDelegate, INMessageContentViewDelegate>

@property (nonatomic, strong) INMessage * message;
@property (nonatomic, strong) CellBlock messageHeightDeterminedBlock;

@property (nonatomic, weak) IBOutlet INMessageContentView * bodyView;
@property (nonatomic, weak) IBOutlet UIButton * fromProfileButton;
@property (nonatomic, weak) IBOutlet INRecipientsLabel * fromField;
@property (nonatomic, weak) IBOutlet INRecipientsLabel * toField;
@property (nonatomic, weak) IBOutlet UILabel * dateField;
@property (nonatomic, weak) IBOutlet UIButton * draftDeleteButton;
@property (nonatomic, weak) IBOutlet UIButton * draftEditButton;
@property (nonatomic, weak) IBOutlet UIView * draftOptionsView;
@property (nonatomic, weak) IBOutlet UIView * headerContainerView;
@property (nonatomic, strong) CALayer * headerBorderLayer;

+ (float)cachedHeightForMessage:(INMessage*)message;

@end
