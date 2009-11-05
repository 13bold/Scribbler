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
	return [self initWithTitle:nil artist:nil duration:0.0];
}
- (id)initWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration
{
	if (self = [super init])
	{
		[self setTitle:theTitle];
		[self setArtist:theArtist];
		[self setDuration:theDuration];
		
		timeLog = [[NSMutableArray alloc] init];
	}
	return self;
}
+ (id)track
{
	return [[[self alloc] init] autorelease];
}
+ (id)trackWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration
{
	return [[[self alloc] initWithTitle:theTitle artist:theArtist duration:theDuration] autorelease];
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
@synthesize duration;
@synthesize webService = lastfm;

#pragma mark Track control methods
- (void)play
{
	if ([timeLog count] > 0)
	{
		LFPlaySession *last = [timeLog lastObject];
		if (![last hasStopped])
			return;
	}
	
	LFPlaySession *play = [LFPlaySession session];
	[timeLog addObject:play];
}
- (void)pause
{
	if ([timeLog count] < 1)
		return;
	
	LFPlaySession *last = [timeLog lastObject];
	if (![last hasStopped])
		[last stop];
}
- (CGFloat)playingTime
{
	CGFloat total = 0.0;
	for (LFPlaySession *ps in timeLog)
		total += [ps length];
	return total;
}
- (void)stop
{
	[self stopAndScrobble:YES];
}
- (void)stopAndScrobble:(BOOL)shouldScrobble
{
	[self pause];
	if (shouldScrobble)
		[lastfm scrobbleTrackIfNecessary:self];
}

#pragma mark Track web service methods
- (void)love
{
	[lastfm loveTrack:self];
}
- (void)ban
{
	[lastfm banTrack:self];
}

@end
