//
//  EditPaneTextView.m
//  MarkdownLive
//
//  Created by Akihiro Noguchi on 9/05/11.
//  Copyright 2011 Aki. All rights reserved.
//

#import "EditPaneTextView.h"
#import "EditPaneLayoutManager.h"
#import "PreferencesManager.h"
#import "PreferencesController.h"

#import "NSColor+colorWithCSSDefinition.h"
#import "ORCSyntaxRange.h"

NSString * const	kEditPaneTextViewChangedNotification		= @"EditPaneTextViewChangedNotification";
NSString * const	kEditPaneColorChangedNotification			= @"EditPaneColorChangedNotification";

@implementation EditPaneTextView

@synthesize scheme = _scheme;
@synthesize syntax = _syntax;

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateFont)
												 name:kEditPaneFontNameChangedNotification
											   object:nil];
	
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	
	[defaultsController addObserver:self
						 forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneForegroundColor]
							options:0
							context:kEditPaneColorChangedNotification];
	[defaultsController addObserver:self
						 forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneBackgroundColor]
							options:0
							context:kEditPaneColorChangedNotification];
	[defaultsController addObserver:self
						 forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneSelectionColor]
							options:0
							context:kEditPaneColorChangedNotification];
	[defaultsController addObserver:self
						 forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneCaretColor]
							options:0
							context:kEditPaneColorChangedNotification];
	
	[self setUsesFontPanel:NO];
	
#if 0
	NSTextContainer *textContainer = [self textContainer];
	[textContainer setWidthTracksTextView:YES];
	layoutMan = [[EditPaneLayoutManager alloc] init];
	[textContainer replaceLayoutManager:layoutMan];
#endif
	
	[self setTextContainerInset:NSMakeSize(10.0, 10.0)];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self];
}

#if 0
- (void)keyDown:(NSEvent *)aEvent {
	[super keyDown:aEvent];
	[[NSNotificationCenter defaultCenter] postNotificationName:(__bridge NSString *)(kEditPaneTextViewChangedNotification)
														object:self];
}
#endif

- (void)setMarkedText:(id)aString
		selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange {
	id resultString;
	if ([aString isKindOfClass:[NSAttributedString class]]) {
		resultString = [aString mutableCopy];
		selectedRange = NSMakeRange(0, [resultString length]);
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
							   [PreferencesManager editPaneForegroundColor], NSUnderlineColorAttributeName,
							   nil];
		[resultString setAttributes:attrs range:selectedRange];
	} else {
		resultString = aString;
	}
	
	[super setMarkedText:resultString
		   selectedRange:selectedRange replacementRange:replacementRange];
}

#if 0
- (void)updateColors {
	[[self enclosingScrollView] setBackgroundColor:[PreferencesManager editPaneBackgroundColor]];
	[self setTextColor:[PreferencesManager editPaneForegroundColor]];
	[self setInsertionPointColor:[PreferencesManager editPaneCaretColor]];
	NSDictionary *selectedAttr = [NSDictionary dictionaryWithObject:[PreferencesManager editPaneSelectionColor]
															 forKey:NSBackgroundColorAttributeName];
	[self setSelectedTextAttributes:selectedAttr];
}
#endif

- (void)updateFont {
	_defaultFont = [PreferencesManager editPaneFont];
	if (_defaultFont == nil)  return;
	//layoutMan.font = _defaultFont;
	[self setFont:_defaultFont];
	// FIXME: Rehighlight using _rootSyntaxRange
}

