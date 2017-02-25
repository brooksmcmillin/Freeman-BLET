//
//  BLUBeaconDetailViewController.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 19/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUBeaconDetailViewController.h"
#import "BLUBeaconListViewController.h"
#import "BLUBeaconConfigurationViewController.h"
#import "BLUTableViewCell.h"
#import "BLUTextFieldCell.h"
#import "BLUPickerCell.h"
#import "BLUBeaconFormatter.h"
#import "NSData+String.h"

NSString * const BLUStoredConfigurationsArrayPath       = @"storedConfigurationsArray.plist";
NSString * const BLUStoredConfigurationIdentifierKey    = @"BLUStoredConfigurationIdentifier";
NSString * const BLUStoredConfigurationKey              = @"BLUStoredConfiguration";

NSString * const BLUStoredStagesArrayPath               = @"storedStagesArray.plist";
NSString * const BLUStoredStageIdentifierKey            = @"BLUStoredStageIdentifier";
NSString * const BLUStoredStageKey                      = @"BLUStoredStage";

typedef NS_ENUM(NSUInteger, BLUBeaconControlMode) {
    BLUBeaconControlModeConnect,
    BLUBeaconControlModeDisconnect
};

typedef NS_ENUM(NSUInteger, BLUBeaconDetailSection) {
    BLUBeaconDetailSectionBeaconInformation = 0,
    BLUBeaconDetailSectionPassword,
    BLUBeaconDetailSectionSBeacon,
    BLUBeaconDetailSectionIBeacon,
    BLUBeaconDetailSectionEddystoneBeacon,
    BLUBeaconDetailSectionMotionBeacon,
    BLUBeaconDetailSectionLightBeacon,
    BLUBeaconDetailSectionTimeout,
    BLUBeaconDetailSectionWriteConfiguration,
    BLUBeaconDetailSectionError
};

typedef NS_ENUM(NSUInteger, BLUBeaconFirmwareUpdateStage) {
    BLUBeaconFirmwareUpdateStageNone = 0,
    BLUBeaconFirmwareUpdateStageWipe,
    BLUBeaconFirmwareUpdateStageUpdate
};

@interface BLUBeaconDetailViewController () <BLUConfigurableBeaconDelegate, BLUSEncryptedBeaconDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
@property (nonatomic, weak)     IBOutlet    UIBarButtonItem         *connectButton;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *nameCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *typeCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *rssiCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *statusCell;

@property (nonatomic, weak)     IBOutlet    BLUTextFieldCell        *passwordCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sIDCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sTemperatureCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sBatteryVoltageCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sBatteryTypeCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sDeviceTypeCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sFirmwareRevisionCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sDecodingCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *sDecodedCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *iUUIDCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *iMajorCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *iMinorCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *iRotationIdentifierCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *iDecodingCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneNamespaceCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneURLCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneTemperatureCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneBatteryVoltageCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneCounterCell;
@property (weak, nonatomic) IBOutlet BLUTableViewCell *eddystoneInstanceCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *motionBatteryVoltageCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *motionTemperatureCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *motionXAxisCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *motionYAxisCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *motionZAxisCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *lightIdentifierCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *lightLumensCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *timeoutCell;
@property (nonatomic, weak)     IBOutlet    BLUPickerCell           *timeoutPickerCell;

@property (nonatomic, weak)     IBOutlet    UITableViewCell         *errorCell;

@property (nonatomic, strong)               NSError                 *connectionError;
@property (nonatomic, assign)               BLUBeaconControlMode    controlMode;
@property (nonatomic, strong)               BLUConfigurableBeacon   *configurableBeacon;
@property (nonatomic, copy)                 BLUBeaconConfiguration  *scheduledConfiguration;
@property (nonatomic, copy)                 BLUBeaconConfiguration  *storedConfiguration;
@property (nonatomic, strong) BLUAccelerometerSettings *accelerometerSettings;

@property (nonatomic, assign) BOOL hasMotionBeacon;

@property (nonatomic, strong) UIAlertView *writingAlert;

- (IBAction)connectToBeacon:(id)sender;
@end

@implementation BLUBeaconDetailViewController
{
    id   _keyboardWillShowNotifier;
    id   _keyboardWillHideNotifier;

    id   _rotatingIBeaconNotifier;
    
    BOOL _showsTimeoutPicker;
    BOOL _showsErrorCell;
    
    NSInteger _timeoutDays;
    NSInteger _timeoutHours;
    NSInteger _timeoutMinutes;
}
 
#pragma mark - Managing the beacon

