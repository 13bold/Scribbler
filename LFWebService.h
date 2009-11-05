//
//  LFWebService.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Forward declarations
@class LFTrack;

@interface LFWebService : NSObject {
	id delegate;
	NSString *APIKey;
	NSString *sharedSecret;
	NSString *clientID;
	
	NSString *sessionKey;
	
	LFTrack *currentTrack;
	NSMutableArray *requestQueue;
}

// Initializers
+ (id)sharedWebService;

// Properties
@property(assign) id delegate;
@property(copy) NSString *APIKey;
@property(copy) NSString *sharedSecret;
@property(copy) NSString *clientID;
@property(copy) NSString *sessionKey;
@property(retain,readonly) LFTrack *currentTrack;

// Session methods
- (void)establishNewSession;

// Track methods
- (void)startPlayingTrack:(LFTrack *)theTrack;
- (void)scrobbleTrackIfNecessary:(LFTrack *)theTrack;
- (void)loveTrack:(LFTrack *)theTrack;
- (void)banTrack:(LFTrack *)theTrack;

@end

// Delegate interface
@interface LFWebServiceDelegate

// Session management
- (void)sessionStartedWithKey:(NSString *)theKey;

// Track responses
- (void)nowPlayingSucceededForTrack:(LFTrack *)theTrack;
- (void)scrobbleSucceededForTrack:(LFTrack *)theTrack;
- (void)loveSucceededForTrack:(LFTrack *)theTrack;
- (void)banSucceededForTrack:(LFTrack *)theTrack;

- (void)nowPlayingFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)scrobbleFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)loveFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)banFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;

@end
