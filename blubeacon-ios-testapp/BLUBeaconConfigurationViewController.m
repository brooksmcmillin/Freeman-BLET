//
//  BLUBeaconConfigurationViewController.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 25/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUBeaconConfigurationViewController.h"
#import "BLUBeaconAdvancedSettingsViewController.h"
#import "BLUTextFieldCell.h"
#import "BLUHexKeyboard.h"
#import "BLUMajorMinorTextFieldHelper.h"
#import "BLUUUIDTextFieldHelper.h"
#import "NSData+String.h"
#import "BLUAccelerometerSettingsTableViewController.h"

typedef NS_ENUM(NSUInteger, BLUBeaconConfigurationSection) {
    BLUBeaconConfigurationSectionSBeaconV1 = 0,
    BLUBeaconConfigurationSectionSBeaconV2,
    BLUBeaconConfigurationSectionIBeacon,
    BLUBeaconConfigurationSectionEddystoneUIDBeacon,
    BLUBeaconConfigurationSectionEddystoneURLBeacon,
    BLUBeaconConfigurationSectionEddystoneTLMBeacon,
    BLUBeaconConfigurationSectionMotionBeacon,
    BLUBeaconConfigurationSectionLightSensorBeacon
};

@interface BLUBeaconConfigurationViewController () <BLUHexKeyboardDelegate>
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *iBeaconUUIDCell;
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *iBeaconMajorCell;
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *iBeaconMinorCell;

@property (nonatomic, weak) IBOutlet BLUTextFieldCell *eddystoneBeaconNamespaceCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *eddystoneBeaconInstanceCell;
@property (nonatomic, weak) IBOutlet BLUTextFieldCell *eddystoneBeaconURLCell;
@end

@implementation BLUBeaconConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupKeyboards];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshLabels];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveValues];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Content

- (void)refreshLabels {
    switch (self.configurationType) {
        case BLUConfigurationTypeIBeacon:
            self.iBeaconUUIDCell.textField.text = [self.scheduledConfiguration.iBeacon.proximityUUID UUIDString];
            CLBeaconMajorValue majorValue = [self.scheduledConfiguration.iBeacon.major unsignedIntValue];
            self.iBeaconMajorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:majorValue inHex:(BOOL)(((BLUHexKeyboard *)self.iBeaconMajorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal)];
            CLBeaconMajorValue minorValue = [self.scheduledConfiguration.iBeacon.minor unsignedIntValue];
            self.iBeaconMinorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:minorValue inHex:(BOOL)(((BLUHexKeyboard *)self.iBeaconMinorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal)];
            break;
        case BLUConfigurationTypeSBeacon:
            break;
        case BLUConfigurationTypeEddystoneBeacon:
            self.eddystoneBeaconURLCell.textField.text = self.scheduledConfiguration.eddystoneURLBeacon.URL.absoluteString ?: nil;
            self.eddystoneBeaconNamespaceCell.textField.text = [self.scheduledConfiguration.eddystoneUIDBeacon.identifier.namespaceIdentifier hexStringRepresentation];
            self.eddystoneBeaconInstanceCell.textField.text = [self.scheduledConfiguration.eddystoneUIDBeacon.identifier.instanceIdentifier hexStringRepresentation];
            break;
        case BLUConfigurationTypeMotionBeacon:
            break;
        case BLUConfigurationTypeNone:
        default:
            break;
    }
}

