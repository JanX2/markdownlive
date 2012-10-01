/*******************************************************************************
	discountWrapper.m - <http://github.com/rentzsch/MarkdownLive>
		Copyright (c) 2006-2011 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import "JXMappedStringConverter.h"

#include "discountWrapper.h"

//#define Line discountLine
#import "markdown.h"
//#undef Line

#include "mkdioWrapper.h"
#include "markdownWrapper.h"
#include "syntaxTreeWalker.h"

#import "ORCSyntaxRange.h"

NSString *discountToHTML(NSString *markdown, ORCSyntaxRange **rootSyntaxRange) {
    NSString *result = nil;
    
    JXMappedStringConverter *stringConverter = [JXMappedStringConverter stringConverterWithString:markdown];
    char *markdownUTF8 = (char *)[stringConverter UTF8String];
    NSUInteger markdownUTF8Length = [stringConverter UTF8Length];
    
    Document *document = mkd_string_wrapper(markdownUTF8, markdownUTF8Length, 0);
    
    if (document) {
        if (mkd_compile_wrapper(document, 0)) {
            if (rootSyntaxRange != NULL) {
                syntaxTreeWalker(document, stringConverter, rootSyntaxRange);
                //NSLog(@"%@", [*rootSyntaxRange treeDescription]);
            }
            
            char *htmlUTF8;
            int htmlUTF8Len = mkd_document_wrapper(document, &htmlUTF8);
            if (htmlUTF8Len != EOF) {
                result = [[[NSString alloc] initWithBytes:htmlUTF8
                                                   length:htmlUTF8Len
                                                 encoding:NSUTF8StringEncoding] autorelease];
            }
            
            mkd_cleanup_wrapper(document);
        }
    }
    
    return result;
}