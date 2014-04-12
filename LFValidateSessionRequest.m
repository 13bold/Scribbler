//
//  LFValidateSessionRequest.m
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

#import "LFValidateSessionRequest.h"

#if LFUseTouchXML
#import "TouchXML.h"
#endif


@implementation LFValidateSessionRequest

#pragma mark Overridden methods
- (id)initWithTrack:(LFTrack *)theTrack
{
	if (self = [super initWithTrack:theTrack])
	{
		requestType = LFRequestValidateSession;
	}
	return self;
}
- (void)dispatch
{
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							@"user.getInfo", @"method",
							[delegate sessionKey], @"sk",
							[delegate APIKey], @"api_key",
							nil];
	
	NSURL *theURL = [self URLWithParameters:params sign:YES];
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL];
	
	if (connection)
	{
		connection = nil;
	}
	connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	NSError *err;
#if LFUseTouchXML
	CXMLDocument *theResponse = [[CXMLDocument alloc] initWithData:responseData options:0 error:&err];
#else
	NSXMLDocument *theResponse = [[NSXMLDocument alloc] initWithData:responseData options:0 error:&err];
#endif
	
	if (err)
	{
		failureCount++;
		
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:err];
		return;
	}
	
#if LFUseTouchXML
	CXMLElement *root = [theResponse rootElement];
#else
	NSXMLElement *root = [theResponse rootElement];
#endif
	NSString *status = [[[root attributeForName:@"status"] stringValue] lowercaseString];
	
	if ([status isEqualToString:@"ok"])
	{
		NSString *username = [[[[[root elementsForName:@"user"] objectAtIndex:0] elementsForName:@"name"] objectAtIndex:0] stringValue];
		
		if ([[username lowercaseString] isEqualToString:[[delegate sessionUser] lowercaseString]])
		{
			failureCount = 0;
			
			if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
				[delegate requestSucceeded:self];
		}
		else
		{
			// valid session but for a different user, sounds suspicious
			// Last.fm does not presently allow you to change your username
			// we're going to fail here, just to be on the safe side
			
			failureCount++;
			
			if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
				[delegate request:self failedWithError:[NSError errorWithDomain:@"LFMFramework" code:0 userInfo:[NSDictionary dictionaryWithObject:@"An unknown error occurred." forKey:NSLocalizedDescriptionKey]]];
		}
	}
	else if ([status isEqualToString:@"failed"])
	{
		failureCount++;
		
#if LFUseTouchXML
		CXMLElement *errorNode = [[root elementsForName:@"error"] objectAtIndex:0];
#else
		NSXMLElement *errorNode = [[root elementsForName:@"error"] objectAtIndex:0];
#endif
		NSError *theError = [NSError errorWithDomain:@"Last.fm" code:[[[errorNode attributeForName:@"code"] stringValue] integerValue] userInfo:[NSDictionary dictionaryWithObject:[errorNode stringValue] forKey:NSLocalizedDescriptionKey]];
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:theError];
	}
	else
	{
		failureCount++;
		
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:[NSError errorWithDomain:@"LFMFramework" code:0 userInfo:[NSDictionary dictionaryWithObject:@"An unknown error occurred." forKey:NSLocalizedDescriptionKey]]];
	}
	
	connection = nil;
}

@end
