//
//  LFWebService.h
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


// Connection states
typedef enum _LFConnectionState {
	LFNotConnected = 0,
	LFConnected = 1,
	LFConnecting = 2
} LFConnectionState;

// Forward declarations
@class LFTrack;
@class LFRequest;

@interface LFWebService : NSObject {
	id delegate;
	NSString *APIKey;
	NSString *sharedSecret;
	NSString *clientID;
	NSString *clientVersion;
	
	NSString *pendingToken;
	NSString *sessionKey;
	NSString *sessionUser;
	
	LFTrack *currentTrack;
	NSMutableArray *requestQueue;
	
	BOOL runningRequest;
	BOOL autoScrobble;
	
	NSTimer *queueTimer;
	
	LFConnectionState state;
}

// Initializers
+ (id)sharedWebService;

// Properties
@property(assign) id delegate;
@property(assign,readonly) LFConnectionState state;
@property(copy) NSString *APIKey;
@property(copy) NSString *sharedSecret;
@property(copy) NSString *clientID;
@property(copy) NSString *clientVersion;
@property(copy) NSString *sessionKey;
@property(copy) NSString *sessionUser;
@property(assign) BOOL autoScrobble;
@property(retain,readonly) LFTrack *currentTrack;

// Session methods (new sessions)
- (NSString *)establishNewSession;
- (NSString *)establishNewMobileSessionWithUsername:(NSString *)theUser password:(NSString *)thePassword;
- (NSString *)finishSessionAuthorization;

// Session methods (existing sessions)
- (NSString *)validateSessionCredentials;

// Track methods
- (NSString *)startPlayingTrack:(LFTrack *)theTrack;
- (NSString *)scrobbleTrackIfNecessary:(LFTrack *)theTrack;
- (NSString *)loveTrack:(LFTrack *)theTrack;
- (NSString *)banTrack:(LFTrack *)theTrack;

@end

