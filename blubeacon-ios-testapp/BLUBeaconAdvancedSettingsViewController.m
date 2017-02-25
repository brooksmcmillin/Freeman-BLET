//
//  BLUBeaconAdvancedSettingsViewController.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUBeaconAdvancedSettingsViewController.h"
#import "BLUTableViewCell.h"
#import "BLUPickerCell.h"
#import "BLUBeaconFormatter.h"
#import "IntervalPickerDataSource.h"

@interface BLUBeaconAdvancedSettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate, IntervalPickerDataSourceDelegate>
@property (nonatomic, weak) IBOutlet BLUTableViewCell           *dayIntervalCell;
@property (nonatomic, weak) IBOutlet BLUPickerCell              *dayIntervalPickerCell;
@property (nonatomic, weak) IBOutlet BLUTableViewCell           *dayTxPowerCell;
@property (nonatomic, weak) IBOutlet BLUPickerCell              *dayTxPowerPickerCell;

@property (nonatomic, weak) IBOutlet BLUTableViewCell           *nightIntervalCell;
@property (nonatomic, weak) IBOutlet BLUPickerCell              *nightIntervalPickerCell;
@property (nonatomic, weak) IBOutlet BLUTableViewCell           *nightTxPowerCell;
@property (nonatomic, weak) IBOutlet BLUPickerCell              *nightTxPowerPickerCell;
@property (weak, nonatomic) IBOutlet UISwitch *connectableSwitch;

@property (nonatomic, strong) IntervalPickerDataSource *intervalPickerDataSource;

@end

