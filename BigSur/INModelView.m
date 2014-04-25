//
//  INModelView.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelView.h"
#import "INModelObject.h"

@implementation INModelView

+ (id)viewForClass:(Class)modelClass
{
    INModelView * view = [[INModelView alloc] init];
    [view setModelClass: modelClass];
    return view;
}

- (void)repopulate:(BOOL)calculateChanges
{
    // immediately refresh our data from what is now available in the cache
//    [modelClass persistedInstancesMatching:predicate sortedBy:sortDescriptors limit:10 offset:0 withCallback:^(NSArray *matchingItems) {
//        if (!calculateChanges) {
//            self.items = matchingItems;
//            [self.delegate viewChanged: nil];
//            
//        } else {
//            NSMutableArray * newItems = [NSMutableArray array];
//            NSMutableArray * remainingItems = [self.items mutableCopy];
//            NSMutableArray * changes = [NSMutableArray array];
//            
//            for (int newIndex = 0; newIndex < [objects count]; newIndex ++) {
//                INModelObject * obj = [objects objectAtIndex: newIndex];
//                int oldIndex = [self.items indexOfObjectIdenticalTo: obj];
//                
//                if (oldIndex == NSNotFound) {
//                    // item has been added!
//                    [changes addObject: [INModelViewChange changeForAddingItemAtIndex: 0]];
//                    
//                } else if (oldIndex != newIndex) {
//                    // item has been added!
//                    [changes addObject: [INModelViewChange changeForAddingItemAtIndex: 0]];
//
//                }
//            }
//            INModelObject *
//            INContact * b = [objects firstObject];
//            NSLog(@"%p = %p ? ", a, b);
//        }
//    }];
}

@end
