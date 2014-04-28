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

+ (id)instanceMatching:(INModelObject*)obj;

/**
 Returns the model object with the given ID currently in memory, if one exists.
 The primary purpose of this method is to retrieve an instance of an object so
 you can avoid allocating a new one, and avoid scenarios where multiple copies of
 a single logical object are floating around.
 
 @param ID The ID of the object you're looking for.
 
 @return An instance, or nil.
 */
+ (id)instanceMatchingID:(id)ID;

/**
 Returns an instance populated from the dictionary representation provided.
 This function does not always return new instances. If the same object has
 been requested previously and is still in memory it will return it, updating
 it as necessary to match the data in "dict".
 
 @param dict A dictionary with key-value pairs matching the ones
 declared in resourceMapping.
 
 @return A populated instance
 */
+ (id)instanceWithResourceDictionary:(NSDictionary*)dict;

+ (void)attachInstance:(INModelObject*)obj;

- (id)detatchedCopy;
- (BOOL)isDetatched;

@end
