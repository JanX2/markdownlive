//
//  JXMappedStringConverter.h
//  HUTF8MappedUTF16String-demo
//
//  Created by Jan on 25.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

@interface JXMappedStringConverter : NSObject {
	NSString *_string;
	
	NSMutableData *_utf16data;
	NSUInteger _utf16Length;
	
	NSMutableData *_utf8data;
	NSUInteger _utf8Length;
	
	struct HUTF8MappedUTF16String *_mappedString;
}

@property (nonatomic, strong) NSString *string;

@property (nonatomic, readonly) NSUInteger UTF8Length;

+ (id)stringConverterWithString:(NSString *)string;
- (id)initWithString:(NSString *)aString;

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;

- (NSData *)UTF8Data; // Immutable copy of the converted data. 
- (const char *)UTF8String NS_RETURNS_INNER_POINTER; // Convenience to return null-terminated UTF8 representation, autoreleased. 

- (NSUInteger)UTF16IndexForUTF8Index:(NSUInteger)index; // Call -UTF8Data or -UTF8String before both of these!
- (NSRange)UTF16RangeForUTF8Range:(NSRange)u8range;

@end
