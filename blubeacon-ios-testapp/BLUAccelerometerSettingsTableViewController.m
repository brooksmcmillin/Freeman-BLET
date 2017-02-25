//
//  BLUAccelerometerSettingsTableViewController.m
//  blubeacon-ios-testapp
//
//  Created by Jason Clary on 3/11/16.
//  Copyright © 2016 Bluvision Inc. All rights reserved.
//

#import "BLUAccelerometerSettingsTableViewController.h"
#import "BLUTextFieldCell.h"

#import <Bluvision/Bluvision.h>

@interface BLUAccelerometerSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *motionXAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *motionYAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *motionZAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *transientXAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *transientYAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *transientZAxisSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *highPassFilterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *motionThreasholdSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *transientThreasholdSwitch;

@property (weak, nonatomic) IBOutlet BLUTextFieldCell *motionSensitivityCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *transientSensitivityCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *motionDebounceCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *transientDebounceCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *rateCell;
@property (weak, nonatomic) IBOutlet BLUTextFieldCell *cutoffCell;

@property (weak, nonatomic) IBOutlet UILabel *xAxisLabel;
@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel;
@property (weak, nonatomic) IBOutlet UILabel *zAxisLabel;

@property (weak, nonatomic) IBOutlet UILabel *xCounterPlus;
@property (weak, nonatomic) IBOutlet UILabel *yCounterPlus;
@property (weak, nonatomic) IBOutlet UILabel *zCounterPlus;

@property (weak, nonatomic) IBOutlet UILabel *xCounterMinus;
@property (weak, nonatomic) IBOutlet UILabel *zCounterMinus;
@property (weak, nonatomic) IBOutlet UILabel *yCounterMinus;

@end

@implementation BLUAccelerometerSettingsTableViewController

- (void)viewDidLoad {

    if (!self.accelerometerSettings) {
        self.accelerometerSettings = [BLUAccelerometerSettings defaultSettings];
    }

    [self configure];
}

- (void)configure {
    self.motionXAxisSwitch.on = self.accelerometerSettings.motionAxisesEnables & BLUMotionAxisEnabledX;
    self.motionYAxisSwitch.on = self.accelerometerSettings.motionAxisesEnables & BLUMotionAxisEnabledY;
    self.motionZAxisSwitch.on = self.accelerometerSettings.motionAxisesEnables & BLUMotionAxisEnabledZ;

    self.transientXAxisSwitch.on = self.accelerometerSettings.transientAxisesEnables & BLUMotionAxisEnabledX;
    self.transientYAxisSwitch.on = self.accelerometerSettings.transientAxisesEnables & BLUMotionAxisEnabledY;
    self.transientZAxisSwitch.on = self.accelerometerSettings.transientAxisesEnables & BLUMotionAxisEnabledZ;

    self.highPassFilterSwitch.on = self.accelerometerSettings.isHighPassFilterEnabled;
    self.motionThreasholdSwitch.on = self.accelerometerSettings.isMotionThreasholdEnabled;
    self.transientThreasholdSwitch.on = self.accelerometerSettings.isTransientThreasholdEnabled;

    self.motionSensitivityCell.textField.text = @(self.accelerometerSettings.motionSensitivity).stringValue;
    self.transientSensitivityCell.textField.text = @(self.accelerometerSettings.transientSensitivity).stringValue;
    self.motionDebounceCell.textField.text = @(self.accelerometerSettings.motionDebounce).stringValue;
    self.transientDebounceCell.textField.text = @(self.accelerometerSettings.transientDebounce).stringValue;
    self.rateCell.textField.text = @(self.accelerometerSettings.rate).stringValue;
    self.cutoffCell.textField.text = @(self.accelerometerSettings.cutoff).stringValue;

    [self startReadingAccelerometerData];
}

- (IBAction)save:(id)sender {
    BLUMotionAxisEnabled motionAxises = self.motionXAxisSwitch.on << 0 | self.motionYAxisSwitch.on << 1 | self.motionZAxisSwitch.on << 2;
    self.accelerometerSettings.motionAxisesEnables = motionAxises;

    BLUMotionAxisEnabled transientAxises = self.transientXAxisSwitch.on << 0 | self.transientYAxisSwitch.on << 1 | self.transientZAxisSwitch.on << 2;

    self.accelerometerSettings.transientAxisesEnables = transientAxises;
    self.accelerometerSettings.highPassFilterEnabled = self.highPassFilterSwitch.on;
    self.accelerometerSettings.motionThreasholdEnabled = self.motionThreasholdSwitch.on;
    self.accelerometerSettings.transientThreasholdEnabled = self.transientThreasholdSwitch.on;
    self.accelerometerSettings.motionSensitivity = self.motionSensitivityCell.textField.text.integerValue;
    self.accelerometerSettings.transientSensitivity = self.transientSensitivityCell.textField.text.integerValue;
    self.accelerometerSettings.motionDebounce = self.motionDebounceCell.textField.text.integerValue;
    self.accelerometerSettings.transientDebounce = self.transientDebounceCell.textField.text.integerValue;
    self.accelerometerSettings.rate = self.rateCell.textField.text.integerValue;
    self.accelerometerSettings.cutoff = self.cutoffCell.textField.text.integerValue;

    typeof(self) __weak weakSelf = self;
    [self.beacon setAccelerometerSettings:self.accelerometerSettings completion:^(BOOL success, NSError * _Nonnull error) {
        typeof(self) __strong strongSelf = weakSelf;

        if (error) {
            [strongSelf showAlertWithTitle:@"Error" message:error.localizedDescription];
            return;
        }

        [strongSelf showAlertWithTitle:@"Succes" message:@"Saved accelerometer settings to device"];
    }];
}

- (void)startReadingAccelerometerData {
    [self.beacon startReadingAccelerometerDataWithBlock:^(BLUAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        self.xCounterPlus.text = [@"X: " stringByAppendingString:accelerometerData.xAxisPositiveCounter.stringValue];
        self.xCounterMinus.text = [@"X: " stringByAppendingString:accelerometerData.xAxisNegitiveCounter.stringValue];
        self.yCounterPlus.text = [@"Y: " stringByAppendingString:accelerometerData.yAxisPositiveCounter.stringValue];
        self.yCounterMinus.text = [@"Y: " stringByAppendingString:accelerometerData.yAxisNegitiveCounter.stringValue];
        self.zCounterPlus.text = [@"Z: " stringByAppendingString:accelerometerData.zAxisPositiveCounter.stringValue];
        self.zCounterMinus.text = [@"Z: " stringByAppendingString:accelerometerData.zAxisNegitiveCounter.stringValue];
        self.xAxisLabel.text = [@"X: " stringByAppendingString:accelerometerData.xAxisAcceleration.stringValue];
        self.yAxisLabel.text = [@"Y: " stringByAppendingString:accelerometerData.yAxisAcceleration.stringValue];
        self.zAxisLabel.text = [@"Z: " stringByAppendingString:accelerometerData.zAxisAcceleration.stringValue];
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
