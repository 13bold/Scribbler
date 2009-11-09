//
//  Controller.m
//  Last.fm
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

#import "Controller.h"
#import "UIController.h"
#import <Last.fm/Last.fm.h>
#import "EMKeychainProxy.h"
#import "EMKeychainItem.h"


@implementation Controller

#pragma mark Initializers
+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"LastFMConfigured", @"", @"LastFMUsername", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

#pragma mark Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// We'll use this variable for when we need to switch back and
	// forth between the web browser
	authorizationPending = NO;
	
	// First, let's setup the web service object
	// You can obtain the API key and shared secret on your API info page
	//  - http://www.last.fm/api/account
	
	LFWebService *lastfm = [LFWebService sharedWebService];
	[lastfm setDelegate:self];
	[lastfm setAPIKey:@"5b792457bd456c690c79b486ada9be36"];
	[lastfm setSharedSecret:@"d305d74e7998346c544191206e9bb4dc"];
	
	// We'll also set our client ID for scrobbling
	// You can obtain one of these by contacting Last.fm
	//  - http://www.last.fm/api/submissions#1.1
	// For now, we'll use the testing ID 'tst'
	[lastfm setClientID:@"tst"];
	
	// We're also going to turn off autoscrobble, which
	// scrobbles the last playing track automatically
	// whenever a new track starts playing
	[lastfm setAutoScrobble:NO];
	
	// In order to run, we need a valid session key
	// First, we'll check to see if we have one. If we do,
	// we'll set it, then test it. Otherwise, we'll wait for
	// someone to click the "Connect" button.
	[self connectWithStoredCredentials];
}
- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	// If we have a pending authorization, this is our
	// cue to start trying to validate it, since the user likely
	// just switched back from the browser window
	if (authorizationPending)
	{
		authorizationPending = NO;
		[self completeAuthorization:aNotification];
	}
}

#pragma mark Authorization methods
- (void)connectWithStoredCredentials
{
	// we have stored credentials, so we'll grab the user from the defaults,
	// then grab the session key from the keychain...
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LastFMConfigured"])
	{
		NSString *theUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastFMUsername"];
		
		NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
		EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
		if (keyItem)
		{
			// we'll set both the user and session key in the web service
			LFWebService *lastfm = [LFWebService sharedWebService];
			[lastfm setSessionUser:theUser];
			[lastfm setSessionKey:[keyItem password]];
			
			// and then attempt to validate the credentials
			[lastfm validateSessionCredentials];
			
			// Adjust the UI
			[uiController showAuthValidatingPane];
		}
	}
}
- (IBAction)connectWithLastFM:(id)sender
{
	// This means we're going to force establish a new Last.fm session
	[[LFWebService sharedWebService] establishNewSession];
	
	// Adjust the UI to show status
	[uiController showAuthPreAuthPane];
}
- (IBAction)disconnectFromLastFM:(id)sender
{
	// We need to get the username
	NSString *theUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastFMUsername"];
	
	// We need to delete the user default information
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LastFMConfigured"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastFMUsername"];
	
	// And clear the Keychain info
	NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
	EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
	if (keyItem)
		[keyItem setPassword:@""];
	
	// Finally, clear out the web service...
	LFWebService *lastfm = [LFWebService sharedWebService];
	[lastfm setSessionUser:nil];
	[lastfm setSessionKey:nil];
	
	// ... and update the UI
	[uiController showAuthConnectPane];
}
- (IBAction)completeAuthorization:(id)sender
{
	// And now we finish authorization
	[[LFWebService sharedWebService] finishSessionAuthorization];
}
- (IBAction)openManagementPage:(id)sender
{
	// Manage third-party application access on Last.fm
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm/settings/applications"]];
}

#pragma mark Track methods
- (IBAction)startPlayingTrack:(id)sender
{
	LFTrack *track = [LFTrack trackWithTitle:[trackName stringValue] artist:[trackArtist stringValue] duration:[trackDuration floatValue]];
	[track setPlayingTime:[trackPlayTime floatValue]];
	[[LFWebService sharedWebService] startPlayingTrack:track];
	
	// We don't use the "play" method here, because we already
	// forced a playing time, and we don't want to mess with that
	// We're doing our own time tracking, so we just need to tell
	// LFWebService what to do, rather than let it handle things
}
- (IBAction)scrobbleTrack:(id)sender
{
	LFTrack *track = [LFTrack trackWithTitle:[trackName stringValue] artist:[trackArtist stringValue] duration:[trackDuration floatValue]];
	[track setPlayingTime:[trackPlayTime floatValue]];
	[track stop]; // forces a scrobble
}
- (IBAction)loveTrack:(id)sender
{
	LFTrack *track = [LFTrack trackWithTitle:[trackName stringValue] artist:[trackArtist stringValue] duration:[trackDuration floatValue]];
	[track setPlayingTime:[trackPlayTime floatValue]];
	[track love];
	[track stop]; // forces a scrobble
}
- (IBAction)banTrack:(id)sender
{
	LFTrack *track = [LFTrack trackWithTitle:[trackName stringValue] artist:[trackArtist stringValue] duration:[trackDuration floatValue]];
	[track setPlayingTime:[trackPlayTime floatValue]];
	[track ban];
	[track stop]; // forces a scrobble
}

#pragma mark Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL
{
	// OK, so the first stage is done; we'll update the
	// UI to match the current status,
	// then open up the web browser to have the user allow our demo app
	// access
	[uiController showAuthWaitingPane];
	
	[[NSWorkspace sharedWorkspace] openURL:theURL];
	authorizationPending = YES;
}
- (void)sessionAuthorizationStillPending
{
	// We tried to authorize the session, but the user
	// isn't done in the web browser yet. Wait 5 seconds,
	// then try again.
	
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(completeAuthorization:) userInfo:nil repeats:NO];
}
- (void)sessionAuthorizationFailed
{
	// We failed. Epically.
	[uiController showAuthConnectPane];
}
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser
{
	// The session key will be valid for future uses -- it never
	// expires unless explicitly revoked by the Last.fm user.
	// Therefore, we can store the user as a default, and then store
	// the key in the Keychain for future use.
	
	[[NSUserDefaults standardUserDefaults] setObject:theUser forKey:@"LastFMUsername"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LastFMConfigured"];
	
	NSString *keychainService = [NSString stringWithFormat:@"Last.fm (%@)", [[NSBundle mainBundle] bundleIdentifier]];
	EMGenericKeychainItem *keyItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:keychainService withUsername:theUser];
	if (keyItem)
		[keyItem setPassword:theKey];
	else
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:keychainService withUsername:theUser password:theKey];
	
	// Hooray! we're up and running
	[uiController showAuthConnectedPaneWithUser:theUser];
}

- (void)sessionValidatedForUser:(NSString *)theUser
{
	// Hooray! we're up and running
	[uiController showAuthConnectedPaneWithUser:theUser];
}
- (void)sessionInvalidForUser:(NSString *)theUser
{
	// We failed. Epically.
	[uiController showAuthConnectPane];
}

@end
