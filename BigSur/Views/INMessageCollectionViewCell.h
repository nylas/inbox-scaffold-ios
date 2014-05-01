//
//  INMessageCollectionViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/1/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INMessage.h"

@class INMessageCollectionViewCell;

typedef void (^ CellBlock)();

@interface INMessageCollectionViewCell : UICollectionViewCell <UIWebViewDelegate>

@property (nonatomic, strong) INMessage * message;
@property (nonatomic, strong) CellBlock messageHeightDeterminedBlock;

@property (nonatomic, weak) IBOutlet UIWebView * bodyWebView;

+ (float)cachedHeightForMessage:(INMessage*)message;

@end
