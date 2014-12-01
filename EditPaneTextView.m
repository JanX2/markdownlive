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

NSString * const	kEditPaneTextViewChangedNotification		= @"EditPaneTextViewChangedNotification";
void *kEditPaneColorChangedNotification = &kEditPaneColorChangedNotification;

@implementation EditPaneTextView

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
	
	NSTextContainer *textContainer = [self textContainer];
	[textContainer setWidthTracksTextView:YES];
	layoutMan = [[EditPaneLayoutManager alloc] init];
	[textContainer replaceLayoutManager:layoutMan];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	
	[defaultsController removeObserver:self
							forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneForegroundColor]
							   context:kEditPaneColorChangedNotification];
	[defaultsController removeObserver:self
							forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneBackgroundColor]
							   context:kEditPaneColorChangedNotification];
	[defaultsController removeObserver:self
							forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneSelectionColor]
							   context:kEditPaneColorChangedNotification];
	[defaultsController removeObserver:self
							forKeyPath:[NSString stringWithFormat:@"values.%@", kEditPaneCaretColor]
							   context:kEditPaneColorChangedNotification];
}

- (void)keyDown:(NSEvent *)aEvent {
	[super keyDown:aEvent];
	[[NSNotificationCenter defaultCenter] postNotificationName:kEditPaneTextViewChangedNotification
														object:self];
}

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

- (void)updateColors {
	[[self enclosingScrollView] setBackgroundColor:[PreferencesManager editPaneBackgroundColor]];
	[self setTextColor:[PreferencesManager editPaneForegroundColor]];
	[self setInsertionPointColor:[PreferencesManager editPaneCaretColor]];
	NSDictionary *selectedAttr = [NSDictionary dictionaryWithObject:[PreferencesManager editPaneSelectionColor]
															 forKey:NSBackgroundColorAttributeName];
	[self setSelectedTextAttributes:selectedAttr];
}

- (void)updateFont {
	layoutMan.font = [PreferencesManager editPaneFont];
	[self setFont:layoutMan.font];
}

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

@end
