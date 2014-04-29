//
//  INModelObject.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INAPIManager.h"

@class INAPIOperation;

#define API_TIMESTAMP_FORMAT @"yyyy-MM-dd HH:mm:ss"

static NSString * INModelObjectChangedNotification = @"model_changed";

/**
 INModelObject is the base class for model objects in the Inbox framework. It provides
 core functionality related to object serialization and is intended to be subclassed.
*/
@interface INModelObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSString * namespaceID;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSDate * updatedAt;

/** @name Resource Representation */

/** 
 Uses the resourceMapping mapping and the object's property values
 to create a JSON-compatible NSDictionary.
 
 @return An NSDictionary of JSON-compatible key-value pairs.
*/
- (NSMutableDictionary*)resourceDictionary;

/**
 Applies the JSON to the object, overriding existing property values when key-value
 pairs are present in the json.
 
 @param json A JSON dictionary with one or more key-value pairs matching the ones
 declared in resourceMapping.
*/
- (void)updateWithResourceDictionary:(NSDictionary*)dict;


/** @name Resource Loading and Saving */

/**
 @return The path to the object on the API.
 */

- (NSString*)APIPath;

/**
 Reload the model by perfoming a GET request to the APIPath.
 
 @param callback An optional callback that allows you to capture errors and present
 alerts that the user may expect when a reload fails.
 */
- (void)reload:(ErrorBlock)callback;

/**
 Save the model to the server. This method may be overriden in subclasses. The 
 default implementation does a PUT to the APIPath for objects with IDs, and a POST
 to the APIPath (without an ID) for new objects.
 
 Note that -save is eventually persistent. The save operation may be held in queue
 until network connectivity is available.
 
 @return An INAPIAction that you can use to track the progress of the save operation.
 */
- (INAPIOperation*)save;


/** @name Override Points & Subclassing Support */

/**
 Subclasses override resourceMapping to define the mapping between their
 Objective-C @property's and the key-value pairs in their JSON representations. Providing
 this mapping allows -initWithResourceDictionary: and -resourceDictionary to convert the instance
 into JSON without additional glue code.
 
 A typical subclass implementation looks like this:
 
 + (NSMutableDictionary *)resourceMapping
 {
   NSMutableDictionary * mapping = [super resourceMapping];
   [mapping addEntriesFromDictionary: @{
     @"firstName": @"first_name",
     @"lastName": @"last_name",
     @"emailAddress": @"email_address"
   }];
   return mapping;
 }
 
 @return A dictionary mapping iOS property names to JSON fields.
 */
+ (NSMutableDictionary *)resourceMapping;


/**
 Setup should be overridden in subclasses to perform additional initialization
 that needs to take place after -initWithCoder: or -initWithResourceDictionary: The base class
 implementation does nothing.
 */
- (void)setup;


@end
