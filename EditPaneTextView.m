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
#import "NSMutableArray+JXSparse.h"
#import "ORCSyntaxRange.h"

NSString * const	kEditPaneTextViewChangedNotification		= @"EditPaneTextViewChangedNotification";
NSString * const	kEditPaneColorChangedNotification			= @"EditPaneColorChangedNotification";

@implementation EditPaneTextView

@synthesize schemeDict = _schemeDict;
@synthesize schemeArray = _schemeArray;
//@synthesize syntax = _syntax;

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
	[_schemeDict release];
    [_schemeArray release];
	//[_schemeData release];
	
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

	[self updateSchemeArray];
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




void applyAttributesFromArrayIndexToTextRange(NSArray *array, NSUInteger index, NSMutableAttributedString *text, NSRange range)
{
    NSDictionary *typeDict = [array jx_objectOrNilAtIndex:index];
    if (typeDict != nil) {
        NSFont *font = [typeDict objectForKey:@"font"];
        NSColor *color = [typeDict objectForKey:@"color"];
        NSColor *backgroundColor = [typeDict objectForKey:@"backgroundColor"];
        
        if (font != nil)  [text addAttribute:NSFontAttributeName value:font range:range];
        if (color != nil)  [text addAttribute:NSForegroundColorAttributeName value:color range:range];
        if (backgroundColor != nil)  [text addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
    }
}

static void
highlightSyntaxRangeSubTree(ORCSyntaxRange *currentNode, NSArray *schemeArray, NSMutableAttributedString *text)
{
	NSArray *children = currentNode.childRanges;
	
	for (ORCSyntaxRange *child in children) {
		// Highlight currentNode
		ORCSyntaxRangeType syntaxType = child.syntaxType;
		if (syntaxType == ORCSyntaxRangeTypeHeader) {
			NSArray *headerArray = [schemeArray jx_objectOrNilAtIndex:syntaxType];
			if (headerArray != nil) {
				applyAttributesFromArrayIndexToTextRange(headerArray, child.headerLevel, text, child.range);
			}
		}
		else {
			applyAttributesFromArrayIndexToTextRange(schemeArray, syntaxType, text, child.range);
		}
		
		NSArray *childNodes = child.childRanges;
		if (childNodes != nil) {
			highlightSyntaxRangeSubTree(child, schemeArray, text);
		}
	}
}

- (void)updateHighlight;
{
	NSMutableAttributedString *textStorage = [self textStorage];
	if (textStorage.length == 0)  return;
	
	[textStorage beginEditing];

	// Reset to default formatting
	NSDictionary *typeDict = [_schemeArray jx_objectOrNilAtIndex:ORCSyntaxRangeTypeDefault];
	if (typeDict != nil) {
		NSFont *font = [typeDict objectForKey:@"font"];
		NSColor *color = [typeDict objectForKey:@"color"];
		NSColor *backgroundColor = [typeDict objectForKey:@"backgroundColor"];
		NSColor *cursorColor = [typeDict objectForKey:@"cursorColor"];
		
		if (font != nil)  [self setFont:font];
		if (color != nil)  [self setTextColor:color];
		if (backgroundColor != nil) {
			[self setBackgroundColor:backgroundColor];
			[(NSScrollView *)self.superview setBackgroundColor:backgroundColor];
		}
		if (cursorColor != nil)  [self setInsertionPointColor:cursorColor];
	}
	
	highlightSyntaxRangeSubTree(_rootSyntaxRange, _schemeArray, textStorage);
	
	[textStorage endEditing];
}

- (void)highlightWithRootSyntaxRange:(ORCSyntaxRange *)theRootSyntaxRange
{
	if (theRootSyntaxRange == nil)  return;
	
    if (_rootSyntaxRange != theRootSyntaxRange) {
        [theRootSyntaxRange retain];
        [_rootSyntaxRange release];
        _rootSyntaxRange = theRootSyntaxRange;
		
		[self updateHighlight];
    }
}



#pragma mark - Scheme

NSDictionary * typeDictFor(ORCSyntaxRangeType type, int headerLevel, NSFont *baseFont, NSDictionary *colorsDict, NSDictionary *scheme) {
	NSString *typeName = [ORCSyntaxRange syntaxTypeNameForRangeType:type
														headerLevel:headerLevel];
	
	NSMutableDictionary *dictForType = [[scheme objectForKey:typeName] mutableCopy];
	
	// Swap color names with NSColor objects.
	NSString *colorKeys[] = {@"color", @"backgroundColor", @"cursorColor"};
	NSUInteger colorKeysCount = sizeof(colorKeys)/sizeof(colorKeys[0]);
	for (NSUInteger i = 0; i < colorKeysCount; i++) {
		NSString *colorKey = colorKeys[i];
		NSString *colorName = [dictForType objectForKey:colorKey];
		NSColor *color = [colorsDict objectForKey:colorName];
		if (color == nil)  continue;
		[dictForType setObject:color forKey:colorKey];
	}
	
	// Modify base font according to scheme
	NSNumber *fontSizeNumber = [dictForType objectForKey:@"size"];
	NSNumber *isBoldNumber = [dictForType objectForKey:@"isBold"];
	NSNumber *isItalicNumber = [dictForType objectForKey:@"isItalic"];
	NSNumber *isMonospacedNumber = [dictForType objectForKey:@"isMonospaced"];
	
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font = baseFont;
	
	CGFloat defaultFontSize;
	NSNumber *defaultFontSizeNumber = [[scheme objectForKey:@"default"] objectForKey:@"size"];
	if (defaultFontSizeNumber != nil) {
		defaultFontSize = [defaultFontSizeNumber doubleValue];
	}
	else {
		defaultFontSize = baseFont.pointSize;
	}

	CGFloat fontSize = defaultFontSize;
	if (fontSizeNumber != nil) {
		fontSize = [fontSizeNumber doubleValue];
		
		// Scale base font size according to relative font size compared to default size.
		// This way, the user can change the font size and the scheme settings will scale accordingly. 
		fontSize = (fontSize/defaultFontSize) * baseFont.pointSize;
		
		font = [fontManager convertFont:font
								 toSize:fontSize];
	}
	
	if (isMonospacedNumber != nil) {
		BOOL isMonospaced = [isMonospacedNumber boolValue];
		// FIXME: This is a bit crude. We should allow the user to select a monospaced/proportional font pair (like TextEdit). 
		if (isMonospaced) {
			// FIXME: Apparenty, this doesn’t work, because most fonts don’t know that they are monospaced even though they are.
			if (!([fontManager traitsOfFont:font] & NSFixedPitchFontMask)) {
				font = [fontManager convertFont:font
									   toFamily:@"Menlo"];
				if (font == nil)  font = [NSFont userFixedPitchFontOfSize:fontSize];
			}
		} else {
			// FIXME: See above.
			if (([fontManager traitsOfFont:font] & NSFixedPitchFontMask)) {
				font = [fontManager convertFont:font
									   toFamily:@"Helvetica"];
				if (font == nil)  font = [NSFont userFontOfSize:fontSize];
			}
		}
	}
	
	if (isBoldNumber != nil) {
		BOOL isBold = [isBoldNumber boolValue];
		font = [fontManager convertFont:font
							toHaveTrait:(isBold ? NSBoldFontMask : NSUnboldFontMask)];
	}
	
	if (isItalicNumber != nil) {
		BOOL isItalic = [isItalicNumber boolValue];
		font = [fontManager convertFont:font
							toHaveTrait:(isItalic ? NSItalicFontMask : NSUnitalicFontMask)];
	}
	
	if (font != nil) {
		[dictForType setObject:font forKey:@"font"];
	}
	
	return dictForType;
}

- (void)loadScheme:(NSString *)schemeFilename {
    NSString *schemePath = [[NSBundle mainBundle] pathForResource:schemeFilename ofType:@"plist" inDirectory:nil];
    self.schemeDict = [NSDictionary dictionaryWithContentsOfFile:schemePath];
	//[self updateSchemeArray];
}

- (void)updateSchemeArray;
{
	NSDictionary *colorsBaseDict = [_schemeDict objectForKey:@"colors"];
	NSMutableDictionary *colorsDict = [NSMutableDictionary dictionaryWithCapacity:colorsBaseDict.count];
	
	[colorsBaseDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *colorCode, BOOL *stop) {
		NSColor *color = [NSColor colorWithCSSDefinition:colorCode];
		if (color == nil)  return;
		[colorsDict setObject:color forKey:key];
	}];
	//NSLog(@"\n%@", colorsDict);
	
	ORCSyntaxRangeType typeCount = ORCSyntaxRangeTypeCount;
	NSMutableArray *schemeArray = [NSMutableArray arrayWithCapacity:typeCount];
	int maxHeaderLevel = 6;
	for (ORCSyntaxRangeType type = 0; type < typeCount; type++) {
		if (type == ORCSyntaxRangeTypeHeader) {
			NSMutableArray *headerArray = [NSMutableArray arrayWithCapacity:maxHeaderLevel+1];
			for (int headerLevel = 1; headerLevel <= maxHeaderLevel; headerLevel++) {
				NSDictionary *dictForType = typeDictFor(type, headerLevel, _defaultFont, colorsDict, _schemeDict);
				[headerArray jx_setObject:dictForType atIndex:headerLevel];
			}
			[schemeArray jx_setObject:headerArray atIndex:type];
		}
		else {
			NSDictionary *dictForType = typeDictFor(type, 0, _defaultFont, colorsDict, _schemeDict);
			[schemeArray jx_setObject:dictForType atIndex:type];
		}
	}
	
	//NSLog(@"\n%@", schemeArray);
	
	self.schemeArray = schemeArray;

	[self updateHighlight];
}

@end
