//
//  LFWebServicePrivate.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
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

#import "LFWebService.h"
#import "LFRequest.h"


@interface LFWebService()<LFRequestDelegate>

// Properties
@property(copy,readonly) NSString *scrobbleSessionID;
@property(copy,readonly) NSString *scrobbleNPURL;
@property(copy,readonly) NSString *scrobbleSubmissionURL;

// Scrobbler methods
- (NSString *)performScrobblerHandshake;

// Web service methods
- (void)dispatchNextRequestIfPossible;
- (void)dispatchTimerCalled:(NSTimer *)theTimer;

// Request callback methods
- (void)requestSucceeded:(LFRequest *)theRequest;
- (void)request:(LFRequest *)theRequest failedWithError:(NSError *)theError;

@end
