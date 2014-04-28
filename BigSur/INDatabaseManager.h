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

static NSString * INModelsPersistedNotification = @"INModelsPersistedNotification";

@protocol INDatabaseObserver <NSObject>

- (void)managerDidPersistModels:(NSArray*)models;
- (void)managerDidPerformTransaction;

@end

@interface INDatabaseManager : NSObject
{
    FMDatabaseQueue * _queue;
    NSHashTable * _observers;
}

+ (INDatabaseManager *)shared;

- (void)prepare;

- (void)registerCacheObserver:(NSObject<INDatabaseObserver>*)observer;

- (void)persistModel:(INModelObject*)model;
- (void)persistModels:(NSArray*)models;

- (void)selectModelsOfClass:(Class)klass withQuery:(NSString*)query andParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback;

@end
