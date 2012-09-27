/*
 *  ORCDiscount.h
 *  MarkdownLive
 *
 *  Created by Jonathan on 09/07/2011.
 *  Copyright 2011 mugginsoft.com. 
 *  Some rights reserved: <http://opensource.org/licenses/mit-license.php>
 *
 */
#import <Cocoa/Cocoa.h>

@class ORCSyntaxRange;

@interface ORCDiscount : NSObject {
}

+ (NSString *)markdown2HTML:(NSString *)markdown;
+ (NSString *)markdown2HTML:(NSString *)markdown rootSyntaxRange:(ORCSyntaxRange **)rootSyntaxRangeRanges;
+ (NSString *)HTMLPage:(NSString *)markdownHTML withCSSHTML:(NSString *)cssHTML;
+ (NSString *)HTMLPage:(NSString *)markdownHTML withCSSFromURL:(NSURL *)cssURL;
+ (NSURL *)cssURL;

@end
