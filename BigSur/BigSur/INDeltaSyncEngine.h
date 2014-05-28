//
//  INDeltaSyncEngine.h
//  BigSur
//
//  Created by Ben Gotow on 5/27/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INDeltaSyncEngine : NSObject <INSyncEngine>

@property (nonatomic, strong) NSMutableArray * syncOperations;
@property (nonatomic, strong) NSDate * syncDate;
@property (nonatomic, strong) NSTimer * syncTimer;

@property (nonatomic, strong) UILocalNotification * unreadNotification;

- (id)initWithConfiguration:(NSDictionary*)config;
- (void)syncWithCallback:(ErrorBlock)callback;

@end
