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
	CGFloat duration;
	NSMutableArray *timeLog;
}

// Initializers
- (id)initWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration;
+ (id)track;
+ (id)trackWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration;

// Properties
@property(copy) NSString *title;
@property(copy) NSString *artist;
@property(assign) CGFloat duration;
@property(assign) LFWebService *webService;

// Track control methods
- (void)play;
- (void)pause;
- (CGFloat)playingTime;
- (void)stop;
- (void)stopAndScrobble:(BOOL)shouldScrobble;

// Track web service methods
- (void)love;
- (void)ban;

@end
