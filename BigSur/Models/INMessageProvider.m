//
//  INMessageProvider.m
//  BigSur
//
//  Created by Ben Gotow on 4/30/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INMessageProvider.h"
#import "INThread.h"

@implementation INMessageProvider

- (id)initWithThreadID:(NSString *)threadID andNamespaceID:(NSString*)namespaceID
{
	NSPredicate * threadPredicate = [NSComparisonPredicate predicateWithFormat:@"threadID = %@", threadID];
	self = [super initWithClass:[INMessage class] andNamespaceID:namespaceID andUnderlyingPredicate:threadPredicate];
	if (self) {
	}
	return self;
}

- (NSDictionary *)queryParamsForPredicate:(NSPredicate*)predicate
{
	NSMutableDictionary * params = [NSMutableDictionary dictionary];
	
	if ([predicate isKindOfClass: [NSCompoundPredicate class]]) {
		if ([(NSCompoundPredicate*)predicate compoundPredicateType] != NSAndPredicateType)
			NSAssert(false, @"Only AND predicates are currently supported in constructing queries.");
			
		for (NSPredicate * subpredicate in [(NSCompoundPredicate*)predicate subpredicates])
			[params addEntriesFromDictionary: [self queryParamsForPredicate: subpredicate]];
	
	} else if ([predicate isKindOfClass: [NSComparisonPredicate class]]) {
		NSComparisonPredicate * pred = (NSComparisonPredicate*)predicate;
		if ([[pred rightExpression] expressionType] != NSConstantValueExpressionType)
			NSAssert(false, @"Only constant values can be on the RHS of predicates.");
		if ([[pred leftExpression] expressionType] != NSKeyPathExpressionType)
			NSAssert(false, @"Only property names can be on the LHS of predicates.");
				

		NSString * keyPath = [[pred leftExpression] keyPath];
		
		if ([keyPath isEqualToString: @"namespaceID"]) {
			// ignore - it's in the URL
		} else if ([keyPath isEqualToString: @"threadID"]) {
			[params setObject:[[pred rightExpression] constantValue] forKey:@"thread"];
		}
	}
	
	return params;
}


@end
