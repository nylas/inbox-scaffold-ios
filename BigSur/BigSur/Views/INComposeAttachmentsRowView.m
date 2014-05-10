//
//  INComposeAttachmentsRowView.m
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INComposeAttachmentsRowView.h"
#import "INAttachmentTableViewCell.h"
#import "UIView+FrameAdditions.h"

@implementation INComposeAttachmentsRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _attachments = [NSMutableArray array];
        
        _attachmentsTableView = [[UITableView alloc] initWithFrame: CGRectZero];
        [_attachmentsTableView setScrollEnabled: NO];
        [_attachmentsTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [_attachmentsTableView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [_attachmentsTableView setDataSource: self];
        [_attachmentsTableView setBackgroundColor: [UIColor clearColor]];
        [self addSubview: _attachmentsTableView];
        self.bodyView = _attachmentsTableView;
        
        self.animatesBottomBorder = YES;
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    if ([_attachments count] == 0)
        return CGSizeMake(UIViewNoIntrinsicMetric, 0);
    
    return CGSizeMake(UIViewNoIntrinsicMetric, [_attachments count] * [_attachmentsTableView rowHeight] + 8);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_attachmentsTableView setFrame: CGRectMake(0, 3, self.frame.size.width, 1000)];
}

- (NSArray*)attachments
{
    return [_attachments copy];
}

- (void)addAttachment:(id)thing
{
    [self animateAttachmentChange:^{
        [_attachments insertObject:thing atIndex:0];
    } withTableUpdates:^{
        [_attachmentsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }];
}

- (void)removeAttachmentAtIndex:(int)index
{
    NSIndexPath * ip = [NSIndexPath indexPathForItem:index inSection:0];

    [self animateAttachmentChange:^{
        [_attachments removeObjectAtIndex: index];
    } withTableUpdates:^{
        [_attachmentsTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationRight];
    }];
}

- (void)animateAttachmentChange:(VoidBlock)changeBlock withTableUpdates:(VoidBlock)tableBlock
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_attachmentsTableView beginUpdates];
        changeBlock();
        [self invalidateIntrinsicContentSize];
        [self updateConstraints];
        [self.superview layoutIfNeeded];
        [_bottomBorder setFrame: CGRectMake(-1, -1, self.frame.size.width + 2, self.frame.size.height)];
        tableBlock();
        [_attachmentsTableView endUpdates];
    } completion:^(BOOL finished) {
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INAttachmentTableViewCell * cell = (INAttachmentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) cell = [[INAttachmentTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    id attachment = [_attachments objectAtIndex: [indexPath row]];
    [cell setAttachment: attachment];
    [cell setDeleteCallback: ^{
        int index = [_attachments indexOfObject: attachment];
        [self removeAttachmentAtIndex: index];
    }];
    
    return cell;
}

@end
