//
//  SYUIController.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SYUIController.h"


@implementation SYUIController

#pragma mark Initializers
- (void)awakeFromNib
{
	[self composeInterface];
}

#pragma mark Composition methods
- (void)composeInterface
{
	// apply the bottom bar
	[mainWindow setContentBorderThickness:23.0 forEdge:NSMinYEdge];
}

#pragma mark Display methods
- (void)unusableTrack
{
	[trackTitle setStringValue:@"Unscrobbleable Track"];
	[trackSubline setStringValue:@"This track is lacking a title or artist."];
}
- (void)nothingPlaying
{
	[trackTitle setStringValue:@"Nothing Playing"];
	[trackSubline setStringValue:@"Play a track in iTunes to begin scrobbling."];
}
- (void)displayTrack:(NSString *)theTitle subline:(NSString *)subline
{
	[trackTitle setStringValue:theTitle];
	[trackSubline setStringValue:subline];
}

#pragma mark Auth methods
- (void)showConnectMessage
{
	[statusField setStringValue:@"Click to connect with your Last.fm Account."];
}
- (void)showPreAuthMessage
{
	[statusField setStringValue:@"Making authorization request…"];
}
- (void)showWaitingMessage
{
	[statusField setStringValue:@"Waiting for authorization…"];
}
- (void)showValidatingMessage
{
	[statusField setStringValue:@"Validating credentials…"];
}
- (void)showConnectedWithUser:(NSString *)theUser
{
	[statusField setStringValue:theUser];
}

@end
