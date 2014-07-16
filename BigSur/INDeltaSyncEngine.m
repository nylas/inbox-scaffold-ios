//
//  INDeltaSyncEngine.m
//  BigSur
//
//  Created by Ben Gotow on 5/27/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INDeltaSyncEngine.h"
#import "INConvenienceCategories.h"
#import "INAppDelegate.h"

#define REQUEST_PAGE_SIZE 50
#define SYNC_STAMPS_KEY @"sync-stamps"

@implementation INDeltaSyncEngine

- (id)initWithConfiguration:(NSDictionary*)config
{
    self = [super init];
    if (self) {
        _syncOperations = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sync) name:INAuthenticationChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sync) name:BigSurNamespaceChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPeriodicSync) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPeriodicSync) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUnreadState) name:UIApplicationWillResignActiveNotification object:nil];

        // trim local cache. We need to do this on boot so that we don't inadvertently
        // delete data the user is looking at!
        [[INDatabaseManager shared] selectModelsOfClass:[INNamespace class] matching:nil sortedBy:nil limit:1000 offset:0 withCallback:^(NSArray *objects) {
            for (INNamespace * namespace in objects)
                [self trimLocalCacheForNamespace: namespace];
        }];
        
        [self startPeriodicSync];
    }
    return self;
}

- (void)startPeriodicSync
{
    [_syncTimer invalidate];
    _syncTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(sync) userInfo:nil repeats:YES];
    [self sync];
}

- (void)stopPeriodicSync
{
    [_syncTimer invalidate];
    _syncTimer = nil;
}

- (void)refreshUnreadState
{
    [self refreshUnreadStateWithCallback: NULL];
}

- (void)refreshUnreadStateWithCallback:(VoidBlock)callback
{
    BOOL notify = ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive);
    
    // update our unread thread count
    NSPredicate * unread = [NSComparisonPredicate predicateWithFormat:@"ANY tagIDs = %@", INTagIDUnread];
    NSPredicate * inbox = [NSComparisonPredicate predicateWithFormat:@"ANY tagIDs = %@", INTagIDInbox];
    NSPredicate * unreadAndInbox = [NSCompoundPredicate andPredicateWithSubpredicates: @[inbox, unread]];
    
    [[INDatabaseManager shared] countModelsOfClass:[INThread class] matching:unreadAndInbox withCallback:^(long count) {
        if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == count) {
            if (callback)
                callback();
            return;
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: count];
        if (_unreadNotification)
            [[UIApplication sharedApplication] cancelLocalNotification: _unreadNotification];

        if (!notify) {
            if (callback)
                callback();
            return;
        }
        
        if (count > 1) {
            // You have 12 unread messages.
            _unreadNotification = [UILocalNotification new];
            [_unreadNotification setSoundName: @"notif-unread-sound.aiff"];
            [_unreadNotification setAlertAction: @"View"];
            [_unreadNotification setAlertBody: [NSString stringWithFormat: @"You have %d unread messages.", (int)count]];
            [[UIApplication sharedApplication] presentLocalNotificationNow: _unreadNotification];
            if (callback)
                callback();

        } else {
            // "New Email Subject"
            [[INDatabaseManager shared] selectModelsOfClass:[INThread class] matching:unreadAndInbox sortedBy:nil limit:1 offset:0 withCallback:^(NSArray *objects) {
                INThread * thread = [objects firstObject];
                _unreadNotification = [UILocalNotification new];
                [_unreadNotification setSoundName: @"notif-unread-sound.aiff"];
                [_unreadNotification setAlertAction: @"View"];
                [_unreadNotification setUserInfo: @{@"thread_id": [thread ID], @"namespace_id": [thread namespaceID]}];
                [_unreadNotification setAlertBody: [NSString stringWithFormat: @"%@", [thread subject]]];
                [[UIApplication sharedApplication] presentLocalNotificationNow: _unreadNotification];
                if (callback)
                    callback();
            }];
        }
    }];
}

- (BOOL)providesCompleteCacheOf:(Class)klass
{
    if (klass == [INMessage class])
        return NO;
    return YES;
}

- (void)sync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[INAPIManager shared] isAuthenticated])
            [self syncWithCallback: NULL];
    });
}

- (void)syncWithCallback:(ErrorBlock)callback
{
    [self syncNamespace: [[INAppDelegate current] currentNamespace] withCallback: callback];
}

