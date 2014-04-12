//
//  LFPlaySession.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/5/09.
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

#import "LFPlaySession.h"


@implementation LFPlaySession

#pragma mark Initializers
- (id)init
{
	return [self initWithStartTime:nil];
}
- (id)initWithStartTime:(NSDate *)theTime
{
	if (self = [super init])
	{
		if (!theTime)
			theTime = [NSDate date];
		
		[self setStartTime:theTime];
	}
	return self;
}
+ (id)session
{
	return [[self alloc] init];
}
+ (id)sessionWithStartTime:(NSDate *)theTime
{
	return [[self alloc] initWithStartTime:theTime];
}

#pragma mark Deallocator

#pragma mark Properties
@synthesize startTime;
@synthesize stopTime;

#pragma mark Control methods
- (void)start
{
	[self setStartTime:[NSDate date]];
}
- (void)stop
{
	[self setStopTime:[NSDate date]];
}
- (BOOL)hasStopped
{
	return (stopTime != nil);
}

#pragma mark Status methods
- (CGFloat)length
{
	NSDate *s = (startTime != nil) ? startTime : [NSDate date];
	NSDate *e = (stopTime != nil) ? stopTime : [NSDate date];
	return (CGFloat)[e timeIntervalSinceDate:s];
}

@end
