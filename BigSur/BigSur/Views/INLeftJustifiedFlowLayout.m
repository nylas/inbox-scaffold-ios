//
//  INLeftJustifiedFlowLayout.m
//  BigSur
//
//  Created by Ben Gotow on 5/5/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INLeftJustifiedFlowLayout.h"

@implementation INLeftJustifiedFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray * layoutAttributes = [super layoutAttributesForElementsInRect: rect];
    for (UICollectionViewLayoutAttributes * attributes in layoutAttributes)
        [self adjustAttributes: attributes];
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id attributes = (UICollectionViewLayoutAttributes*)[super layoutAttributesForItemAtIndexPath: indexPath];
    [self adjustAttributes: attributes];
    return attributes;
}

- (void)adjustAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    // Important: This function calls itself on other cells in some scenarios. It must be FAST.
    // Don't do time-consuming things here.
    NSIndexPath * indexPath = [attributes indexPath];
    
    // make sure that we always left-justify the cell in a non-full row. The default flow layout
    // implementation sort of spreads the cells across the center and increases spacing. This is
    // kind of strange.
    CGRect previousFrame = CGRectZero;
    if ([indexPath row] > 0) {
        NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
        if ([previousIndexPath row] != NSNotFound)
            previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    }
    CGRect frame = attributes.frame;
    
    if (previousFrame.origin.y == frame.origin.y)
        frame.origin.x = previousFrame.origin.x + previousFrame.size.width + self.minimumInteritemSpacing;
    else
        frame.origin.x = [self sectionInset].left;
    
    [attributes setFrame: frame];
}


@end
