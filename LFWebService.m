//
//  LFWebService.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 {13bold}. All rights reserved.
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

#import "LFWebService.h"
#import "LFTrack.h"
#import "LFRequest.h"


@implementation LFWebService

#pragma mark Initializers
- (id)init
{
	if (self = [super init])
	{
		clientID = @"tst";
		requestQueue = [[NSMutableArray alloc] init];
		
		runningRequest = NO;
	}
	return self;
}
+ (id)sharedWebService
{
	static id __sharedLFWebService = nil;
	if (!__sharedLFWebService)
		__sharedLFWebService = [[self alloc] init];
	return __sharedLFWebService;
}

#pragma mark Deallocator
- (void)dealloc
{
	[APIKey release];
	[sharedSecret release];
	[clientID release];
	[sessionKey release];
	[currentTrack release];
	[requestQueue release];
	[super dealloc];
}

#pragma mark Properties
@synthesize delegate;
@synthesize APIKey;
@synthesize sharedSecret;
@synthesize clientID;
@synthesize sessionKey;
@synthesize currentTrack;

#pragma mark Session methods
- (void)establishNewSession
{
}

#pragma mark Track methods
- (void)startPlayingTrack:(LFTrack *)theTrack
{
}
- (void)scrobbleTrackIfNecessary:(LFTrack *)theTrack
{
}
- (void)loveTrack:(LFTrack *)theTrack
{
	LFRequest *theRequest = [LFRequest requestWithTrack:theTrack requestType:LFRequestLove];
	[requestQueue addObject:theRequest];
	[self dispatchNextRequestIfPossible];
}
- (void)banTrack:(LFTrack *)theTrack
{
	LFRequest *theRequest = [LFRequest requestWithTrack:theTrack requestType:LFRequestBan];
	[requestQueue addObject:theRequest];
	[self dispatchNextRequestIfPossible];
}

#pragma mark Web service methods
- (void)dispatchNextRequestIfPossible
{
	if (!runningRequest && [requestQueue count] > 0)
	{
		LFRequest *nextRequest = [requestQueue objectAtIndex:0];
		runningRequest = YES;
		[nextRequest setDelegate:self];
		[nextRequest dispatch];
	}
}

#pragma mark Request callback methods
- (void)requestSucceeded:(LFRequest *)theRequest
{
}
- (void)request:(LFRequest *)theRequest failedWithError:(NSError *)theError
{
	[theRequest setDelegate:nil];
}

@end
