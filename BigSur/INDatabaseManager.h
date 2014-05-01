//
//  INDatabaseManager.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMResultSet.h>
#import "INModelObject.h"

@protocol INDatabaseObserver <NSObject>
@required
- (void)managerDidPersistModels:(NSArray *)models;
- (void)managerDidUnpersistModels:(NSArray*)models;
- (void)managerDidReset;
@end

@interface INDatabaseManager : NSObject
{
	NSMutableDictionary * _initializedModelClasses;
	NSHashTable * _observers;

	FMDatabaseQueue * _queue;
	dispatch_queue_t _queryDispatchQueue;
}

+ (INDatabaseManager *)shared;

/**
 Clear the entire local cache by destroying the database file.
*/
- (void)resetDatabase;

/**
 Register for updates when objects are added and removed from the database cache.
 The INDatabaseManager uses weak references, so it's not necessary to unregister
 as an observer.
 
 @param observer The object that would like to observe the database for changes.
*/
- (void)registerCacheObserver:(NSObject <INDatabaseObserver> *)observer;

/**
 Save or update a single INModelObject in the local database.
 This method notifies observers that the model has been stored.

 @param model The model to be saved to the database.
*/
- (void)persistModel:(INModelObject *)model;

/**
 Save or update a set of INModelObjects in a single database transaction. This is the
 preferred way of persisting multiple models, and you should try to use this method 
 whenever possible.

 This method notifies observers that the models have been stored.
 
 @param models An array of INModelObjects of the same class.
*/
- (void)persistModels:(NSArray *)models;

/**
 Remove an object from the local database cache and notify observers of the change.
 
 @param model The object to remove.
*/
- (void)unpersistModel:(INModelObject *)model;

- (INModelObject*)selectModelOfClass:(Class)klass withID:(NSString*)ID;

/**
 Find models matching the provided predicate and return them, sorted by the sort descriptors.
 
 Note that predicates and sort descriptors should reference class properties, not the underlying
 database columns. ("namespaceID", not "namespace_id"). The predicates and sort descriptors you
 create can only reference properties returned from [class databaseIndexProperties], which have 
 been indexed and have their own table columns under the hood.
 
 @param klass The type of models. Must be a subclass of INModelObject.
 @param wherePredicate A comparison or compound NSPredicate.
 @param sortDescriptors One or more sort descriptors.
 @param limit The maximum number of objects to return.
 @param offset The initial offset into the results. Useful when paging.
 @param callback A block that accepts an array of INModelObjects. At this time, the callback is called synchronously.
*/
- (void)selectModelsOfClass:(Class)klass matching:(NSPredicate *)wherePredicate sortedBy:(NSArray *)sortDescriptors limit:(int)limit offset:(int)offset withCallback:(ResultsBlock)callback;

/**
Find models using the provided query and query parameters (substitutions for ? in the query).
This is a more direct version of -selectModelsOfClass:matching:sortedBy:limit:offset:withCallback;
*/
- (void)selectModelsOfClass:(Class)klass withQuery:(NSString *)query andParameters:(NSDictionary *)arguments andCallback:(ResultsBlock)callback;

@end
