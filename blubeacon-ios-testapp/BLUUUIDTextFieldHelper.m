//
//  BLUUUIDTextFieldHelper.m
//  Beacon Maker
//
//  Created by Matthias Bauch on 19/06/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import "BLUUUIDTextFieldHelper.h"

@implementation BLUUUIDTextFieldHelper

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self textField:textField shouldChangeCharactersInRange:range replacementString:string dashes:YES length:32];
}

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string dashes:(BOOL)dashes length:(NSUInteger)length {
    NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF-"];

    NSString *stringToReplace = [textField.text substringWithRange:range];
    if ([stringToReplace isEqualToString:@"-"]) {
        // user does not want to delete dash, he wants to delete the number before the dash. so delete both
        range = NSMakeRange(range.location-1, range.length+1);
    }

    NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSString *squashed = [resultingString stringByReplacingOccurrencesOfString:@"[\\s]+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, resultingString.length)];
    NSString *resultWithoutWhiteSpace = [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([resultWithoutWhiteSpace rangeOfCharacterFromSet:[hexCharacterSet invertedSet]].location != NSNotFound) {
        return NO;
    }

    NSString *uuidWithoutDashes = [resultWithoutWhiteSpace stringByReplacingOccurrencesOfString:@"-" withString:@""];

    // turn into upper case string
    uuidWithoutDashes = [uuidWithoutDashes uppercaseString];

    // uuid is 36, without dashes it should be 32
    if ([uuidWithoutDashes length] > length) {
        return NO;
    }

    // add dashes back when string is long enoughd
    NSMutableString *uuidWithAddedDashed = [uuidWithoutDashes mutableCopy];

    if (dashes) {
        if ([uuidWithAddedDashed length] > 7) {
            [uuidWithAddedDashed insertString:@"-" atIndex:8];
        }
        if ([uuidWithAddedDashed length] > 12) {
            [uuidWithAddedDashed insertString:@"-" atIndex:13];
        }
        if ([uuidWithAddedDashed length] > 17) {
            [uuidWithAddedDashed insertString:@"-" atIndex:18];
        }
        if ([uuidWithAddedDashed length] > 22) {
            [uuidWithAddedDashed insertString:@"-" atIndex:23];
        }
    }


    // set modified text back. and since we modified the text ourselves, return NO to prevent further modifications
    textField.text = uuidWithAddedDashed;
    return NO;
}

@end
