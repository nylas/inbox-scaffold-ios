//
//  INModelObject.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ResultsBlock)(NSArray * objects);

#define NOTIF_MODEL_CHANGED @"model_changed"

#define API_TIMESTAMP_FORMAT @"yyyy-MM-dd HH:mm:ss"

/**
 INModelObject is the base class for model objects in the Inbox framework. It provides
 core functionality related to object serialization and is intended to be subclassed.
*/
@interface INModelObject : NSObject <NSCoding>
{
    BOOL _detatched;
}

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSDate * updatedAt;

/** @name Globally Unique Instances */

+ (id)attachedInstanceMatching:(INModelObject*)obj;
+ (id)attachedInstanceWithID:(id)ID;
+ (id)attachedInstanceForResourceDictionary:(NSDictionary*)dict;

+ (void)attachInstance:(INModelObject*)obj;

- (id)detatchedCopy;
- (BOOL)isDetatched;

/** @name Resource Representation */

/**
 Initializes a new instance of the object using the mapping function
 resourceMapping to populate Objective-C properties.
 
 @param json A dictionary with key-value pairs matching the ones
 declared in resourceMapping.

 @return A populated object
 */
- (id)initWithResourceDictionary:(NSDictionary*)json;

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


/** @name Override Points & Subclassing Support */

/**
 Subclasses override resourceMapping to define the mapping between their
 Objective-C @property's and the key-value pairs in their JSON representations. Providing
 this mapping allows -initWithResourceDictionary: and -resourceDictionary to convert the instance
 into JSON without additional glue code.
 
 A typical subclass implementation looks like this:
 
 + (NSMutableDictionary *)resourceMapping
 {
   NSMutableDictionary * mapping = [[super resourceMapping] addEntriesFromDictionary: @{
     @"firstName": @"first_name",
     @"lastName": @"last_name",
     @"emailAddress": @"email_address"
   }];
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
