//
//  NSData+String.m
//  blubeacon-ios-testapp
//
//  Created by Jason Clary on 7/9/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "NSData+String.h"

@implementation NSData (String)

- (NSString *)hexStringRepresentation {
    const unsigned char *bytes = [self bytes];
    NSMutableString *string = [NSMutableString new];

    for (NSUInteger i = 0; i < self.length; i++) {
        [string appendFormat:@"%02X",bytes[i]];
    }

    return [NSString stringWithString:string];
}

+(NSData *)dataWithHexString:(NSString *)hex
{
    if (!hex.length) {
        return nil;
    }

    if (![hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length) {
        return nil;
    }

    char buf[3];
    buf[2] = '\0';
    NSAssert(0 == [hex length] % 2, @"Hex strings should have an even number of digits (%@)", hex);
    unsigned char *bytes = malloc([hex length]/2);
    unsigned char *bp = bytes;
    for (CFIndex i = 0; i < [hex length]; i += 2) {
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char *b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
        NSAssert(b2 == buf + 2, @"String should be all hex digits: %@ (bad digit around %ld)", hex, i);
    }

    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}

@end
