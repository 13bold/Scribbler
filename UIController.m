//
//  UIController.m
//  Scribbler
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
#import "Controller.h"


@implementation UIController

#pragma mark UI methods
- (void)showAuthConnectPane
{
	[authInstructionText setStringValue:@"In order to use Last.fm within this application, you first need to connect it with your account. Click the button below to get started."];
	[authStatus setHidden:YES];
	[authSpinner stopAnimation:self];
	
	[authConnectButton setTitle:@"Connect with Last.fm"];
	
	// get frame, set size, and center
	NSRect buttonFrame = [authConnectButton frame];
	buttonFrame.size.width = 174.0; // taken from IB
	
	CGFloat parentWidth = [[authConnectButton superview] frame].size.width;
	buttonFrame.origin.x = (parentWidth / 2.0) - (buttonFrame.size.width / 2.0);
	[authConnectButton setFrame:buttonFrame];
	
	[authConnectButton setAction:@selector(connectWithLastFM:)];
	[authConnectButton setHidden:NO];
}
- (void)showAuthPreAuthPane
{
	[authInstructionText setStringValue:@"In order to use Last.fm within this application, you first need to connect it with your account. Click the button below to get started."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Making Authorization Request…"];
	
	// measure the gap
	NSRect statusFrame = [authStatus frame];
	NSRect spinFrame = [authSpinner frame];
	CGFloat gap = spinFrame.origin.x - (statusFrame.origin.x + statusFrame.size.width);
	
	// adjust the size of the status field
	[authStatus sizeToFit];
	
	// reposition the spinner
	statusFrame = [authStatus frame];
	spinFrame.origin.x = statusFrame.origin.x + statusFrame.size.width + gap;
	[authSpinner setFrame:spinFrame];
	
	// now center both of them
	CGFloat totalWidth = statusFrame.size.width + gap + spinFrame.size.width;
	CGFloat parentWidth = [[authStatus superview] frame].size.width;
	CGFloat adjustment = statusFrame.origin.x - ((parentWidth / 2.0) - (totalWidth / 2.0));
	
	statusFrame.origin.x -= adjustment;
	spinFrame.origin.x -= adjustment;
	[authStatus setFrame:statusFrame];
	[authSpinner setFrame:spinFrame];
	
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthWaitingPane
{
	[authInstructionText setStringValue:@"You will now need to provide authorization to Last.fm in your web browser, which should open for you. Once you've finished, return here and wait for authorization to complete."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Awaiting Authorization…"];
	
	// measure the gap
	NSRect statusFrame = [authStatus frame];
	NSRect spinFrame = [authSpinner frame];
	CGFloat gap = spinFrame.origin.x - (statusFrame.origin.x + statusFrame.size.width);
	
	// adjust the size of the status field
	[authStatus sizeToFit];
	
	// reposition the spinner
	statusFrame = [authStatus frame];
	spinFrame.origin.x = statusFrame.origin.x + statusFrame.size.width + gap;
	[authSpinner setFrame:spinFrame];
	
	// now center both of them
	CGFloat totalWidth = statusFrame.size.width + gap + spinFrame.size.width;
	CGFloat parentWidth = [[authStatus superview] frame].size.width;
	CGFloat adjustment = statusFrame.origin.x - ((parentWidth / 2.0) - (totalWidth / 2.0));
	
	statusFrame.origin.x -= adjustment;
	spinFrame.origin.x -= adjustment;
	[authStatus setFrame:statusFrame];
	[authSpinner setFrame:spinFrame];
	
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthValidatingPane
{
	[authInstructionText setStringValue:@"Please wait while I validate the credentials from your last authorization with Last.fm."];
	[authConnectButton setHidden:YES];
	[authStatus setStringValue:@"Checking Authorization…"];
	
	// measure the gap
	NSRect statusFrame = [authStatus frame];
	NSRect spinFrame = [authSpinner frame];
	CGFloat gap = spinFrame.origin.x - (statusFrame.origin.x + statusFrame.size.width);
	
	// adjust the size of the status field
	[authStatus sizeToFit];
	
	// reposition the spinner
	statusFrame = [authStatus frame];
	spinFrame.origin.x = statusFrame.origin.x + statusFrame.size.width + gap;
	[authSpinner setFrame:spinFrame];
	
	// now center both of them
	CGFloat totalWidth = statusFrame.size.width + gap + spinFrame.size.width;
	CGFloat parentWidth = [[authStatus superview] frame].size.width;
	CGFloat adjustment = statusFrame.origin.x - ((parentWidth / 2.0) - (totalWidth / 2.0));
	
	statusFrame.origin.x -= adjustment;
	spinFrame.origin.x -= adjustment;
	[authStatus setFrame:statusFrame];
	[authSpinner setFrame:spinFrame];
	
	[authStatus setHidden:NO];
	[authSpinner startAnimation:self];
}
- (void)showAuthConnectedPaneWithUser:(NSString *)username
{
	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hello, %@! You have successfully connected your Last.fm account with this application. You can now Love and Ban tracks, as well as scrobble your plays to Last.fm.", username]];
	[str addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(7, [username length])];
	
	[authInstructionText setAttributedStringValue:str];
	[str release];
	
	[authSpinner stopAnimation:self];
	[authStatus setHidden:YES];
	
	[authConnectButton setTitle:@"Disconnect from Last.fm"];
	
	// get frame, set size, and center
	NSRect buttonFrame = [authConnectButton frame];
	buttonFrame.size.width = 195.0; // taken from IB
	
	CGFloat parentWidth = [[authConnectButton superview] frame].size.width;
	buttonFrame.origin.x = (parentWidth / 2.0) - (buttonFrame.size.width / 2.0);
	[authConnectButton setFrame:buttonFrame];
	
	[authConnectButton setAction:@selector(disconnectFromLastFM:)];
	[authConnectButton setHidden:NO];
}

@end
