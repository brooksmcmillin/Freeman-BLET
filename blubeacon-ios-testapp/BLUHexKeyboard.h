//
//  BLUHexKeyboard.h
//
//  Created by Matthias Bauch on 15/05/14.
//  Copyright (c) 2014 Matthias Bauch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BLUHexKeyboardMode) {
    BLUHexKeyboardModeHexadecimal,
    BLUHexKeyboardModeDecimal
};

// keys for UserDefaults
extern NSString * const BLUUDKeyHexModeEnabled;

// keys for notifications
extern NSString * const BLUHexModeDidChangeNotification;

@class BLUHexKeyboard;

@protocol BLUHexKeyboardDelegate <NSObject>
@optional
- (void)hexKeyboard:(BLUHexKeyboard *)keyboard didSwitchToKeyboardMode:(BLUHexKeyboardMode)newMode oldMode:(BLUHexKeyboardMode)oldMode;
- (void)hexKeyboardDidTapRandomButton:(BLUHexKeyboard *)keyboard;
- (void)hexKeyboardWillCloseRecentMenu:(BLUHexKeyboard *)keyboard;
@end

@interface BLUHexKeyboard : UIView
@property (weak, nonatomic) id <BLUHexKeyboardDelegate> delegate;
@property (assign, nonatomic) BLUHexKeyboardMode mode;
@property (assign, nonatomic) BOOL doesAllowModeSwitch;


+ (instancetype)keyboardWithDelegate:(id <BLUHexKeyboardDelegate>)delegate;
@end
