//
//  INModelView.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelProvider.h"
#import "INModelProviderChange.h"
#import "INModelObject.h"
#import "INModelObject+DatabaseCache.h"
#import "NSObject+AssociatedObjects.h"

@implementation INModelProviderChange : NSObject

- (INModelProviderChange*)changeOfType:(INModelProviderChangeType)type forItem:(INModelObject*)item atIndex:(NSInteger)index
{
    INModelProviderChange * change = [[INModelProviderChange alloc] init];
    [change setType: type];
    [change setItem: item];
    [change setIndex: index];
    return change;
}

@end


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
    [self fetchFromCache];

    // make an API request to refresh our data
    if (_cachePolicy == INModelProviderCacheThenNetwork) {
        [self fetchFromAPI];
    }
}

- (void)fetchFromCache
{
    // immediately refresh our data from what is now available in the cache
    [_modelClass persistedInstancesMatching:_predicate sortedBy:_sortDescriptors limit:10 offset:0 withCallback:^(NSArray *matchingItems) {
        self.items = matchingItems;
        if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)])
            [self.delegate providerDataRefreshed];
    }];
}

- (void)fetchFromAPI
{
    // overridden in subclasses. When the fetch is complete and values are stored to the database,
    // another fetchFromCache should be performed to retrieve them and notify the delegate.
}

#pragma mark Receiving Updates from the Database

- (void)managerDidPersistModels:(NSArray*)savedModels
{
    NSMutableArray * filteredSavedModels = [savedModels filteredArrayUsingPredicate: self.predicate];
    
    // compute the models that were added   (saved - currently in our set)
    NSMutableArray * addedModels = [NSMutableArray arrayWithArray: filteredSavedModels];
    [addedModels removeObjectsInArray: self.items];

    // compute the models that were changed (saved - added)
    NSMutableArray * changedModels = [NSMutableArray arrayWithArray: filteredSavedModels];
    [changedModels removeObjectsInArray: addedModels];

    // compute the models that were changed and no longer match our predicate (saved - filtered)
    NSMutableArray * removedModels = [NSMutableArray arrayWithArray: savedModels];
    [savedModels removeObjectsInArray: filteredSavedModels];
    
    
        // resort our array and
        NSMutableArray * allItems = [self.items arrayByAddingObjectsFromArray: addedModels];
        [allItems sortUsingDescriptors: self.sortDescriptors];
        self.items = allItems;

        if ([self.delegate respondsToSelector: @selector(providerDataAltered:)]) {

        } else {
            if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)])
                [self.delegate providerDataRefreshed];
        }
        [filteredModels se
        
        
            NSMutableArray * changes = [NSMutableArray array];
            for (INModelObject * item in newItems) {
                NSInteger index = [allItems indexOfObjectIdenticalTo: item];
                [changes addObject: [INModelProviderChange changeOfType:INModelProviderChangeAdd forItem:item atIndex:index]];
            }
            [self.delegate providerDataAltered: changes];

        } else if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)])
            [self.delegate providerDataRefreshed];
        }
    }
}

- (void)managerDidRemoveModels:(NSArray*)models
{
    // potentially do smart things here.
    if ([[models firstObject] class] == _modelClass)
        [self performSelectorOnMainThreadOnce:@selector(refresh)];
}

@end
