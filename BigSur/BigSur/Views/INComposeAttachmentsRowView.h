//
//  INComposeAttachmentsRowView.h
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRowView.h"

@class INComposeAttachmentsRowView;

@protocol INComposeAttachmentsRowViewDelegate <NSObject>

- (NSArray*)attachmentsForAttachmentsView:(INComposeAttachmentsRowView*)view;
- (void)attachmentsView:(INComposeAttachmentsRowView*)view confirmRemoveAttachmentAtIndex:(NSInteger)index;

@end

@interface INComposeAttachmentsRowView : INComposeRowView <UITableViewDataSource>
{
    UITableView * _attachmentsTableView;
}
@property (nonatomic, weak) NSObject <INComposeAttachmentsRowViewDelegate>* delegate;

- (void)animateAttachmentAdditionAtIndex:(NSInteger)index withBlock:(VoidBlock)block;
- (void)animateAttachmentRemovalAtIndex:(NSInteger)index withBlock:(VoidBlock)block;

@end
