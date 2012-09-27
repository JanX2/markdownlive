//
//	JXMappedStringConverterTests.m
//	JXMappedStringConverterTests
//
//	Created by Jan on 25.09.12.
//	Copyright (c) 2012 Jan. All rights reserved.
//

#import "JXMappedStringConverterTests.h"

#import "JXMappedStringConverter.h"
#import "NSString+UTF8Substring.h"


#define U16_IS_SINGLE(c) !(((c)&0xfffff800)==0xd800)



typedef struct _JXRangePairInfo {
    NSUInteger u8index;
    NSRange u16range;
	NSString *expectedString;
} JXRangePairInfo;


@implementation JXMappedStringConverterTests

- (void)setUp
{
	[super setUp];
	
	// Set-up code here.
}

- (void)tearDown
{
	// Tear-down code here.
	
	[super tearDown];
}

- (void)testExample
{
	// Our original Unicode test string
	unichar u16chars[] = {
	// Unicode characters:
	//    h    e   j        ♜    |    ♞    |        𝄞             d   å
	// Unicode (bits/char):
	//    8    8   8   8    16    8    16    8       32        8   8   16
	// UTF-8 widths (bytes/char):
	//    1    1   1   1     3    1     3    1        4        1   1    2
	'h','e','j',' ',0x265c,'|',0x265e,'|',0xd834,0xdd1e,' ','d',0xe5 };
	NSString *str = [NSString stringWithCharacters:u16chars
											length:sizeof(u16chars)/sizeof(*u16chars)];
	
	JXRangePairInfo pairInfos[] =
	{
		{
			.u8index = 0,
			.u16range = {.location = 0, .length = 1},
			.expectedString = @"h"
		},
		{
			.u8index = 1,
			.u16range = {.location = 1, .length = 1},
			.expectedString = @"e"
		},
		{
			.u8index = 2,
			.u16range = {.location = 2, .length = 1},
			.expectedString = @"j"
		},
		{
			.u8index = 3,
			.u16range = {.location = 3, .length = 1},
			.expectedString = @" "
		},
		{
			.u8index = 4,
			.u16range = {.location = 4, .length = 1},
			.expectedString = @"♜"
		},
		{
			.u8index = 5,
			.u16range = {.location = 4, .length = 1},
			.expectedString = @"♜"
		},
		{
			.u8index = 6,
			.u16range = {.location = 4, .length = 1},
			.expectedString = @"♜"
		},
		{
			.u8index = 7,
			.u16range = {.location = 5, .length = 1},
			.expectedString = @"|"
		},
		{
			.u8index = 8,
			.u16range = {.location = 6, .length = 1},
			.expectedString = @"♞"
		},
		{
			.u8index = 9,
			.u16range = {.location = 6, .length = 1},
			.expectedString = @"♞"
		},
		{
			.u8index = 10,
			.u16range = {.location = 6, .length = 1},
			.expectedString = @"♞"
		},
		{
			.u8index = 11,
			.u16range = {.location = 7, .length = 1},
			.expectedString = @"|"
		},
		{
			.u8index = 12,
			.u16range = {.location = 8, .length = 2},
			.expectedString = @"𝄞"
		},
		{
			.u8index = 13,
			.u16range = {.location = 8, .length = 2},
			.expectedString = @"𝄞"
		},
		{
			.u8index = 14,
			.u16range = {.location = 8, .length = 2},
			.expectedString = @"𝄞"
		},
		{
			.u8index = 15,
			.u16range = {.location = 8, .length = 2},
			.expectedString = @"𝄞"
		},
		{
			.u8index = 16,
			.u16range = {.location = 10, .length = 1},
			.expectedString = @" "
		},
		{
			.u8index = 17,
			.u16range = {.location = 11, .length = 1},
			.expectedString = @"d"
		},
		{
			.u8index = 18,
			.u16range = {.location = 12, .length = 1},
			.expectedString = @"å"
		},
		{
			.u8index = 19,
			.u16range = {.location = 12, .length = 1},
			.expectedString = @"å"
		}
	};
	//int pairInfoCount = sizeof(pairInfo)/sizeof(JXRangePairInfo);
	
	JXMappedStringConverter *stringConverter = [JXMappedStringConverter stringConverterWithString:str];
	
	// Convert
	const char *u8buf = [stringConverter UTF8String];
	NSUInteger u8len = [stringConverter UTF8Length];
	
	fprintf(stderr, "utf8 value => '%s'\n", u8buf);
	
	for (NSUInteger i = 0; i < u8len; i++) {
		JXRangePairInfo pairInfo = pairInfos[i];
		
		STAssertEquals(pairInfo.u8index, i, [NSString stringWithFormat:@"pairInfo u8index mismatch for index %lu.", (unsigned long)i]);

		NSUInteger index = [stringConverter UTF16IndexForUTF8Index:i];
		unichar c1 = [stringConverter characterAtIndex:index];
		
		NSRange u16range;
		if (U16_IS_SINGLE(c1)) {
			u16range = NSMakeRange(index, 1);
		} else {
			u16range = NSMakeRange(index, 2);
		}
		
		STAssertTrue(NSEqualRanges(pairInfo.u16range, u16range), [NSString stringWithFormat:@"pairInfo u16range mismatch for index %lu.", (unsigned long)i]);
		
		NSString *substring = [str substringWithRange:u16range];
		STAssertEqualObjects(pairInfo.expectedString, substring, [NSString stringWithFormat:@"pairInfo string mismatch for index %lu.", (unsigned long)i]);
	}
	
	NSRange u8range = NSMakeRange(2, u8len-4); // should be "j ♜|♞|𝄞 d"
											   //u8range = NSMakeRange(12, 1); // should be "𝄞"
	STAssertTrue(NSEqualRanges(NSMakeRange(2, 16), u8range), @"u8range mismatch.");

	NSString *u8substr = [NSString jx_substringFromUTF8String:u8buf
													withRange:u8range];
	STAssertEqualObjects(@"j ♜|♞|𝄞 d", u8substr, @"u8substr mismatch.");
	
	NSRange u16range = [stringConverter UTF16RangeForUTF8Range:u8range];
	STAssertTrue(NSEqualRanges(NSMakeRange(2, 10), u16range), @"u16range mismatch.");

	NSString *u16substr = [str substringWithRange:u16range];
	STAssertEqualObjects(@"j ♜|♞|𝄞 d", u16substr, @"u16substr mismatch.");
}

@end