- (void)saveValues {
    switch (self.configurationType) {
        case BLUConfigurationTypeIBeacon: {
            NSUUID *UUID = self.scheduledConfiguration.iBeacon.proximityUUID;
            if (self.iBeaconUUIDCell.textField.text.length > 0) {
                NSUUID *userUUID = [[NSUUID alloc] initWithUUIDString:self.iBeaconUUIDCell.textField.text];
                if (userUUID) {
                    UUID = userUUID;
                }
            }
            NSNumber *major = self.scheduledConfiguration.iBeacon.major;
            if (self.iBeaconMajorCell.textField.text.length > 0) {
                major = @([BLUMajorMinorTextFieldHelper valueFromString:self.iBeaconMajorCell.textField.text inHex:((BLUHexKeyboard *)self.iBeaconMajorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal]);
            }
            NSNumber *minor = self.scheduledConfiguration.iBeacon.minor;
            if (self.iBeaconMinorCell.textField.text.length > 0) {
                minor = @([BLUMajorMinorTextFieldHelper valueFromString:self.iBeaconMinorCell.textField.text inHex:((BLUHexKeyboard *)self.iBeaconMinorCell.textField.inputView).mode == BLUHexKeyboardModeHexadecimal]);
            }
            BLUIBeacon *iBeacon = [[BLUIBeacon alloc] initWithProximityUUID:UUID major:major minor:minor];
            self.scheduledConfiguration.iBeacon = iBeacon;
            break;
        }
        case BLUConfigurationTypeSBeacon:
            break;
        case BLUConfigurationTypeEddystoneBeacon: {

            NSData *namespace = [NSData dataWithHexString:self.eddystoneBeaconNamespaceCell.textField.text];
            NSData *instance = [NSData dataWithHexString:self.eddystoneBeaconInstanceCell.textField.text];

            BLUEddystoneIdentifier *identifier = self.scheduledConfiguration.eddystoneUIDBeacon.identifier;

            if (namespace && instance) {
                identifier =[[BLUEddystoneIdentifier alloc] initWithNamespaceIdentifier:namespace instanceIdentifier:instance];
            }

            BLUEddystoneUIDBeacon *eddystoneUIDBeacon = [[BLUEddystoneUIDBeacon alloc] initWithIdentifier:identifier];
            self.scheduledConfiguration.eddystoneUIDBeacon = eddystoneUIDBeacon;
            
            NSURL *URL = self.scheduledConfiguration.eddystoneURLBeacon.URL;
            if (self.eddystoneBeaconURLCell.textField.text.length > 0) {
                NSURL *userURL = [NSURL URLWithString:self.eddystoneBeaconURLCell.textField.text];
                if (userURL) {
                    URL = userURL;
                }
            }
            BLUEddystoneURLBeacon *eddystoneURLBeacon = [[BLUEddystoneURLBeacon alloc] initWithURL:URL];
            self.scheduledConfiguration.eddystoneURLBeacon = eddystoneURLBeacon;
            
            break;
        }
        case BLUConfigurationTypeMotionBeacon:
        case BLUConfigurationTypeLightSensorBeacon:
        case BLUConfigurationTypeNone:
        default:
            break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushAdvancedSettings"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        BLUBeaconAdvancedSettingsViewController *viewController = (BLUBeaconAdvancedSettingsViewController *)segue.destinationViewController;
        viewController.configurationBeacon  = [self configurationBeaconForSection:indexPath.section];
        viewController.advancedSettings     = [self advancedSettingsForSection:indexPath.section];
    }
    if ([segue.identifier isEqualToString:@"showAccelerometerSettings"]) {
        BLUAccelerometerSettingsTableViewController *viewController = (BLUAccelerometerSettingsTableViewController *)segue.destinationViewController;
        viewController.beacon = (BLUSBeacon *)self.configurableBeacon;
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger rowCount = [tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.section <= BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (indexPath.row == rowCount - 1) {
            [self performSegueWithIdentifier:@"pushAdvancedSettings" sender:indexPath];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeSBeacon) {
            return 0.0;
        }
    }
    else if (indexPath.section == BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeIBeacon) {
            return 0.0;
        }
    }
    else if (indexPath.section == BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeMotionBeacon) {
            return 0.0;
        }
    }
    else if (indexPath.section == BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (self.configurationType != BLUConfigurationTypeLightSensorBeacon) {
            return 0.0;
        }
    }
    else if (indexPath.section > BLUBeaconConfigurationSectionIBeacon &&
             indexPath.section < BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeEddystoneBeacon) {
            return 0.0;
        }
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeSBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeIBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeMotionBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (self.configurationType != BLUConfigurationTypeLightSensorBeacon) {
            return nil;
        }
    }
    else if (section > BLUBeaconConfigurationSectionIBeacon &&
             section < BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeEddystoneBeacon) {
            return nil;
        }
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section < BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeSBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeIBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeMotionBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (self.configurationType != BLUConfigurationTypeLightSensorBeacon) {
            return 0.000001;
        }
    }
    else if (section > BLUBeaconConfigurationSectionIBeacon &&
             section < BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeEddystoneBeacon) {
            return 0.000001;
        }
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section < BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeSBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeIBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeMotionBeacon) {
            return nil;
        }
    }
    else if (section == BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (self.configurationType != BLUConfigurationTypeLightSensorBeacon) {
            return nil;
        }
    }
    else if (section > BLUBeaconConfigurationSectionIBeacon &&
             section < BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeEddystoneBeacon) {
            return nil;
        }
    }
    
    return [super tableView:tableView titleForFooterInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeSBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionIBeacon) {
        if (self.configurationType != BLUConfigurationTypeIBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeMotionBeacon) {
            return 0.000001;
        }
    }
    else if (section == BLUBeaconConfigurationSectionLightSensorBeacon) {
        if (self.configurationType != BLUConfigurationTypeLightSensorBeacon) {
            return 0.000001;
        }
    }
    else if (section > BLUBeaconConfigurationSectionIBeacon &&
             section < BLUBeaconConfigurationSectionMotionBeacon) {
        if (self.configurationType != BLUConfigurationTypeEddystoneBeacon) {
            return 0.000001;
        }
    }
    
    return [super tableView:tableView heightForFooterInSection:section];
}