- (void)removeObserversForBeacon:(BLUBeacon *)beacon {
    [beacon removeObserver:self forKeyPath:@"RSSI"];

    if ([beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        [beacon removeObserver:self forKeyPath:@"uptime"];
    }
    if ([beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        [beacon removeObserver:self forKeyPath:@"decoding"];
        [beacon removeObserver:self forKeyPath:@"decoded"];
    }
    if ([beacon isKindOfClass:[BLUIBeacon class]]) {
        BLUIBeacon *iBeacon = (BLUIBeacon *)beacon;
        if (iBeacon.isDecoding) {
            [self removeObserversForRotatingIBeacon];
        }
    }
}

- (void)addObserversForBeacon:(BLUBeacon *)beacon {
    [beacon addObserver:self forKeyPath:@"RSSI" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    if ([beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        [beacon addObserver:self forKeyPath:@"uptime" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    if ([beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        [beacon addObserver:self forKeyPath:@"decoding" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [beacon addObserver:self forKeyPath:@"decoded" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    if ([beacon isKindOfClass:[BLUIBeacon class]]) {
        BLUIBeacon *iBeacon = (BLUIBeacon *)beacon;
        if (iBeacon.isDecoding) {
            [self addObserversForRotatingIBeacon];
        }
    }
}

- (void)setBeacon:(BLUBeacon *)beacon {
    if (_beacon != beacon) {
        if (_beacon) {
            [self removeObserversForBeacon:_beacon];
        }
        _beacon = beacon;
        [self addObserversForBeacon:_beacon];
        
        if ([_beacon isKindOfClass:[BLUConfigurableBeacon class]]) {
            self.configurableBeacon = (BLUConfigurableBeacon *)_beacon;
            [self.configurableBeacon setDelegate:self];
        }
        if ([_beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
            BLUSEncryptedBeacon *encrBeacon = (BLUSEncryptedBeacon *)_beacon;
            [encrBeacon setEncryptionDelegate:self];
        }
        
        // Update the view.
        [self configureView];
    }
}

- (void)setConfigurableBeacon:(BLUConfigurableBeacon *)configurableBeacon {
    if (_configurableBeacon != configurableBeacon) {
        _configurableBeacon = configurableBeacon;
        
        if (_configurableBeacon.connectionState >= BLUConfigurableBeaconConnectionStateConnected) {
            self.scheduledConfiguration = _configurableBeacon.configuration;
        }
    }
}

- (void)doInitialSetup {
    if (!self.configurableBeacon) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        self.passwordCell.textField.delegate = self;
    }
    else {
        [self.connectButton setPossibleTitles:[NSSet setWithArray:@[@"Connect", @"Disconnect", @"Cancel"]]];
    }
}

#pragma mark - View lifecycle

- (void)addObserversForBeaconManager {
    [self.beaconManager addObserver:self forKeyPath:@"centralManagerState" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserversForBeaconManager {
    [self.beaconManager removeObserver:self forKeyPath:@"centralManagerState" context:nil];
}

- (void)addObserversForRotatingIBeacon {
    if (_rotatingIBeaconNotifier) {
        [self removeObserversForRotatingIBeacon];
    }
    
    _rotatingIBeaconNotifier = [[NSNotificationCenter defaultCenter] addObserverForName:BLUBeaconListViewControllerDidUpdateRotatingIBeaconNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        BLUIBeacon *oldIBeacon = note.userInfo[@"oldIBeacon"];
        if ([oldIBeacon isEqual:self.beacon]) {
            BLUIBeacon *updatedIBeacon = note.userInfo[@"newIBeacon"];
            if (updatedIBeacon) {
                self.beacon = updatedIBeacon;
            }
        }
    }];
}

- (void)removeObserversForRotatingIBeacon {
    if (_rotatingIBeaconNotifier) {
        [[NSNotificationCenter defaultCenter] removeObserver:_rotatingIBeaconNotifier];
    }
}

- (void)configureView {
    // Update the user interface for the beacon.
    self.connectButton.enabled = (self.beaconManager.centralManagerState == CBCentralManagerStatePoweredOn);
    
    self.title = [self beaconNameString];
    self.nameCell.detailTextLabel.text = [self beaconNameString];
    self.typeCell.detailTextLabel.text = [self beaconTypeString];
    self.rssiCell.detailTextLabel.text = [NSString stringWithFormat:@"%li dBm", (long)[self.beacon.RSSI integerValue]];
    
    if (self.configurableBeacon) {
        if (!self.navigationItem.rightBarButtonItem) {
            [self.navigationItem setRightBarButtonItem:self.connectButton animated:YES];
        }
        
        self.controlMode = [self controlModeForConnectionState:self.configurableBeacon.connectionState];
        [self.connectButton setTitle:[self buttonTitleForConnectionState:self.configurableBeacon.connectionState]];
        [self.statusCell.detailTextLabel setText:[self statusTitleForConnectionState:self.configurableBeacon.connectionState]];
        
        BLUSBeacon *sBeacon = (BLUSBeacon *)self.configurableBeacon;
        self.sIDCell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", [sBeacon.identifier unsignedLongLongValue]];
        self.sTemperatureCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f °C", sBeacon.temperature.degreesCelsius];
        self.sBatteryVoltageCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f V", sBeacon.battery.voltage];
        self.sBatteryTypeCell.detailTextLabel.text = [sBeacon.battery batteryTypeString] ?: @"Unknown";
        self.sDeviceTypeCell.detailTextLabel.text = [sBeacon.device typeString] ?: @"Unknown";
        self.sFirmwareRevisionCell.detailTextLabel.text = sBeacon.device.firmwareRevision ? [NSString stringWithFormat:@"%li", (long)sBeacon.device.firmwareRevision.integerValue] : @"Unknown";
        
        if ([self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
            BLUSEncryptedBeacon *encrBeacon = (BLUSEncryptedBeacon *)self.configurableBeacon;
            [self refreshLabelsWithSEncryptedBeacon:encrBeacon];
        }

        NSArray *associatedBeacons = [self.beaconManager associatedBeaconsForBeacon:self.configurableBeacon];
        for (id beacon in associatedBeacons) {
            if ([beacon isKindOfClass:[BLUMotionBeacon class]]) {
                BLUMotionBeacon *motionBeacon = (BLUMotionBeacon *)beacon;
                [self refreshLabelsWithMotionBeacon:motionBeacon];
            }
            if ([beacon isKindOfClass:[BLULightSensorBeacon class]]) {
                BLULightSensorBeacon *lightBeacon = (BLULightSensorBeacon *)beacon;
                [self refreshLabelsWithLightSensorBeacon:lightBeacon];
            }
            if ([beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]) {
                BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)beacon;
                [self refreshLabelsWithEddystoneUIDBeacon:eddystoneBeacon];
            }
            if ([beacon isKindOfClass:[BLUEddystoneURLBeacon class]]) {
                BLUEddystoneURLBeacon *eddystoneBeacon = (BLUEddystoneURLBeacon *)beacon;
                [self refreshLabelsWithEddystoneURLBeacon:eddystoneBeacon];
            }
            if ([beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
                BLUEddystoneTLMBeacon *eddystoneBeacon = (BLUEddystoneTLMBeacon *)beacon;
                [self refreshLabelsWithEddystoneTLMBeacon:eddystoneBeacon];
            }
        }
        [self refreshLabelsWithIBeacon:nil];
    }
    else {
        if (self.navigationItem.rightBarButtonItem) {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }

    if (self.scheduledConfiguration) {
        self.timeoutCell.textLabel.text = [BLUBeaconFormatter timeoutStringFromInterval:self.scheduledConfiguration.globalSettings.energySavingTimeout];
        [self refreshTimeoutPickerWithTimeInterval:self.scheduledConfiguration.globalSettings.energySavingTimeout];
        [self refreshLabelsWithIBeacon:self.scheduledConfiguration.iBeacon];
        [self refreshLabelsWithEddystoneUIDBeacon:self.scheduledConfiguration.eddystoneUIDBeacon];
        [self refreshLabelsWithEddystoneURLBeacon:self.scheduledConfiguration.eddystoneURLBeacon];
    }

    BOOL isRotatingIBeacon = NO;
    if ([self.beacon isKindOfClass:[BLUIBeacon class]]) {
        BLUIBeacon *iBeacon = (BLUIBeacon *)self.beacon;
        isRotatingIBeacon = iBeacon.isDecoding;
        [self refreshLabelsWithIBeacon:iBeacon];
    }

    if ([self.beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]) {
        BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)self.beacon;
        [self refreshLabelsWithEddystoneUIDBeacon:eddystoneBeacon];
    }
    if ([self.beacon isKindOfClass:[BLUEddystoneURLBeacon class]]) {
        BLUEddystoneURLBeacon *eddystoneBeacon = (BLUEddystoneURLBeacon *)self.beacon;
        [self refreshLabelsWithEddystoneURLBeacon:eddystoneBeacon];
    }
    if ([self.beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        BLUEddystoneTLMBeacon *eddystoneBeacon = (BLUEddystoneTLMBeacon *)self.beacon;
        [self refreshLabelsWithEddystoneTLMBeacon:eddystoneBeacon];
    }

    if ([self.beacon isKindOfClass:[BLUMotionBeacon class]]) {
        BLUMotionBeacon *motionBeacon = (BLUMotionBeacon *)self.beacon;
        [self refreshLabelsWithMotionBeacon:motionBeacon];
    }
    if ([self.beacon isKindOfClass:[BLULightSensorBeacon class]]) {
        BLULightSensorBeacon *lightBeacon = (BLULightSensorBeacon *)self.beacon;
        [self refreshLabelsWithLightSensorBeacon:lightBeacon];
    }
    
    [self.rssiCell toggleFullSeparatorInsets:!self.configurableBeacon];
    [self.sFirmwareRevisionCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected || [self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]])];
    [self.sDecodedCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected)];
    
    [self.iMinorCell toggleFullSeparatorInsets:((!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected) && !isRotatingIBeacon)];
    [self.iDecodingCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected)];
    
    [self.eddystoneNamespaceCell toggleFullSeparatorInsets:![self shouldShowRow:2 inSection:BLUBeaconDetailSectionEddystoneBeacon]];
    [self.eddystoneURLCell toggleFullSeparatorInsets:![self shouldShowRow:0 inSection:BLUBeaconDetailSectionEddystoneBeacon]];
    [self.eddystoneTemperatureCell toggleFullSeparatorInsets:![self shouldShowRow:0 inSection:BLUBeaconDetailSectionEddystoneBeacon]];
    [self.eddystoneCounterCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected)];
    [self.motionZAxisCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected)];
    [self.lightLumensCell toggleFullSeparatorInsets:(!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected)];
    [self.timeoutCell toggleFullSeparatorInsets:!_showsTimeoutPicker];
}

- (void)refreshLabelsWithSEncryptedBeacon:(BLUSEncryptedBeacon *)encrBeacon {
    self.sDecodingCell.detailTextLabel.text = encrBeacon.isDecoding ? @"Yes" : @"No";
    self.sDecodedCell.detailTextLabel.text = encrBeacon.isDecoded ? @"Yes" : @"No";
}

- (void)refreshLabelsWithIBeacon:(BLUIBeacon *)iBeacon {
    self.iUUIDCell.detailTextLabel.text = iBeacon.proximityUUID.UUIDString ?: @"Unknown";
    self.iMajorCell.detailTextLabel.text = iBeacon.major ? [NSString stringWithFormat:@"%u", [iBeacon.major unsignedShortValue]] : @"Unknown";
    self.iMinorCell.detailTextLabel.text = iBeacon.minor ? [NSString stringWithFormat:@"%u", [iBeacon.minor unsignedShortValue]] : @"Unknown";
    self.iRotationIdentifierCell.detailTextLabel.text = iBeacon.rotationIdentifier ? [NSString stringWithFormat:@"%X", [iBeacon.rotationIdentifier unsignedIntValue]] : @"Unknown";
    self.iDecodingCell.detailTextLabel.text = iBeacon.isDecoding ? @"Yes" : @"No";
}

- (void)refreshLabelsWithEddystoneUIDBeacon:(BLUEddystoneUIDBeacon *)eddystoneBeacon {
    if (eddystoneBeacon.identifier) {
        self.eddystoneNamespaceCell.detailTextLabel.text = [eddystoneBeacon.identifier.namespaceIdentifier hexStringRepresentation] ?: @"Unknown";
        self.eddystoneInstanceCell.detailTextLabel.text = [eddystoneBeacon.identifier.instanceIdentifier hexStringRepresentation] ?: @"Unknown";
    }
}

- (void)refreshLabelsWithEddystoneURLBeacon:(BLUEddystoneURLBeacon *)eddystoneBeacon {
    if (eddystoneBeacon.URL) {
        self.eddystoneURLCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", eddystoneBeacon.URL] ?: @"Unknown";
    }
}

- (void)refreshLabelsWithEddystoneTLMBeacon:(BLUEddystoneTLMBeacon *)eddystoneBeacon {
    self.eddystoneTemperatureCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f °C", eddystoneBeacon.temperature.degreesCelsius];
    self.eddystoneBatteryVoltageCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f V", eddystoneBeacon.battery.voltage];
    self.eddystoneCounterCell.detailTextLabel.text = [NSString stringWithFormat:@"%li / %li", (long)eddystoneBeacon.uptime, (long)eddystoneBeacon.frameCount];
}

- (void)refreshLabelsWithMotionBeacon:(BLUMotionBeacon *)motionBeacon {
    self.motionTemperatureCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f °C", motionBeacon.temperature.degreesCelsius];
    self.motionBatteryVoltageCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f V", motionBeacon.battery.voltage];
    self.motionXAxisCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f g's", motionBeacon.xAxisAcceleration.doubleValue];
    self.motionYAxisCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f g's", motionBeacon.yAxisAcceleration.doubleValue];
    self.motionZAxisCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f g's", motionBeacon.zAxisAcceleration.doubleValue];
    self.hasMotionBeacon = YES;
}

- (void)refreshLabelsWithLightSensorBeacon:(BLULightSensorBeacon *)lightBeacon {
    NSNumber *identifier = lightBeacon.identifier;
    if (!identifier && self.configurableBeacon && (
        [self.configurableBeacon isKindOfClass:[BLUSBeacon class]] ||
        [self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]])) {
        BLUSBeacon *sBeacon = (BLUSBeacon *)self.configurableBeacon;
        identifier = sBeacon.identifier;
    }
    
    self.lightIdentifierCell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", [identifier unsignedLongLongValue]];
    self.lightLumensCell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [lightBeacon.lumens floatValue]];
}

- (void)refreshTimeoutPickerWithTimeInterval:(NSTimeInterval)timeInterval {
    _timeoutDays        = (timeInterval / 3600) / 24;
    NSInteger remaining = timeInterval - (_timeoutDays * 3600 * 24);
    _timeoutHours       = remaining / 3600;
    remaining           = remaining - (_timeoutHours * 3600);
    _timeoutMinutes     = remaining / 60;
    
    [self.timeoutPickerCell.pickerView selectRow:366*25+_timeoutDays inComponent:0 animated:NO];
    [self.timeoutPickerCell.pickerView selectRow:24*25+_timeoutHours inComponent:1 animated:NO];
    [self.timeoutPickerCell.pickerView selectRow:60*25+_timeoutMinutes inComponent:2 animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self clearStoredData];
    [self doInitialSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObserversForBeaconManager];
    [self setupPickerView];
    [self.timeoutCell toggleFullSeparatorInsets:!_showsTimeoutPicker];
    [self toggleKeyboardNotifiers:YES];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeObserversForBeaconManager];
    [self removeObserversForRotatingIBeacon];
    if ([self.navigationController isMovingFromParentViewController]) {
        self.beacon = nil;
        
        [self toggleKeyboardNotifiers:NO];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushConfiguration"]) {
        BLUBeaconConfigurationViewController *viewController = (BLUBeaconConfigurationViewController *)segue.destinationViewController;
        viewController.configurationType = ((NSNumber *)sender).unsignedIntegerValue;
        viewController.configurableBeacon = self.configurableBeacon;
        viewController.scheduledConfiguration = self.scheduledConfiguration;
        viewController.accelerometerSettings = self.accelerometerSettings;
    }
}

#pragma mark - Tableview Setup

- (void)updateTableHeaders {
    for (int section = 0; section <= BLUBeaconDetailSectionError; section++) {
        [self.tableView headerViewForSection:section].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:section].uppercaseString;
    }
}

- (void)updateTableFooters {
    for (int section = 0; section <= BLUBeaconDetailSectionError; section++) {
        [self.tableView footerViewForSection:section].textLabel.text = [self tableView:self.tableView titleForFooterInSection:section];
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BLUConfigurationType configType = BLUConfigurationTypeNone;
    if (indexPath.section == BLUBeaconDetailSectionSBeacon && indexPath.row == 8) {
        configType = BLUConfigurationTypeSBeacon;
    }
    else if (indexPath.section == BLUBeaconDetailSectionIBeacon && indexPath.row == 5) {
        configType = BLUConfigurationTypeIBeacon;
    }
    else if (indexPath.section == BLUBeaconDetailSectionEddystoneBeacon && indexPath.row == 6) {
        configType = BLUConfigurationTypeEddystoneBeacon;
    }

    else if (indexPath.section == BLUBeaconDetailSectionMotionBeacon && indexPath.row == 5) {
        configType = BLUConfigurationTypeMotionBeacon;
    }
    else if (indexPath.section == BLUBeaconDetailSectionLightBeacon && indexPath.row == 2) {
        configType = BLUConfigurationTypeLightSensorBeacon;
    }
    if (configType != BLUConfigurationTypeNone && self.scheduledConfiguration) {
        [self performSegueWithIdentifier:@"pushConfiguration" sender:@(configType)];
    }
    
    if (indexPath.section == BLUBeaconDetailSectionTimeout && indexPath.row == 0) {
        [tableView beginUpdates];
        _showsTimeoutPicker = !_showsTimeoutPicker;
        [tableView endUpdates];
        [self.timeoutCell toggleFullSeparatorInsets:!_showsTimeoutPicker];
    }
    
    if (indexPath.section == BLUBeaconDetailSectionWriteConfiguration) {
        if (indexPath.row == 0) {
            [self writeConfiguration:self.scheduledConfiguration];
        }
        else if (indexPath.row == 1) {
            [self updateFirmware];
        }
        else if (indexPath.row == 2) {
            [self restoreDefaultSettings];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self shouldShowRow:indexPath.row inSection:indexPath.section]) {
        return 0.0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (![self shouldShowSection:section]) {
        return nil;
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (![self shouldShowSection:section]) {
        return 0.000001;
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (![self shouldShowSection:section]) {
        return nil;
    }
    
    return [super tableView:tableView titleForFooterInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (![self shouldShowSection:section]) {
        return 0.000001;
    }
    
    return [super tableView:tableView heightForFooterInSection:section];
}

#pragma mark - Connection Management

- (IBAction)connectToBeacon:(id)sender {
    self.controlMode = [self controlModeForConnectionState:self.configurableBeacon.connectionState];
    switch (self.controlMode) {
        case BLUBeaconControlModeDisconnect:
            [self.configurableBeacon disconnect];
            break;
        case BLUBeaconControlModeConnect:
        default:
            [self.tableView beginUpdates];
            self.connectionError = nil;
            _showsErrorCell = NO;
            [self.tableView endUpdates];
            
            [self updateTableHeaders];
            [self updateTableFooters];
            
            if ([self.passwordCell.textField isFirstResponder]) {
                [self.passwordCell.textField resignFirstResponder];
            }
            NSString *password = nil;
            if (self.passwordCell.textField.text.length > 0) {
                password = [self.passwordCell.textField.text copy];
            }
            [self.configurableBeacon connectWithPassword:password timeoutInterval:20.0 retryCount:3];
            break;
    }
}

#pragma mark - Configuration Management

- (void)toggleAdvertisementEncryptionForConfiguration:(BLUBeaconConfiguration *)configuration {
    /**
     *  Beacon advertisement encryption sample code
     *  Use `BLUBeaconEncryptionSettings` to configure, enable and disable advertisement encrpytion for
     *  iBeacon and sBeacon broadcasts.
     *
     *  When using sBeacon advertisement encryption, the beacon will start rotating its Bluetooth address.
     *  This results in iOS / Core Bluetooth presenting the beacon as a newly found Bluetooth peripheral.
     *  If you enabled sBeacon encryption on an instance of `BLUSBeacon` it will become invalid at this point.
     *  Once you disconnect from the beacon the Bluvision SDK will find a new instance of `BLUSEncryptedBeacon`.
     *  This object will represent the encrypted beacon and the SDK will try to internally predict upcoming address
     *  rotations to keep the `BLUSEncryptedBeacon` you first found valid.
     *  Once you disable sBeacon encryption on the beacon and disconnect, your original `BLUSBeacon` instance will
     *  become valid again as the beacon rotates back to its original Bluetooth address.
     */
    
    BLUBeaconEncryptionSettings *encryptionSettings = [BLUBeaconEncryptionSettings defaultEncryptionSettings];
    
    // This explicitly disables sBeacon advertisement encryption
    //BLUSBeaconEncryptionSettings *sBeaconSettings = [BLUSBeaconEncryptionSettings disabledSettings];
    //encryptionSettings.sBeaconEncryptionSettings = sBeaconSettings;
    
    // This explicitly disables iBeacon advertisement encryption
    //BLUIBeaconEncryptionSettings *iBeaconSettings = [BLUIBeaconEncryptionSettings disabledSettings];
    //encryptionSettings.iBeaconEncryptionSettings = iBeaconSettings;
    
    // This configures iBeacon advertisement encryption with a static rotation list
    // Only one iBeacon encryption mode can be active at the same time.
    //BLUIBeaconEncryptionSettings *iBeaconSettings = [BLUIBeaconEncryptionSettings encryptionSettingsWithMajorRotationStartValue:@1000 minorRotationStartValue:@1000 increment:@1 rotationCount:@64];
    //encryptionSettings.iBeaconEncryptionSettings = iBeaconSettings;
    
    // This configures iBeacon advertisement encryption with an encrypted rotating identifier
    // Only one iBeacon encryption mode can be active at the same time.
    //BLUIBeaconEncryptionSettings *iBeaconSettings = [BLUIBeaconEncryptionSettings encryptionSettingsWithRotationIdentifier:@0xABCDEF rotationIdentifierBitLength:@24 rotationKey:[BLUIBeaconEncryptionSettings defaultKeyForIBeaconRotation]];
    //encryptionSettings.iBeaconEncryptionSettings = iBeaconSettings;
    
    // Enable this to pick a custom rotation interval and sync mode for advertisement encryption
    //encryptionSettings.rotationInterval = 300;
    //encryptionSettings.encryptionSyncMode = BLUBeaconEncryptionSyncModeSyncToCurrentTime;
    
    configuration.encryptionSettings = encryptionSettings;
}

- (void)writeConfiguration:(BLUBeaconConfiguration *)configuration {
    if (![self.beacon isKindOfClass:[BLUConfigurableBeacon class]] || !configuration) {
        return;
    }
    
    BLUConfigurableBeacon *configurableBeacon = (BLUConfigurableBeacon *)self.beacon;
    if (configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected) {
        return;
    }

    self.writingAlert = [[UIAlertView alloc] initWithTitle:@"Writing to Beacon ..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.writingAlert show];
    
    // Enable this to setup sBeacon and iBeacon advertisement encryption for this configuration
    //[self toggleAdvertisementEncryptionForConfiguration:configuration];
    
    typeof (self) __weak weakSelf = self;
    [configurableBeacon setConfiguration:configuration options:BLUBeaconConfigurationOptionsChangedValues completion:^(BLUBeaconConfiguration *writtenConfiguration, NSError *error) {
        typeof(self) __strong strongSelf = weakSelf;
        [strongSelf dismissWritingAlertWithError:error];
        if (strongSelf.storedConfiguration) {
            [strongSelf removeStoredConfigurationForConfigurableBeacon:strongSelf.configurableBeacon];
            strongSelf.storedConfiguration = nil;
        }
    }];
}

- (void)restoreDefaultSettings {
    if (![self.beacon isKindOfClass:[BLUConfigurableBeacon class]]) {
        return;
    }

    BLUConfigurableBeacon *configurableBeacon = (BLUConfigurableBeacon *)self.beacon;

    self.writingAlert = [[UIAlertView alloc] initWithTitle:@"Restoring Default Settings...." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.writingAlert show];

    typeof(self) __weak weakSelf = self;
    [configurableBeacon restoreDefaultSettingsWithCompletion:^(BOOL success, NSError *error) {
        typeof(self) __strong strongSelf = weakSelf;
        [strongSelf dismissWritingAlertWithError:error];
    }];

}

- (void)setNewBeaconPassword:(NSString *)password {
    self.writingAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Writing Password" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.writingAlert show];
    
    typeof(self) __weak weakSelf = self;
    [self.configurableBeacon setNewBeaconPassword:password completion:^(NSError *error) {
        typeof(self) __strong strongSelf = weakSelf;
        [strongSelf.writingAlert dismissWithClickedButtonIndex:strongSelf.writingAlert.cancelButtonIndex animated:YES];
        strongSelf.writingAlert = nil;
        
        if (error) {
            strongSelf.errorCell.textLabel.text = error.localizedDescription;
            [strongSelf.tableView beginUpdates];
            _showsErrorCell = YES;
            [strongSelf.tableView endUpdates];
        }
    }];
}

- (void)dismissWritingAlertWithError:(NSError *)error {
    [self.writingAlert dismissWithClickedButtonIndex:self.writingAlert.cancelButtonIndex animated:YES];
    [self configureView];
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error writing to Beacon" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorAlert show];
    }
    
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Beacon written successfully" message:nil delegate:nil cancelButtonTitle:@"Ok, thanks" otherButtonTitles:nil];
    [successAlert show];
}

#pragma mark - Firmware Management

- (void)updateFirmware {
    if (![self.configurableBeacon isKindOfClass:[BLUSBeacon class]] &&
        ![self.configurableBeacon isKindOfClass:[BLUSLegacyBeacon class]] &&
        ![self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        UIAlertView *completedAlert = [[UIAlertView alloc] initWithTitle:@"Firmware update failed" message:@"Beacon not supported" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [completedAlert show];
        
        return;
    }
    BLUSBeacon *sBeacon = (BLUSBeacon *)self.configurableBeacon;
    BLUBeaconFirmwareUpdateStage stage = [self storedStageForConfigurableBeacon:self.configurableBeacon];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"firmware" ofType:@"sfw"];
    NSData *firmwareFile = [NSData dataWithContentsOfFile:path];
    
    BLUFirmwareImage *image = [BLUFirmwareImage firmwareImageForData:firmwareFile configurableBeacon:sBeacon];
    if (stage == BLUBeaconFirmwareUpdateStageNone) {
        // Fresh update ...
        if (image) {
            if (image.isLoaderImage) {
                stage = BLUBeaconFirmwareUpdateStageWipe;
            }
            else {
                stage = BLUBeaconFirmwareUpdateStageUpdate;
            }
        }
        else {
            stage = BLUBeaconFirmwareUpdateStageUpdate;
            image = [self stageTwoFirmwareImageForSBeacon:sBeacon];
            if (![self checkFirmwareImageAndFail:image stage:stage]) {
                return;
            }
            
            if ([sBeacon requiresLoaderImageForFirmwareImage:image]) {
                stage = BLUBeaconFirmwareUpdateStageWipe;
                image = [self stageOneFirmwareImageForSBeacon:sBeacon];
                if (![self checkFirmwareImageAndFail:image stage:stage]) {
                    return;
                }
            }
        }
        [self startUpdatingFirmwareWithImage:image stage:stage isFirstUpdate:YES];
    }
    else if (stage == BLUBeaconFirmwareUpdateStageWipe) {
        // Wiping failed before? Repeat ...
        if (!image || !image.isLoaderImage) {
            image = [self stageOneFirmwareImageForSBeacon:sBeacon];
        }
        if (![self checkFirmwareImageAndFail:image stage:stage]) {
            return;
        }
        [self startUpdatingFirmwareWithImage:image stage:stage isFirstUpdate:NO];
    }
    else if (stage == BLUBeaconFirmwareUpdateStageUpdate) {
        // Wiping successful, continue updating ...
        if (!image || image.isLoaderImage) {
            image = [self stageTwoFirmwareImageForSBeacon:sBeacon];
        }
        if (![self checkFirmwareImageAndFail:image stage:stage]) {
            return;
        }
        [self startUpdatingFirmwareWithImage:image stage:stage isFirstUpdate:NO];
    }
}

- (void)startUpdatingFirmwareWithImage:(BLUFirmwareImage *)image stage:(BLUBeaconFirmwareUpdateStage)stage isFirstUpdate:(BOOL)firstUpdate {
    NSString *title = [NSString stringWithFormat:@"Updating firmware (Stage %li)\n", (long)stage];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    [self storeFirmwareUpdateStage:stage forConfigurableBeacon:self.configurableBeacon];
    if (firstUpdate) {
        // Only store the current configuration if this is the first time we try updating this beacon
        // We don't want to overwrite a stored configuration with the configuration of a loader beacon!
        [self storeConfiguration:self.configurableBeacon.configuration forConfigurableBeacon:self.configurableBeacon];
    }
    [self.configurableBeacon updateFirmwareWithImage:image progress:^(float percentComplete) {
        NSLog(@"Firmware Update Progress: %f", percentComplete);
        alert.title = [NSString stringWithFormat:@"%@%.2f %% completed", title, percentComplete];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"Firmware Update completed with error: %@", error.localizedDescription);
        if (alert.isVisible) {
            [alert dismissWithClickedButtonIndex:alert.cancelButtonIndex animated:YES];
        }
        
        [self notifyFirmwareUpdateFinishedWithError:error stage:stage];
    }];
}

- (void)notifyFirmwareUpdateFinishedWithError:(NSError *)error stage:(BLUBeaconFirmwareUpdateStage)stage {
    NSString *title = nil;
    NSString *message = nil;
    if (error) {
        self.connectionError = error;
        self.errorCell.textLabel.text = error.localizedDescription;
        [self.tableView beginUpdates];
        _showsErrorCell = YES;
        [self.tableView endUpdates];
        
        title = @"Firmware update failed";
        message = error.localizedDescription;
    }
    else if (stage == BLUBeaconFirmwareUpdateStageWipe) {
        stage = BLUBeaconFirmwareUpdateStageUpdate;
        [self storeFirmwareUpdateStage:stage forConfigurableBeacon:self.configurableBeacon];
        title = @"Firmware update stage 1 completed";
        message = @"Please reconnect to your beacon to initiate stage 2";
    }
    else {
        title = @"Firmware update completed";
        message = @"Your beacon has been disconnected and will reboot now.";
        [self removeStoredStageForConfigurableBeacon:self.configurableBeacon];
    }
    
    UIAlertView *completedAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [completedAlert show];
}

- (BOOL)checkFirmwareImageAndFail:(BLUFirmwareImage *)image stage:(BLUBeaconFirmwareUpdateStage)stage {
    if (!image) {
        NSError *error = [[NSError alloc] initWithDomain:@"BLUBeaconTestAppErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey : @"No image found for firmware update"}];
        [self notifyFirmwareUpdateFinishedWithError:error stage:stage];
        
        return NO;
    }
    return YES;
}
    
- (BLUFirmwareImage *)stageTwoFirmwareImageForSBeacon:(BLUSBeacon *)beacon {
    NSString *path = nil;
    switch (beacon.device.type) {
        case BLUDeviceTypeUnknown:
        case BLUDeviceTypeTag24mm:
            path = [[NSBundle mainBundle] pathForResource:@"bleTag_enc_363" ofType:@"bin"];
            break;
        case BLUDeviceTypeTag27mm:
            path = [[NSBundle mainBundle] pathForResource:@"bleTag27_enc_363" ofType:@"bin"];
            break;
        case BLUDeviceTypeTagCC27mm:
        case BLUDeviceTypeTagCCaa:
            path = [[NSBundle mainBundle] pathForResource:@"bleTag_cc_27_nl_enc_371" ofType:@"bin"];
            break;
        case BLUDeviceTypeTagHQ:
        case BLUDeviceTypeTagCC24mm:
        case BLUDeviceTypeTagAA:
        case BLUDeviceTypeBle2Wifi:
        case BLUDeviceTypeUSB:
        case BLUDeviceTypeNanoUSB:
        default:
            break;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    BLUFirmwareImage *image = [BLUFirmwareImage firmwareImageForData:data configurableBeacon:beacon];
    
    return image;
}

- (BLUFirmwareImage *)stageOneFirmwareImageForSBeacon:(BLUSBeacon *)beacon {
    NSString *path = nil;
    switch (beacon.device.type) {
        case BLUDeviceTypeUnknown:
        case BLUDeviceTypeTag24mm:
            path = [[NSBundle mainBundle] pathForResource:@"bleTag_enc_363" ofType:@"bin"];
            break;
        case BLUDeviceTypeTag27mm:
            path = [[NSBundle mainBundle] pathForResource:@"bleTag27_enc_363" ofType:@"bin"];
            break;
        case BLUDeviceTypeTagCC27mm:
        case BLUDeviceTypeTagCCaa:
            path = [[NSBundle mainBundle] pathForResource:@"fwload_bleTag_cc_27_nl_enc" ofType:@"bin"];
            break;
        case BLUDeviceTypeTagHQ:
        case BLUDeviceTypeTagCC24mm:
        case BLUDeviceTypeTagAA:
        case BLUDeviceTypeBle2Wifi:
        case BLUDeviceTypeUSB:
        case BLUDeviceTypeNanoUSB:
        default:
            break;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    BLUFirmwareImage *image = [BLUFirmwareImage firmwareImageForData:data configurableBeacon:beacon];
    
    return image;
}

#pragma mark - Configurable Beacon Delegate

- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didChangeState:(BLUConfigurableBeaconConnectionState)state {
    [self configureView];
}

- (void)configurableBeaconDidConnect:(BLUConfigurableBeacon *)configurableBeacon {
    [configurableBeacon enableBeaconSpeaker:YES andLED:YES];

    self.scheduledConfiguration = configurableBeacon.configuration;
    self.accelerometerSettings = [BLUAccelerometerSettings defaultSettings];
    
    [self.tableView beginUpdates];
    [self configureView];
    self.connectionError = nil;
    _showsErrorCell = NO;
    [self.tableView endUpdates];
    
    [self updateTableHeaders];
    [self updateTableFooters];
    
    BOOL stageAlert = NO;
    BLUBeaconFirmwareUpdateStage stage = [self storedStageForConfigurableBeacon:self.configurableBeacon];
    if (stage > BLUBeaconFirmwareUpdateStageNone) {
        stageAlert = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firmware update in progress" message:@"This beacon was in the process of being updated recently. Would you like to continue this update now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    
    BLUBeaconConfiguration *config = [self storedConfigurationForConfigurableBeacon:self.configurableBeacon];
    if (config && !stageAlert) {
        self.storedConfiguration = config;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configuration available" message:@"There's a stored configuration for this beacon. Would you like to apply it now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", @"Delete Configuration", nil];
        [alert show];
    }
}

- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didDisconnectWithError:(NSError *)error {
    self.scheduledConfiguration = [self.configurableBeacon.configuration copy];

    if ([self.writingAlert isVisible]) {
        [self.writingAlert dismissWithClickedButtonIndex:self.writingAlert.cancelButtonIndex animated:YES];
    }

    [self.tableView beginUpdates];
    [self configureView];
    [self.tableView endUpdates];
    
    [self updateTableHeaders];
    [self updateTableFooters];
    
    if (error) {
        self.connectionError = error;
        self.errorCell.textLabel.text = error.localizedDescription;
        [self.tableView beginUpdates];
        _showsErrorCell = YES;
        [self.tableView endUpdates];
        
        if (error.code == 5022) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect Now", nil];
            alert.tag = error.code;
            [alert show];
        }
    }
}

#pragma mark - Encrypted sBeacon delegate

- (void)sEncryptedBeaconDidDecodeAdvertisement:(BLUSEncryptedBeacon *)sEncryptedBeacon {
    [self configureView];
}

- (void)sEncryptedBeacon:(BLUSEncryptedBeacon *)sEncryptedBeacon didFailToDecodeAdvertisementWithError:(NSError *)error {}
- (void)sEncryptedBeacon:(BLUSEncryptedBeacon *)sEncryptedBeacon didChangeFromPeripheralIdentifier:(NSUUID *)oldPeripheralIdentifier toPeripheralIdentifier:(NSUUID *)peripheralIdentifier {}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"RSSI"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rssiCell.detailTextLabel.text = [NSString stringWithFormat:@"%li dBm", (long)[self.beacon.RSSI integerValue]];
            
            if ([self.beacon isKindOfClass:[BLUMotionBeacon class]]) {
                [self refreshLabelsWithMotionBeacon:(BLUMotionBeacon *)self.beacon];
            }
            if ([self.beacon isKindOfClass:[BLULightSensorBeacon class]]) {
                [self refreshLabelsWithLightSensorBeacon:(BLULightSensorBeacon *)self.beacon];
            }
        });
    }
    else if ([keyPath isEqualToString:@"centralManagerState"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectButton.enabled = (self.beaconManager.centralManagerState == CBCentralManagerStatePoweredOn);
        });
    }
    else if ([keyPath isEqualToString:@"uptime"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshLabelsWithEddystoneTLMBeacon:(BLUEddystoneTLMBeacon *)self.beacon];
        });
    }
    else if ([keyPath isEqualToString:@"decoding"] ||
             [keyPath isEqualToString:@"decoded"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshLabelsWithSEncryptedBeacon:(BLUSEncryptedBeacon *)self.beacon];
        });
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Helpers

- (NSString *)beaconNameString {
    NSString *beaconName = @"Unknown Beacon";
    if ([self.beacon isKindOfClass:[BLUBluetoothBeacon class]]) {
        BLUBluetoothBeacon *bBeacon = (BLUBluetoothBeacon *)self.beacon;
        beaconName = [bBeacon.name copy];
    }
    else if ([self.beacon isKindOfClass:[BLUIBeacon class]]) {
        beaconName = @"iBeacon";
    }
    return beaconName;
}

- (NSString *)beaconTypeString {
    NSString *beaconType = @"Unknown Beacon";
    if ([self.beacon isKindOfClass:[BLUSBeacon class]]) {
        beaconType = @"sBeacon";
    }
    else if ([self.beacon isKindOfClass:[BLUSLegacyBeacon class]]) {
        beaconType = @"Legacy sBeacon";
    }
    else if ([self.beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        beaconType = @"Encrypted sBeacon";
    }
    else if ([self.beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]) {
        beaconType = @"Eddystone UID Beacon";
    }
    else if ([self.beacon isKindOfClass:[BLUEddystoneURLBeacon class]]) {
        beaconType = @"Eddystone URL Beacon";
    }
    else if ([self.beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        beaconType = @"Eddystone TLM Beacon";
    }
    else if ([self.beacon isKindOfClass:[BLUIBeacon class]]) {
        BLUIBeacon *iBeacon = (BLUIBeacon *)self.beacon;
        if (iBeacon.decoding) {
            beaconType = @"Rotating iBeacon";
        }
        else {
            beaconType = @"iBeacon";
        }
    }
    else if ([self.beacon isKindOfClass:[BLUMotionBeacon class]]) {
        beaconType = @"Motion Beacon";
    }
    else if ([self.beacon isKindOfClass:[BLULightSensorBeacon class]]) {
        beaconType = @"Light Sensor Beacon";
    }
    return beaconType;
}

- (BLUBeaconControlMode)controlModeForConnectionState:(BLUConfigurableBeaconConnectionState)connectionState {
    BLUBeaconControlMode controlMode = BLUBeaconControlModeConnect;
    switch (connectionState) {
        case BLUConfigurableBeaconConnectionStateConnecting:
        case BLUConfigurableBeaconConnectionStateDiscovering:
        case BLUConfigurableBeaconConnectionStateConnected:
        case BLUConfigurableBeaconConnectionStateReading:
        case BLUConfigurableBeaconConnectionStateWriting:
        case BLUConfigurableBeaconConnectionStateUpdatingFirmware:
            controlMode = BLUBeaconControlModeDisconnect;
            break;
        case BLUConfigurableBeaconConnectionStateDisconnected:
        default:
            controlMode = BLUBeaconControlModeConnect;
            break;
    }
    return controlMode;
}

- (NSString *)buttonTitleForConnectionState:(BLUConfigurableBeaconConnectionState)connectionState {
    NSString *buttonTitle = nil;
    switch (connectionState) {
        case BLUConfigurableBeaconConnectionStateConnecting:
        case BLUConfigurableBeaconConnectionStateDiscovering:
            buttonTitle = @"Cancel";
            break;
        case BLUConfigurableBeaconConnectionStateConnected:
        case BLUConfigurableBeaconConnectionStateReading:
        case BLUConfigurableBeaconConnectionStateWriting:
        case BLUConfigurableBeaconConnectionStateUpdatingFirmware:
            buttonTitle = @"Disconnect";
            break;
        case BLUConfigurableBeaconConnectionStateDisconnected:
        default:
            buttonTitle = @"Connect";
            break;
    }
    return buttonTitle;
}

- (NSString *)statusTitleForConnectionState:(BLUConfigurableBeaconConnectionState)connectionState {
    NSString *title = nil;
    switch (connectionState) {
        case BLUConfigurableBeaconConnectionStateDisconnected:
            title = @"Beacon Disconnected";
            break;
        case BLUConfigurableBeaconConnectionStateConnecting:
            title = @"Beacon Connecting";
            break;
        case BLUConfigurableBeaconConnectionStateDiscovering:
            title = @"Beacon Discovering Services";
            break;
        case BLUConfigurableBeaconConnectionStateConnected:
            title = @"Beacon Connected";
            break;
        case BLUConfigurableBeaconConnectionStateReading:
            title = @"Beacon Reading Data";
            break;
        case BLUConfigurableBeaconConnectionStateWriting:
            title = @"Beacon Writing Data";
            break;
        case BLUConfigurableBeaconConnectionStateUpdatingFirmware:
            title = @"Beacon Updating Firmware";
            break;
        case BLUConfigurableBeaconConnectionStateAuthenticating:
            title = @"Beacon Authenticating";
            break;
        default:
            title = @"Beacon State Unknown";
            break;
    }
    NSLog(@"%@", title);
    return title;
}

- (BOOL)shouldShowSection:(NSInteger)section {
    if (!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected) {
        if (section == BLUBeaconDetailSectionTimeout  ||
            section == BLUBeaconDetailSectionWriteConfiguration) {
            return NO;
        }
    }
    
    if (!self.configurableBeacon && section == BLUBeaconDetailSectionPassword) {
        return NO;
    }
    
    if ([self.beacon isKindOfClass:[BLUIBeacon class]]) {
        if (section == BLUBeaconDetailSectionSBeacon ||
            section == BLUBeaconDetailSectionMotionBeacon ||
            section == BLUBeaconDetailSectionLightBeacon ||
            section == BLUBeaconDetailSectionEddystoneBeacon ) {
            return NO;
        }
    }
    
    if ([self.beacon isKindOfClass:[BLUMotionBeacon class]] ||
        [self.beacon isKindOfClass:[BLULightSensorBeacon class]]) {
        if (section == BLUBeaconDetailSectionSBeacon ||
            section == BLUBeaconDetailSectionIBeacon ||
            section == BLUBeaconDetailSectionEddystoneBeacon ) {
            return NO;
        }
        
        if ([self.beacon isKindOfClass:[BLUMotionBeacon class]]) {
            if (section == BLUBeaconDetailSectionLightBeacon) {
                return NO;
            }
        }
        if ([self.beacon isKindOfClass:[BLULightSensorBeacon class]]) {
            if (section == BLUBeaconDetailSectionMotionBeacon) {
                return NO;
            }
        }
    }

    if ([self.beacon isKindOfClass:[BLUEddystoneUIDBeacon class]] ||
        [self.beacon isKindOfClass:[BLUEddystoneURLBeacon class]] ||
        [self.beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        if (section == BLUBeaconDetailSectionSBeacon ||
            section == BLUBeaconDetailSectionIBeacon ||
            section == BLUBeaconDetailSectionMotionBeacon ||
            section == BLUBeaconDetailSectionLightBeacon) {
            return NO;
        }
    }
    
    if (section == BLUBeaconDetailSectionError && !_showsErrorCell) {
        return NO;
    }
    
    if (self.configurableBeacon && section == BLUBeaconDetailSectionMotionBeacon) {
        NSArray *associatedBeacons = [self.beaconManager associatedBeaconsForBeacon:self.configurableBeacon];
        BOOL available = NO;
        for (id beacon in associatedBeacons) {
            if ([beacon isKindOfClass:[BLUMotionBeacon class]]) {
                available = YES;
                break;
            }
        }
        if (!available && !self.configurableBeacon.configuration.motionBeaconAdvancedSettings.available) {
            return NO;
        }
    }
    
    if (self.configurableBeacon && section == BLUBeaconDetailSectionLightBeacon) {
        NSArray *associatedBeacons = [self.beaconManager associatedBeaconsForBeacon:self.configurableBeacon];
        BOOL available = NO;
        for (id beacon in associatedBeacons) {
            if ([beacon isKindOfClass:[BLULightSensorBeacon class]]) {
                available = YES;
                break;
            }
        }
        if (!available && !self.configurableBeacon.configuration.lightSensorBeaconAdvancedSettings.available) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)shouldShowRow:(NSInteger)row inSection:(NSInteger)section {
    if (![self shouldShowSection:section]) {
        return NO;
    }
    
    if (!self.configurableBeacon || self.configurableBeacon.connectionState < BLUConfigurableBeaconConnectionStateConnected) {
        if ((section == BLUBeaconDetailSectionSBeacon && row == 8)  ||
            (section == BLUBeaconDetailSectionIBeacon && row == 5)  ||
            (section == BLUBeaconDetailSectionMotionBeacon && row == 5) ||
            (section == BLUBeaconDetailSectionLightBeacon && row == 2) ||
            (section == BLUBeaconDetailSectionEddystoneBeacon && row == 6)) {
            return NO;
        }
    }
    
    if (!self.configurableBeacon) {
        if (section == BLUBeaconDetailSectionBeaconInformation && row == 3) {
            return NO;
        }

        if ((section == BLUBeaconDetailSectionEddystoneBeacon && row <= 1 && ![self.beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]) ||
            (section == BLUBeaconDetailSectionEddystoneBeacon && row == 2 && ![self.beacon isKindOfClass:[BLUEddystoneURLBeacon class]])  ||
            (section == BLUBeaconDetailSectionEddystoneBeacon && row > 2  && ![self.beacon isKindOfClass:[BLUEddystoneTLMBeacon class]])) {
            return NO;
        }
    }
    
    if (![self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        if (section == BLUBeaconDetailSectionSBeacon && (row == 6 || row == 7)) {
            return NO;
        }
    }
    
    if (section == BLUBeaconDetailSectionIBeacon &&
        (row == 3 || row == 4)) {
        if (![self.beacon isKindOfClass:[BLUIBeacon class]]) {
            return NO;
        }
        else {
            BLUIBeacon *iBeacon = (BLUIBeacon *)self.beacon;
            if (!iBeacon.isDecoding) {
                return NO;
            }
        }
    }
    
    if (section == BLUBeaconDetailSectionTimeout && row == 1 && !_showsTimeoutPicker) {
        return NO;
    }
    
    if (section == BLUBeaconDetailSectionWriteConfiguration && row == 1) {
        if (!([self.configurableBeacon isKindOfClass:[BLUSBeacon class]] ||
              [self.configurableBeacon isKindOfClass:[BLUSLegacyBeacon class]] ||
              [self.configurableBeacon isKindOfClass:[BLUSEncryptedBeacon class]])) {
            return NO;
        }
        if (![self beaconCanUpdateFirmware:(BLUSBeacon *)self.configurableBeacon]) {
            return NO;
        }
    }

    if (section == BLUBeaconDetailSectionWriteConfiguration && row == 3) {
        if (!self.hasMotionBeacon) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)beaconCanUpdateFirmware:(BLUSBeacon *)beacon {
    int targetRevision = 0;
    
    switch (beacon.device.type) {
        case BLUDeviceTypeUnknown:
        case BLUDeviceTypeTag24mm:
        case BLUDeviceTypeTag27mm:
            targetRevision = 363;
            break;
        case BLUDeviceTypeTagCC27mm:
        case BLUDeviceTypeTagCCaa:
            targetRevision = 376;
            break;
        case BLUDeviceTypeTagHQ:
        case BLUDeviceTypeTagCC24mm:
        case BLUDeviceTypeTagAA:
        case BLUDeviceTypeBle2Wifi:
        case BLUDeviceTypeUSB:
        case BLUDeviceTypeNanoUSB:
        default:
            break;
    }
    
    if (targetRevision == 0) {
        return NO;
    }
    if (beacon.device.firmwareRevision.intValue > targetRevision) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Text Field and Delegate

- (void)toggleKeyboardNotifiers:(BOOL)on {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    static UIEdgeInsets oldContentInset;
    static UIEdgeInsets oldIndicatorInset;
    
    if (on) {
        if (!_keyboardWillShowNotifier) {
            _keyboardWillShowNotifier = [nc addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                oldContentInset = self.tableView.contentInset;
                oldIndicatorInset = self.tableView.scrollIndicatorInsets;
                CGSize keyboardSize = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                UIEdgeInsets contentInsets;
                if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                    contentInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0, (keyboardSize.height), 0.0);
                }
                else {
                    contentInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0, (keyboardSize.width), 0.0);
                }
                oldContentInset = self.tableView.contentInset;
                oldIndicatorInset = self.tableView.scrollIndicatorInsets;
                                             
                NSNumber *rate = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
                [UIView animateWithDuration:rate.floatValue animations:^{
                    self.tableView.contentInset = contentInsets;
                    self.tableView.scrollIndicatorInsets = contentInsets;
                }
                completion:^(BOOL finished) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }];
            }];
        }
        if (!_keyboardWillHideNotifier) {
            _keyboardWillHideNotifier = [nc addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                NSNumber *rate = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
                [UIView animateWithDuration:rate.floatValue animations:^{
                    self.tableView.contentInset = oldContentInset;
                    self.tableView.scrollIndicatorInsets = oldIndicatorInset;
                }];
            }];
        }
    }
    else {
        [nc removeObserver:_keyboardWillShowNotifier];
        [nc removeObserver:_keyboardWillHideNotifier];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField { }

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.passwordCell.textField] &&
        self.configurableBeacon.connectionState == BLUConfigurableBeaconConnectionStateConnected)
    {
        [self setNewBeaconPassword:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PickerView

- (void)setupPickerView {
    [self.timeoutPickerCell.pickerView selectRow:25*366 inComponent:0 animated:NO];
    [self.timeoutPickerCell.pickerView selectRow:25*24 inComponent:1 animated:NO];
    [self.timeoutPickerCell.pickerView selectRow:25*60 inComponent:2 animated:NO];
    
    CGFloat widthForComponent = self.view.bounds.size.width / 3.0;
    CGFloat originX           = widthForComponent / 2.0;
    
    UILabel *minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX + widthForComponent * 2 - 10.0, self.timeoutPickerCell.pickerView.frame.size.height / 2 - 14, widthForComponent/2, 30)];
    minuteLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    minuteLabel.text = @"min";
    [self.timeoutPickerCell.pickerView addSubview:minuteLabel];
    
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0 + originX + widthForComponent, self.timeoutPickerCell.pickerView.frame.size.height / 2 - 14, widthForComponent/2, 30)];
    hourLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    hourLabel.text = @"hrs";
    [self.timeoutPickerCell.pickerView addSubview:hourLabel];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0 + originX, self.timeoutPickerCell.pickerView.frame.size.height / 2 - 14, widthForComponent/2, 30)];
    dayLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    dayLabel.text = @"days";
    [self.timeoutPickerCell.pickerView addSubview:dayLabel];

}

#pragma mark - PickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger count     = 0;
    if (component == 0)
    {
        count = 366;
        _timeoutDays = row % count;
        [pickerView selectRow:count*25+_timeoutDays inComponent:0 animated:NO];
    }
    else if (component == 1)
    {
        count = 24;
        _timeoutHours = row % count;
        [pickerView selectRow:count*25+_timeoutHours inComponent:1 animated:NO];
    }
    else if (component == 2)
    {
        count = 60;
        _timeoutMinutes = row % count;
        [pickerView selectRow:count*25+_timeoutMinutes inComponent:2 animated:NO];
    }
    NSInteger seconds = 0;
    seconds += _timeoutDays * 24 * 3600;
    seconds += _timeoutHours * 3600;
    seconds += _timeoutMinutes * 60;
    
    self.scheduledConfiguration.globalSettings.energySavingTimeout = seconds;
    self.timeoutCell.textLabel.text = [BLUBeaconFormatter timeoutStringFromInterval:seconds];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger count = 0;
    if (component == 0)
        count = 366 * 50;
    else if (component == 1)
        count = 24 * 50;
    else if (component == 2)
        count = 60 * 50;
    return count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 100.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGFloat width = pickerView.frame.size.width / 3.0;
    UIView *columnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    CGFloat x = component == 0 ? 4 : 0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, 10.0 + width/3.0-x, 30)];//
    [columnView addSubview:label];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    label.font = [UIFont systemFontOfSize:23.0f];
    label.textAlignment = NSTextAlignmentRight;
    return columnView;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger count = 1;
    if (component == 0)
        count = 366;
    else if (component == 1)
        count = 24;
    else if (component == 2)
        count = 60;
    
    return [NSString stringWithFormat:@"%ld", (long)(row % count)];
}

