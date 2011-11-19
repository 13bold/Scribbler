//
//  LFTrack.h
//  Scribbler
//
//  Created by Matt Patenaude on 11/4/09.
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


// Forward declarations
@class LFWebService;

@interface LFTrack : NSObject {
	LFWebService *lastfm;
	NSString *title;
	NSString *artist;
	NSString *album;
	NSUInteger albumPosition;
	CGFloat duration;
	NSString *mbID;
	NSMutableArray *timeLog;
}

// Initializers
- (id)initWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration;
+ (id)track;
+ (id)trackWithTitle:(NSString *)theTitle artist:(NSString *)theArtist duration:(CGFloat)theDuration;

// Properties
@property(copy) NSString *title;
@property(copy) NSString *artist;
@property(copy) NSString *album;
@property(assign) NSUInteger albumPosition;
@property(copy) NSString *mbID;
@property(assign) CGFloat duration;
@property(assign) LFWebService *webService;

// Track control methods
- (void)play;
- (void)pause;
- (CGFloat)playingTime;
- (void)setPlayingTime:(CGFloat)pTime;
- (void)addPlayingTime:(CGFloat)pTime;
- (NSTimeInterval)startTime;
- (void)stop;
- (void)stopAndScrobble:(BOOL)shouldScrobble;

// Track web service methods
- (void)love;
- (void)ban;

@end
