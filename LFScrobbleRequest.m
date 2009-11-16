//
//  LFScrobbleRequest.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/6/09.
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

#import "LFScrobbleRequest.h"
#import "LFTrack.h"


@implementation LFScrobbleRequest

#pragma mark Overridden methods
- (id)initWithTrack:(LFTrack *)theTrack
{
	if (self = [super initWithTrack:theTrack])
	{
		requestType = LFRequestScrobble;
	}
	return self;
}
- (void)dispatch
{
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							[delegate scrobbleSessionID], @"s",
							([track artist] != nil) ? [track artist] : @"", @"a[0]",
							([track title] != nil) ? [track title] : @"", @"t[0]",
							[NSString stringWithFormat:@"%0.0f", [track startTime]], @"i[0]",
							@"P", @"o[0]",
							(([track shouldLoveTrack]) ? @"L" : (([track shouldBanTrack]) ? @"B" : @"")), @"r[0]",
							([track album] != nil) ? [track album] : @"", @"b[0]",
							[NSString stringWithFormat:@"%0.0f", [track duration]], @"l[0]",
							([track albumPosition] > 0) ? [NSString stringWithFormat:@"%u", [track albumPosition]] : @"", @"n[0]",
							([track mbID] != nil) ? [track mbID] : @"", @"m[0]",
							nil];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[delegate scrobbleSubmissionURL]]];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:[[self queryStringWithParameters:params sign:NO] dataUsingEncoding:NSUTF8StringEncoding]];
	[params release];
	
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
			
			if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
				[delegate requestSucceeded:self];
		}
		else
		{
			failureCount++;
			
			NSString *errString = [rLines objectAtIndex:0];
			NSUInteger code = 0;
			if ([[errString lowercaseString] hasPrefix:@"badsession"])
				code = 1;
			else if ([[errString lowercaseString] hasPrefix:@"failed"])
				code = 2;
			
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
