//
//  INTroubleshootingSyncEngine.h
//  BigSur
//
//  Created by Ben Gotow on 6/13/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INStressTestSyncEngine : NSObject <INSyncEngine>

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSMutableArray * threads;

- (id)initWithConfiguration:(NSDictionary*)config;

@end
