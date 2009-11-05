//
//  LFWebServiceDelegate.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LFWebService.h"


@protocol LFWebServiceDelegate

// All methods are optional
@optional

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
