//
//  BLUMajorMinorTextFieldHelper.m
//  Beacon Maker
//
//  Created by Matthias Bauch on 19/06/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import "BLUMajorMinorTextFieldHelper.h"

@implementation BLUMajorMinorTextFieldHelper

+ (BOOL)isStringValidDecimalMajorMinorValue:(NSString *)string {
    NSCharacterSet *decCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    // should not have a character that is not in decCharacterSet
    if ([string rangeOfCharacterFromSet:[decCharacterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    // should not be longer than 5 char, 65535 is max
    if ([string length] > 5) {
        return NO;
    }
    // should not start with 0
    if ([string hasPrefix:@"0"]) {
        return NO;
    }
    // value should not be bigger than 0xFFF (65535)
    NSInteger value = [string integerValue];
    if (value > 65535) {
        return NO;
    }
    return YES;
}

+ (BOOL)isStringValidHexadecimalMajorMinorValue:(NSString *)string {
    NSCharacterSet *hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
    // should not have a character that is not in hexCharacterSet
    if ([string rangeOfCharacterFromSet:[hexCharacterSet invertedSet]].location != NSNotFound) {
        return NO;
    }
    // should not be longer than 4 char, FFFF is max
    if ([string length] > 4) {
        return NO;
    }
    return YES;
}

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string inHex:(BOOL)hexEnabled {
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *squashed = [resultingString stringByReplacingOccurrencesOfString:@"[\\s]+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, resultingString.length)];
    NSString *resultWithoutWhiteSpace = [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL isValidHexString = [self isStringValidHexadecimalMajorMinorValue:resultWithoutWhiteSpace];
    BOOL isValidDecString = [self isStringValidDecimalMajorMinorValue:resultWithoutWhiteSpace];
    
    if (hexEnabled) {
        if (!isValidHexString) {
            return NO;
        }
    }
    else {
        if (!isValidDecString) {
            return NO;
        }
    }
    
    resultWithoutWhiteSpace = [resultWithoutWhiteSpace uppercaseString];
    // set modified text back. and since we modified the text ourselves, return NO to prevent further modifications
    textField.text = resultWithoutWhiteSpace;
    return NO;
}

+ (uint16_t)valueFromString:(NSString *)string inHex:(BOOL)hexEnabled {
    uint16_t returnValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    if (hexEnabled) {
        unsigned int value;
        if ([scanner scanHexInt:&value]) {
            returnValue = (uint16_t)value;
        }
    }
    else {
        int value;
        if ([scanner scanInt:&value]) {
            returnValue = (uint16_t)value;
        }
    }
    return returnValue;
}

+ (NSString *)stringFromValue:(uint16_t)value inHex:(BOOL)hexEnabled {
    NSString *string;
    // treat 0 as empty text
    if (value != 0) {
        if (hexEnabled) {
            string = [NSString stringWithFormat:@"%04X", value];
        }
        else {
            string = [NSString stringWithFormat:@"%u", value];
        }
    }
    return string;
}

+ (NSString *)combinedStringForValue:(uint16_t)value {
    return [NSString stringWithFormat:@"%u / %04X", value, value];
}

+ (uint16_t)valueFromCombinedString:(NSString *)string {
    // TODO: DO proper parsing depending on settings configuration
    return [self valueFromString:string inHex:NO];
}

@end
