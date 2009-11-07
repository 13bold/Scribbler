//
//  Controller.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/4/09.
//  Copyright 2009 {13bold}. All rights reserved.
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
#import <Last.fm/Last.fm.h>


@implementation Controller

#pragma mark Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
	
	// In order to run, we need a valid session key
	// First, we'll check to see if we have one. If we do,
	// we'll set it, then test it. Otherwise, we'll wait for
	// someone to click the "Connect" button.
}

#pragma mark Authorization methods
- (IBAction)connectWithLastFM:(id)sender
{
	// This means we're going to force establish a new Last.fm session
	[[LFWebService sharedWebService] establishNewSession];
	
	// While we're waiting, let's make it not clickable, and show an animation
	[authButton setEnabled:NO];
	[authSpinner startAnimation:self];
}
- (IBAction)openManagementPage:(id)sender
{
	// Manage third-part application access on Last.fm
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm/settings/applications"]];
}

@end
