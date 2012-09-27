/*******************************************************************************
	discountWrapper.h - <http://github.com/rentzsch/MarkdownLive>
		Copyright (c) 2006-2011 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import <Foundation/Foundation.h>

@class ORCSyntaxRange;

NSString *discountToHTML(NSString *markdown, ORCSyntaxRange **rootSyntaxRange);