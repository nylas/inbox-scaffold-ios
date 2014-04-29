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
#import "NSObject+Properties.h"

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
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
        _initializedModelClasses = [NSMutableDictionary dictionary];
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

- (void)registerCacheObserver:(NSObject<INDatabaseObserver>*)observer
{
    [_observers addObject: observer];
}

- (void)checkModelTable:(Class)klass
{
    NSAssert([klass isSubclassOfClass: [INModelObject class]], @"Only subclasses of INModelObject can be cached.");

    if (!_initializedModelClasses[NSStringFromClass(klass)]) {
        [_initializedModelClasses setObject:@(YES) forKey:NSStringFromClass(klass)];
        [self initializeModelTable:klass];
    }
}

- (void)initializeModelTable:(Class)klass
{
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray * cols = [@[@"id INTEGER PRIMARY KEY", @"data BLOB"] mutableCopy];
        NSMutableArray * colIndexQueries = [NSMutableArray array];
        NSString * tableName = [klass databaseTableName];
        
        for (NSString * propertyName in [klass databaseIndexProperties]) {
            NSString * colName = [klass resourceMapping][propertyName];
            NSString * colType = nil;
            NSString * type = [NSString stringWithCString: [klass typeOfPropertyNamed: propertyName] encoding:NSUTF8StringEncoding];
            
            if ([type isEqualToString: @"int"]) {
                colType = @"INTEGER";
                
            } else if ([type isEqualToString: @"float"]) {
                colType = @"REAL";
                    
            } else if ([type isEqualToString: @"T@\"NSString\""]) {
                colType = @"TEXT";
            }
            if (colType && colName) {
                [cols addObject: [NSString stringWithFormat: @"`%@` %@", colName, colType]];
                [colIndexQueries addObject: [NSString stringWithFormat: @"CREATE INDEX IF NOT EXISTS \"%@\" ON \"%@\" (\"%@\")", colName, tableName, colName]];
            }
        }
        
        NSString * colsString = [cols componentsJoinedByString: @","];
        NSString * query = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS `%@` (%@);", tableName, colsString];

        [db executeUpdate: query];
        for (NSString * indexQuery in colIndexQueries)
            [db executeUpdate: indexQuery];

        if ([db hadError])
            *rollback = YES;
    }];
}

#pragma mark Finding Objects

- (void)persistModel:(INModelObject*)model
{
    [self checkModelTable: [model class]];
    
    [_queue inDatabase:^(FMDatabase *db) {
        [self writeModel:model toDatabase:db];
        // notify providers that this model was updated. This may result in views being updated.
        [[_observers setRepresentation] makeObjectsPerformSelector:@selector(managerDidPersistModels:) withObject:@[model]];
    }];
}

- (void)persistModels:(NSArray*)models
{
    [self checkModelTable: [[models firstObject] class]];

    [_queue inDatabase:^(FMDatabase *db) {
        for (INModelObject * model in models)
            [self writeModel:model toDatabase:db];
        // notify providers that models were updated. This may result in views being updated.
        [[_observers setRepresentation] makeObjectsPerformSelector:@selector(managerDidPersistModels:) withObject:models];
    }];
}

- (void)writeModel:(INModelObject*)model toDatabase:(FMDatabase*)db
{
    NSAssert([model ID] != nil, @"Unsaved models should not be written to the cache.");

    NSString * tableName = [[model class] databaseTableName];
    NSMutableArray * columns = [@[@"id", @"data"] mutableCopy];
    NSMutableArray * columnPlaceholders = [@[@"?", @"?"] mutableCopy];
    NSMutableArray * values = [NSMutableArray array];
    
    NSError * jsonError = nil;
    NSData * json = [NSJSONSerialization dataWithJSONObject:[model resourceDictionary] options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (jsonError) {
        NSLog(@"Object serialization failed. Not saved to cache! %@", [jsonError localizedDescription]);
        return;
    }
    [values addObject: [model ID]];
    [values addObject: json];
    
    for (NSString * propertyName in [[model class] databaseIndexProperties]) {
        NSString * colName = [[model class] resourceMapping][propertyName];
        [columns addObject: colName];
        [columnPlaceholders addObject: @"?"];
        
        id value = [model valueForKey: propertyName];
        if (!value) value = [NSNull null];
        [values addObject: value];
    }

    NSString * columnsStr = [NSString stringWithFormat:@"`%@`", [columns componentsJoinedByString: @"`,`"]];
    NSString * columnPlaceholdersStr = [columnPlaceholders componentsJoinedByString:@","];
    
    NSString * query = [NSString stringWithFormat: @"REPLACE INTO %@ (%@) VALUES (%@)", tableName, columnsStr, columnPlaceholdersStr];
    [db executeUpdate:query withArgumentsInArray:values];
}

- (void)selectModelsOfClass:(Class)klass withQuery:(NSString*)query andParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback
{
    [self checkModelTable: klass];

    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:query withParameterDictionary:arguments];

        NSMutableArray * objects = [@[] mutableCopy];
        INModelObject * obj = nil;
        while ((obj = [result nextModelOfClass: klass]))
            [objects addObject: obj];
        [result close];
        
        NSLog(@"%@ RETRIEVED %d %@s", query, [objects count], NSStringFromClass(klass));

        if (callback)
            callback(objects);
    }];
}

@end
