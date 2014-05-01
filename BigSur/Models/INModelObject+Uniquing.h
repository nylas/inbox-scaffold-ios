//
//  INModelObject+Uniquing.h
//  BigSur
//
//  Created by Ben Gotow on 4/28/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject.h"

@interface INModelObject (Uniquing)

/** @name Globally Unique Instances */

/**
 Returns the model object with the given ID currently in memory, if one exists.
 The primary purpose of this method is to retrieve an instance of an object so
 you can avoid allocating a new one, and avoid scenarios where multiple copies of
 a single logical object are floating around.

 @param ID The ID of the object you're looking for.

 @return An instance, or nil.
 */
+ (id)attachedInstanceMatchingID:(id)ID createIfNecessary:(BOOL)shouldCreate didCreate:(BOOL*)didCreate;


+ (void)attachInstance:(INModelObject *)obj;

- (id)detatchedCopy;
- (BOOL)isDetatched;

@end
