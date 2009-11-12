//
//  SYLCDView.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SYLCDView.h"


@implementation SYLCDView

#pragma mark Drawing methods
- (void)drawRect:(NSRect)dirtyRect
{
	// I'm feeling lazy; please ignore the inefficiency
	dirtyRect = [self bounds];
	
	[[NSImage imageNamed:@"lcd"] drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
