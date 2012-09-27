/*******************************************************************************
    syntaxTreeWalker.h - <http://github.com/rentzsch/MarkdownLive>
        Copyright (c) 2012 Jan Weiß: <http://www.geheimwerk.de>
        Some rights reserved: <http://opensource.org/licenses/mit-license.php>

    ***************************************************************************/

#import <Foundation/Foundation.h>

#import "markdown.h"

@class JXMappedStringConverter;
@class ORCSyntaxRange;

void syntaxTreeWalker(Document *doc, JXMappedStringConverter *stringConverter, ORCSyntaxRange **rootSyntaxRange);
