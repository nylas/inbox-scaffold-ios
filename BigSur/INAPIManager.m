//
//  INAPIManager.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INAPIManager.h"

#if DEBUG
#define API_URL [NSURL URLWithString: @"http://localhost/"]
#else
#define API_URL [NSURL URLWithString: @"http://localhost/"]
#endif


@implementation INAPIManager

+ (INAPIManager *)shared
{
    static INAPIManager * sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[INAPIManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: API_URL];
        [_requestManager setResponseSerializer: [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingAllowFragments]];
        [_requestManager setRequestSerializer: [AFJSONRequestSerializer serializerWithWritingOptions: NSJSONWritingPrettyPrinted]];
    }
    return self;
}

@end
