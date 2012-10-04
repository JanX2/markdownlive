/*******************************************************************************
 discountWrapper.m - <http://github.com/rentzsch/MarkdownLive>
 Copyright (c) 2012 Jan Weiß: <http://www.geheimwerk.de>
 Some rights reserved: <http://opensource.org/licenses/mit-license.php>
 
 ***************************************************************************/

#import "syntaxTreeWalker.h"

#import "ORCSyntaxRange.h"
#import "JXMappedStringConverter.h"

static ORCSyntaxRangeType rangeTypeForDiscountType(int typ)
{
    switch (typ) {
        case WHITESPACE: return ORCSyntaxRangeTypeWhitespace;
        case CODE      : return ORCSyntaxRangeTypeVerbatim;
        case QUOTE     : return ORCSyntaxRangeTypeQuote;
        case MARKUP    : return ORCSyntaxRangeTypeMarkup;
        case HTML      : return ORCSyntaxRangeTypeHTML;
        case DL        : return ORCSyntaxRangeTypeDL;
        case UL        : return ORCSyntaxRangeTypeUL;
        case OL        : return ORCSyntaxRangeTypeOL;
        case LISTITEM  : return ORCSyntaxRangeTypeListItem;
        case HDR       : return ORCSyntaxRangeTypeHeader;
        case HR        : return ORCSyntaxRangeTypeHorizontalRow;
        case TABLE     : return ORCSyntaxRangeTypeTable;
        case SOURCE    : return ORCSyntaxRangeTypeRoot;
        case STYLE     : return ORCSyntaxRangeTypeStyle;
        default        : return ORCSyntaxRangeTypeUndefined;
    }
}

NS_INLINE void accumulateRangeForLine(Line *p, Range *range_p)
{
    if (range_p->location == IndexNotFound)  *range_p = p->range;
    for ( p = p->next; p ; p = p->next ) {
        range_p->length += p->range.length;
    }
}

NS_INLINE void accumulateRangeForParagraph(Paragraph *pp, Range *range_p)
{
    Line *p;
    while ( pp ) {
        p = pp->text;
        if ( p ) {
            accumulateRangeForLine(p, range_p);
        }
        pp = pp->down;
    }
}

NS_INLINE int maxRange(Range range) {
    return (range.location + range.length);
}

NS_INLINE void extendRangeToIncludeRange(Range *parent_range_p, Range range) {
    if (parent_range_p->location == IndexNotFound) {
        *parent_range_p = range;
    }
    else {
        parent_range_p->length = maxRange(range) - parent_range_p->location;
    }

}

void accumulateRangeForParagraphTree(Paragraph *pp, Range *parent_range_p)
{
    Line *line;
    
    while ( pp ) {
        line = pp->text;
        
        if ( line ) {
            accumulateRangeForLine(line, &(pp->range));
            extendRangeToIncludeRange(parent_range_p, pp->range);
        }
        
        Paragraph *first_child = pp->down;
        if ( first_child ) {
            accumulateRangeForParagraphTree(first_child, &(pp->range));
            extendRangeToIncludeRange(parent_range_p, first_child->range);
        }
        
        pp = pp->next;
    }
}

static void walkTree(Paragraph *pp, JXMappedStringConverter *stringConverter, ORCSyntaxRange *parentSyntaxRange)
{
    NSMutableArray *siblings = parentSyntaxRange.childRanges;
    
    while ( pp ) {
        ORCSyntaxRange *syntaxRange = nil;
        
        NSRange utf16Range;
        {
            Range range = pp->range;
            
            if ( range.location != IndexNotFound ) {
                NSRange utf8Range = NSMakeRange(range.location, range.length);
                utf16Range = [stringConverter UTF16RangeForUTF8Range:utf8Range];
            }
            else {
                utf16Range = NSMakeRange(NSNotFound, 0);
            }
        }
        
        ORCSyntaxRangeType type = rangeTypeForDiscountType(pp->typ);
        
        syntaxRange = [ORCSyntaxRange syntaxRangeWithRange:utf16Range
                                                syntaxType:type
                                               headerLevel:pp->hnumber];
        
        if ( syntaxRange ) {
            [siblings addObject:syntaxRange];
        }
        
        if ( pp->down ) {
            syntaxRange.childRanges = [NSMutableArray array];
            walkTree(pp->down, stringConverter, syntaxRange);
        }
        pp = pp->next;
    }
}

void syntaxTreeWalker(Document *doc, JXMappedStringConverter *stringConverter, ORCSyntaxRange **rootSyntaxRange)
{
    Paragraph *pp;
    for ( pp = doc->code; pp ; pp = pp->next ) {
        if ( pp->typ == SOURCE ) {
            ORCSyntaxRangeType type = rangeTypeForDiscountType(pp->typ);
            *rootSyntaxRange = [ORCSyntaxRange syntaxRangeWithRange:NSMakeRange(NSNotFound, 0)
                                                         syntaxType:type
                                                        headerLevel:0];
            (*rootSyntaxRange).childRanges = [NSMutableArray array];
            
            accumulateRangeForParagraphTree(pp->down, &(pp->range));
            walkTree(pp->down, stringConverter, *rootSyntaxRange);
            
            break;
        }
    }
}