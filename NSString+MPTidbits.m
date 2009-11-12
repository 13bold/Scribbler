//
//  NSString+MPTidbits.m
//  MPTidbits
//
//  Created by Matt Patenaude on 12/22/08.
//  Copyright (C) 2008 - 09 Matt Patenaude.
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

#import "NSString+MPTidbits.h"
#import "MPFunctions.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString(MPTidbits)

- (BOOL)isEmpty
{
	return [self isEmptyIgnoringWhitespace:YES];
}
- (BOOL)isEmptyIgnoringWhitespace:(BOOL)ignoreWhitespace
{
	NSString *toCheck = (ignoreWhitespace) ? [self stringByTrimmingWhitespace] : self;
	return [toCheck isEqualToString:@""];
}
- (NSString *)stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)MD5Hash
{
	const char *input = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(input, strlen(input), result);
	return MPHexStringFromBytes(result, CC_MD5_DIGEST_LENGTH);
}
- (NSString *)SHA1Hash
{
	const char *input = [self UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(input, strlen(input), result);
	return MPHexStringFromBytes(result, CC_SHA1_DIGEST_LENGTH);
}

@end

@implementation NSMutableString(MPTidbits)

- (void)trimCharactersInSet:(NSCharacterSet *)aCharacterSet
{
	// trim front
	NSRange frontRange = NSMakeRange(0, 1);
	while ([aCharacterSet characterIsMember:[self characterAtIndex:0]])
		[self deleteCharactersInRange:frontRange];
	
	// trim back
	while ([aCharacterSet characterIsMember:[self characterAtIndex:([self length] - 1)]])
		[self deleteCharactersInRange:NSMakeRange(([self length] - 1), 1)];
}
- (void)trimWhitespace
{
	[self trimCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end

