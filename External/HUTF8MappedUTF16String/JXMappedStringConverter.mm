//
//	JXMappedStringConverter.m
//	HUTF8MappedUTF16String-demo
//
//	Created by Jan on 25.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXMappedStringConverter.h"

#import "HUTF8MappedUTF16String.h"

@implementation JXMappedStringConverter

@synthesize string = _string;

@synthesize UTF8Length = _utf8Length;

+ (id)stringConverterWithString:(NSString *)string;
{
	return [[[self alloc] initWithString:string] autorelease];
}

- (id)initWithString:(NSString *)aString;
{
	self = [super init];
	
	if (self) {
		self.string = aString;
		_mappedString = new HUTF8MappedUTF16String;
	}
	
	return self;
}

- (void)dealloc
{
	[_string release];
	[_utf16data release];
	[_utf8data release];

	delete _mappedString; _mappedString = NULL;

	[super dealloc];
}


- (NSUInteger)length;
{
	return _string.length;
}

- (unichar)characterAtIndex:(NSUInteger)index;
{
	unichar c = (*_mappedString)[index];
	return c;
}


NS_INLINE void jx_CFStringPrepareUnicharBufferData(CFStringRef string, CFRange string_range, const UniChar **string_chars, NSMutableData **utf16Data) {
	*string_chars = (unichar *)CFStringGetCharactersPtr(string);
	if (*string_chars == NULL) {
		// Fallback in case CFStringGetCharactersPtr() didn’t return an internal pointer.
		NSUInteger utf16DataSize = string_range.length * sizeof(UniChar);
		if (*utf16Data == nil) {
			*utf16Data = [[NSMutableData alloc] initWithCapacity:utf16DataSize];
		} else {
			[*utf16Data setLength:utf16DataSize];
		}
		*string_chars = (unichar *)[*utf16Data mutableBytes];
		CFStringGetCharacters(string, string_range, (UniChar *)*string_chars);
	}
}

- (void)convertToUTF8;
{
	CFStringRef string = (CFStringRef)_string;
	unichar *u16buf;
	
	_utf16Length = CFStringGetLength(string);
	CFRange string_range = CFRangeMake(0, _utf16Length);
	
	// Prepare UTF-16 buffer
	jx_CFStringPrepareUnicharBufferData(string, string_range, (const UniChar **)&u16buf, &_utf16data);
	
	_mappedString->setUTF16String(u16buf, _utf16Length, true);
	
	// Prepare UTF-8 buffer
	NSUInteger utf8dataSize = _mappedString->maximumUTF8Size()+1;
	if (_utf8data == nil) {
		_utf8data = [[NSMutableData alloc] initWithCapacity:utf8dataSize];
	} else {
		[_utf8data setLength:utf8dataSize];
	}
	uint8_t *u8buf = (uint8_t *)[_utf8data mutableBytes];
	
	// Convert
	size_t u8len = _mappedString->convert(u8buf);
	
	u8buf[u8len] = '\0';
	_utf8Length = (NSUInteger)u8len;
}

- (NSData *)UTF8Data;
{
	[self convertToUTF8];
	
	return [[_utf8data copy] autorelease];
}

- (const char *)UTF8String;
{
	[self convertToUTF8];
	
	return (const char *)[_utf8data bytes];
}

- (NSUInteger)UTF16IndexForUTF8Index:(NSUInteger)i;
{
	//if (_mappedString == NULL)  return NSNotFound;
	
	size_t index = _mappedString->UTF16IndexForUTF8Index(i);
	return (NSUInteger)index;
}

- (NSRange)UTF16RangeForUTF8Range:(NSRange)u8range;
{
	//if (_mappedString == NULL)  return NSMakeRange(NSNotFound, 0);
	
	NSRange u16range = _mappedString->UTF16RangeForUTF8Range(u8range);
	return u16range;
}

@end
