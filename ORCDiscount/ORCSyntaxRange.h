//
//  ORCSyntaxRange.h
//  MarkdownLive
//
//  Created by Jan on 27.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

enum {
	ORCSyntaxRangeTypeWhitespace = 0,
	ORCSyntaxRangeTypeCode,
	ORCSyntaxRangeTypeQuote,
	ORCSyntaxRangeTypeMarkup,
	ORCSyntaxRangeTypeHTML,
	ORCSyntaxRangeTypeDL,
	ORCSyntaxRangeTypeUL,
	ORCSyntaxRangeTypeOL,
	ORCSyntaxRangeTypeListItem,
	ORCSyntaxRangeTypeHeader,
	ORCSyntaxRangeTypeHorizontalRow,
	ORCSyntaxRangeTypeTable,
	ORCSyntaxRangeTypeSource,
	ORCSyntaxRangeTypeStyle,
	ORCSyntaxRangeTypeUndefined
};
typedef NSUInteger ORCSyntaxRangeType;

@interface ORCSyntaxRange : NSObject {
	NSRange _range;
	ORCSyntaxRangeType _syntaxType;
	int _headerLevel;
}

@property (readonly) NSRange range;
@property (readonly) ORCSyntaxRangeType syntaxType;
@property (nonatomic, readonly) int headerLevel;

+ (id)syntaxRangeWithRange:(NSRange)theRange
				syntaxType:(ORCSyntaxRangeType)theSyntaxType
				headerLevel:(int)theHeaderLevel;
- (id)initWithRange:(NSRange)theRange
		 syntaxType:(ORCSyntaxRangeType)theSyntaxType
		headerLevel:(int)theHeaderLevel;

@end
