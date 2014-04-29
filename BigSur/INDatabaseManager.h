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
#import "INModelObject+DatabaseCache.h"

@protocol INDatabaseObserver <NSObject>

- (void)managerDidPersistModels:(NSArray *)models;
- (void)managerDidRemoveModels:(NSArray *)models;

@end

@interface INDatabaseManager : NSObject
{
	NSMutableDictionary * _initializedModelClasses;

	FMDatabaseQueue * _queue;
	NSHashTable * _observers;
}

+ (INDatabaseManager *)shared;

- (void)registerCacheObserver:(NSObject <INDatabaseObserver> *)observer;

- (void)persistModel:(INModelObject *)model;
- (void)persistModels:(NSArray *)models;

- (void)selectModelsOfClass:(Class)klass withQuery:(NSString *)query andParameters:(NSDictionary *)arguments andCallback:(ResultsBlock)callback;

@end
