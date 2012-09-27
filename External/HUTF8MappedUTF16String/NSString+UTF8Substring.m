//
//  NSString+UTF8Substring.m
//  HUTF8MappedUTF16String-demo
//
//  Created by Jan on 25.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "NSString+UTF8Substring.h"

@implementation NSString (UTF8Substring)

+ (NSString *)jx_substringFromUTF8String:(const char *)u8buf withRange:(NSRange)u8range;
{
	// Wartning: This will blow up if u8buf goes away before the substring does!
	NSString *u8substr =
	[[[NSString alloc] initWithBytesNoCopy:(void *)(u8buf + u8range.location)
									length:u8range.length
								  encoding:NSUTF8StringEncoding
							  freeWhenDone:NO] autorelease];
	return u8substr;
}

@end
