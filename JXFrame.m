//
//  JXFrame.m
//  MarkdownLive
//
//  Created by Jan on 28.09.12.
//  Copyright 2012 Jan Weiß
//
//  Released under the BSD software licence.
//

#import "JXFrame.h"

@implementation JXFrame

@synthesize indent = _indent;
@synthesize unichar = _c;

+ (id)frameWithIndent:(int)theIndent unichar:(unichar)theUnichar;
{
    id result = [[[self class] alloc] initWithIndent:theIndent unichar:theUnichar];
	
    return result;
}

- (id)initWithIndent:(int)theIndent unichar:(unichar)theUnichar
{
    self = [super init];
	
    if (self) {
        _indent = theIndent;
        _c = theUnichar;
    }
	
    return self;
}
@end
