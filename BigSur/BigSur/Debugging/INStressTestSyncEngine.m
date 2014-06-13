//
//  INTroubleshootingSyncEngine.m
//  BigSur
//
//  Created by Ben Gotow on 6/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INStressTestSyncEngine.h"

@implementation INStressTestSyncEngine

- (id)initWithConfiguration:(NSDictionary*)config
{
    self = [super init];
    if (self) {
		_timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(update) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			INNamespace * namespace = [[INNamespace alloc] init];
			[namespace updateWithResourceDictionary:@{@"email_address":@"bengotow@gmail.com", @"id":@"namespace_id"}];
			[[INDatabaseManager shared] persistModel: namespace];
			[[NSNotificationCenter defaultCenter] postNotificationName:INNamespacesChangedNotification object:nil];
		});
		
		_threads = [NSMutableArray array];
		for (int ii = 0; ii < 200; ii ++) {
			INThread * thread = [[INThread alloc] init];
			NSDictionary * d = @{@"id":[NSString stringWithFormat: @"%d", ii],
								 @"subject":@"Hello World",
								 @"namespace":@"namespace_id",
								 @"tags": @[ @{@"id":INTagIDInbox, @"name":@"inbox"},
											 @{@"id":INTagIDUnread, @"name":@"unread"}
											],
								 @"last_message_date": @([[NSDate date] timeIntervalSince1970]),
								 @"from": @[@{@"email": @"bengotow@gmail.com"}],
								 @"participants":@[@{@"email": @"ben@inboxapp.com", @"name": @"Ben Gotow"}]
								 };
			[thread updateWithResourceDictionary:d];
			[_threads addObject: thread];
		}
	}
	return self;
}

- (BOOL)providesCompleteCacheOf:(Class)klass
{
	return YES;
}

- (void)resetSyncState
{
	
}

- (void)update
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		for (INThread * thread in _threads) {
			NSString * r = [NSString stringWithFormat:@"%d",rand()];
			[thread setSubject: r];
		}
		[[INDatabaseManager shared] persistModels: _threads];
	});
}

@end
