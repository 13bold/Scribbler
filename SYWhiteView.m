//
//  SYWhiteView.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SYWhiteView.h"


@implementation SYWhiteView

#pragma mark Drawing methods
- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor whiteColor] set];
	NSRectFill(dirtyRect);
}

@end
