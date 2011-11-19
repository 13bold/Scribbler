//
//  LFTrack.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/4/09.
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
		albumPosition = 0;
		
		lastfm = [LFWebService sharedWebService];
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
	[album release];
	[mbID release];
	[timeLog release];
	[super dealloc];
}

#pragma mark Properties
@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize albumPosition;
@synthesize duration;
@synthesize mbID;
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
	else
		[lastfm startPlayingTrack:self];
	
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
	return (total <= duration) ? total : duration;
}
- (void)setPlayingTime:(CGFloat)pTime
{
	[timeLog removeAllObjects];
	[self addPlayingTime:pTime];
}
- (void)addPlayingTime:(CGFloat)pTime
{
	LFPlaySession *ps = [LFPlaySession session];
	
	NSDate *now = [NSDate date];
	NSDate *then = [NSDate dateWithTimeIntervalSince1970:([now timeIntervalSince1970] - pTime)];
	[ps setStartTime:then];
	[ps setStopTime:now];
	[timeLog addObject:ps];
}
- (NSTimeInterval)startTime
{
	if ([timeLog count] < 1)
		return 0;
	
	LFPlaySession *ps = [timeLog objectAtIndex:0];
	return [[ps startTime] timeIntervalSince1970];
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
