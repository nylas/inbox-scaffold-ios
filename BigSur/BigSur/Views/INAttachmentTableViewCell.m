//
//  INAttachmentTableViewCell.m
//  BigSur
//
//  Created by Ben Gotow on 5/9/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAttachmentTableViewCell.h"

@implementation INAttachmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self imageView] setClipsToBounds: YES];
        [[self imageView] setContentMode: UIViewContentModeScaleAspectFill];
    
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleBar];
        [_progressView setProgress: 0.2];
        [_progressView setTrackTintColor: [UIColor colorWithWhite:0.9 alpha:1]];
        [[self contentView] addSubview: _progressView];

        self.xButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [_xButton setTitle:@"X" forState:UIControlStateNormal];
        [_xButton addTarget:self action:@selector(triggerDeleteCallback:) forControlEvents:UIControlEventTouchUpInside];
        [_xButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [[self contentView] addSubview: _xButton];
        
        [self setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float h = self.frame.size.height - 8;
    [[self imageView] setFrame: CGRectMake(8, 4, h, h)];
    [[self progressView] setFrame: CGRectMake(h + 13, (self.frame.size.height - 3)/2, self.frame.size.width - (h + 13 + 30 + 8), 3)];
    [[self xButton] setFrame: CGRectMake(self.frame.size.width - 30, 4, 30, h)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setAttachment:(id)attachment
{
    if ([attachment isKindOfClass: [UIImage class]]) {
        [[self imageView] setImage: attachment];
    }
}

- (void)triggerDeleteCallback:(id)sender
{
    if (_deleteCallback)
        _deleteCallback();
}



@end
