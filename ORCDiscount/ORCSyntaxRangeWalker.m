//
//  ORCSyntaxRangeWalker.m
//
//  Copyright (C) 2007 David L Parsons
//  Copyright (c) 2012 Jan Weiß
//	Based on “dumptree.c”; part of “Discount” by David L Parsons. 
//  Ported to Obj-C by Jan Weiß. 
//
//  Released under the BSD software licence.
//

#import "ORCSyntaxRange.h"
#import "JXFrame.h"

static void
pushPrefix(int indent, unichar c, NSMutableArray *stack)
{
    JXFrame *frame = [JXFrame frameWithIndent:indent unichar:c];
    [stack addObject:frame];
}


NS_INLINE void
popPrefix(NSMutableArray *stack)
{
    [stack removeLastObject];
}


static void
changePrefix(NSMutableArray *stack, unichar c)
{
    unichar ch;
	
    if (stack.count == 0)  return;
	
	JXFrame *frame = [stack lastObject];
    ch = frame.unichar;
	
    if ( ch == '+' || ch == '|' ) {
		frame.unichar = c;
	}
}


static NSUInteger
printPrefix(NSMutableArray *stack, NSMutableString *out)
{
    NSUInteger length = out.length;
	unichar c;
	
	NSUInteger stackCount = stack.count;
    if (stackCount == 0)  return 0;
	
	JXFrame *frame = [stack lastObject];
    c = frame.unichar;
	
    if ( c == '+' || c == '-' ) {
		[out appendFormat:@"--%C", c];
		frame.unichar = (c == '-') ? ' ' : '|';
    }
    else {
		for (NSUInteger i = 0; i < stackCount; i++ ) {
			if (i > 0) {
				[out appendString:@"  "];
			}
			frame = [stack objectAtIndex:i];
			c = frame.unichar;
			[out appendFormat:@"%*s%C", frame.indent + 2, " ", c];
			if ( c == '`' ) {
				frame.unichar = ' ';
			}
		}
	}
	
	[out appendString:@"--"];
	
	length = out.length - length;
	return length;
}


static void
dumpSubTree(ORCSyntaxRange *currentNode, id locale, NSMutableArray *stack, NSMutableString *out)
{
	NSArray *children = currentNode.childRanges;
	NSUInteger childrenCount = children.count;
	NSUInteger lastChildIndex = childrenCount - 1;
	NSUInteger childIndex = 0;
	
	for (ORCSyntaxRange *child in children) {
		
		if (childIndex == lastChildIndex && childrenCount > 1) {
			changePrefix(stack, '`');
		}
		
		/*NSUInteger prefixLength = */printPrefix(stack, out);
		//NSUInteger nextIndentationLevel = ((prefixLength + 2) / 4) + 1;
		
		NSString *contentObjectDescription = [child description];
		[out appendString:contentObjectDescription];
		int d = contentObjectDescription.length;
		
		NSArray *childNodes = child.childRanges;
		NSUInteger childNodesCount;
		if (childNodes != nil && ((childNodesCount = childNodes.count) > 0)) {
			BOOL hasSibling = (childNodesCount > 1);
			pushPrefix(d, (hasSibling ? '+' : '-'), stack);
			dumpSubTree(child, locale, stack, out);
			popPrefix(stack);
		}
		else {
			[out appendString:@"\n"];
		}
		
		childIndex++;
    }
}


static void
makeTreeDescription(ORCSyntaxRange *rootNode, id locale, NSMutableString *out, NSUInteger indentationDepth, NSString *title)
{
    NSMutableArray *stack = [[NSMutableArray alloc] init];
			
	[out appendString:title];
	if ([title isEqualToString:@"\n"] == NO)  indentationDepth += title.length;
	
	NSUInteger childNodesCount = rootNode.childRanges.count;
	BOOL hasSibling = (childNodesCount > 1);
	pushPrefix(indentationDepth, (hasSibling ? '+' : '-'), stack);
	dumpSubTree(rootNode, locale, stack, out);
}
