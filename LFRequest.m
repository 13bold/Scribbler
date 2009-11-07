//
//  LFRequest.m
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

#import "LFRequest.h"
#import "LFTrack.h"
#import "LFWebService.h"
#import "LFWebServicePrivate.h"
#import "NSString+LFExtensions.h"


@implementation LFRequest

#pragma mark Initializers
- (id)init
{
	return [self initWithTrack:nil];
}
- (id)initWithTrack:(LFTrack *)theTrack
{
	if (self = [super init])
	{
		[self setTrack:theTrack];
		requestType = LFRequestUnknown;
		
		responseData = [[NSMutableData alloc] init];
		identifier = [[NSString stringWithNewUUID] copy];
	}
	return self;
}
+ (id)request
{
	return [[[self alloc] init] autorelease];
}
+ (id)requestWithTrack:(LFTrack *)theTrack
{
	return [[[self alloc] initWithTrack:theTrack] autorelease];
}

#pragma mark Deallocator
- (void)dealloc
{
	[track release];
	[identifier release];
	[connection release];
	[response release];
	[responseData release];
	[super dealloc];
}

#pragma mark Properties
@synthesize delegate;
@synthesize track;
@synthesize requestType;
@synthesize identifier;
@synthesize response;
@synthesize responseData;

#pragma mark Dispatch methods
- (void)dispatch
{
	// Can't do anything
	NSLog(@"Last.fm.framework: warning, attempt to dispatch generic request");
}

#pragma mark Composition methods
- (NSURL *)URLWithParameters:(NSDictionary *)params sign:(BOOL)shouldSign
{
	// get the URL root
	static NSString *__LFWebServiceURL = nil;
	if (!__LFWebServiceURL)
		__LFWebServiceURL = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"LFWebServiceURL"];
	
	// compose the URL string
	NSMutableString *output = [NSMutableString string];
	[output appendFormat:@"%@?", __LFWebServiceURL];
	
	NSMutableArray *parts = [[NSMutableArray alloc] init];
	for (NSString *key in params)
		[parts addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
	
	[output appendString:[parts componentsJoinedByString:@"&"]];
	[parts release];
	
	// now sign if necessary
	if (shouldSign)
	{
		NSString *sig = [self signatureWithParameters:params];
		[output appendFormat:@"&api_sig=%@", sig];
	}
	
	return [NSURL URLWithString:output];
}
- (NSString *)signatureWithParameters:(NSDictionary *)params
{
	NSMutableString *paramList = [[NSMutableString alloc] init];
	
	NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	for (NSString *key in keys)
		[paramList appendFormat:@"%@%@", key, [params objectForKey:key]];
	
	[paramList appendString:[delegate sharedSecret]];
	
	NSString *output = [paramList MD5Hash];
	[paramList release];
	return output;
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse
{
	// clear out any data that's there
	[responseData setLength:0];
	
	if (response)
	{
		[response release];
		response = nil;
	}
	response = [theResponse retain];
}
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	// grab that data!
	[responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	// hooray!
	if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
		[delegate requestSucceeded:self];
	
	[connection release];
	connection = nil;
}
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	// boo!
	if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
		[delegate request:self failedWithError:error];
	
	[connection release];
	connection = nil;
}

@end
