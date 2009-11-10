//
//  LFWebService.m
//  Last.fm
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

#import "LFWebService.h"
#import "LFWebServiceDelegate.h"
#import "LFWebServicePrivate.h"
#import "LFTrack.h"
#import "LFRequest.h"
#import "LFRequestTypes.h"


@implementation LFWebService

#pragma mark Initializers
- (id)init
{
	if (self = [super init])
	{
		clientID = @"tst";
		clientVersion = @"1.0";
		requestQueue = [[NSMutableArray alloc] init];
		
		runningRequest = NO;
		autoScrobble = YES;
		handshakeInProgress = NO;
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
	[clientVersion release];
	[sessionUser release];
	[sessionKey release];
	[scrobbleSessionID release];
	[scrobbleNPURL release];
	[scrobbleSubmissionURL release];
	[currentTrack release];
	[requestQueue release];
	[queueTimer release];
	[super dealloc];
}

#pragma mark Properties
@synthesize delegate;
@synthesize APIKey;
@synthesize sharedSecret;
@synthesize clientID;
@synthesize clientVersion;
@synthesize sessionKey;
@synthesize sessionUser;
@synthesize scrobbleSessionID;
@synthesize scrobbleNPURL;
@synthesize scrobbleSubmissionURL;
@synthesize autoScrobble;
@synthesize currentTrack;

#pragma mark Session methods (new sessions)
- (NSString *)establishNewSession
{
	if (pendingToken)
	{
		[pendingToken release];
		pendingToken = nil;
	}
	
	LFGetTokenRequest *theRequest = [LFGetTokenRequest request];
	[requestQueue insertObject:theRequest atIndex:0];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}
- (NSString *)finishSessionAuthorization
{
	if (!pendingToken)
	{
		NSLog(@"Last.fm.framework: warning, session authorization was not pending");
		return nil;
	}
	
	LFGetSessionRequest *theRequest = [LFGetSessionRequest request];
	[theRequest setToken:pendingToken];
	[requestQueue insertObject:theRequest atIndex:0];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}

#pragma mark Session methods (existing sessions)
- (NSString *)validateSessionCredentials
{
	LFValidateSessionRequest *theRequest = [LFValidateSessionRequest request];
	[requestQueue insertObject:theRequest atIndex:0];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}

#pragma mark Scrobbler methods
- (NSString *)performScrobblerHandshake
{
	handshakeInProgress = YES;
	
	LFScrobblerHandshakeRequest *theRequest = [LFScrobblerHandshakeRequest request];
	[requestQueue insertObject:theRequest atIndex:0];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}

#pragma mark Track methods
- (NSString *)startPlayingTrack:(LFTrack *)theTrack
{
	if (!scrobbleSessionID && !handshakeInProgress)
		[self performScrobblerHandshake];
	
	if (autoScrobble && currentTrack)
		[currentTrack stop];
	
	if (currentTrack)
	{
		[currentTrack release];
		currentTrack = nil;
	}
	currentTrack = [theTrack retain];
	
	if (!theTrack)
		return nil;
	
	LFNowPlayingRequest *theRequest = [LFNowPlayingRequest requestWithTrack:theTrack];
	[requestQueue addObject:theRequest];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}
- (NSString *)scrobbleTrackIfNecessary:(LFTrack *)theTrack
{
	if (!scrobbleSessionID && !handshakeInProgress)
		[self performScrobblerHandshake];
	
	if (!theTrack)
	{
		if (currentTrack)
			theTrack = currentTrack;
		else
			return nil;
	}
	
	// track must be longer than 30 seconds, and it must
	// have played for either greater than 240 seconds, or
	// greater than half its length, whichever comes first
	if ([theTrack duration] > 30.0 && ([theTrack playingTime] > 240.0 || [theTrack playingTime] > ([theTrack duration] / 2.0)))
	{
		LFScrobbleRequest *theRequest = [LFScrobbleRequest requestWithTrack:theTrack];
		[requestQueue addObject:theRequest];
		[self dispatchNextRequestIfPossible];
		
		if (currentTrack)
		{
			[currentTrack release];
			currentTrack = nil;
		}
		
		return [theRequest identifier];
	}
	return nil;
}
- (NSString *)loveTrack:(LFTrack *)theTrack
{
	if (!theTrack)
	{
		if (currentTrack)
			theTrack = currentTrack;
		else
			return nil;
	}
	
	LFLoveRequest *theRequest = [LFLoveRequest requestWithTrack:theTrack];
	[requestQueue addObject:theRequest];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}
- (NSString *)banTrack:(LFTrack *)theTrack
{
	if (!theTrack)
	{
		if (currentTrack)
			theTrack = currentTrack;
		else
			return nil;
	}
	
	LFBanRequest *theRequest = [LFBanRequest requestWithTrack:theTrack];
	[requestQueue addObject:theRequest];
	[self dispatchNextRequestIfPossible];
	return [theRequest identifier];
}

#pragma mark Web service methods
- (void)dispatchNextRequestIfPossible
{
	if (!runningRequest && [requestQueue count] > 0)
	{
		if (queueTimer)
		{
			[queueTimer invalidate];
			[queueTimer release];
			queueTimer = nil;
		}
		
		LFRequest *nextRequest = [requestQueue objectAtIndex:0];
		
		if (([nextRequest requestType] != LFRequestGetToken && [nextRequest requestType] != LFRequestGetSession) && sessionKey == nil)
			return;
		
		runningRequest = YES;
		[nextRequest setDelegate:self];
		[nextRequest dispatch];
	}
}
- (void)dispatchTimerCalled:(NSTimer *)theTimer
{
	[self dispatchNextRequestIfPossible];
}

#pragma mark Request callback methods
- (void)requestSucceeded:(LFRequest *)theRequest
{
	runningRequest = NO;
	BOOL shouldProceed = NO;
	
	if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
		[delegate requestSucceeded:[theRequest identifier]];
	
	LFRequestType r = [theRequest requestType];
	if (r == LFRequestNowPlaying)
	{
		if (delegate && [delegate respondsToSelector:@selector(nowPlayingSucceededForTrack:)])
			[delegate nowPlayingSucceededForTrack:[theRequest track]];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestScrobble)
	{
		if (delegate && [delegate respondsToSelector:@selector(scrobbleSucceededForTrack:)])
			[delegate scrobbleSucceededForTrack:[theRequest track]];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestLove)
	{
		if (delegate && [delegate respondsToSelector:@selector(loveSucceededForTrack:)])
			[delegate loveSucceededForTrack:[theRequest track]];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestBan)
	{
		if (delegate && [delegate respondsToSelector:@selector(banSucceededForTrack:)])
			[delegate banSucceededForTrack:[theRequest track]];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestGetToken)
	{
		if (pendingToken)
		{
			[pendingToken release];
			pendingToken = nil;
		}
		
		pendingToken = [[(LFGetTokenRequest *)theRequest token] copy];
		
		NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://last.fm/api/auth?api_key=%@&token=%@", APIKey, pendingToken]];
		
		if (delegate && [delegate respondsToSelector:@selector(sessionNeedsAuthorizationViaURL:)])
			[delegate sessionNeedsAuthorizationViaURL:authURL];
		else
			[[NSWorkspace sharedWorkspace] openURL:authURL];
	}
	else if (r == LFRequestGetSession)
	{
		if (pendingToken)
		{
			[pendingToken release];
			pendingToken = nil;
		}
		
		if (sessionUser)
		{
			[sessionUser release];
			sessionUser = nil;
		}
		sessionUser = [[(LFGetSessionRequest *)theRequest sessionUser] copy];
		
		if (sessionKey)
		{
			[sessionKey release];
			sessionKey = nil;
		}
		sessionKey = [[(LFGetSessionRequest *)theRequest sessionKey] copy];
		
		if (delegate && [delegate respondsToSelector:@selector(sessionCreatedWithKey:user:)])
			[delegate sessionCreatedWithKey:sessionKey user:sessionUser];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestValidateSession)
	{
		if (delegate && [delegate respondsToSelector:@selector(sessionValidatedForUser:)])
			[delegate sessionValidatedForUser:sessionUser];
		
		shouldProceed = YES;
	}
	else if (r == LFRequestScrobblerHandshake)
	{
		handshakeInProgress = NO;
		
		if (scrobbleSessionID)
		{
			[scrobbleSessionID release];
			scrobbleSessionID = nil;
		}
		scrobbleSessionID = [[(LFScrobblerHandshakeRequest *)theRequest sessionID] copy];
		
		if (scrobbleNPURL)
		{
			[scrobbleNPURL release];
			scrobbleNPURL = nil;
		}
		scrobbleNPURL = [[(LFScrobblerHandshakeRequest *)theRequest nowPlayingURL] copy];
		
		if (scrobbleSubmissionURL)
		{
			[scrobbleSubmissionURL release];
			scrobbleSubmissionURL = nil;
		}
		scrobbleSubmissionURL = [[(LFScrobblerHandshakeRequest *)theRequest submissionURL] copy];
		
		if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeSucceeded)])
			[delegate scrobblerHandshakeSucceeded];
		
		shouldProceed = YES;
	}
	else
		shouldProceed = YES;
	
	[requestQueue removeObject:theRequest];
	if (shouldProceed)
		[self dispatchNextRequestIfPossible];
	else
	{
		if (queueTimer)
		{
			[queueTimer invalidate];
			[queueTimer release];
			queueTimer = nil;
		}
		queueTimer = [[NSTimer scheduledTimerWithTimeInterval:150.0 target:self selector:@selector(dispatchTimerCalled:) userInfo:nil repeats:NO] retain];
	}
}
- (void)request:(LFRequest *)theRequest failedWithError:(NSError *)theError
{
	runningRequest = NO;
	BOOL shouldProceed = NO;
	
	if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
		[delegate request:[theRequest identifier] failedWithError:theError];
	
	[theRequest setDelegate:nil];
	
	// if it's a "try again" type error, leave it in the queue, redispatch
	// if it's not a communication error, but it's a "this request will never work" error, remove, dispatch
	// if it's a communication error, leave it in the queue, but don't dispatch
	
	LFRequestType r = [theRequest requestType];
	if (r == LFRequestNowPlaying)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"])
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(nowPlayingFailedForTrack:error:willRetry:)])
				[delegate nowPlayingFailedForTrack:[theRequest track] error:theError willRetry:YES];
		}
		else
		{
			// this means we need to rehandshake, so add a handshake to the front of
			// the queue, and being redispatching
			
			if (delegate && [delegate respondsToSelector:@selector(nowPlayingFailedForTrack:error:willRetry:)])
				[delegate nowPlayingFailedForTrack:[theRequest track] error:theError willRetry:YES];
			
			LFScrobblerHandshakeRequest *theRequest = [LFScrobblerHandshakeRequest request];
			[requestQueue insertObject:theRequest atIndex:0];
			handshakeInProgress = YES;
			shouldProceed = YES;
		}
	}
	else if (r == LFRequestScrobble)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"])
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(scrobbleFailedForTrack:error:willRetry:)])
				[delegate scrobbleFailedForTrack:[theRequest track] error:theError willRetry:YES];
		}
		else
		{
			// 1 = BADSESSION, 2 = FAILED <reason>
			// if this is a badsession, rehandshake and begin redispatching
			// otherwise, halt redispatching but leave in queue
			
			if (delegate && [delegate respondsToSelector:@selector(scrobbleFailedForTrack:error:willRetry:)])
				[delegate scrobbleFailedForTrack:[theRequest track] error:theError willRetry:YES];
			
			if ([theError code] == 1)
			{
				LFScrobblerHandshakeRequest *theRequest = [LFScrobblerHandshakeRequest request];
				[requestQueue insertObject:theRequest atIndex:0];
				handshakeInProgress = YES;
				shouldProceed = YES;
			}
		}
	}
	else if (r == LFRequestLove)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"])
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(loveFailedForTrack:error:willRetry:)])
				[delegate loveFailedForTrack:[theRequest track] error:theError willRetry:YES];
		}
		else
		{
			if ([theError code] == 6)	// invalid track name
			{
				if (delegate && [delegate respondsToSelector:@selector(loveFailedForTrack:error:willRetry:)])
					[delegate loveFailedForTrack:[theRequest track] error:theError willRetry:NO];
				
				[requestQueue removeObject:theRequest];
				shouldProceed = YES;
			}
			else if ([theError code] == 9)	// invalid session key
			{
				if (delegate && [delegate respondsToSelector:@selector(loveFailedForTrack:error:willRetry:)])
					[delegate loveFailedForTrack:[theRequest track] error:theError willRetry:YES];
				
				// session key was revoked
				if (delegate && [delegate respondsToSelector:@selector(sessionKeyRevoked:forUser:)])
					[delegate sessionKeyRevoked:sessionKey forUser:sessionUser];
			}
			else
			{
				// halt redispatching, try later
				if (delegate && [delegate respondsToSelector:@selector(loveFailedForTrack:error:willRetry:)])
					[delegate loveFailedForTrack:[theRequest track] error:theError willRetry:YES];
			}
		}
	}
	else if (r == LFRequestBan)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"])
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(banFailedForTrack:error:willRetry:)])
				[delegate banFailedForTrack:[theRequest track] error:theError willRetry:YES];
		}
		else
		{
			if ([theError code] == 6)	// invalid track name
			{
				if (delegate && [delegate respondsToSelector:@selector(banFailedForTrack:error:willRetry:)])
					[delegate banFailedForTrack:[theRequest track] error:theError willRetry:NO];
				
				[requestQueue removeObject:theRequest];
				shouldProceed = YES;
			}
			else if ([theError code] == 9)	// invalid session key
			{
				if (delegate && [delegate respondsToSelector:@selector(banFailedForTrack:error:willRetry:)])
					[delegate banFailedForTrack:[theRequest track] error:theError willRetry:YES];
				
				// session key was revoked
				if (delegate && [delegate respondsToSelector:@selector(sessionKeyRevoked:forUser:)])
					[delegate sessionKeyRevoked:sessionKey forUser:sessionUser];
			}
			else
			{
				// halt redispatching, try later
				if (delegate && [delegate respondsToSelector:@selector(banFailedForTrack:error:willRetry:)])
					[delegate banFailedForTrack:[theRequest track] error:theError willRetry:YES];
			}
		}
	}
	else if (r == LFRequestGetToken)
	{
		// we'll just try again later on this one
		if (delegate && [delegate respondsToSelector:@selector(sessionRequestCouldNotBeMade)])
			[delegate sessionRequestCouldNotBeMade];
	}
	else if (r == LFRequestGetSession)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"] || [theError code] != 14)
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(sessionAuthorizationFailed)])
				[delegate sessionAuthorizationFailed];
		}
		else if ([theError code] == 14)	// token not yet authorized
		{
			if (delegate && [delegate respondsToSelector:@selector(sessionAuthorizationStillPending)])
				[delegate sessionAuthorizationStillPending];
		}
		
		[requestQueue removeObject:theRequest];
	}
	else if (r == LFRequestValidateSession)
	{
		if (delegate && [delegate respondsToSelector:@selector(sessionInvalidForUser:)])
			[delegate sessionInvalidForUser:sessionUser];
		
		if ([[theError domain] isEqualToString:@"Last.fm"])	// eg, not a communication error
		{
			// session key was revoked
			if (delegate && [delegate respondsToSelector:@selector(sessionKeyRevoked:forUser:)])
				[delegate sessionKeyRevoked:sessionKey forUser:sessionUser];
		}
		
		[requestQueue removeObject:theRequest];
	}
	else if (r == LFRequestScrobblerHandshake)
	{
		if (![[theError domain] isEqualToString:@"Last.fm"])
		{
			NSLog(@"Last.fm.framework: error, %@", [theError localizedDescription]);
			if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeFailed:willRetry:)])
				[delegate scrobblerHandshakeFailed:theError willRetry:YES];
		}
		else
		{
			// 1 = BANNED, 2 = BADAUTH, 3 = BADTIME, 4 = FAILED <reason>
			switch ([theError code])
			{
				case 1:
					if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeFailed:willRetry:)])
						[delegate scrobblerHandshakeFailed:theError willRetry:NO];
					if (delegate && [delegate respondsToSelector:@selector(scrobblerClient:bannedForVersion:)])
						[delegate scrobblerClient:clientID bannedForVersion:clientVersion];
					[requestQueue removeObject:theRequest];
					handshakeInProgress = NO;
					break;
					
				case 2:
					if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeFailed:willRetry:)])
						[delegate scrobblerHandshakeFailed:theError willRetry:NO];
					// session key was revoked
					if (delegate && [delegate respondsToSelector:@selector(sessionKeyRevoked:forUser:)])
						[delegate sessionKeyRevoked:sessionKey forUser:sessionUser];
					[requestQueue removeObject:theRequest];
					handshakeInProgress = NO;
					break;
					
				case 3:
					if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeFailed:willRetry:)])
						[delegate scrobblerHandshakeFailed:theError willRetry:NO];
					if (delegate && [delegate respondsToSelector:@selector(scrobblerRejectedSystemTime)])
						[delegate scrobblerRejectedSystemTime];
					[requestQueue removeObject:theRequest];
					handshakeInProgress = NO;
					break;
					
				case 4:
				default:
					if (delegate && [delegate respondsToSelector:@selector(scrobblerHandshakeFailed:willRetry:)])
						[delegate scrobblerHandshakeFailed:theError willRetry:YES];
					break;
			}
		}
	}
	else
	{
		NSLog(@"Last.fm.framework: error, %@", [theError description]);
		shouldProceed = YES;
	}
	
	if (shouldProceed)
		[self dispatchNextRequestIfPossible];
	else
	{
		if (queueTimer)
		{
			[queueTimer invalidate];
			[queueTimer release];
			queueTimer = nil;
		}
		queueTimer = [[NSTimer scheduledTimerWithTimeInterval:150.0 target:self selector:@selector(dispatchTimerCalled:) userInfo:nil repeats:NO] retain];
	}
}

@end
