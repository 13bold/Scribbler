//
//  Controller.h
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

#import <Cocoa/Cocoa.h>
#import <Scribbler/Scribbler.h>


// Forward declarations
@class UIController;

@interface Controller : NSObject<LFWebServiceDelegate> {
	IBOutlet UIController *uiController;
	BOOL authorizationPending;
	
	IBOutlet NSTextField *trackName;
	IBOutlet NSTextField *trackArtist;
	IBOutlet NSTextField *trackDuration;
	IBOutlet NSTextField *trackPlayTime;
	
	IBOutlet NSTextField *activityLog;
}

// Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)aNotification;

// Log methods
- (void)log:(NSString *)format, ...;

// Authorization methods
- (void)connectWithStoredCredentials;
- (IBAction)connectWithLastFM:(id)sender;
- (IBAction)disconnectFromLastFM:(id)sender;
- (IBAction)completeAuthorization:(id)sender;
- (IBAction)openManagementPage:(id)sender;

// Track methods
- (IBAction)startPlayingTrack:(id)sender;
- (IBAction)scrobbleTrack:(id)sender;
- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;

// Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL;
- (void)sessionAuthorizationStillPending;
- (void)sessionAuthorizationFailed;
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser;

- (void)sessionValidatedForUser:(NSString *)theUser;
- (void)sessionInvalidForUser:(NSString *)theUser;
- (void)sessionKeyRevoked:(NSString *)theKey forUser:(NSString *)theUser;

- (void)scrobblerHandshakeSucceeded;
- (void)scrobblerHandshakeFailed:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)scrobblerClient:(NSString *)theClientID bannedForVersion:(NSString *)theClientVersion;
- (void)scrobblerRejectedSystemTime;

- (void)nowPlayingSucceededForTrack:(LFTrack *)theTrack;
- (void)scrobbleSucceededForTrack:(LFTrack *)theTrack;
- (void)loveSucceededForTrack:(LFTrack *)theTrack;
- (void)banSucceededForTrack:(LFTrack *)theTrack;

- (void)nowPlayingFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)scrobbleFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)loveFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;
- (void)banFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;

@end