- (void)syncNamespace:(INNamespace*)namespace withCallback:(ErrorBlock)callback
{
    NSMutableArray * types = [@[@"contact", @"tag", @"thread"] mutableCopy];

    // Don't sync if no namespace is provided
    // Don't sync if a sync is already in progress
    // Don't sync if the network is not reachable
    if ((!namespace) || ([_syncOperations count] > 0) || (![[[[INAPIManager shared] AF] reachabilityManager] isReachable])) {
        if (callback)
            callback(NO, nil);
        return;
    }
    
    NSLog(@"Syncing...");
    
    ErrorBlock subCompletionBlock = ^(BOOL success, NSError * error) {
        if (success == NO) {
            for (AFHTTPRequestOperation * op in _syncOperations)
                [op cancel];
            [_syncOperations removeAllObjects];
        }
        if ([_syncOperations count] == 0) {
            _syncDate = [NSDate date];
            [self refreshUnreadStateWithCallback:^{
				[[NSNotificationCenter defaultCenter] postNotificationName:INSyncFinishedNotification object:nil];
				NSLog(@"Sync has finished.");
                if (callback)
                    callback(success, error);
            }];
        }
    };
    
    // if this is our first sync for this namespace, do a full sync of
    // contacts and tags and omit them from the event based sync
    if ([self hasSyncedNamespace: namespace] == NO) {
        [self syncClass:[INTag class] withCallback: subCompletionBlock];
        [self syncClass:[INContact class] withCallback: subCompletionBlock];
        [types removeObject: @"contact"];
        [types removeObject: @"tags"];
    }

    // do an event-based sync that will fetch delta-updates
    [self syncEventsOfTypes:types inNamespace:namespace withCallback:subCompletionBlock];
}

- (void)syncClass:(Class)klass withCallback:(ErrorBlock)callback
{
    [self syncClass:klass page:0 withCallback:callback];
}

- (void)syncClass:(Class)klass page:(int)page withCallback:(ErrorBlock)callback
{
    INNamespace * namespace = [[INAppDelegate current] currentNamespace];
    if (!namespace) {
        if (callback)
            callback(NO, nil);
        return;
    }

    NSString * path = [NSString stringWithFormat:@"/n/%@/%@", [namespace ID], [klass resourceAPIName]];
    AFHTTPRequestOperation * op = [[INAPIManager shared].AF GET:path parameters:@{@"offset":@(page * REQUEST_PAGE_SIZE), @"limit":@(REQUEST_PAGE_SIZE)} success:^(AFHTTPRequestOperation *operation, id models) {
        [_syncOperations removeObject: operation];
        if ([models count] >= REQUEST_PAGE_SIZE) {
            [self syncClass: klass page: page + 1 withCallback: callback];
        } else {
            if (callback)
                callback(YES, nil);
        }
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Syncing %@ failed with %@", NSStringFromClass(klass), [error localizedDescription]);
        [_syncOperations removeObject: operation];
        if (callback)
            callback(NO, error);
	}];
    
    AFHTTPResponseSerializer * serializer = [[INAPIManager shared] responseSerializerForClass: klass];
    [op setResponseSerializer:serializer];
    [_syncOperations addObject: op];
}

- (void)syncEventsOfTypes:(NSArray*)types inNamespace:(INNamespace*)namespace withCallback:(ErrorBlock)callback
{
    [self obtainSyncStampForNamespace:namespace withCallback:^(id stamp, NSError * error) {
        if (!stamp || error)
            return callback(NO, error);
        
        NSString * path = [NSString stringWithFormat:@"/n/%@/sync/events", [namespace ID]];
        NSDictionary * params = @{@"stamp": stamp, @"type": [types componentsJoinedByString:@","]};
        NSDate * start = [NSDate date];
		
        AFHTTPRequestOperation * op = [[INAPIManager shared].AF GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
            // Check that the response is valid
            if (![response isKindOfClass: [NSDictionary class]]) {
                NSError * error = [NSError inboxErrorWithFormat: @"The /sync/events API returned an object that was not a dictionary: %@", response];
                return callback(NO, error);
            }
            
            NSArray * events = response[@"events"];
            NSMutableArray * modelsToSave = [NSMutableArray array];
            NSMutableArray * modelsToDelete = [NSMutableArray array];
            
            for (NSDictionary * event in events) {
                // convert the provided type into a model class
                Class eventClass = NSClassFromString([NSString stringWithFormat:@"IN%@", [event[@"object_type"] capitalizedString]]);
                NSString * eventType = event[@"event"];
                
                if ((!eventClass) || (![eventClass isSubclassOfClass: [INModelObject class]])) {
                    NSLog(@"Event skipped. No INModelObject subclass for %@", event[@"object_type"]);
                    continue;
                }
                
                if ([eventType isEqualToString: @"create"] || [eventType isEqualToString: @"modify"]) {
                    // find or create the object in our local cache and update it
                    INModelObject * model = [eventClass instanceWithID: event[@"id"] inNamespaceID: [namespace ID]];
                    [model updateWithResourceDictionary: event[@"attributes"]];
                    [modelsToSave addObject: model];
                    
                } else if ([eventType isEqualToString: @"delete"]) {
                    // find the model and add it to our list of models to delete
                    INModelObject * model = [eventClass instanceWithID: event[@"id"] inNamespaceID: [namespace ID]];
                    [modelsToDelete addObject: model];
                }
            }
			
            // Save / delete all of the models at the same time
            [[INDatabaseManager shared] unpersistModels: modelsToDelete];
            [[INDatabaseManager shared] persistModels: modelsToSave];
            [_syncOperations removeObject: operation];
            
			NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate: start];
			NSUInteger size = [[operation responseData] length] / 1024;
            NSLog(@"Delta sync received %d events ending with %@. (%f sec, %dk)", [events count], response[@"events_end"], seconds, size);
			
			// Update our local sync stamp
			if (response[@"events_end"] && (![response[@"events_end"] isEqualToString: response[@"events_start"]])) {
				[self obtainedSyncStamp:response[@"events_end"] forNamespace: namespace];
				[self syncEventsOfTypes: types inNamespace: namespace withCallback: callback];

            } else {
                callback(YES, nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_syncOperations removeObject: operation];
            error = [NSError inboxErrorWithDescription: @"Could not fetch sync events." underlyingError: error];
            NSLog(@"Syncing events failed with error %@", error);
            callback(NO, error);
        }];
        
        [_syncOperations addObject: op];
    }];
}