#if 0
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	
#pragma unused(keyPath)
#pragma unused(object)
#pragma unused(change)
	
	if (context == kEditPaneColorChangedNotification) {
		[self updateColors];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#endif




static void
highlightSyntaxRangeSubTree(ORCSyntaxRange *currentNode, NSDictionary *schemeDict, NSMutableAttributedString *text)
{
	NSArray *children = currentNode.childRanges;
	
	//NSFont *defaultFont = [schemeDict objectForKey:@"defaultFont"];
	NSFont *boldFont = [schemeDict objectForKey:@"boldFont"];
	
	for (ORCSyntaxRange *child in children) {
		// Highlight currentNode
		if (child.syntaxType == ORCSyntaxRangeTypeHeader) {
			[text addAttribute:NSFontAttributeName value:boldFont range:child.range];
		}
		else {
		}
		
		NSArray *childNodes = child.childRanges;
		if (childNodes != nil) {
			highlightSyntaxRangeSubTree(child, schemeDict, text);
		}
    }
}



- (void)highlightWithRootSyntaxRange:(ORCSyntaxRange *)theRootSyntaxRange
{
	if (theRootSyntaxRange == nil)  return;
	
    if (_rootSyntaxRange != theRootSyntaxRange) {
        [theRootSyntaxRange retain];
        [_rootSyntaxRange release];
        _rootSyntaxRange = theRootSyntaxRange;
		
		NSFontTraitMask boldTrait = NSBoldFontMask;
		NSFontManager *manager = [NSFontManager sharedFontManager];
		NSFont *boldFont = [manager convertFont:_defaultFont toHaveTrait:boldTrait];
		NSDictionary *schemeDict = [NSDictionary dictionaryWithObjectsAndKeys:
									_defaultFont, @"defaultFont",
									boldFont, @"boldFont",
									nil];
		
		NSMutableAttributedString *textStorage = [self textStorage];
		
		// Reset to basic formatting
		NSRange textStorageRange = NSMakeRange(0, textStorage.length);
		[textStorage addAttribute:NSFontAttributeName value:_defaultFont range:textStorageRange];
		[textStorage removeAttribute:NSForegroundColorAttributeName range:textStorageRange];
		[textStorage removeAttribute:NSBackgroundColorAttributeName range:textStorageRange];

		highlightSyntaxRangeSubTree(_rootSyntaxRange, schemeDict, textStorage);
    }
}



#if 0
#pragma mark - Scheme

- (void)loadScheme:(NSString *)schemeFilename {
    NSString *schemePath = [[NSBundle mainBundle] pathForResource:schemeFilename ofType:@"plist" inDirectory:nil];
    self.scheme = [NSDictionary dictionaryWithContentsOfFile:schemePath];
}

- (NSColor *)_colorFor:(NSString *)key {
    NSString *colorCode = [[self.scheme objectForKey:@"colors"] objectForKey:key];
    if (!colorCode)  return nil;
    NSColor *color = [NSColor colorWithCSSDefinition:colorCode];
    return color;
}

- (NSFont *)_font {
    return [self _fontOfSize:12 bold:NO];
}

- (NSFont *)_fontOfSize:(NSInteger)size bold:(BOOL)wantsBold {
    NSString *fontName = [self.scheme objectForKey:@"font"];
    NSFont *font = [NSFont fontWithName:fontName size:size];
    if (!font)  font = [NSFont systemFontOfSize:size];
    
    if (wantsBold) {
        NSFontTraitMask traits = NSBoldFontMask;
        NSFontManager *manager = [NSFontManager sharedFontManager];
        font = [manager fontWithFamily:fontName traits:traits weight:5.0 size:size];
    }
    
    return font;
}

- (NSInteger) _defaultSize {
    NSInteger defaultSize = [(NSNumber *)[self.scheme objectForKey:@"size"] integerValue];
    if (!defaultSize) defaultSize = 12;
    return defaultSize;
}

#pragma mark - Syntax

- (void)loadSyntax:(NSString *)syntaxFilename {
    NSString *schemePath = [[NSBundle mainBundle] pathForResource:syntaxFilename ofType:@"plist" inDirectory:nil];
    self.syntax = [NSDictionary dictionaryWithContentsOfFile:schemePath];
}

#pragma mark - Highlighting

- (void)highlight {
    NSColor *background = [self _colorFor:@"background"];
    NSInteger defaultSize = [self _defaultSize];
    NSFont *defaultFont = [self _fontOfSize:defaultSize bold:NO];
    [self setBackgroundColor:background];
    [(NSScrollView *)self.superview setBackgroundColor:background];
    [self setTextColor:[self _colorFor:@"default"]];
    [self setFont:defaultFont];
    
    NSMutableAttributedString *textStorage = [self textStorage];
    NSRange range = NSMakeRange(0, [textStorage length]);
    [self highlightRange:range content:textStorage];
}

- (void)highlightRange:(NSRange)range content:(NSMutableAttributedString *)content {
    NSColor *defaultColor = [self _colorFor:@"default"];
    NSInteger defaultSize = [self _defaultSize];
    NSFont *defaultFont = [self _fontOfSize:defaultSize bold:NO];
    [self _setFont:defaultFont range:range content:content];
    [self _setTextColor:defaultColor range:range content:content];
    [self _setBackgroundColor:[NSColor clearColor] range:range content:content];
    
    NSString *string = [content string];
    
    for (NSString *type in [self.syntax allKeys]) {
        NSDictionary *params = [self.syntax objectForKey:type];
        NSString *pattern = [params objectForKey:@"pattern"];
        NSString *colorName = [params objectForKey:@"color"];
        NSColor *color = [self _colorFor:colorName];
        NSString *backgroundColorName = [params objectForKey:@"backgroundColor"];
        NSColor *backgroundColor = [self _colorFor:backgroundColorName];
        NSInteger size = [(NSNumber *)[params objectForKey:@"size"] integerValue];
        BOOL isBold = [(NSNumber *)[params objectForKey:@"isBold"] boolValue];
        NSFont *font = [self _fontOfSize:(size ? size : defaultSize) bold:isBold];
        NSInteger patternGroup = [(NSNumber *)[params objectForKey:@"patternGroup"] integerValue];
        
        NSError *error = nil;
        NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines) error:&error]; // FIXME: We need to cache the compiled NSRegularExpression objects
        NSArray *matches = [expr matchesInString:string options:0 range:range];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = patternGroup ? [match rangeAtIndex:patternGroup] : [match range];
            [self _setTextColor:color range:range content:content];
            if (backgroundColor) {
				[self _setBackgroundColor:backgroundColor
									range:range
								  content:content];
			}
            [self _setFont:font range:range content:content];
        }
    }
}

#pragma mark - Changing text attributes

- (void) _setTextColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content {
    if (!color) return;
    [content addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void) _setBackgroundColor:(NSColor *)color range:(NSRange)range content:(NSMutableAttributedString *)content {
    [content addAttribute:NSBackgroundColorAttributeName value:color range:range];
}

- (void) _setFont:(NSFont *)font range:(NSRange)range content:(NSMutableAttributedString *)content {
    [content addAttribute:NSFontAttributeName value:font range:range];
}
#endif

#if 0
#pragma mark - Pasting

- (void)paste:(id)sender {
    [super paste:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:kEditPaneTextViewChangedNotification
														object:self];
}

- (void)cut:(id)sender {
    [super cut:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:kEditPaneTextViewChangedNotification
														object:self];
}
#endif



@end
