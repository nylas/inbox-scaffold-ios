//
//  INAPIManager.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^ResultsBlock)(NSArray * objects);
typedef void (^ErrorBlock)(NSError * error);

@class INAPIOperation;

@interface INAPIManager : AFHTTPRequestOperationManager

+ (INAPIManager *)shared;

- (void)queueAPIOperation:(INAPIOperation*)operation;


@end
