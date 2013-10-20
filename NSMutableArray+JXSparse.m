//
//  NSMutableArray+JXSparse.m
//  MarkdownLive
//
//  Created by Jan on 02.10.12.
//	Based on “OFSparseArray”
//  Copyright 1997-2005, 2007-2008, 2010-2011 Omni Development, Inc.  All rights reserved.
//  This software may only be used and reproduced according to the
//  terms in the file OmniSourceLicense.html, which should be
//  distributed with this project and can also be found at
//  <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//  (basically MIT license)

#import "NSMutableArray+JXSparse.h"

static NSNull *nullValue = nil;

@implementation NSArray (JXSparse)

- (id)jx_objectOrNilAtIndex:(NSUInteger)anIndex;
{
	id value;
	
	if (anIndex >= self.count)  return nil;
	
	value = [self objectAtIndex:anIndex];
	
	if (value == nullValue)  return nil;
	
	return value;
}

@end


@implementation NSMutableArray (JXSparse)

+ (void)load {
	nullValue = [NSNull null];
}

NS_INLINE void extendCapacity(NSMutableArray *self, NSUInteger anIndex) {
	while (self.count < anIndex) {
		[self addObject:nullValue];
	}
}

- (void)jx_setObject:(id)anObject atIndex:(NSUInteger)anIndex;
{
	if (anObject == nil) {
		anObject = nullValue;
	}
	
	if (anIndex < self.count) {
		[self replaceObjectAtIndex:anIndex withObject:anObject];
	} else {
		extendCapacity(self, anIndex);
		[self addObject:anObject];
	}
}


- (void)jx_getObjects:(id __unsafe_unretained [])objects storingDataIn:(NSMutableData *)data;
{
	NSRange range = NSMakeRange(0, self.count);
	[data setLength:(sizeof(id) * range.length)];
	objects = (__unsafe_unretained id *)[data mutableBytes];
	
	[self getObjects:objects range:range];
	
	for (int i = 0; i < range.length; i++) {
		if (objects[i] == nullValue)  objects[i] = nil;
	}
}

@end
