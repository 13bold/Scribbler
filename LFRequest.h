//
//  LFRequest.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Request types
typedef enum _LFRequestType {
	LFRequestUnknown = 0,
	LFRequestNowPlaying = 1,
	LFRequestScrobble = 2,
	LFRequestLove = 3,
	LFRequestBan = 4
} LFRequestType;

// Forward declarations
@class LFTrack;

@interface LFRequest : NSObject {
	LFTrack *track;
	LFRequestType requestType;
}

// Initializers
- (id)initWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType;
+ (id)request;
+ (id)requestWithTrack:(LFTrack *)theTrack requestType:(LFRequestType)theType;

// Properties
@property(retain) LFTrack *track;
@property(assign) LFRequestType type;

@end