#pragma mark - Alerts

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 5022) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSString *password = nil;
            if (self.passwordCell.textField.text.length > 0) {
                password = [self.passwordCell.textField.text copy];
            }
            [self.configurableBeacon forceConnectWithPassword:password timeoutInterval:20.0 retryCount:3];
            
            self.connectionError = nil;
            self.errorCell.textLabel.text = nil;
            [self.tableView beginUpdates];
            _showsErrorCell = NO;
            [self.tableView endUpdates];
        }
    }
    else if ([alertView.title isEqualToString:@"Configuration available"]) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (buttonIndex == 1){
                // Use
                [self writeConfiguration:self.storedConfiguration];
            }
            else if (buttonIndex == 2) {
                // Delete
                [self removeStoredConfigurationForConfigurableBeacon:self.configurableBeacon];
                self.storedConfiguration = nil;
            }
        }
        else {
            self.storedConfiguration = nil;
        }
    }
    else if ([alertView.title isEqualToString:@"Firmware update in progress"]) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self updateFirmware];
        }
    }
}

#pragma mark - Stored Configurations

- (NSString *)storedConfigurationsPath {
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:BLUStoredConfigurationsArrayPath];
}

- (NSArray *)storedConfigurations {
    NSString *path = [self storedConfigurationsPath];
    
    NSArray *storedConfigurations = nil;
    @try {
        id storedConfigurationsObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if ([storedConfigurationsObject isKindOfClass:[NSArray class]]) {
            storedConfigurations = storedConfigurationsObject;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return storedConfigurations;
}

- (BLUBeaconConfiguration *)storedConfigurationForConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    NSArray *storedConfigurations = [self storedConfigurations];
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"(BLUStoredConfigurationIdentifier == %@)", beacon.peripheralIdentifier.UUIDString];
    NSArray *results = [storedConfigurations filteredArrayUsingPredicate:identifierPredicate];
    NSDictionary *configurationDictionary = [results firstObject];
    BLUBeaconConfiguration *config = configurationDictionary[BLUStoredConfigurationKey];
    
    return config;
}

