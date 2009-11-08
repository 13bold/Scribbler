//
//  Controller.h
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

#import <Cocoa/Cocoa.h>
#import <Last.fm/Last.fm.h>


// Forward declarations
@class UIController;

@interface Controller : NSObject<LFWebServiceDelegate> {
	IBOutlet UIController *uiController;
	
	IBOutlet NSButton *authButton;
	IBOutlet NSProgressIndicator *authSpinner;
	
	BOOL authorizationPending;
}

// Application delegate methods
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)aNotification;

// Authorization methods
- (void)connectWithStoredCredentials;
- (IBAction)connectWithLastFM:(id)sender;
- (IBAction)disconnectFromLastFM:(id)sender;
- (IBAction)completeAuthorization:(id)sender;
- (IBAction)openManagementPage:(id)sender;

// Web service delegate methods
- (void)sessionNeedsAuthorizationViaURL:(NSURL *)theURL;
- (void)sessionAuthorizationStillPending;
- (void)sessionAuthorizationFailed;
- (void)sessionCreatedWithKey:(NSString *)theKey user:(NSString *)theUser;

- (void)sessionValidatedForUser:(NSString *)theUser;
- (void)sessionInvalidForUser:(NSString *)theUser;

@end
