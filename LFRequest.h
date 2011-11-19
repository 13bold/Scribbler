//
//  LFRequest.h
//  Scribbler
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

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED > 0
#define LFUseTouchXML 1
#else
#define LFUseTouchXML 0
#endif

// Request types
typedef enum _LFRequestType {
	LFRequestUnknown = 0,
	LFRequestNowPlaying = 1,
	LFRequestScrobble = 2,
	LFRequestLove = 3,
	LFRequestBan = 4,
	LFRequestGetToken = 5,
	LFRequestGetSession = 6,
	LFRequestGetMobileSession = 9,
	LFRequestValidateSession = 7
} LFRequestType;

// Forward declarations
@class LFTrack;
@protocol LFRequestDelegate;

@interface LFRequest : NSObject {
	NSObject<LFRequestDelegate> *delegate;
	LFTrack *track;
	LFRequestType requestType;
	
	NSString *identifier;
	
	NSURLConnection *connection;
	NSURLResponse *response;
	NSMutableData *responseData;
	
	NSUInteger failureCount;
}

// Initializers
- (id)initWithTrack:(LFTrack *)theTrack;
+ (id)request;
+ (id)requestWithTrack:(LFTrack *)theTrack;

// Properties
@property(assign) NSObject<LFRequestDelegate> *delegate;
@property(retain) LFTrack *track;
@property(assign,readonly) LFRequestType requestType;
@property(copy,readonly) NSString *identifier;
@property(retain,readonly) NSURLResponse *response;
@property(retain,readonly) NSMutableData *responseData;
@property(assign,readonly) NSUInteger failureCount;

// Dispatch methods
- (void)dispatch;

// Composition methods
- (NSURL *)URLWithParameters:(NSDictionary *)params sign:(BOOL)shouldSign;
- (NSString *)queryStringWithParameters:(NSDictionary *)params sign:(BOOL)shouldSign;
- (NSString *)signatureWithParameters:(NSDictionary *)params;

// NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error;

@end

// Delegate methods
@protocol LFRequestDelegate

- (NSString *)APIKey;
- (NSString *)sharedSecret;
- (NSString *)clientID;
- (NSString *)clientVersion;
- (NSString *)sessionKey;
- (NSString *)sessionUser;

- (void)requestSucceeded:(LFRequest *)theRequest;
- (void)request:(LFRequest *)theRequest failedWithError:(NSError *)theError;

@end


