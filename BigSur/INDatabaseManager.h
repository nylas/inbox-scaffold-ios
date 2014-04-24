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


@interface INDatabaseManager : NSObject
{
    FMDatabaseQueue * _queue;
}

+ (INDatabaseManager *)shared;

- (void)prepare;

- (void)persistModel:(INModelObject*)model;
- (void)persistModels:(NSArray*)models;

- (void)selectModelsOfClass:(Class)klass withQuery:(NSString*)query andParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback;

@end
