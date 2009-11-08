//
//  UIController.m
//  Last.fm
//
//  Created by Matt Patenaude on 11/8/09.
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

#import "UIController.h"


@implementation UIController

#pragma mark UI methods
- (void)showAuthConnectPane
{
	[authInstructionText setStringValue:@"In order to use Last.fm within this application, you first need to connect it with your account. Click the button below to get started."];
	[authStatus setHidden:YES];
	[authSpinner stopAnimation:self];
	[authConnectButton setHidden:NO];
}
- (void)showAuthPreAuthPane
{
	[authInstructionText setStringValue:@"In order to use Last.fm within this application, you first need to connect it with your account. Click the button below to get started."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Making Authorization Request…"];
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthWaitingPane
{
	[authInstructionText setStringValue:@"You will now need to provide authorization to Last.fm in your web browser, which should open for you. Once you've finished, return here and wait for authorization to complete."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Awaiting Authorization…"];
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthValidatingPane
{
	[authInstructionText setStringValue:@"Please wait while I validate the credentials from your last authorization with Last.fm."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Checking Authorization…"];
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthConnectedPane
{
	[authInstructionText setStringValue:@"Connected!"];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Connected!"];
	[authStatus setHidden:NO];
	[authSpinner stopAnimation:self];
}

@end
