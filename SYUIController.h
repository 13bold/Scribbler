//
//  SYUIController.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SYUIController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextField *trackTitle;
	IBOutlet NSTextField *trackSubline;
	
	IBOutlet NSTextField *statusField;
}

// Composition methods
- (void)composeInterface;

// Display methods
- (void)unusableTrack;
- (void)nothingPlaying;
- (void)displayTrack:(NSString *)theTitle subline:(NSString *)subline;

// Auth methods
- (void)showConnectMessage;
- (void)showPreAuthMessage;
- (void)showWaitingMessage;
- (void)showValidatingMessage;
- (void)showConnectedWithUser:(NSString *)theUser;

@end
