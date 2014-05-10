//
//  INAttachmentTableViewCell.h
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INAttachmentTableViewCell : UITableViewCell

@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UIButton * xButton;
@property (nonatomic, strong) VoidBlock deleteCallback;

- (void)setAttachment:(id)attachment;

@end
