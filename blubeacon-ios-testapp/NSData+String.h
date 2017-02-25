//
//  NSData+String.h
//  blubeacon-ios-testapp
//
//  Created by Jason Clary on 7/9/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (String)

- (NSString *)hexStringRepresentation;
+(NSData *)dataWithHexString:(NSString *)hex;

@end