#pragma mark - Keyboard Setup

- (void)setupKeyboards {
    BLUHexKeyboard *iUUIDKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    iUUIDKeyboard.doesAllowModeSwitch = NO;
    iUUIDKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.iBeaconUUIDCell.textField.inputView = iUUIDKeyboard;
    self.iBeaconUUIDCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.iBeaconUUIDCell.textField];
    
    BLUHexKeyboard *majorKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    majorKeyboard.doesAllowModeSwitch = YES;
    majorKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.iBeaconMajorCell.textField.inputView = majorKeyboard;
    self.iBeaconMajorCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.iBeaconMajorCell.textField];
    
    BLUHexKeyboard *minorKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    minorKeyboard.doesAllowModeSwitch = YES;
    minorKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.iBeaconMinorCell.textField.inputView = minorKeyboard;
    self.iBeaconMinorCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.iBeaconMinorCell.textField];

    BLUHexKeyboard *eddystoneUIDKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    eddystoneUIDKeyboard.doesAllowModeSwitch = NO;
    eddystoneUIDKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.eddystoneBeaconNamespaceCell.textField.inputView = eddystoneUIDKeyboard;
    self.eddystoneBeaconNamespaceCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.eddystoneBeaconNamespaceCell.textField];

    BLUHexKeyboard *eddystoneInstanceKeyboard = [BLUHexKeyboard keyboardWithDelegate:self];
    eddystoneInstanceKeyboard.doesAllowModeSwitch = NO;
    eddystoneInstanceKeyboard.mode = BLUHexKeyboardModeHexadecimal;
    self.eddystoneBeaconInstanceCell.textField.inputView = eddystoneInstanceKeyboard;
    self.eddystoneBeaconInstanceCell.textField.inputAccessoryView = [self newDoneToolbarForResponder:self.eddystoneBeaconInstanceCell.textField];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.iBeaconMajorCell.textField] || [textField isEqual:self.iBeaconMinorCell.textField])
    {
        BOOL hexEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:BLUUDKeyHexModeEnabled];
        BLUHexKeyboard *hexKeyboard = (BLUHexKeyboard *)textField.inputView;
        if ([hexKeyboard isKindOfClass:[BLUHexKeyboard class]]) {
            hexEnabled = (BOOL)(hexKeyboard.mode == BLUHexKeyboardModeHexadecimal);
        }
        
        return [BLUMajorMinorTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string inHex:hexEnabled];
    }
    else if ([textField isEqual:self.iBeaconUUIDCell.textField]) {
        return [BLUUUIDTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    else if ([textField isEqual:self.eddystoneBeaconNamespaceCell.textField]) {
        return [BLUUUIDTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string dashes:NO length:20];
    }
    else if ([textField isEqual:self.eddystoneBeaconInstanceCell.textField]) {
        return [BLUUUIDTextFieldHelper textField:textField shouldChangeCharactersInRange:range replacementString:string dashes:NO length:12];
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
    if ([keyboard isEqual:self.iBeaconUUIDCell.textField.inputView]) {
        return self.iBeaconUUIDCell.textField;
    }
    if ([keyboard isEqual:self.iBeaconMajorCell.textField.inputView]) {
        return self.iBeaconMajorCell.textField;
    }
    if ([keyboard isEqual:self.iBeaconMinorCell.textField.inputView]) {
        return self.iBeaconMinorCell.textField;
    }
    if ([keyboard isEqual:self.eddystoneBeaconNamespaceCell.textField.inputView]) {
        return self.eddystoneBeaconNamespaceCell.textField;
    }

    if ([keyboard isEqual:self.eddystoneBeaconInstanceCell.textField.inputView]) {
        return self.eddystoneBeaconInstanceCell.textField;
    }
    
    return nil;
}

- (void)hexKeyboard:(BLUHexKeyboard *)keyboard didSwitchToKeyboardMode:(BLUHexKeyboardMode)newMode oldMode:(BLUHexKeyboardMode)oldMode {
    if ([keyboard isEqual:self.iBeaconMajorCell.textField.inputView]) {
        CLBeaconMajorValue majorValue = [BLUMajorMinorTextFieldHelper valueFromString:self.iBeaconMajorCell.textField.text inHex:(BOOL)(oldMode == BLUHexKeyboardModeHexadecimal)];
        self.iBeaconMajorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:majorValue inHex:(BOOL)(newMode == BLUHexKeyboardModeHexadecimal)];
    }
    else if ([keyboard isEqual:self.iBeaconMinorCell.textField.inputView]) {
        CLBeaconMinorValue minorValue = [BLUMajorMinorTextFieldHelper valueFromString:self.iBeaconMinorCell.textField.text inHex:(BOOL)(oldMode == BLUHexKeyboardModeHexadecimal)];
        self.iBeaconMinorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:minorValue inHex:(BOOL)(newMode == BLUHexKeyboardModeHexadecimal)];
    }
}

