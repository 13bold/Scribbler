//
//  LFRequest.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LFRequest.h"
#import "LFTrack.h"


@implementation LFRequest

#pragma mark Initializers
- (id)init
{
	return [self initWithTrack:nil requestType:LFRequestUnknown];
}
- (id)initWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType
{
	if (self = [super init])
	{
		[self setTrack:theTrack];
		[self setType:theType];
	}
	return self;
}
+ (id)request
{
	return [[[self alloc] init] autorelease];
}
+ (id)requestWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType
{
	return [[[self alloc] initWithTrack:theTrack requestType:theType] autorelease];
}

#pragma mark Deallocator
- (void)dealloc
{
	[track release];
	[super dealloc];
}

#pragma mark Properties
@synthesize track;
@synthesize type;

@end
