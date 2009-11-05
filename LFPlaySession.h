//
//  LFPlaySession.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LFPlaySession : NSObject {
	NSDate *startTime;
	NSDate *stopTime;
}

// Initializers
- (id)initWithStartTime:(NSDate *)theTime;
+ (id)session;
+ (id)sessionWithStartTime:(NSDate *)theTime;

// Properties
@property(retain) NSDate *startTime;
@property(retain) NSDate *stopTime;

// Control methods
- (void)start;
- (void)stop;
- (BOOL)hasStopped;

// Status methods
- (CGFloat)length;

@end
