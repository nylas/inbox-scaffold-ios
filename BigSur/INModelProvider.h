//
//  INModelView.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDatabaseManager.h"

@class INNamespace;

typedef enum : NSUInteger {
	INModelProviderCacheOnly,
	INModelProviderCacheThenNetwork
} INModelProviderCachePolicy;

typedef enum : NSUInteger {
	INModelProviderChangeAdd,
	INModelProviderChangeRemove,
	INModelProviderChangeUpdate
} INModelProviderChangeType;


@interface INModelProviderChange : NSObject
@property (nonatomic, assign) INModelProviderChangeType type;
@property (nonatomic, strong) INModelObject * item;
@property (nonatomic, assign) NSInteger index;

+ (INModelProviderChange *)changeOfType:(INModelProviderChangeType)type forItem:(INModelObject *)item atIndex:(NSInteger)index;
@end


@interface INModelProviderChangeSet : NSObject
@property (nonatomic, strong) NSArray * changes;
- (NSArray*)indexPathsFor:(INModelProviderChangeType)changeType;
@end



@protocol INModelProviderDelegate <NSObject>
@optional
- (void)providerDataChanged;
- (void)providerDataAltered:(INModelProviderChangeSet *)changeSet;
- (void)providerDataFetchFailed:(NSError *)error;
- (void)providerDataFetchCompleted;
@end

@interface INModelProvider : NSObject <INDatabaseObserver>
{
	NSPredicate * _underlyingPredicate;
	AFHTTPRequestOperation * _fetchOperation;
	BOOL _refetchRequested;
}

@property (nonatomic, strong) NSString * namespaceID;
@property (nonatomic, strong) Class modelClass;

@property (nonatomic, strong) NSArray * items;
@property (nonatomic, strong) NSPredicate * itemFilterPredicate;
@property (nonatomic, strong) NSArray * itemSortDescriptors;
@property (nonatomic, assign) NSRange itemRange;
@property (nonatomic, assign) INModelProviderCachePolicy itemCachePolicy;

@property (nonatomic, weak) NSObject <INModelProviderDelegate> * delegate;

- (id)initWithClass:(Class)modelClass andNamespaceID:(NSString*)namespaceID andUnderlyingPredicate:(NSPredicate*)predicate;

- (void)refresh;

- (void)fetchFromCache;
- (void)fetchFromAPI;

@end
