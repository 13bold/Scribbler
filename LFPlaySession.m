//
//  LFPlaySession.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
	return [[[self alloc] init] autorelease];
}
+ (id)sessionWithStartTime:(NSDate *)theTime
{
	return [[[self alloc] initWithStartTime:theTime] autorelease];
}

#pragma mark Deallocator
- (void)dealloc
{
	[startTime release];
	[stopTime release];
	[super dealloc];
}

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
