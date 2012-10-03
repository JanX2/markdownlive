//
//  EditPaneTextView.h
//  MarkdownLive
//
//  Created by Akihiro Noguchi on 9/05/11.
//  Copyright 2011 Aki. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void *kEditPaneTextViewChangedNotification;

@class EditPaneLayoutManager;
@class ORCSyntaxRange;

@interface EditPaneTextView : NSTextView {
	//EditPaneLayoutManager *layoutMan;
	
	ORCSyntaxRange *_rootSyntaxRange;
	NSFont *_defaultFont;
	
    //NSMutableData *_schemeData;
    NSDictionary *_schemeDict;
    NSArray *_schemeArray;
    //NSDictionary *_syntax;
}

@property (retain) NSDictionary *schemeDict;
@property (retain) NSArray *schemeArray;
//@property (retain) NSDictionary *syntax;

#if ENABLE_NON_SYNTAX_HIGHLIGHTED_TEXT
- (void)updateColors;
#endif
- (void)updateFont;

#pragma mark - Highlighting
- (void)highlightWithRootSyntaxRange:(ORCSyntaxRange *)theRootSyntaxRange;

#if 0
- (void) highlight;
- (void) highlightRange:(NSRange)range content:(NSMutableAttributedString *)content;
#endif

#pragma mark - Scheme
- (void) loadScheme:(NSString *)schemeFilename;
#if 0
- (NSColor *) _colorFor:(NSString *)key;
- (NSFont *) _font;
- (NSFont *) _fontOfSize:(NSInteger)size bold:(BOOL)wantsBold;
- (NSInteger) _defaultSize;

#pragma mark - Syntax
- (void) loadSyntax:(NSString *)syntaxFilename;

#pragma mark - Changing text attributes
- (void) _setTextColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content;
- (void) _setBackgroundColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content;
- (void) _setFont:(NSFont *)font range:(NSRange)range content:(NSMutableAttributedString *)content;
#endif

@end
