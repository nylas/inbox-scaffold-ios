//
//  INThread.h
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"

@interface INThread : INModelObject

@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSArray * participants;
@property (nonatomic, strong) NSDate * lastMessageDate;

@end
