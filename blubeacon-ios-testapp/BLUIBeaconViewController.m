//
//  BLUIBeaconViewController.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 30/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUIBeaconViewController.h"
#import "BLUTextFieldCell.h"
#import "BLUHexKeyboard.h"
#import "BLUMajorMinorTextFieldHelper.h"
#import "BLUUUIDTextFieldHelper.h"
#import "NSData+String.h"

@interface BLUIBeaconViewController () <UITextFieldDelegate, BLUHexKeyboardDelegate>
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *uuidCell;
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *majorCell;
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *minorCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *rotationCell;

@property (nonatomic, weak) IBOutlet UIBarButtonItem  *saveButton;

- (IBAction)closeView:(id)sender;
- (IBAction)saveSelection:(id)sender;
@end

@implementation BLUIBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupKeyboards];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSelection:(id)sender {
    if (self.uuidCell.textField.text.length > 0) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidCell.textField.text];
        if (uuid) {
            NSNumber *major = nil;
            if (self.majorCell.textField.text.length > 0) {
                major = @([BLUMajorMinorTextFieldHelper valueFromString:self.majorCell.textField.text inHex:((BLUHexKeyboard *)self.majorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal]);
            }
            NSNumber *minor = nil;
            if (self.minorCell.textField.text.length > 0) {
                minor = @([BLUMajorMinorTextFieldHelper valueFromString:self.minorCell.textField.text inHex:((BLUHexKeyboard *)self.minorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal]);
            }

            NSData *rotationKey = nil;
            if (self.rotationCell.textField.text.length) {
                rotationKey = [NSData dataWithHexString:self.rotationCell.textField.text];
                
            }
            
            if ([self.delegate respondsToSelector:@selector(iBeaconViewController:didFinishWithIBeaconUUID:major:minor:rotationKey:)]) {
                [self.delegate iBeaconViewController:self didFinishWithIBeaconUUID:uuid major:major minor:minor rotationKey:rotationKey];
            }
            [self closeView:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter a valid iBeacon UUID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (IBAction)closeView:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard Setup

- (void)setupKeyboards {
    BLUHexKeyboard *uuidKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    uuidKeyboard.doesAllowModeSwitch = NO;
    uuidKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.uuidCell.textField.inputView = uuidKeyboard;
    self.uuidCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.uuidCell.textField];
    
    BLUHexKeyboard *majorKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    majorKeyboard.doesAllowModeSwitch = YES;
    majorKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.majorCell.textField.inputView = majorKeyboard;
    self.majorCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.majorCell.textField];
    
    BLUHexKeyboard *minorKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    minorKeyboard.doesAllowModeSwitch = YES;
    minorKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.minorCell.textField.inputView = minorKeyboard;
    self.minorCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.minorCell.textField];

    BLUHexKeyboard *rotationKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    rotationKeyboard.doesAllowModeSwitch = NO;
    rotationKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.rotationCell.textField.inputView = rotationKeyboard;
    self.rotationCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.rotationCell.textField];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.majorCell.textField] || [textField isEqual:self.minorCell.textField])
    {
        BOOL hexEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:BLUUDKeyHexModeEnabled];
        BLUHexKeyboard *hexKeyboard = (BLUHexKeyboard *)textField.inputView;
        if ([hexKeyboard isKindOfClass:[BLUHexKeyboard class]]) {
            hexEnabled = (BOOL)(hexKeyboard.mode == BLUHexKeyboardModeHexadecimal);
        }
        
        return [BLUMajorMinorTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string inHex:hexEnabled];
    }
    else if ([textField isEqual:self.uuidCell.textField]) {
        return [BLUUUIDTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField { }

- (void)textFieldDidEndEditing:(UITextField *)textField { }

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Hex Keyboard Delegate

- (UIToolbar *)newDoneToolbarForResponder:(UIResponder *)responder {
    UIToolbar *doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:responder action:@selector(resignFirstResponder)];
    doneButton.tintColor = [UIColor blackColor];
    doneBar.items = @[flexibleSpace, doneButton];
    return doneBar;
}

- (UITextField *)textFieldForKeyboard:(UIView *)keyboard {
    if ([keyboard isEqual:self.uuidCell.textField.inputView])
        return self.uuidCell.textField;
    if ([keyboard isEqual:self.majorCell.textField.inputView])
        return self.majorCell.textField;
    if ([keyboard isEqual:self.minorCell.textField.inputView])
        return self.minorCell.textField;
    if ([keyboard isEqual:self.rotationCell.textField.inputView]) {
        return self.rotationCell.textField;
    }
    return nil;
}

- (void)hexKeyboard:(BLUHexKeyboard *)keyboard didSwitchToKeyboardMode:(BLUHexKeyboardMode)newMode oldMode:(BLUHexKeyboardMode)oldMode {
    if ([keyboard isEqual:self.majorCell.textField.inputView]) {
        CLBeaconMajorValue majorValue = [BLUMajorMinorTextFieldHelper valueFromString:self.majorCell.textField.text inHex:(BOOL)(oldMode == BLUHexKeyboardModeHexadecimal)];
        self.majorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:majorValue inHex:(BOOL)(newMode == BLUHexKeyboardModeHexadecimal)];
    }
    else if ([keyboard isEqual:self.minorCell.textField.inputView]) {
        CLBeaconMinorValue minorValue = [BLUMajorMinorTextFieldHelper valueFromString:self.minorCell.textField.text inHex:(BOOL)(oldMode == BLUHexKeyboardModeHexadecimal)];
        self.minorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:minorValue inHex:(BOOL)(newMode == BLUHexKeyboardModeHexadecimal)];
    }
}

- (void)hexKeyboardDidTapRandomButton:(BLUHexKeyboard *)keyboard {
    if ([keyboard isEqual:self.uuidCell.textField.inputView]) {
        NSUUID *newUUID = [NSUUID UUID];
        self.uuidCell.textField.text = newUUID.UUIDString;
    }
    else if ([keyboard isEqual:self.majorCell.textField.inputView]) {
        CLBeaconMajorValue randomValue = arc4random_uniform(0xFFFF+1);
        self.majorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:randomValue inHex:(BOOL)(keyboard.mode == BLUHexKeyboardModeHexadecimal)];
    }
    else if ([keyboard isEqual:self.minorCell.textField.inputView]) {
        CLBeaconMinorValue randomValue = arc4random_uniform(0xFFFF+1);
        self.minorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:randomValue inHex:(BOOL)(keyboard.mode == BLUHexKeyboardModeHexadecimal)];
    }
}

@end
