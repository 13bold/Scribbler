//
//  LFScrobblerHandshakeRequest.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/8/09.
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

#import "LFScrobblerHandshakeRequest.h"
#import "NSString+LFExtensions.h"


@implementation LFScrobblerHandshakeRequest

#pragma mark Properties
@synthesize sessionID;
@synthesize nowPlayingURL;
@synthesize submissionURL;

#pragma mark Overridden methods
- (id)initWithTrack:(LFTrack *)theTrack
{
	if (self = [super initWithTrack:theTrack])
	{
		requestType = LFRequestScrobblerHandshake;
	}
	return self;
}
- (void)dealloc
{
	[sessionID release];
	[nowPlayingURL release];
	[submissionURL release];
	[super dealloc];
}
- (void)dispatch
{
	// get the URL root
	static NSString *__LFSubmissionsURL = nil;
	if (!__LFSubmissionsURL)
		__LFSubmissionsURL = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"LFSubmissionsURL"];
	
	NSDate *requestTime = [NSDate date];
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							@"true", @"hs",
							LFSubmissionsAPISupportedVersion, @"p",
							[delegate clientID], @"c",
							[delegate clientVersion], @"v",
							[delegate sessionUser], @"u",
							[NSString stringWithFormat:@"%0.0f", [requestTime timeIntervalSince1970]], @"t",
							[[NSString stringWithFormat:@"%@%0.0f", [delegate sharedSecret], [requestTime timeIntervalSince1970]] MD5Hash], @"a",
							[delegate APIKey], @"api_key",
							[delegate sessionKey], @"sk",
							nil];
	
	NSString *queryString = [self queryStringWithParameters:params sign:NO];
	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", __LFSubmissionsURL, queryString]];
	[params release];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];
	
	if (connection)
	{
		[connection release];
		connection = nil;
	}
	connection = [[NSURLConnection connectionWithRequest:theRequest delegate:self] retain];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	if (responseString)
	{
		NSArray *rLines = [responseString componentsSeparatedByString:@"\n"];
		
		if ([[[rLines objectAtIndex:0] lowercaseString] hasPrefix:@"ok"])
		{
			failureCount = 0;
			
			if (sessionID)
			{
				[sessionID release];
				sessionID = nil;
			}
			sessionID = [[rLines objectAtIndex:1] copy];
			
			if (nowPlayingURL)
			{
				[nowPlayingURL release];
				nowPlayingURL = nil;
			}
			nowPlayingURL = [[rLines objectAtIndex:2] copy];
			
			if (submissionURL)
			{
				[submissionURL release];
				submissionURL = nil;
			}
			submissionURL = [[rLines objectAtIndex:3] copy];
			
			if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
				[delegate requestSucceeded:self];
		}
		else
		{
			failureCount++;
			
			NSString *errString = [rLines objectAtIndex:0];
			NSUInteger code = 0;
			if ([[errString lowercaseString] hasPrefix:@"banned"])
				code = 1;
			else if ([[errString lowercaseString] hasPrefix:@"badauth"])
				code = 2;
			else if ([[errString lowercaseString] hasPrefix:@"badtime"])
				code = 3;
			else if ([[errString lowercaseString] hasPrefix:@"failed"])
				code = 4;
			
			NSError *theError = [NSError errorWithDomain:@"Last.fm" code:code userInfo:[NSDictionary dictionaryWithObject:errString forKey:NSLocalizedDescriptionKey]];
			if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
				[delegate request:self failedWithError:theError];
		}
	}
	else
	{
		failureCount++;
		
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:[NSError errorWithDomain:@"LFMFramework" code:0 userInfo:[NSDictionary dictionaryWithObject:@"An unknown error occurred." forKey:NSLocalizedDescriptionKey]]];
	}
	
	[responseString release];
	[connection release];
	connection = nil;
}

@end
