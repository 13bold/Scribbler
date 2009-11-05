//
//  LFTrack.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Forward declarations
@class LFWebService;

@interface LFTrack : NSObject {
	LFWebService *lastfm;
	NSString *title;
	NSString *artist;
	NSMutableArray *timeLog;
}

// Initializers
- (id)initWithTitle:(NSString *)theTitle artist:(NSString *)theArtist;
+ (id)track;
+ (id)trackWithTitle:(NSString *)theTitle artist:(NSString *)theArtist;

// Properties
@property(copy) NSString *title;
@property(copy) NSString *artist;
@property(assign) LFWebService *webService;

// Track control methods
- (void)play;
- (void)pause;
- (CGFloat)playingTime;

// Track attribute methods
- (void)love;
- (void)ban;

@end
