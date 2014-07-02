//
//  BPopdownMenu.m
//  Bloganizer
//
//  Created by Ben Gotow on 7/10/13.
//  Copyright (c) 2013 Bloganizer Inc. All rights reserved.
//

#import "BPopdownMenu.h"
#import "UIView+FrameAdditions.h"

#define ITEM_FONT [UIFont fontWithName:@"HelveticaNeue" size:15]

@implementation BPopdownMenu

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 160, 0)];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame: self.bounds];
        [_tableView setDelegate: self];
        [_tableView setDataSource: self];
        [_tableView setRowHeight: 36];
        [_tableView setScrollEnabled: NO];
        [_tableView setBounces: NO];
        [_tableView setAlwaysBounceVertical: NO];
        [_tableView setBackgroundColor: [UIColor whiteColor]];
        [[_tableView layer] setCornerRadius: 2];
        [_tableView setClipsToBounds: YES];
        [self addSubview: _tableView];
        
        _optionChecked = -1;
        
        _arrow = [[UIImageView alloc] initWithFrame: CGRectMake(0, -14, 16, 16)];
        [_arrow setImage: [UIImage imageNamed: @"popover_arrow.png"]];
        [self setClipsToBounds: NO];
        [self addSubview: _arrow];
        
        [[self layer] setBackgroundColor: [[UIColor whiteColor] CGColor]];
        [[self layer] setCornerRadius: 3];
        [[self layer] setShadowOffset: CGSizeMake(0, 1)];
        [[self layer] setShadowOpacity: 0.3];
        [[self layer] setShadowRadius: 5];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_tableView setFrame: CGRectInset(self.bounds, 4,4)];
    [_arrow in_setFrameX: [[self layer] anchorPoint].x * (self.bounds.size.width) - _arrow.bounds.size.width/2];
}

- (void)setOptions:(NSArray *)options
{
    _options = options;
    
    float maxWidth = 0;
    for (NSString * option in options) {
        float optionWidth = 40 + [option boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: ITEM_FONT} context:nil].size.width;
        maxWidth = fmaxf(maxWidth, optionWidth);
    }
    
    [self in_setFrameHeight: [_options count] * 36 + 4];
    [self in_setFrameWidth: maxWidth];
    [_tableView reloadData];
}

- (void)setCheckedItemIndex:(int)index
{
    _optionChecked = index;
    [_tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    UIView * backView = [[UIView alloc] initWithFrame:cell.frame];
    backView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = backView;
    
    [cell setAccessoryType: (_optionChecked == [indexPath row]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    [[cell textLabel] setHighlightedTextColor: [UIColor blackColor]];
    [[cell textLabel] setTextColor: [UIColor colorWithWhite:0.1 alpha:1]];
    [[cell textLabel] setFont: ITEM_FONT];
    [[cell textLabel] setText: [_options objectAtIndex: [indexPath row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector: @selector(popdownMenu:optionSelected:)])
        [_delegate popdownMenu:self optionSelected:[indexPath row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
