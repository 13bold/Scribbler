//
//  LFGetMobileSessionRequest.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/6/09.
//  Copyright (C) 2009 - 10 {13bold}.
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

#import "LFGetMobileSessionRequest.h"
#import "NSString+LFExtensions.h"

#if LFUseTouchXML
#import "TouchXML.h"
#endif


@implementation LFGetMobileSessionRequest

#pragma mark Properties
@synthesize sessionUser;
@synthesize sessionPassword;
@synthesize sessionKey;

#pragma mark Overridden methods
- (id)initWithTrack:(LFTrack *)theTrack
{
	if (self = [super initWithTrack:theTrack])
	{
		requestType = LFRequestGetMobileSession;
	}
	return self;
}
- (void)dealloc
{
	[sessionUser release];
	[sessionPassword release];
	[sessionKey release];
	[super dealloc];
}
- (void)dispatch
{
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							@"auth.getMobileSession", @"method",
							sessionUser, @"username",
							[[NSString stringWithFormat:@"%@%@", sessionUser, [sessionPassword MD5Hash]] MD5Hash], @"authToken",
							[delegate APIKey], @"api_key",
							nil];
	
	NSURL *theURL = [self URLWithParameters:params sign:YES];
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
		failureCount = 0;
		
#if LFUseTouchXML
		CXMLElement *session = [[root elementsForName:@"session"] objectAtIndex:0];
#else
		NSXMLElement *session = [[root elementsForName:@"session"] objectAtIndex:0];
#endif
		
		if (sessionUser)
		{
			[sessionUser release];
			sessionUser = nil;
		}
		sessionUser = [[[[session elementsForName:@"name"] objectAtIndex:0] stringValue] copy];
		
		if (sessionKey)
		{
			[sessionKey release];
			sessionKey = nil;
		}
		sessionKey = [[[[session elementsForName:@"key"] objectAtIndex:0] stringValue] copy];
		
		if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
			[delegate requestSucceeded:self];
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
	
	[theResponse release];
	[connection release];
	connection = nil;
}

@end
