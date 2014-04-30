//
//  INAPIManager.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class INAPIOperation;
@class INModelObject;

typedef void (^ ResultsBlock)(NSArray * objects);
typedef void (^ ModelBlock)(INModelObject * object);
typedef void (^ ErrorBlock)(NSError * error);

@interface INAPIManager : AFHTTPRequestOperationManager

+ (INAPIManager *)shared;

- (void)queueAPIOperation:(INAPIOperation *)operation;

@end
