//
//  INStupidFullSyncEngine.h
//  BigSur
//
//  Created by Ben Gotow on 5/16/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INStupidFullSyncEngine : NSObject <INSyncEngine>

@property (nonatomic, assign) int syncInProgress;
@property (nonatomic, strong) NSMutableArray * syncOperations;

- (id)initWithConfiguration:(NSDictionary*)config;
- (BOOL)providesCompleteCacheOf:(Class)klass;

- (void)sync;
- (void)syncWithCallback:(ErrorBlock)callback;
- (void)syncClass:(Class)klass callback:(ErrorBlock)callback;

@end