- (void)trimLocalCacheForNamespace:(INNamespace*)namespace
{
    NSPredicate * timestampPredicate = nil;
    
    NSTimeInterval maxMessageAge = [[NSDate dateWithTimeIntervalSinceNow: -60 * 60 * 24] timeIntervalSince1970];
    NSTimeInterval maxThreadAge = [[NSDate dateWithTimeIntervalSinceNow: -4 * 31 * (60 * 60 * 24)] timeIntervalSince1970];
    
    // Q: "Do we really have to inflate the objects just to delete them??"
    // A: Yes - it's easier this way, because some objects have more complicated deletion routines
    // (threads delete their tags from the tags table, etc.) and the objects may want to run code in
    // willUnpersist:. The one drawback of this approach is that if someone were viewing one of these
    // messages or threads onscreen, they would see it get blown away. We may want to address that someday.
    
    // Eliminate threads older than 4 months
    timestampPredicate = [NSComparisonPredicate predicateWithFormat:@"lastMessageDate < %d", (int)maxThreadAge];
    [[INDatabaseManager shared] selectModelsOfClass:[INThread class] matching:timestampPredicate sortedBy:nil limit:0 offset:0 withCallback:^(NSArray * threads) {
        [[INDatabaseManager shared] unpersistModels: threads];
    }];
    
    // Eliminate messages older than 2 months
    timestampPredicate = [NSComparisonPredicate predicateWithFormat:@"date < %d", (int)maxMessageAge];
    [[INDatabaseManager shared] selectModelsOfClass:[INMessage class] matching:timestampPredicate sortedBy:nil limit:0 offset:0 withCallback:^(NSArray * messages) {
        [[INDatabaseManager shared] unpersistModels: messages];
    }];
}

- (void)resetSyncState
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: SYNC_STAMPS_KEY];
}

- (BOOL)hasSyncedNamespace:(INNamespace*)namespace
{
    return ([[[NSUserDefaults standardUserDefaults] objectForKey: SYNC_STAMPS_KEY] objectForKey: [namespace ID]] != nil);
}

- (void)obtainSyncStampForNamespace:(INNamespace*)namespace withCallback:(ResultBlock)callback
{
    // Check to see if there's a stamp in our user defaults for this namespace
    NSString * cacheStamp = [[[NSUserDefaults standardUserDefaults] objectForKey: SYNC_STAMPS_KEY] objectForKey: [namespace ID]];
    if (cacheStamp)
        return callback(cacheStamp, nil);
    
    // Fetch a new stamp, assuming we want the entire transaction log for the last four months
    NSString * stampPath = [NSString stringWithFormat: @"/n/%@/sync/generate_stamp", [namespace ID]];
    NSTimeInterval timestamp = [[NSDate dateWithTimeIntervalSinceNow: -4 * 31 * (60 * 60 * 24)] timeIntervalSince1970];

    [[INAPIManager shared].AF POST:stampPath parameters:@{@"start":@((int)timestamp)} success:^(AFHTTPRequestOperation *operation, id response) {
        NSString * stamp = [response objectForKey: @"stamp"];
        [self obtainedSyncStamp: stamp forNamespace: namespace];
        callback(stamp, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        error = [NSError inboxErrorWithDescription: @"Could not generate sync stamp." underlyingError: error];
        callback(nil, error);
    }];
}

- (void)obtainedSyncStamp:(NSString *)stamp forNamespace:(INNamespace*)namespace
{
    NSMutableDictionary * keys = [NSMutableDictionary dictionaryWithDictionary: [[NSUserDefaults standardUserDefaults] objectForKey:SYNC_STAMPS_KEY]];
    [keys setObject: stamp forKey:[namespace ID]];
    [[NSUserDefaults standardUserDefaults] setObject: keys forKey: SYNC_STAMPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
