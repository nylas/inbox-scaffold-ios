//
//  INModelObject+DatabaseCache.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject+DatabaseCache.h"
#import "INDatabaseManager.h"
#import "INPredicateConverter.h"

@implementation INModelObject (DatabaseCache)

#pragma Database Representation

+ (NSString*)databaseTableName
{
    return NSStringFromClass(self);
}

+ (NSArray*)databaseIndexProperties
{
    return nil;
}
+ (NSString*)databaseTableCreateStatement
{
    NSArray * cols = [@[@"id INTEGER PRIMARY KEY", @"data BLOB"] mutableCopy];
    
    for (NSString * propertyName in databaseIndexProperties) {
        
    }


    NSString * colsString = [cols componentsJoinedByString: @","];
    NSString * query = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ (%@);", [self databaseTableName], colsString];
    
    CREATE INDEX IF NOT EXISTS \"%@\" ON \"%@\" (\"%@\");
    NSMutableString *createTable = [NSMutableString stringWithCapacity:100];
	[createTable appendFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" (\"rowid\" INTEGER PRIMARY KEY", tableName];
	
	for (YapDatabaseSecondaryIndexColumn *column in setup)
	{
		if (column.type == YapDatabaseSecondaryIndexTypeInteger)
		{
			[createTable appendFormat:@", \"%@\" INTEGER", column.name];
		}
		else if (column.type == YapDatabaseSecondaryIndexTypeReal)
		{
			[createTable appendFormat:@", \"%@\" REAL", column.name];
		}
		else if (column.type == YapDatabaseSecondaryIndexTypeText)
		{
			[createTable appendFormat:@", \"%@\" TEXT", column.name];
		}
	}
	
	[createTable appendString:@");"];
	
	int status = sqlite3_exec(db, [createTable UTF8String], NULL, NULL, NULL);
	if (status != SQLITE_OK)
	{
		YDBLogError(@"%@ - Failed creating secondary index table (%@): %d %s",
		            THIS_METHOD, tableName, status, sqlite3_errmsg(db));
		return NO;
	}
	
	for (YapDatabaseSecondaryIndexColumn *column in setup)
	{
		NSString *createIndex =
        [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS \"%@\" ON \"%@\" (\"%@\");",
         column.name, tableName, column.name];
		
		status = sqlite3_exec(db, [createIndex UTF8String], NULL, NULL, NULL);
		if (status != SQLITE_OK)
		{
			YDBLogError(@"Failed creating index on '%@': %d %s", column.name, status, sqlite3_errmsg(db));
			return NO;
		}
	}
	
}

+ (NSString*)databaseReplaceStatement
{
    NSArray * cols = [[self resourceMapping] allValues];
    NSString * colsStr = [NSString stringWithFormat:@"`%@`", [cols componentsJoinedByString: @"`,`"]];
    NSMutableArray * vals = [NSMutableArray array];
    for (NSString * col in cols)
        [vals addObject: [NSString stringWithFormat:@":%@", col]];
    NSString * valsStr = [vals componentsJoinedByString:@","];
    
    return [NSString stringWithFormat: @"REPLACE INTO %@ (%@) VALUES (%@)", [self databaseTableName], colsStr, valsStr];
}

#pragma Database Retrieval

+ (void)persistedInstancesMatching:(NSPredicate*)wherePredicate sortedBy:(NSArray*)sortDescriptors limit:(int)limit offset:(int)offset withCallback:(ResultsBlock)callback
{
    NSMutableString * query = [[NSMutableString alloc] initWithFormat: @"SELECT * FROM %@", [self databaseTableName]];
    INPredicateConverter * converter = [[INPredicateConverter alloc] init];
    [converter setTargetModelClass: self];
    
    if (wherePredicate) {
        NSString * whereClause = [converter SQLFilterForPredicate: wherePredicate];
        [query appendFormat: @" WHERE %@", whereClause];
    }
    
    if ([sortDescriptors count] > 0) {
        NSMutableArray * sortClauses = [NSMutableArray array];
        for (NSSortDescriptor * descriptor in sortDescriptors) {
            NSString * sql = [converter SQLSortForSortDescriptor: descriptor];
            if (sql) [sortClauses addObject: sql];
        }
        [query appendFormat:@" ORDER BY %@", [sortClauses componentsJoinedByString:@", "]];
    }
    
    [self persistedInstancesForQuery:query withParameters:nil andCallback:callback];
}

+ (void)persistedInstancesForQuery:(NSString*)query withParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback
{
    [[INDatabaseManager shared] selectModelsOfClass:self withQuery:query andParameters:arguments andCallback:callback];
}

- (void)persist
{
    [[INDatabaseManager shared] persistModel: self];
}

@end