- (void)hexKeyboardDidTapRandomButton:(BLUHexKeyboard *)keyboard {
    if ([keyboard isEqual:self.iBeaconUUIDCell.textField.inputView]) {
        NSUUID *newUUID = [NSUUID UUID];
        self.iBeaconUUIDCell.textField.text = newUUID.UUIDString;
    }
    else if ([keyboard isEqual:self.eddystoneBeaconNamespaceCell.textField.inputView]) {
        NSUUID *newUID = [NSUUID UUID];
        uuid_t uuid;
        [newUID getUUIDBytes:uuid];

        NSData *namespace = [NSData dataWithBytes:uuid length:10];

        self.eddystoneBeaconNamespaceCell.textField.text = [namespace hexStringRepresentation];
    }
    else if ([keyboard isEqual:self.eddystoneBeaconInstanceCell.textField.inputView]) {
        NSUUID *newUID = [NSUUID UUID];
        uuid_t uuid;
        [newUID getUUIDBytes:uuid];

        NSData *instance = [NSData dataWithBytes:uuid length:6];
        self.eddystoneBeaconInstanceCell.textField.text = [instance hexStringRepresentation];
    }
    else if ([keyboard isEqual:self.iBeaconMajorCell.textField.inputView]) {
        CLBeaconMajorValue randomValue = arc4random_uniform(0xFFFF+1);
        self.iBeaconMajorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:randomValue inHex:(BOOL)(keyboard.mode == BLUHexKeyboardModeHexadecimal)];
    }
    else if ([keyboard isEqual:self.iBeaconMinorCell.textField.inputView]) {
        CLBeaconMinorValue randomValue = arc4random_uniform(0xFFFF+1);
        self.iBeaconMinorCell.textField.text = [BLUMajorMinorTextFieldHelper stringFromValue:randomValue inHex:(BOOL)(keyboard.mode == BLUHexKeyboardModeHexadecimal)];
    }
}

#pragma mark - Helpers

- (BLUBeaconAdvancedSettings *)advancedSettingsForSection:(NSInteger)section {
    switch (section) {
        case BLUBeaconConfigurationSectionSBeaconV1:
            return self.scheduledConfiguration.sBeaconV1AdvancedSettings;
        case BLUBeaconConfigurationSectionSBeaconV2:
            return self.scheduledConfiguration.sBeaconV2AdvancedSettings;
        case BLUBeaconConfigurationSectionIBeacon:
            return self.scheduledConfiguration.iBeaconAdvancedSettings;
        case BLUBeaconConfigurationSectionEddystoneUIDBeacon:
            return self.scheduledConfiguration.eddystoneBeaconUIDAdvancedSettings;
        case BLUBeaconConfigurationSectionEddystoneURLBeacon:
            return self.scheduledConfiguration.eddystoneBeaconURLAdvancedSettings;
        case BLUBeaconConfigurationSectionEddystoneTLMBeacon:
            return self.scheduledConfiguration.eddystoneBeaconTLMAdvancedSettings;
        case BLUBeaconConfigurationSectionMotionBeacon:
            return self.scheduledConfiguration.motionBeaconAdvancedSettings;
        case BLUBeaconConfigurationSectionLightSensorBeacon:
            return self.scheduledConfiguration.lightSensorBeaconAdvancedSettings;
        default:
            return nil;
    }
}

- (id)configurationBeaconForSection:(NSInteger)section {
    switch (section) {
        case BLUBeaconConfigurationSectionSBeaconV1:
            return self.scheduledConfiguration.sBeacon;
        case BLUBeaconConfigurationSectionSBeaconV2:
            return self.scheduledConfiguration.sBeacon;
        case BLUBeaconConfigurationSectionIBeacon:
            return self.scheduledConfiguration.iBeacon;
        case BLUBeaconConfigurationSectionEddystoneUIDBeacon:
            return self.scheduledConfiguration.eddystoneUIDBeacon;
        case BLUBeaconConfigurationSectionEddystoneURLBeacon:
            return self.scheduledConfiguration.eddystoneURLBeacon;
        case BLUBeaconConfigurationSectionEddystoneTLMBeacon:
        case BLUBeaconConfigurationSectionMotionBeacon:
        case BLUBeaconConfigurationSectionLightSensorBeacon:
        default:
            return nil;
    }
}

@end
