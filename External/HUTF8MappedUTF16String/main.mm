#import "HUTF8MappedUTF16String.h"
// example and a kind of a test

#define U16_IS_SINGLE(c) !(((c)&0xfffff800)==0xd800)

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  // Our original Unicode test string
  unichar u16chars[] = {
  // Unicode characters:
  //    h    e   j        ♜    |    ♞    |        𝄞             d   å
  // Unicode (bits/char):
  //    8    8   8   8    16    8    16    8       32        8   8   16
  // UTF-8 widths (bytes/char):
  //    1    1   1   1     3    1     3    1        4        1   1    2
        'h','e','j',' ',0x265c,'|',0x265e,'|',0xd834,0xdd1e,' ','d',0xe5 };
  NSString *str = [NSString stringWithCharacters:u16chars length:
      sizeof(u16chars)/sizeof(*u16chars)];
  HUTF8MappedUTF16String mappedString;
  mappedString.setNSString(str, NSMakeRange(0,str.length));
  
  // UTF-8 buffer
  NSMutableData *utf8data = [NSMutableData dataWithCapacity:mappedString.maximumUTF8Size()+1];
  uint8_t *u8buf = (uint8_t *)[utf8data mutableBytes];
  
  // convert
  size_t u8len = mappedString.convert(u8buf);
  
  u8buf[u8len] = '\0';
  fprintf(stderr, "utf8 value => '%s'\n", u8buf);
  
  for (size_t i=0; i<u8len; i++) {
    size_t index = mappedString.UTF16IndexForUTF8Index(i);
    unichar c = mappedString[index];
    
    if (U16_IS_SINGLE(c)) {
      NSLog(@"utf8[%zu] => utf16[%zu] -> '%C' \\u%x", i, index, c, c);
    } else {
      NSLog(@"utf8[%zu] => utf16[%zu..%zu] -> '%C%C' \\u%x \\u%x",
            i, index, index+1, c, mappedString[index+1],
            c, mappedString[index+1]);
    }
  }
  
  NSRange u8range = NSMakeRange(2, u8len-4); // should be "j ♜|♞|𝄞 d"
  //u8range = NSMakeRange(12, 1); // should be "𝄞"
  NSString *u8substr = // temporary so we can use NSLog
      [[[NSString alloc] initWithBytesNoCopy:u8buf+u8range.location
                                      length:u8range.length
                                    encoding:NSUTF8StringEncoding
                                freeWhenDone:NO] autorelease];
  NSLog(@"u8range: %@ -> '%@'", NSStringFromRange(u8range), u8substr);
  NSRange u16range = mappedString.UTF16RangeForUTF8Range(u8range);
  NSString *u16substr = [str substringWithRange:u16range];
  NSLog(@"u16range: %@ -> '%@'", NSStringFromRange(u16range), u16substr);

  [pool drain];
  return 0;
}
