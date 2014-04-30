//
//  INModelView.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelProvider.h"
#import "INModelObject.h"
#import "NSObject+AssociatedObjects.h"

@implementation INModelProviderChange : NSObject

+ (INModelProviderChange *)changeOfType:(INModelProviderChangeType)type forItem:(INModelObject *)item atIndex:(NSInteger)index
{
	INModelProviderChange * change = [[INModelProviderChange alloc] init];
	[change setType:type];
	[change setItem:item];
	[change setIndex:index];
	return change;
}

@end

@implementation INModelProvider

+ (id)providerForClass:(Class)modelClass
{
	INModelProvider * view = [[INModelProvider alloc] init];

	[view setModelClass:modelClass];
	return view;
}

- (id)init
{
	self = [super init];

	if (self)
		// subscribe to updates about the local database cache. This creates
		// a weak reference to us, so we don't have to worry about unregistering later.
		[[INDatabaseManager shared] registerCacheObserver:self];
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
	if (_cachePolicy == INModelProviderCacheThenNetwork)
		[self fetchFromAPI];
}

- (void)fetchFromCache
{
	// immediately refresh our data from what is now available in the cache
	[[INDatabaseManager shared] selectModelsOfClass:_modelClass matching:_predicate sortedBy:_sortDescriptors limit:1000 offset:0 withCallback:^(NSArray * matchingItems) {
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

- (void)managerDidPersistModels:(NSArray *)savedArray
{
	NSSet * savedModels = [NSSet setWithArray: savedArray];
	NSSet * savedMatchingModels = [savedModels filteredSetUsingPredicate: self.predicate];
	NSSet * existingModels = [NSSet setWithArray: self.items];
	
	// compute the models that were added   (saved & matching - currently in our set)
	NSMutableSet * addedModels = [savedMatchingModels mutableCopy];
	[addedModels minusSet: existingModels];

	// compute the models that were changed (saved & matching - added)
	NSMutableSet * changedModels = [savedMatchingModels mutableCopy];
	[changedModels minusSet: addedModels];

	// compute the models that were changed and no longer match our predicate (in existing and not in matching)
	NSMutableSet * removedModels = [savedModels mutableCopy];
	[removedModels minusSet: savedMatchingModels];
	[removedModels intersectSet: existingModels];

	// Add the addedModels to our cached set and then resort
	NSMutableArray * allItems = [self.items mutableCopy];

	// If our delegate wants to be notified of item-level changes, compute those. Please
	// note that this code was designed for readability over efficiency. If it's too slow
	// we'll come back to it :-)
	if ([self.delegate respondsToSelector:@selector(providerDataAltered:)]) {
		NSMutableArray * changes = [NSMutableArray array];
		
		for (INModelObject * item in removedModels) {
			NSInteger index = [allItems indexOfObjectIdenticalTo:item];
			[changes addObject:[INModelProviderChange changeOfType:INModelProviderChangeRemove forItem:item atIndex:index]];
		}

		[allItems removeObjectsInArray: [removedModels allObjects]];
		[allItems addObjectsFromArray: [addedModels allObjects]];
		[allItems sortUsingDescriptors:self.sortDescriptors];
		self.items = allItems;

		for (INModelObject * item in addedModels) {
			NSInteger index = [allItems indexOfObjectIdenticalTo:item];
			[changes addObject:[INModelProviderChange changeOfType:INModelProviderChangeAdd forItem:item atIndex:index]];
		}
		for (INModelObject * item in changedModels) {
			NSInteger index = [allItems indexOfObjectIdenticalTo:item];
			[changes addObject:[INModelProviderChange changeOfType:INModelProviderChangeUpdate forItem:item atIndex:index]];
		}
		
		[self.delegate providerDataAltered:changes];

	} else if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)]) {
		[allItems addObjectsFromArray: [addedModels allObjects]];
		[allItems removeObjectsInArray: [removedModels allObjects]];
		[allItems sortUsingDescriptors:self.sortDescriptors];
		self.items = allItems;
		[self.delegate providerDataRefreshed];
	}
}

- (void)managerDidUnpersistModels:(NSArray*)models
{
	NSMutableArray * newItems = [NSMutableArray arrayWithArray: self.items];
	[newItems removeObjectsInArray: models];
	
	if ([self.delegate respondsToSelector:@selector(providerDataAltered:)]) {
		NSMutableArray * changes = [NSMutableArray array];
		for (INModelObject * item in models) {
			NSInteger index = [self.items indexOfObjectIdenticalTo:item];
			[changes addObject:[INModelProviderChange changeOfType:INModelProviderChangeRemove forItem:item atIndex:index]];
		}

		self.items = newItems;
		[self.delegate providerDataAltered:changes];

	} else if ([self.delegate respondsToSelector:@selector(providerDataRefreshed)]) {
		self.items = newItems;
		[self.delegate providerDataRefreshed];
	}
}

@end
