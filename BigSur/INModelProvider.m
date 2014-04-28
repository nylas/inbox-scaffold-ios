//
//  INModelView.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelProvider.h"
#import "INModelObject.h"
#import "INModelObject+DatabaseCache.h"
#import "NSObject+AssociatedObjects.h"

@implementation INModelProvider

+ (id)providerForClass:(Class)modelClass
{
    INModelProvider * view = [[INModelProvider alloc] init];
    [view setModelClass: modelClass];
    return view;
}

- (id)init
{
    self = [super init];
    if (self) {
        // subscribe to updates about the local database cache. This creates
        // a weak reference to us, so we don't have to worry about unregistering later.
        [[INDatabaseManager shared] registerCacheObserver: self];
    }
    return self;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    _sortDescriptors = sortDescriptors;
    [self performSelectorOnMainThreadOnce:@selector(refresh)];
}

- (void)setPredicate:(NSPredicate *)predicate
{
    _predicate = predicate;
    [self performSelectorOnMainThreadOnce:@selector(refresh)];
}

- (void)refresh
{
    // immediately refresh our data from what is now available in the cache
    [_modelClass persistedInstancesMatching:_predicate sortedBy:_sortDescriptors limit:10 offset:0 withCallback:^(NSArray *matchingItems) {
        self.items = matchingItems;
        if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)])
            [self.delegate providerDataRefreshed];
    }];

    // make an API request to refresh our data
    if (_cachePolicy == INModelProviderCacheThenNetwork) {
        [self fetchItems];
    }
}

- (void)fetchItems
{
    // overridden in subclasses
}

#pragma mark Receiving Updates from the Database

- (void)managerDidPersistModels:(NSArray*)models
{
    // potentially do smart things here.
    if ([[models firstObject] class] == _modelClass)
        [self performSelectorOnMainThreadOnce:@selector(refresh)];
}

- (void)managerDidPerformTransaction;
{
    // invalidate ourselves completely and refresh everything.
    // Custom SQL has been performed and we don't know what has changed.
    [self performSelectorOnMainThreadOnce:@selector(refresh)];
}


@end
