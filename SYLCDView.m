//
//  SYLCDView.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright (C) 2009 {13bold}.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SYLCDView.h"


@implementation SYLCDView

#pragma mark Drawing methods
- (void)drawRect:(NSRect)dirtyRect
{
	// I'm feeling lazy; please ignore the inefficiency
	NSRect bounds = [self bounds];
	
	[[NSImage imageNamed:@"lcd"] drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	// icons
	NSRect iconRect = NSMakeRect(0.0, 0.0, 20.0, 17.0);
	iconRect.origin.x = bounds.size.width - 28.0;
	iconRect.origin.y = 28.0;
	[[NSImage imageNamed:@"lcd-love"] drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.1];
	
	iconRect.origin.y = 10.0;
	[[NSImage imageNamed:@"lcd-ban"] drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.1];
}

@end
