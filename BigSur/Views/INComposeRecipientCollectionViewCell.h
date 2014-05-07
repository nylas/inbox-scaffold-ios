//
//  INComposeRecipientCollectionViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/6/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INComposeRecipientFont [UIFont systemFontOfSize: 15]
#define INComposeRecipientVPadding 3

@interface INComposeRecipientCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView * insetView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * profileImage;

- (void)setRecipient:(NSDictionary*)recipient;

@end
