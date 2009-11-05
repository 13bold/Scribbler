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


@implementation LFRequest

#pragma mark Initializers
- (id)init
{
	return [self initWithTrack:nil requestType:LFRequestUnknown];
}
- (id)initWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType
{
	if (self = [super init])
	{
		[self setTrack:theTrack];
		[self setType:theType];
	}
	return self;
}
+ (id)request
{
	return [[[self alloc] init] autorelease];
}
+ (id)requestWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType
{
	return [[[self alloc] initWithTrack:theTrack requestType:theType] autorelease];
}

#pragma mark Deallocator
- (void)dealloc
{
	[track release];
	[connection release];
	[response release];
	[responseData release];
	[super dealloc];
}

#pragma mark Properties
@synthesize delegate;
@synthesize track;
@synthesize type;
@synthesize response;
@synthesize responseData;

#pragma mark Dispatch methods
- (void)dispatch
{
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse
{
}
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
}
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
}
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
}

@end
