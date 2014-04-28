//
//  INModelView.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDatabaseManager.h"

typedef enum : NSUInteger {
    INModelProviderCacheOnly,
    INModelProviderCacheThenNetwork
} INModelProviderCachePolicy;


@protocol INModelProviderDelegate <NSObject>
@optional
- (void)providerDataRefreshed;
- (void)providerDataAltered:(NSArray*)changes;
@end

@interface INModelProvider : NSObject <INDatabaseObserver>

@property (nonatomic, strong) NSArray * items;

@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray * sortDescriptors;
@property (nonatomic, assign) INModelProviderCachePolicy cachePolicy;
@property (nonatomic, weak) NSObject<INModelProviderDelegate> * delegate;

+ (id)providerForClass:(Class)modelClass;

- (void)refresh;


@end
