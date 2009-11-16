//
//  NSString+LFExtensions.m
//  Scribbler
//
//  Created by Matt Patenaude on 11/6/09.
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

#import "NSString+LFExtensions.h"
#import <CommonCrypto/CommonDigest.h>


NSString *LFHexStringFromBytes(void *bytes, NSUInteger len)
{
	NSMutableString *output = [NSMutableString string];
	
	unsigned char *input = (unsigned char *)bytes;
	
	NSUInteger i;
	for (i = 0; i < len; i++)
		[output appendFormat:@"%02x", input[i]];
	return output;
}

@implementation NSString (LFExtensions)

- (NSString *)MD5Hash
{
	const char *input = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(input, strlen(input), result);
	return LFHexStringFromBytes(result, CC_MD5_DIGEST_LENGTH);
}
+ (NSString *)stringWithNewUUID
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *output = (NSString *)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
	
    return [output autorelease];
}

@end
