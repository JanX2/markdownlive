//
//  ORCSyntaxRange.m
//  MarkdownLive
//
//  Created by Jan on 27.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "ORCSyntaxRange.h"

@implementation ORCSyntaxRange

@synthesize syntaxType = _syntaxType;
@synthesize range = _range;

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
        case ORCSyntaxRangeTypeDL				: return @"DL";
        case ORCSyntaxRangeTypeUL				: return @"UL";
        case ORCSyntaxRangeTypeOL				: return @"OL";
        case ORCSyntaxRangeTypeListItem			: return @"list item";
        case ORCSyntaxRangeTypeHeader			: return @"header";
        case ORCSyntaxRangeTypeHorizontalRow	: return @"horizontal row";
        case ORCSyntaxRangeTypeTable			: return @"table";
        case ORCSyntaxRangeTypeSource			: return @"source";
        case ORCSyntaxRangeTypeStyle			: return @"style";
        default									: return @"undefined";
	}
}

- (NSString *)description;
{
	NSString *rangeDescription;
	if (_range.length == 0) {
		rangeDescription = [NSString stringWithFormat:@"range(%lu)", _range.location];
	}
	else {
		rangeDescription = [NSString stringWithFormat:@"range(%lu->%lu)", _range.location, NSMaxRange(_range)-1];
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

@end
