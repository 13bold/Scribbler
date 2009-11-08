//
//  LFValidateSessionRequest.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LFValidateSessionRequest.h"


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
	NSXMLDocument *theResponse = [[NSXMLDocument alloc] initWithData:responseData options:0 error:&err];
	
	if (err)
	{
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:err];
		return;
	}
	
	NSXMLElement *root = [theResponse rootElement];
	NSString *status = [[[root attributeForName:@"status"] stringValue] lowercaseString];
	
	if ([status isEqualToString:@"ok"])
	{
		NSString *username = [[[[[root elementsForName:@"user"] objectAtIndex:0] elementsForName:@"name"] objectAtIndex:0] stringValue];
		
		if ([[username lowercaseString] isEqualToString:[[delegate sessionUser] lowercaseString]])
		{
			if (delegate && [delegate respondsToSelector:@selector(requestSucceeded:)])
				[delegate requestSucceeded:self];
		}
		else
		{
			// valid session but for a different user, sounds suspicious
			// Last.fm does not presently allow you to change your username
			// we're going to fail here, just to be on the safe side
			if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
				[delegate request:self failedWithError:[NSError errorWithDomain:@"LFMFramework" code:0 userInfo:[NSDictionary dictionaryWithObject:@"An unknown error occurred." forKey:NSLocalizedDescriptionKey]]];
		}

	}
	else if ([status isEqualToString:@"failed"])
	{
		NSXMLElement *errorNode = [[root elementsForName:@"error"] objectAtIndex:0];
		NSError *theError = [NSError errorWithDomain:@"Last.fm" code:[[[errorNode attributeForName:@"code"] objectValue] integerValue] userInfo:[NSDictionary dictionaryWithObject:[errorNode stringValue] forKey:NSLocalizedDescriptionKey]];
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:theError];
	}
	else
	{
		if (delegate && [delegate respondsToSelector:@selector(request:failedWithError:)])
			[delegate request:self failedWithError:[NSError errorWithDomain:@"LFMFramework" code:0 userInfo:[NSDictionary dictionaryWithObject:@"An unknown error occurred." forKey:NSLocalizedDescriptionKey]]];
	}
	
	[theResponse release];
	[connection release];
	connection = nil;
}

@end
