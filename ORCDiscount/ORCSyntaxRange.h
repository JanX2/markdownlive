//
//  ORCSyntaxRange.h
//  MarkdownLive
//
//  Created by Jan on 27.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

enum {
	ORCSyntaxRangeTypeDefault = 0,
	ORCSyntaxRangeTypeWhitespace = 1,
	ORCSyntaxRangeTypeVerbatim,
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
	ORCSyntaxRangeTypeRoot,
	ORCSyntaxRangeTypeStyle,
	ORCSyntaxRangeTypeEmphasis,
	ORCSyntaxRangeTypeStrong,
	ORCSyntaxRangeTypeCode,
	ORCSyntaxRangeTypeUndefined,
	ORCSyntaxRangeTypeCount
};
typedef NSUInteger ORCSyntaxRangeType;

@interface ORCSyntaxRange : NSObject {
	NSRange _range;
	ORCSyntaxRangeType _syntaxType;
	int _headerLevel;
	
	NSMutableArray *_childRanges;
}

@property (readonly) NSRange range;
@property (readonly) ORCSyntaxRangeType syntaxType;
@property (nonatomic, readonly) int headerLevel;

@property (readonly) NSString *syntaxTypeName;

@property (nonatomic, readwrite, retain) NSMutableArray *childRanges;

+ (NSString *)syntaxTypeNameForRangeType:(ORCSyntaxRangeType)type headerLevel:(int)level;

+ (id)syntaxRangeWithRange:(NSRange)theRange
				syntaxType:(ORCSyntaxRangeType)theSyntaxType
				headerLevel:(int)theHeaderLevel;
- (id)initWithRange:(NSRange)theRange
		 syntaxType:(ORCSyntaxRangeType)theSyntaxType
		headerLevel:(int)theHeaderLevel;

- (NSString *)treeDescription;

@end
