//
//  ORCSyntaxRange.m
//  MarkdownLive
//
//  Created by Jan on 27.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "ORCSyntaxRange.h"

#import "ORCSyntaxRangeWalker.m"

@implementation ORCSyntaxRange

@synthesize syntaxType = _syntaxType;
@synthesize range = _range;
@synthesize headerLevel = _headerLevel;

@synthesize childRanges = _childRanges;

+ (id)syntaxRangeWithRange:(NSRange)theRange
				syntaxType:(ORCSyntaxRangeType)theSyntaxType
			   headerLevel:(int)theHeaderLevel;
{
	return [[[self alloc] initWithRange:theRange
							 syntaxType:theSyntaxType
							headerLevel:theHeaderLevel] autorelease];
}

- (id)initWithRange:(NSRange)theRange
		 syntaxType:(ORCSyntaxRangeType)theSyntaxType
		headerLevel:(int)theHeaderLevel;
{
    self = [super init];
	
    if (self) {
        _range = theRange;
        _syntaxType = theSyntaxType;
        _headerLevel = theHeaderLevel;
    }
	
    return self;
}

NSString * typeNameForRangeType(ORCSyntaxRangeType type) {
    switch (type) {
        case ORCSyntaxRangeTypeWhitespace		: return @"whitespace";
        case ORCSyntaxRangeTypeCode				: return @"code";
        case ORCSyntaxRangeTypeQuote			: return @"quote";
        case ORCSyntaxRangeTypeMarkup			: return @"markup";
        case ORCSyntaxRangeTypeHTML				: return @"HTML";
        case ORCSyntaxRangeTypeDL				: return @"definition-list";
        case ORCSyntaxRangeTypeUL				: return @"unordered-list";
        case ORCSyntaxRangeTypeOL				: return @"ordered-list";
        case ORCSyntaxRangeTypeListItem			: return @"list-item";
        case ORCSyntaxRangeTypeHeader			: return @"header";
        case ORCSyntaxRangeTypeHorizontalRow	: return @"horizontal-rule";
        case ORCSyntaxRangeTypeTable			: return @"table";
        case ORCSyntaxRangeTypeRoot				: return @"root";
        case ORCSyntaxRangeTypeStyle			: return @"style";
        default									: return @"undefined";
	}
}

- (NSString *)description;
{
	NSString *rangeDescription;
	if (_range.length == 0) {
		rangeDescription = [NSString stringWithFormat:@"{%lu}", (unsigned long)_range.location];
	}
	else {
		rangeDescription = [NSString stringWithFormat:@"{%lu->%lu (%lu)}",
							(unsigned long)_range.location,
							(unsigned long)NSMaxRange(_range)-1,
							(unsigned long)_range.length];
	}
	
	NSString *typeName;
	if (_syntaxType == ORCSyntaxRangeTypeHeader) {
		typeName = [NSString stringWithFormat:@"%@-%d", typeNameForRangeType(_syntaxType), _headerLevel];
	}
	else {
		typeName = typeNameForRangeType(_syntaxType);
	}

	NSString *description = [NSString stringWithFormat:@"<" /*"%@ %p, "*/ "%@ '%@'>",
							 /*NSStringFromClass([self class]), self, */
							 rangeDescription,
							 typeName
							 ];
	return description;
}

- (NSString *)treeDescription;
{
    NSMutableString *treeDescription = [[NSMutableString alloc] init];
    
	makeTreeDescription(self, nil, treeDescription, 0, @"\n");
	
	return [treeDescription autorelease];
}

@end
