//
//  NSMutableArray+JXSparse.h
//  MarkdownLive
//
//  Created by Jan on 02.10.12.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (JXSparse)

- (id)jx_objectOrNilAtIndex:(NSUInteger)anIndex;

@end


@interface NSMutableArray (JXSparse)

- (void)jx_setObject:(id)anObject atIndex:(NSUInteger)anIndex;

- (void)jx_getObjects:(id __unsafe_unretained [])objects storingDataIn:(NSMutableData *)data;

@end
