//
//  BLUMajorMinorTextFieldHelper.h
//
//  Created by Matthias Bauch on 19/06/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLUMajorMinorTextFieldHelper : NSObject

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string inHex:(BOOL)hexEnabled;
+ (uint16_t)valueFromString:(NSString *)string inHex:(BOOL)hexEnabled;
+ (NSString *)stringFromValue:(uint16_t)value inHex:(BOOL)hexEnabled;
+ (NSString *)combinedStringForValue:(uint16_t)value;
+ (uint16_t)valueFromCombinedString:(NSString *)string;
@end
