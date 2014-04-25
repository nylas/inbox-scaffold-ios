//
//  INModelView.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol INModelViewDelegate <NSObject>

@required
- (void)viewChanged:(NSArray*)changes;

@end

@interface INModelView : NSObject

@property (nonatomic, strong) NSArray * items;

@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray * sortDescriptors;
@property (nonatomic, weak) NSObject<INModelViewDelegate> * delegate;

+ (id)viewForClass:(Class)modelClass;

- (void)repopulate:(BOOL)calculateChanges;

@end
