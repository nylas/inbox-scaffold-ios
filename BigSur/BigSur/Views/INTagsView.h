//
//  INTagsView.h
//  BigSur
//
//  Created by Ben Gotow on 5/14/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INTagsView : UIView
{
	NSMutableArray * _tagViews;
}

@property (nonatomic, assign) NSTextAlignment alignment;

- (void)setTags:(NSArray*)tags;

@end