- (void)storeConfiguration:(BLUBeaconConfiguration *)configuration forConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    if (!configuration || !beacon.peripheralIdentifier) {
        return;
    }
    
    BLUBeaconConfiguration *config = [self storedConfigurationForConfigurableBeacon:beacon];
    if (config && [config isEqual:configuration]) {
        return;
    }
    else if (config) {
        [self removeStoredConfigurationForConfigurableBeacon:beacon];
    }
    
    NSArray *storedConfigurations = [self storedConfigurations];
    NSDictionary *storedConfiguration = @{BLUStoredConfigurationIdentifierKey : beacon.peripheralIdentifier.UUIDString,
                                          BLUStoredConfigurationKey           : configuration};
    
    if (storedConfigurations) {
        storedConfigurations = [storedConfigurations arrayByAddingObject:storedConfiguration];
    }
    else {
        storedConfigurations = @[storedConfiguration];
    }
    
    [self saveStoredConfigurations:storedConfigurations];
}

- (void)saveStoredConfigurations:(NSArray *)storedConfigurations {
    NSString *path = [self storedConfigurationsPath];
    if ([storedConfigurations count]) {
        [NSKeyedArchiver archiveRootObject:storedConfigurations toFile:path];
    }
    else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

- (void)removeStoredConfigurationForConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    if (!beacon.peripheralIdentifier) {
        return;
    }
    
    NSMutableArray *storedConfigurations = [[self storedConfigurations] mutableCopy];
    
    if (storedConfigurations) {
        NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"(BLUStoredConfigurationIdentifier == %@)", beacon.peripheralIdentifier.UUIDString];
        NSArray *results = [storedConfigurations filteredArrayUsingPredicate:identifierPredicate];
        [storedConfigurations removeObjectsInArray:results];
        [self saveStoredConfigurations:storedConfigurations];
    }
}