@implementation BLUBeaconAdvancedSettingsViewController {
    BOOL _showsDayIntervalPicker;
    BOOL _showsDayTxPowerPicker;
    BOOL _showsNightIntervalPicker;
    BOOL _showsNightTxPowerPicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View setup

- (void)setupCells {
    [self.dayTxPowerCell toggleFullSeparatorInsets:!_showsDayTxPowerPicker];
    [self.nightTxPowerCell toggleFullSeparatorInsets:!_showsNightTxPowerPicker];

    self.intervalPickerDataSource = [[IntervalPickerDataSource alloc] init];
    self.intervalPickerDataSource.delegate = self;

    self.dayIntervalPickerCell.pickerView.delegate = self.intervalPickerDataSource;
    self.dayIntervalPickerCell.pickerView.dataSource = self.intervalPickerDataSource;

    self.nightIntervalPickerCell.pickerView.delegate = self.intervalPickerDataSource;
    self.nightIntervalPickerCell.pickerView.dataSource = self.intervalPickerDataSource;


    [self.dayIntervalPickerCell.pickerView selectRow:(NSUInteger)self.advancedSettings.advertisementInterval inComponent:0 animated:NO];
    NSUInteger dayMantissa = (self.advancedSettings.advertisementInterval - (NSUInteger)(self.advancedSettings.advertisementInterval)) * 100;
    [self.dayIntervalPickerCell.pickerView selectRow:dayMantissa inComponent:2 animated:NO];

    [self.nightIntervalPickerCell.pickerView selectRow:(NSUInteger)self.advancedSettings.energySavingAdvertisementInterval inComponent:0 animated:NO];
    NSUInteger nightMantissa =(self.advancedSettings.energySavingAdvertisementInterval - (NSUInteger)(self.advancedSettings.energySavingAdvertisementInterval)) * 100;
    [self.nightIntervalPickerCell.pickerView selectRow:nightMantissa inComponent:2 animated:NO];

    self.dayIntervalCell.detailTextLabel.text = [self hertzDetailStringForInterval:self.advancedSettings.advertisementInterval];
    self.nightIntervalCell.detailTextLabel.text = [self hertzDetailStringForInterval:self.advancedSettings.energySavingAdvertisementInterval];

    NSInteger dayTxIndex = [BLUBeaconFormatter indexForTxPowerValue:@(self.advancedSettings.transmissionPower)];

    self.dayTxPowerCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dBm", [BLUBeaconFormatter txPowerValues][dayTxIndex]];
    [self.dayTxPowerPickerCell.pickerView selectRow:dayTxIndex inComponent:0 animated:NO];
    
    NSInteger nightTxIndex = [BLUBeaconFormatter indexForTxPowerValue:@(self.advancedSettings.energySavingTransmissionPower)];
    self.nightTxPowerCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dBm", [BLUBeaconFormatter txPowerValues][nightTxIndex]];
    [self.nightTxPowerPickerCell.pickerView selectRow:nightTxIndex inComponent:0 animated:NO];

    if ([self.advancedSettings isKindOfClass:[BLUEddystoneBeaconAdvancedSettings class]]) {
        BLUEddystoneBeaconAdvancedSettings *eddystoneSettings = (BLUEddystoneBeaconAdvancedSettings *)self.advancedSettings;
        self.connectableSwitch.on = eddystoneSettings.isConnectable;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            _showsDayIntervalPicker     = !_showsDayIntervalPicker;
            _showsDayTxPowerPicker      = NO;
            _showsNightIntervalPicker   = NO;
            _showsNightTxPowerPicker    = NO;
        }
        else if (indexPath.row == 2) {
            _showsDayTxPowerPicker      = !_showsDayTxPowerPicker;
            _showsDayIntervalPicker     = NO;
            _showsNightIntervalPicker   = NO;
            _showsNightTxPowerPicker    = NO;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _showsNightIntervalPicker   = !_showsNightIntervalPicker;
            _showsDayIntervalPicker     = NO;
            _showsDayTxPowerPicker      = NO;
            _showsNightTxPowerPicker    = NO;
        }
        else if (indexPath.row == 2) {
            _showsNightTxPowerPicker    = !_showsNightTxPowerPicker;
            _showsDayIntervalPicker     = NO;
            _showsDayTxPowerPicker      = NO;
            _showsNightIntervalPicker   = NO;
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    [tableView beginUpdates];
    [tableView endUpdates];
    
    [self.dayTxPowerCell toggleFullSeparatorInsets:!_showsDayTxPowerPicker];
    [self.nightTxPowerCell toggleFullSeparatorInsets:!_showsNightTxPowerPicker];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1 && !_showsDayIntervalPicker) {
            return 0.0;
        }
        else if (indexPath.row == 3 && !_showsDayTxPowerPicker) {
            return 0.0;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 1 && !_showsNightIntervalPicker) {
            return 0.0;
        }
        else if (indexPath.row == 3 && !_showsNightTxPowerPicker) {
            return 0.0;
        }
    }
    else if (indexPath.section == 2 && ![self.advancedSettings isKindOfClass:[BLUEddystoneBeaconAdvancedSettings class]]) {
        return 0.0000001;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2 && ![self.advancedSettings isKindOfClass:[BLUEddystoneBeaconAdvancedSettings class]]) {
        return 0.0000001;
    }

    return [super tableView:tableView heightForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2 && ![self.advancedSettings isKindOfClass:[BLUEddystoneBeaconAdvancedSettings class]]) {
        return nil;
    }

    return [super tableView:tableView titleForHeaderInSection:section];
}

#pragma mark - PickerView Handling

- (NSInteger)numberOfRowsForIntervalPickerView {
    return [BLUBeaconFormatter intervalValues].count;
}

- (NSInteger)numberOfRowsForTxPowerPickerView {
    return [BLUBeaconFormatter txPowerValues].count;
}

- (NSString *)titleForRowForIntervalPickerView:(NSInteger)row {
    if (row == 0) {
        return @"0 Hz - Disabled";
    }
    return [BLUBeaconFormatter intervalStrings][row-1];
}

- (NSString *)titleForRowForTxPowerPickerView:(NSInteger)row {
    return [BLUBeaconFormatter txPowerStrings][row];
}

