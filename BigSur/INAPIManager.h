//
//  INAPIManager.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

static NSString * INAccountChangedNotification = @"INAccountChangedNotification";

@class INAPIOperation;
@class INModelObject;
@class INAccount;

typedef void (^ ResultsBlock)(NSArray * objects);
typedef void (^ ModelBlock)(INModelObject * object);
typedef void (^ AuthenticationBlock)(INAccount * account, NSError * error);
typedef void (^ ErrorBlock)(NSError * error);
typedef void (^ VoidBlock)();

@interface INAPIManager : AFHTTPRequestOperationManager
{
	INAccount * _account;
}

+ (INAPIManager *)shared;

- (void)queueAPIOperation:(INAPIOperation *)operation;

#pragma Authentication

- (void)authenticate:(AuthenticationBlock)completionBlock;
- (INAccount*)account;

@end
