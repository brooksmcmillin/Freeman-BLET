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

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *locationCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *contentsCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *saveCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *nameCell;

@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneNamespaceCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneURLCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneTemperatureCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneBatteryVoltageCell;
@property (nonatomic, weak)     IBOutlet    BLUTableViewCell        *eddystoneCounterCell;
@property (weak, nonatomic) IBOutlet BLUTableViewCell *eddystoneInstanceCell;

- (IBAction)connectToBeacon:(id)sender;
@end

@implementation BLUBeaconDetailViewController
{
    id   _keyboardWillShowNotifier;
    id   _keyboardWillHideNotifier;

    id   _rotatingIBeaconNotifier;
    
    int _outVal;
    
    BOOL _showsTimeoutPicker;
    BOOL _showsErrorCell;
    
    NSInteger _timeoutDays;
    NSInteger _timeoutHours;
    NSInteger _timeoutMinutes;
}
 
#pragma mark - Managing the beacon

/*- (void)removeObserversForBeacon:(BLUBeacon *)beacon {
    [beacon removeObserver:self forKeyPath:@"RSSI"];

    if ([beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        [beacon removeObserver:self forKeyPath:@"uptime"];
    }
    if ([beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        [beacon removeObserver:self forKeyPath:@"decoding"];
        [beacon removeObserver:self forKeyPath:@"decoded"];
    }
}*/

