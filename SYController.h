//
//  SYController.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Last.fm/Last.fm.h>


// Forward declarations
@class SYUIController;

@interface SYController : NSObject {
	IBOutlet SYUIController *ui;
	
	NSMutableArray *recentTracks;
	IBOutlet NSTableView *trackTableView;
	
	LFTrack *currentTrack;
	NSUInteger currentTrackID;
	BOOL wasPlaying;
	
	BOOL authorizationPending;
}

// Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

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
