//
//  INComposeAttachmentsRowView.h
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeRowView.h"

@interface INComposeAttachmentsRowView : INComposeRowView <UITableViewDataSource>
{
    NSMutableArray * _attachments;
    UITableView * _attachmentsTableView;
}

- (NSArray*)attachments;
- (void)addAttachment:(id)thing;

@end
