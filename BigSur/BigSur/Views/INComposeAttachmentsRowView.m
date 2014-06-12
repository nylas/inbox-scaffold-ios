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
	NSArray * attachments = [self.delegate attachmentsForAttachmentsView: self];
    if ([attachments count] == 0)
        return CGSizeMake(UIViewNoIntrinsicMetric, 0);
    
    return CGSizeMake(UIViewNoIntrinsicMetric, [attachments count] * [_attachmentsTableView rowHeight] + 8);
}

- (void)setDelegate:(NSObject<INComposeAttachmentsRowViewDelegate> *)delegate
{
	_delegate = delegate;
	[_attachmentsTableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_attachmentsTableView setFrame: CGRectMake(0, 3, self.frame.size.width, 1000)];
}

- (void)animateAttachmentAdditionAtIndex:(NSInteger)index withBlock:(VoidBlock)block
{
    [self animateAttachmentChange:^{
		block();
    } withTableUpdates:^{
        [_attachmentsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }];
}

- (void)animateAttachmentRemovalAtIndex:(NSInteger)index withBlock:(VoidBlock)block
{
    [self animateAttachmentChange:^{
		block();
    } withTableUpdates:^{
        [_attachmentsTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
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
		[self positionBottomBorder];
        tableBlock();
        [_attachmentsTableView endUpdates];
    } completion:^(BOOL finished) {
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray * attachments = [self.delegate attachmentsForAttachmentsView: self];
    return [attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INAttachmentTableViewCell * cell = (INAttachmentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) cell = [[INAttachmentTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell"];

	NSArray * attachments = [self.delegate attachmentsForAttachmentsView: self];
    INFile * attachment = [attachments objectAtIndex: [indexPath row]];
    [cell setAttachment: attachment];
    [cell setDeleteCallback: ^{
        NSUInteger index = [attachments indexOfObject: attachment];
		[[self delegate] attachmentsView:self confirmRemoveAttachmentAtIndex: index];
    }];
    
    return cell;
}

@end
