//
//  INStupidFullSyncEngine.m
//  BigSur
//
//  Created by Ben Gotow on 5/16/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INStupidFullSyncEngine.h"
#import "INAppDelegate.h"

#define REQUEST_PAGE_SIZE 50

@implementation INStupidFullSyncEngine

- (id)initWithConfiguration:(NSDictionary*)config
{
    self = [super init];
    if (self) {
        self.syncOperations = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndSync) name:INAuthenticationChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndSync) name:BigSurNamespaceChanged object:nil];
        [self checkAndSync];
    }
    return self;
}

- (BOOL)providesCompleteCacheOf:(Class)klass
{
    if (klass == [INMessage class])
        return NO;
    return YES;
}

- (void)checkAndSync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[INAPIManager shared] isAuthenticated]) {
            [self sync];
        
		} else {
            [_syncOperations makeObjectsPerformSelector: @selector(cancel)];
            [_syncOperations removeAllObjects];
        }
    });
}

- (void)sync
{
	if (_syncInProgress > 0)
		return;
	
    [self syncClass:[INTag class] callback: NULL];
    [self syncClass:[INContact class] callback: NULL];
    [self syncClass:[INThread class] callback: NULL];
    [self syncClass:[INDraft class] callback: NULL];
    
    [[INAPIManager shared] retryTasks];
}

- (void)syncWithCallback:(ErrorBlock)callback
{
    [self syncClass:[INThread class] callback:callback];
}

- (void)syncClass:(Class)klass callback:(ErrorBlock)callback
{
    [self syncClass:klass page: 0 callback:callback];
}

- (void)syncClass:(Class)klass page:(int)page callback:(ErrorBlock)callback
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    if (!namespace) return;
    
    NSString * path = [NSString stringWithFormat:@"/n/%@/%@", [namespace ID], [klass resourceAPIName]];
    NSLog(@"SYNC: %@ - %d", path, page);
    
	_syncInProgress += 1;
    AFHTTPRequestOperation * op = [[INAPIManager shared] GET:path parameters:@{@"offset":@(page * REQUEST_PAGE_SIZE), @"limit":@(REQUEST_PAGE_SIZE)} success:^(AFHTTPRequestOperation *operation, id models) {
        if ([models count] >= REQUEST_PAGE_SIZE) {
            [self syncClass: klass page: page + 1 callback: callback];
        } else {
            if (callback)
                callback(YES, nil);
        }
        [_syncOperations removeObject: operation];
		_syncInProgress -= 1;
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // sync interrupted
        if (callback)
            callback(NO, error);
        [_syncOperations removeObject: operation];
		_syncInProgress -= 1;
	}];
    
    INModelResponseSerializer * serializer = [[INModelResponseSerializer alloc] initWithModelClass: klass];
    [op setResponseSerializer:serializer];
    [_syncOperations addObject: op];
}

@end
