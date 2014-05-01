//
//  INModelArrayResponseSerializer.h
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

@interface INModelArrayResponseSerializer : AFJSONResponseSerializer

@property (nonatomic, strong) Class modelClass;

- (id)initWithModelClass:(Class)klass;

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError * __autoreleasing *)error;

@end
