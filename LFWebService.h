//
//  LFWebService.h
//  Last.fm
//
//  Created by Matt Patenaude on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Forward declarations
@class LFTrack;

@interface LFWebService : NSObject {
	id delegate;
	NSString *APIKey;
	NSString *sharedSecret;
	NSString *clientID;
}

// Initializers
+ (id)sharedWebService;

// Properties
@property(assign) id delegate;
@property(copy) NSString *APIKey;
@property(copy) NSString *sharedSecret;
@property(copy) NSString *clientID;

@end
