//
//  INDatabaseManager.m
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INDatabaseManager.h"
#import "INPredicateConverter.h"
#import "FMResultSet+INModelQueries.h"

#define SCHEMA_VERSION 2

@implementation INDatabaseManager

+ (INDatabaseManager *)shared
{
    static INDatabaseManager * sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[INDatabaseManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString * databasePath = [@"~/Documents/cache.db" stringByExpandingTildeInPath];
        NSLog(@"%@", databasePath);
        
        _queue = [FMDatabaseQueue databaseQueueWithPath: databasePath];
    }
    return self;
}

- (int)databaseSchemaVersion
{
    int __block version = -1;
    
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet * set = [db executeQuery: @"PRAGMA user_version"];
        [set next];
        version = [[[set resultDictionary] objectForKey: @"user_version"] intValue];
        [set close];
    }];
    
    return version;
}

- (void)prepare
{
    if ([self databaseSchemaVersion] == 0) {
        // this is a fresh installation. Run the initialization script
        [self executeSQLFileWithName: @"initialization"];
    }

    // apply any migrations necessary to bring the local cache up to date
    for (int version = [self databaseSchemaVersion]; version < SCHEMA_VERSION; version ++) {
        NSString * migrationName = [NSString stringWithFormat:@"from-%d-to-%d", version, version + 1];
        BOOL success = [self executeSQLFileWithName: migrationName];
        if (!success) {
            NSLog(@"Migration %@ failed. The local datastore is stuck at version %d. In the future, we should wipe the local datastore here.", migrationName, version);
            return;
        }
    }
}

- (BOOL)executeSQLFileWithName:(NSString*)sqlFileName
{
    BOOL __block succeeded = NO;
    
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError * error = nil;
        NSString * batchSQLPath = [[NSBundle mainBundle] pathForResource:sqlFileName ofType:@"sql"];
        NSString * batchSQL = [NSString stringWithContentsOfFile: batchSQLPath encoding:NSUTF8StringEncoding error: &error];
        
        if (error || ![batchSQL length]) {
            NSLog(@"Batch SQL run failed because sql could not be found for %@. %@", sqlFileName, [error localizedDescription]);
            *rollback = YES;
        }
        
        NSArray * statements = [batchSQL componentsSeparatedByString:@"\n\n"];
        for (NSString * statement in statements) {
            BOOL success = [db executeUpdate: statement];
            if (!success)
                break;
        }
        
        if ([db hadError]) {
            NSLog(@"Batch SQL failed with error: %@", [db lastErrorMessage]);
            *rollback = YES;
        } else {
            NSLog(@"Batch SQL %@ complete. Executed %d statements.", sqlFileName, [statements count]);
            *rollback = NO;
            succeeded = YES;
        }
    }];
    
    return succeeded;
}

#pragma mark Finding Objects

- (void)persistModel:(INModelObject*)model
{
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[[model class] databaseReplaceStatement] withParameterDictionary: [model resourceDictionary]];
        [INModelObject attachInstance: model];
    }];
}

- (void)persistModels:(NSArray*)models
{
    [_queue inDatabase:^(FMDatabase *db) {
        for (INModelObject * model in models) {
            [db executeUpdate:[[model class] databaseReplaceStatement] withParameterDictionary: [model resourceDictionary]];
            [INModelObject attachInstance: model];
        }
    }];
}

- (void)selectModelsOfClass:(Class)klass withQuery:(NSString*)query andParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback
{
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:query withParameterDictionary:arguments];

        NSMutableArray * objects = [@[] mutableCopy];
        INModelObject * obj = nil;
        while ((obj = [result nextModelOfClass: klass]))
            [objects addObject: obj];
        
        [result close];
        
        NSLog(@"%@ RETURNED %d %@s", query, [objects count], NSStringFromClass(klass));

        if (callback)
            callback(objects);
    }];
}

@end
