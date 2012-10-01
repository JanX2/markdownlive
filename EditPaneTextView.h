//
//  EditPaneTextView.h
//  MarkdownLive
//
//  Created by Akihiro Noguchi on 9/05/11.
//  Copyright 2011 Aki. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kEditPaneTextViewChangedNotification;

@class EditPaneLayoutManager;
@class ORCSyntaxRange;

@interface EditPaneTextView : NSTextView {
	//EditPaneLayoutManager *layoutMan;
	
	ORCSyntaxRange *_rootSyntaxRange;
	NSFont *_defaultFont;
	
    NSDictionary *_scheme;
    NSDictionary *_syntax;
}

@property (retain) NSDictionary *scheme;
@property (retain) NSDictionary *syntax;

#if ENABLE_NON_SYNTAX_HIGHLIGHTED_TEXT
- (void)updateColors;
#endif
- (void)updateFont;

#pragma mark - Highlighting
- (void)highlightWithRootSyntaxRange:(ORCSyntaxRange *)theRootSyntaxRange;

#if 0
- (void) highlight;
- (void) highlightRange:(NSRange)range content:(NSMutableAttributedString *)content;

#pragma mark - Scheme
- (void) loadScheme:(NSString *)schemeFilename;
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
