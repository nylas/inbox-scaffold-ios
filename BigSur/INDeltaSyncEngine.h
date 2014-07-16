//
//  INDeltaSyncEngine.h
//  BigSur
//
//  Created by Ben Gotow on 5/27/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * INSyncFinishedNotification = @"INSyncFinishedNotification";

@interface INDeltaSyncEngine : NSObject <INSyncEngine>

@property (nonatomic, strong) NSMutableArray * syncOperations;
@property (nonatomic, strong) NSDate * syncDate;
@property (nonatomic, strong) NSTimer * syncTimer;

@property (nonatomic, strong) UILocalNotification * unreadNotification;

/* Creates a new instance of the sync engine with the desired configuration.

 @param configuration Currenty unused.
 @return A configured sync engine instance
*/
- (id)initWithConfiguration:(NSDictionary*)config;

/* Start a sync, and call the callback when sync has completely 
 finished or failed with an error.
 
 @param callback A block to invoke when the sync has finished or has failed.
 If a sync is already in progress or there is no current namespace,
the callback is called immediately with success=NO, error=nil.
*/
- (void)syncWithCallback:(ErrorBlock)callback;

/* Clear all sync state, usually called during the logout process. */
- (void)resetSyncState;

@end
