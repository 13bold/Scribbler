//
//  SYController.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
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
#import <Last.fm/Last.fm.h>


// Forward declarations
@class SYUIController;

@interface SYController : NSObject {
	IBOutlet SYUIController *ui;
	IBOutlet NSWindow *mainWindow;
	
	NSMutableArray *recentTracks;
	IBOutlet NSTableView *trackTableView;
	
	LFTrack *currentTrack;
	NSUInteger currentTrackID;
	BOOL wasPlaying;
	
	BOOL authorizationPending;
}

// Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication;

// Connection methods
- (IBAction)connectWithLastFM:(id)sender;
- (IBAction)disconnectFromLastFM:(id)sender;
- (void)connectWithStoredCredentials;
- (void)completeAuthorization;

// Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL;
- (void)sessionAuthorizationStillPending;
- (void)sessionAuthorizationFailed;
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser;

- (void)sessionValidatedForUser:(NSString *)theUser;
- (void)sessionInvalidForUser:(NSString *)theUser;
- (void)sessionKeyRevoked:(NSString *)theKey forUser:(NSString *)theUser;

- (void)scrobblerClient:(NSString *)theClientID bannedForVersion:(NSString *)theClientVersion;

- (void)scrobbleSucceededForTrack:(LFTrack *)theTrack;
- (void)scrobbleFailedForTrack:(LFTrack *)theTrack error:(NSError *)theError willRetry:(BOOL)willRetry;

// Tracking methods
- (void)playerInfoChanged:(NSNotification *)theNotification;
- (IBAction)loveTrack:(id)sender;
- (IBAction)banTrack:(id)sender;

// Table data source methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end