- (void)addObserversForBeacon:(BLUBeacon *)beacon
{
    [beacon addObserver:self forKeyPath:@"RSSI" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    if ([beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]) {
        [beacon addObserver:self forKeyPath:@"uptime" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    if ([beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
        [beacon addObserver:self forKeyPath:@"decoding" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [beacon addObserver:self forKeyPath:@"decoded" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)setBeacon:(BLUBeacon *)beacon {
    if (_beacon != beacon) {
       /* if (_beacon) {
            [self removeObserversForBeacon:_beacon];
        }*/
        _beacon = beacon;
        [self addObserversForBeacon:_beacon];
        if ([_beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
            BLUSEncryptedBeacon *encrBeacon = (BLUSEncryptedBeacon *)_beacon;
            [encrBeacon setEncryptionDelegate:self];
        }
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark - View lifecycle

- (void)addObserversForBeaconManager {
    [self.beaconManager addObserver:self forKeyPath:@"centralManagerState" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserversForBeaconManager {
    [self.beaconManager removeObserver:self forKeyPath:@"centralManagerState" context:nil];
}

- (void)configureView
{
    // Update the user interface for the beacon.
    
    BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)self.beacon;
    
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:[eddystoneBeacon.identifier.instanceIdentifier hexStringRepresentation]];
    [scanner scanHexInt:&outVal];
    
    _outVal = outVal;
    
    [self getCustomData:outVal];
    
    self.title = [NSString stringWithFormat:@"Box #%d Details", outVal];
    self.eddystoneNamespaceCell.detailTextLabel.text = [eddystoneBeacon.identifier.namespaceIdentifier hexStringRepresentation] ?: @"Unknown";
    self.eddystoneInstanceCell.detailTextLabel.text = [eddystoneBeacon.identifier.instanceIdentifier hexStringRepresentation] ?: @"Unknown";
    
    UIButton *saveButton = (UIButton *)[self.saveCell viewWithTag:99];
    [saveButton addTarget:self
                   action:@selector(saveData)
         forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) getCustomData:(int) beaconID
{
    if(beaconID > 0)
    {
    
    NSLog(@"Getting Data: %d", beaconID);
    
    NSString *post = [NSString stringWithFormat:@"beaconID=%d", beaconID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://freeman.brooksmcmillin.com/api/getdata.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //   NSLog(@"Response: %@", [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] );
    
   // NSData *jsonData = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error:&error];
    
    NSString* jsonString = (NSString *) jsonObject;
    NSLog(@"Data: %@", jsonString);
    // Content Cell
    self.eddystoneURLCell.detailTextLabel.text = @"Content Data";
     UITextField *locationTextBox =  (UITextField*)[self.eddystoneCounterCell viewWithTag:99];
     locationTextBox.text = (NSString *)jsonObject[0][1];
     
     // Cell for Location
     UITextField *contentTextBox = (UITextField *)[self.eddystoneURLCell viewWithTag:99];
     contentTextBox.text = (NSString *)jsonObject[0][0];
    
   // NSLog(@"json DATA: %@", (NSString *)jsonObject[0][0]);
    
    // NSLog(@"Response Meta: %@", response);
    
    /*   NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     
     
     NSData * data = [NSURLConnection sendSynchronousRequest:request
     returningResponse:&response
     error:&error];
     
     if (error == nil)
     {
     NSLog([NSString stringWithFormat:@"Response: %@", [response]]);
     }
     else
     {
     NSLog([NSString stringWithFormat:@"Error: %@", error]);
     }*/
    }
    return;
}

-(void)saveData
{
    NSLog(@"Saving Data");
        int beaconID = _outVal;
    
        //  NSLog(@"Checking In: %@ :: %d", deviceName, beaconID);
    
        // Content Cell
        UITextField *locationTextBox =  (UITextField*)[self.eddystoneCounterCell viewWithTag:99];

        // Cell for Location
        UITextField *contentTextBox = (UITextField *)[self.eddystoneURLCell viewWithTag:99];

    
        NSString *post = [NSString stringWithFormat:@"beaconID=%d&contents=%@&location=%@", beaconID, contentTextBox.text, locationTextBox.text];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://freeman.brooksmcmillin.com/api/updatedata.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        /*  NSData * data = [NSURLConnection sendSynchronousRequest:request
         returningResponse:&response
         error:&error];
         
         if (error == nil)
         {
         NSLog([NSString stringWithFormat:@"Response: %@", response]);
         }
         else
         {
         NSLog([NSString stringWithFormat:@"Error: %@", error]);
         }
         */

}


- (void)refreshTimeoutPickerWithTimeInterval:(NSTimeInterval)timeInterval {
    _timeoutDays        = (timeInterval / 3600) / 24;
    NSInteger remaining = timeInterval - (_timeoutDays * 3600 * 24);
    _timeoutHours       = remaining / 3600;
    remaining           = remaining - (_timeoutHours * 3600);
    _timeoutMinutes     = remaining / 60;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addObserversForBeaconManager];
    [self toggleKeyboardNotifiers:YES];
    [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeObserversForBeaconManager];
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
    
    if (indexPath.section == BLUBeaconDetailSectionTimeout && indexPath.row == 0) {
        [tableView beginUpdates];
        _showsTimeoutPicker = !_showsTimeoutPicker;
        [tableView endUpdates];
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

- (void)dismissWritingAlertWithError:(NSError *)error {

    [self configureView];
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error writing to Beacon" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorAlert show];
    }
    
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Beacon written successfully" message:nil delegate:nil cancelButtonTitle:@"Ok, thanks" otherButtonTitles:nil];
    [successAlert show];
}

#pragma mark - Configurable Beacon Delegate

- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didChangeState:(BLUConfigurableBeaconConnectionState)state {
    [self configureView];
}

- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didDisconnectWithError:(NSError *)error {

    [self.tableView beginUpdates];
    [self configureView];
    [self.tableView endUpdates];
    
    [self updateTableHeaders];
    [self updateTableFooters];
    
    if (error) {
        [self.tableView beginUpdates];
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
        });
    }
    else if ([keyPath isEqualToString:@"centralManagerState"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectButton.enabled = (self.beaconManager.centralManagerState == CBCentralManagerStatePoweredOn);
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

- (BOOL)shouldShowSection:(NSInteger)section
{
    
    return YES;
}

- (BOOL)shouldShowRow:(NSInteger)row inSection:(NSInteger)section
{
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Alerts

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 5022) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.tableView endUpdates];
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

#pragma mark - Optional maintenance

- (void)clearStoredData {
    [self removeItemAtPath:[self storedStagesPath]];
    [self removeItemAtPath:[self storedConfigurationsPath]];
}

- (void)removeItemAtPath:(NSString *)path {
   /* if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }*/
}
@end
