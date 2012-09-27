//
//  NSString+UTF8Substring.h
//  HUTF8MappedUTF16String-demo
//
//  Created by Jan on 25.09.12.
//  Copyright 2012 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

@interface NSString (UTF8Substring)

+ (NSString *)jx_substringFromUTF8String:(const char *)u8buf withRange:(NSRange)range;

@end
