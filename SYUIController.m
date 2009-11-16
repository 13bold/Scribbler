//
//  SYUIController.m
//  Scribbler
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
	[connectButton setAction:@selector(connectWithLastFM:)];
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
	[connectButton setAction:@selector(disconnectFromLastFM:)];
}

@end