#pragma mark - PickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:self.dayIntervalPickerCell.pickerView]) {
        if (row == 0) {
            self.advancedSettings.advertisementInterval = 0.0;
            self.dayIntervalCell.detailTextLabel.text = @"Disabled";
        }
        else {
            NSNumber *hzValue = [BLUBeaconFormatter intervalValues][row-1];
            self.advancedSettings.advertisementInterval = 1.0 / hzValue.floatValue;
            self.dayIntervalCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f Hz", hzValue.floatValue];
        }
    }
    else if ([pickerView isEqual:self.nightIntervalPickerCell.pickerView]) {
        if (row == 0) {
            self.advancedSettings.energySavingAdvertisementInterval = 0.0;
            self.nightIntervalCell.detailTextLabel.text = @"Disabled";
        }
        else {
            NSNumber *hzValue = [BLUBeaconFormatter intervalValues][row-1];
            self.advancedSettings.energySavingAdvertisementInterval = 1.0 / hzValue.floatValue;
            self.nightIntervalCell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f Hz", hzValue.floatValue];
        }
    }
    else if ([pickerView isEqual:self.dayTxPowerPickerCell.pickerView]) {
        NSNumber *txValue = [BLUBeaconFormatter txPowerValues][row];
        self.advancedSettings.transmissionPower = txValue.integerValue;
        self.dayTxPowerCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dBm", [BLUBeaconFormatter txPowerValues][row]];
    }
    else if ([pickerView isEqual:self.nightTxPowerPickerCell.pickerView]) {
        NSNumber *txValue = [BLUBeaconFormatter txPowerValues][row];
        self.advancedSettings.energySavingTransmissionPower = txValue.integerValue;
        self.nightTxPowerCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dBm", [BLUBeaconFormatter txPowerValues][row]];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.dayIntervalPickerCell.pickerView] || [pickerView isEqual:self.nightTxPowerPickerCell.pickerView]) {
        return 2;
    }

    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.dayIntervalPickerCell.pickerView] || [pickerView isEqual:self.nightIntervalPickerCell.pickerView]) {
        if (component == 0) {
            return 4;
        }

        return 99;
    }
    else {
        return [self numberOfRowsForTxPowerPickerView];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, pickerView.frame.size.width - 20.0, 22.0)];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual:self.dayIntervalPickerCell.pickerView] || [pickerView isEqual:self.nightIntervalPickerCell.pickerView]) {
        return [self titleForRowForIntervalPickerView:row];
    }
    else {
        return [self titleForRowForTxPowerPickerView:row];
    }
}

- (void)intervalPicker:(IntervalPickerDataSource *)intervalPicker didSelectInterval:(NSNumber *)interval picker:(UIPickerView *)picker {
    NSString *detailString = [self hertzDetailStringForInterval:interval.doubleValue];

    if ([intervalPicker isEqual:self.dayIntervalPickerCell.pickerView.delegate]) {
        self.dayIntervalCell.detailTextLabel.text = detailString;
        self.advancedSettings.advertisementInterval = interval.doubleValue;
    }
    else {
        self.nightIntervalCell.detailTextLabel.text = detailString;
        self.advancedSettings.energySavingAdvertisementInterval = interval.doubleValue;
    }
}

- (NSString *)hertzDetailStringForInterval:(double)interval {
    NSString *detailString = @"Disabled";
    if (interval > 0) {
        detailString = [NSString stringWithFormat:@"%0.2f Seconds", interval];
    }

    return detailString;
}

#pragma mark - connectable switch

- (IBAction)connectableSwitchValueDidChange:(UISwitch *)sender {
    BLUEddystoneBeaconAdvancedSettings *eddystoneSettings = (BLUEddystoneBeaconAdvancedSettings *)self.advancedSettings;

    if (sender.on) {
        eddystoneSettings.connectionRate = 1;
        eddystoneSettings.nonConnectionRate = 0;
    }
    else {
        eddystoneSettings.connectionRate = 0;
        eddystoneSettings.nonConnectionRate = 1;
    }
}

@end
