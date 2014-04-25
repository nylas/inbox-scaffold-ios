//
//  INAPIManager.h
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface INAPIManager : NSObject
{
    AFHTTPRequestOperationManager * _requestManager;
}
+ (INAPIManager *)shared;

@end
