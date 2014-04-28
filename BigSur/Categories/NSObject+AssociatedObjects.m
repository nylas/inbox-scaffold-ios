//
//  NSObject+AssociatedObjects.m
//  
//  Created by Andy Matuschak on 8/27/09.
//  Public domain because I love you.
//

#import "NSObject+AssociatedObjects.h"
#import <objc/runtime.h>

@implementation NSObject (AMAssociatedObjects)

- (void)associateValue:(id)value withKey:(void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)weaklyAssociateValue:(id)value withKey:(void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(void *)key
{
	return objc_getAssociatedObject(self, key);
}

- (void)performSelectorOnMainThreadOnce:(SEL)selector
{
    [self associateValue:[NSNumber numberWithBool: YES] withKey: (void*)selector];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self associatedValueForKey: (void*)selector]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector: selector];
#pragma clang diagnostic pop

            [self associateValue:nil withKey:(void*)selector];
        }
    });
}

@end