#pragma mark - Store Firmware Update Stage

- (NSString *)storedStagesPath {
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:BLUStoredStagesArrayPath];
}

- (NSArray *)storedStages {
    NSString *path = [self storedStagesPath];
    
    NSArray *storedStages = nil;
    @try {
        id storedStagesObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if ([storedStagesObject isKindOfClass:[NSArray class]]) {
            storedStages = storedStagesObject;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return storedStages;
}

- (BLUBeaconFirmwareUpdateStage)storedStageForConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    NSArray *storedStages = [self storedStages];
    NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"(BLUStoredStageIdentifier == %@)", beacon.peripheralIdentifier.UUIDString];
    
    BLUBeaconFirmwareUpdateStage stage = BLUBeaconFirmwareUpdateStageNone;
    NSArray *results = [storedStages filteredArrayUsingPredicate:identifierPredicate];
    if (results.count > 0) {
        NSDictionary *stageDictionary = [results firstObject];
        stage = [stageDictionary[BLUStoredStageKey] unsignedIntegerValue];
    }
    
    return stage;
}

- (void)storeFirmwareUpdateStage:(BLUBeaconFirmwareUpdateStage)stage forConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    if (!beacon || !beacon.peripheralIdentifier) {
        return;
    }
    
    BLUBeaconFirmwareUpdateStage storedStage = [self storedStageForConfigurableBeacon:beacon];
    if (storedStage == stage) {
        return;
    }
    else if (storedStage != BLUBeaconFirmwareUpdateStageNone) {
        [self removeStoredStageForConfigurableBeacon:beacon];
    }
    
    NSArray *storedStages = [self storedStages];
    NSDictionary *stageToStore = @{BLUStoredStageIdentifierKey : beacon.peripheralIdentifier.UUIDString,
                                   BLUStoredStageKey           : @(stage)};
    
    if (storedStages) {
        storedStages = [storedStages arrayByAddingObject:stageToStore];
    }
    else {
        storedStages = @[stageToStore];
    }
    
    [self saveStoredStages:storedStages];
}

- (void)saveStoredStages:(NSArray *)storedStages {
    NSString *path = [self storedStagesPath];
    if ([storedStages count]) {
        [NSKeyedArchiver archiveRootObject:storedStages toFile:path];
    }
    else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
}

- (void)removeStoredStageForConfigurableBeacon:(BLUConfigurableBeacon *)beacon {
    if (!beacon || !beacon.peripheralIdentifier) {
        return;
    }
    
    NSMutableArray *storedStages = [[self storedStages] mutableCopy];
    
    if (storedStages) {
        NSPredicate *identifierPredicate = [NSPredicate predicateWithFormat:@"(BLUStoredStageIdentifier == %@)", beacon.peripheralIdentifier.UUIDString];
        NSArray *results = [storedStages filteredArrayUsingPredicate:identifierPredicate];
        [storedStages removeObjectsInArray:results];
        [self saveStoredStages:storedStages];
    }
}

#pragma mark - Optional maintenance

- (void)clearStoredData {
    [self removeItemAtPath:[self storedStagesPath]];
    [self removeItemAtPath:[self storedConfigurationsPath]];
}

- (void)removeItemAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
}

@end
