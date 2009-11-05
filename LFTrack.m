//
//  LFTrack.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LFTrack.h"
#import "LFWebService.h"
#import "LFPlaySession.h"


@implementation LFTrack

#pragma mark Initializers
- (id)init
{
	return [self initWithTitle:nil artist:nil];
}
- (id)initWithTitle:(NSString *)theTitle artist:(NSString *)theArtist
{
	if (self = [super init])
	{
		[self setTitle:theTitle];
		[self setArtist:theArtist];
		
		timeLog = [[NSMutableArray alloc] init];
	}
	return self;
}
+ (id)track
{
	return [[[self alloc] init] autorelease];
}
+ (id)trackWithTitle:(NSString *)theTitle artist:(NSString *)theArtist
{
	return [[[self alloc] initWithTitle:theTitle artist:theArtist] autorelease];
}

#pragma mark Deallocator
- (void)dealloc
{
	[title release];
	[artist release];
	[timeLog release];
	[super dealloc];
}

#pragma mark Properties
@synthesize title;
@synthesize artist;
@synthesize webService = lastfm;

#pragma mark Track control methods
- (void)play
{
}
- (void)pause
{
}
- (CGFloat)playingTime
{
	CGFloat total = 0.0;
	for (LFPlaySession *ps in timeLog)
		total += [ps length];
	return total;
}

#pragma mark Track attribute methods
- (void)love
{
}
- (void)ban
{
}

@end
