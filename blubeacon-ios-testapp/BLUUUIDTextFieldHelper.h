//
//  BLUUUIDTextFieldHelper.h
//  Beacon Maker
//
//  Created by Matthias Bauch on 19/06/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLUUUIDTextFieldHelper : NSObject

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string dashes:(BOOL)dashes length:(NSUInteger)length;

@end
