//
//  BLUBeaconListViewController.m
//  bluvision_sdk_test
//
//  Created by Lutz Hennig on 19/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUBeaconListViewController.h"
#import "BLUBeaconDetailViewController.h"
#import "BLUIBeaconViewController.h"
#import "BLUBeaconCell.h"
#import "BLUBeaconFormatter.h"
#import "NSData+String.h"

typedef NS_ENUM(NSUInteger, BLUBeaconListSection) {
    BLUBeaconListSectionConfigurable = 0,
    BLUBeaconListSectionEddystone,
    BLUBeaconListSectionIBeacon,
    BLUBeaconListSectionOptional
};

NSString * const BLUBeaconListViewControllerDidUpdateRotatingIBeaconNotification = @"BLUBeaconListViewControllerDidUpdateRotatingIBeacon";

@interface BLUBeaconListViewController () <BLUBeaconManagerDelegate, BLUIBeaconViewControllerDelegate>

@property (nonatomic, strong)           NSMutableArray    *configurableBeacons;
@property (nonatomic, strong)           NSMutableArray    *eddystoneBeacons;
@property (nonatomic, strong)           NSMutableArray    *iBeacons;
@property (nonatomic, strong)           NSMutableArray    *optionalBeacons;
@property (nonatomic, strong)           BLUBeaconManager  *beaconManager;
@property (nonatomic, strong)           NSIndexPath       *selectedIndexPath;

@property (nonatomic, strong)           NSMutableSet      *pendingIBeaconRegions;

@property (nonatomic, weak)   IBOutlet  UIBarButtonItem   *scanButton;
- (IBAction)scanForBeacons:(id)sender;

@property (nonatomic, strong)           NSTimer           *scanResetTimer;
@property (nonatomic, strong) NSData *iBeaconRotationKey;
@end

@implementation BLUBeaconListViewController
{
    int lastUpdate[3];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lastUpdate[0] = 0;
    lastUpdate[1] = 0;
    lastUpdate[2] = 0;
    
    self.beaconManager = [[BLUBeaconManager alloc] initWithDelegate:self];
    BLUBeaconFilter *beaconFilter = [[BLUBeaconFilter alloc] init];
    
    [self.beaconManager addFilter:beaconFilter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.beaconManager.isScanning) {
        [self scanForBeacons:self.scanButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewBeacon:(BLUBeacon *)beacon
{
    if (!self.configurableBeacons)
    {
        self.configurableBeacons = [[NSMutableArray alloc] init];
    }
    if (!self.eddystoneBeacons)
    {
        self.eddystoneBeacons = [[NSMutableArray alloc] init];
    }
    if (!self.iBeacons)
    {
        self.iBeacons = [[NSMutableArray alloc] init];
    }
    if (!self.optionalBeacons)
    {
        self.optionalBeacons = [[NSMutableArray alloc] init];
    }
    NSIndexPath *indexPath = nil;
    /*if ([beacon isKindOfClass:[BLUConfigurableBeacon class]])
    {
        [self.configurableBeacons addObject:beacon];
        indexPath = [NSIndexPath indexPathForRow:self.configurableBeacons.count-1 inSection:BLUBeaconListSectionConfigurable];
        
        //  Enable this to toggle default sBeacon advertisement encryption decoding for any found encrypted sBeacon.
        /*
        if ([beacon isKindOfClass:[BLUSEncryptedBeacon class]]) {
            BLUSEncryptedBeacon *encBeacon = (BLUSEncryptedBeacon *)beacon;
            NSDictionary *keys = [BLUSBeaconEncryptionSettings defaultKeysForSBeaconEncryption];
            NSData *privKey = keys[BLUSBeaconEncryptionKeyDictionaryPrivateKey];
            NSData *rotKey = keys[BLUSBeaconEncryptionKeyDictionaryRotationKey];
            NSData *csKey = keys[BLUSBeaconEncryptionKeyDictionaryChecksumKey];
            encBeacon.privateKey = privKey;
            encBeacon.rotationKey = rotKey;
            encBeacon.checksumKey = csKey;
            encBeacon.rotationInterval = @(300);
        }
        *//*
    }
    else */
    
    // Where beacons are added to the list.
    if ([beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]/* ||
             [beacon isKindOfClass:[BLUEddystoneURLBeacon class]] ||
             [beacon isKindOfClass:[BLUEddystoneTLMBeacon class]]*/)
    {
        
        BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)beacon;
        
      //  if(eddystoneBeacon && eddystoneBeacon.identifier)
            NSLog(@"Test : %@\n", eddystoneBeacon.identifier);
        
        if([[eddystoneBeacon.identifier.namespaceIdentifier hexStringRepresentation] isEqualToString:@"AABBCCDDEEFFAABBCCDD"])
        {
        
            [self.eddystoneBeacons addObject:beacon];
            indexPath = [NSIndexPath indexPathForRow:self.eddystoneBeacons.count-1 inSection:BLUBeaconListSectionEddystone];
        }
    }
    /*else if ([beacon isKindOfClass:[BLUIBeacon class]]) {
        BOOL newBeacon = YES;
        
        //  Enable this to toggle default iBeacon advertisement encryption decoding for any found iBeacon.

        if (self.iBeaconRotationKey) {
            BLUIBeacon *iBeacon = (BLUIBeacon *)beacon;
            [iBeacon enableIBeaconDecoding:YES withRotationKey:self.iBeaconRotationKey identifierBitLength:@16];
            newBeacon = ![self updateRotatingIBeaconWithIBeacon:iBeacon];
        }

        if (newBeacon) {
            [self.iBeacons addObject:beacon];
            indexPath = [NSIndexPath indexPathForRow:self.iBeacons.count-1 inSection:BLUBeaconListSectionIBeacon];
        }
    }
    else if ([beacon isKindOfClass:[BLUMotionBeacon class]] ||
             [beacon isKindOfClass:[BLULightSensorBeacon class]]) {
        [self.optionalBeacons addObject:beacon];
        indexPath = [NSIndexPath indexPathForRow:self.optionalBeacons.count-1 inSection:BLUBeaconListSectionOptional];
    }*/
    
    if (indexPath) {
        BOOL isVisible = self.isViewLoaded && self.view.window;

        if (isVisible) {
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)removeBeacon:(BLUBeacon *)beacon {
    if (!self.configurableBeacons &&
        !self.eddystoneBeacons &&
        !self.iBeacons &&
        !self.optionalBeacons) {
        return;
    }
    NSIndexPath *indexPath = nil;
    if ([self.configurableBeacons containsObject:beacon]) {
        indexPath = [NSIndexPath indexPathForRow:[self.configurableBeacons indexOfObject:beacon] inSection:BLUBeaconListSectionConfigurable];
        [self.configurableBeacons removeObject:beacon];
        
    }
    else if ([self.eddystoneBeacons containsObject:beacon]) {
        indexPath = [NSIndexPath indexPathForRow:[self.eddystoneBeacons indexOfObject:beacon] inSection:BLUBeaconListSectionEddystone];
        [self.eddystoneBeacons removeObject:beacon];
        
    }
    else if ([self.iBeacons containsObject:beacon]) {
        indexPath = [NSIndexPath indexPathForRow:[self.iBeacons indexOfObject:beacon] inSection:BLUBeaconListSectionIBeacon];
        [self.iBeacons removeObject:beacon];
        
    }
    else if ([self.optionalBeacons containsObject:beacon]) {
        indexPath = [NSIndexPath indexPathForRow:[self.optionalBeacons indexOfObject:beacon] inSection:BLUBeaconListSectionOptional];
        [self.optionalBeacons removeObject:beacon];
    }

    BOOL isVisible = self.isViewLoaded && self.view.window;

    if (isVisible) {
        if (indexPath) {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (BOOL)updateRotatingIBeaconWithIBeacon:(BLUIBeacon *)iBeacon {
    if ([self.iBeacons containsObject:iBeacon]) {
        return YES;
    }
    
    NSPredicate *rotationIdentifierPredicate = [NSPredicate predicateWithFormat:@"rotationIdentifier == %@", iBeacon.rotationIdentifier];
    NSArray *results = [self.iBeacons filteredArrayUsingPredicate:rotationIdentifierPredicate];
    
    if (results.count > 0) {
        BLUIBeacon *foundBeacon = [results firstObject];        
        NSInteger index = [self.iBeacons indexOfObject:foundBeacon];
        if (index != NSNotFound && index < self.iBeacons.count) {
            [self.iBeacons replaceObjectAtIndex:index withObject:iBeacon];
                    
            BOOL isVisible = self.isViewLoaded && self.view.window;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:BLUBeaconListSectionIBeacon];
            if (isVisible) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BLUBeaconListViewControllerDidUpdateRotatingIBeaconNotification object:self userInfo: @{@"oldIBeacon" : foundBeacon, @"newIBeacon" : iBeacon}];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSArray *beaconList = nil;
        if (self.selectedIndexPath.section == BLUBeaconListSectionConfigurable) {
            beaconList = self.configurableBeacons;
        }
        else if (self.selectedIndexPath.section == BLUBeaconListSectionEddystone) {
            beaconList = self.eddystoneBeacons;
        }
        else if (self.selectedIndexPath.section == BLUBeaconListSectionIBeacon) {
            beaconList = self.iBeacons;
        }
        else if (self.selectedIndexPath.section == BLUBeaconListSectionOptional) {
            beaconList = self.optionalBeacons;
        }
        
        BLUBeacon *beacon = beaconList[self.selectedIndexPath.row];
        BLUBeaconDetailViewController *controller = [segue destinationViewController];
        
        if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
            controller = (BLUBeaconDetailViewController *)[[segue destinationViewController] topViewController];
        }

        controller.beaconManager = self.beaconManager;
        controller.beacon = beacon;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"presentIBeacon"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        BLUIBeaconViewController *viewController = navigationController.viewControllers[0];
        viewController.delegate = self;
    }
}

- (IBAction)refreshToSort:(id)sender {

    BOOL wasScanning = self.beaconManager.isScanning;
    if (wasScanning) {
        [self.beaconManager stopScanning];
    }

    NSComparisonResult (^comparitor)(BLUBeacon *beacon1, BLUBeacon *beacon2) = ^NSComparisonResult(BLUBeacon *beacon1, BLUBeacon *beacon2)
    {

        if (beacon1.distance == BLUDistanceUnknown)
        {
            return NSOrderedDescending;
        }

        if (beacon2.distance == BLUDistanceUnknown)
        {
            return NSOrderedAscending;
        }

        if (beacon1.distance == beacon2.distance) {
            NSNumber *rssi1 = beacon1.RSSI.integerValue > 0 ? @-127 : beacon1.RSSI;
            NSNumber *rssi2 = beacon2.RSSI.integerValue > 0 ? @-127 : beacon2.RSSI;

            return [rssi2 compare:rssi1];
        }
        else if (beacon1.distance > beacon2.distance)
        {
            return NSOrderedDescending;
        }
        else if (beacon1.distance < beacon2.distance)
        {
            return NSOrderedAscending;
        }

        return NSOrderedSame;
    };


    [self.configurableBeacons sortUsingComparator:comparitor];
    [self.eddystoneBeacons sortUsingComparator:comparitor];
    [self.iBeacons sortUsingComparator:comparitor];
    [self.optionalBeacons sortUsingComparator:comparitor];

    if (wasScanning) {
        [self.beaconManager startScanningForBeacons];
    }

    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case BLUBeaconListSectionConfigurable:
            return self.configurableBeacons.count;
        case BLUBeaconListSectionEddystone:
            return self.eddystoneBeacons.count;
        case BLUBeaconListSectionIBeacon:
            return self.iBeacons.count;
        case BLUBeaconListSectionOptional:
            return self.optionalBeacons.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLUBeaconCell *cell = (BLUBeaconCell *)[tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];

    NSArray *beaconList = nil;
    if (indexPath.section == BLUBeaconListSectionConfigurable)
    {
        beaconList = self.configurableBeacons;
    }
    else if (indexPath.section == BLUBeaconListSectionEddystone)
    {
        beaconList = self.eddystoneBeacons;
    }
    else if (indexPath.section == BLUBeaconListSectionIBeacon)
    {
        beaconList = self.iBeacons;
    }
    else if (indexPath.section == BLUBeaconListSectionOptional)
    {
        beaconList = self.optionalBeacons;
    }
    BLUBeacon *beacon = beaconList[indexPath.row];

    NSString *cellTitle = @"Unknown beacon";
    if ([beacon isKindOfClass:[BLUIBeacon class]])
    {
        cellTitle = ((BLUIBeacon *)beacon).proximityUUID.UUIDString;
    }
    else
    {
        cellTitle = ((BLUBluetoothBeacon *)beacon).name;
    }
    
    BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)beacon;
    
    NSLog(@"Refreshing?\n");
    
    cell.topLabel.text = [self getName:eddystoneBeacon];
    cell.rightLabel.text = [NSString stringWithFormat:@"%li dBm", (long)[beacon.RSSI integerValue]];
    if ([beacon isKindOfClass:[BLUMotionBeacon class]])
    {
        cell.bottomLabel.text = @"Motion Beacon";
    }
    else if ([beacon isKindOfClass:[BLULightSensorBeacon class]])
    {
        cell.bottomLabel.text = @"Light Sensor Beacon";
    }
    else
    {
        cell.bottomLabel.text = [NSString stringWithFormat:@"Distance: %@", [BLUBeaconFormatter titleForBeaconDistance:beacon.distance]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case BLUBeaconListSectionConfigurable:
            return self.configurableBeacons.count > 0 ? 44.0 : 0.0;
        case BLUBeaconListSectionEddystone:
            return self.eddystoneBeacons.count > 0 ? 44.0 : 0.0;
        case BLUBeaconListSectionIBeacon:
            return self.iBeacons.count > 0 ? 44.0 : 0.0;
        case BLUBeaconListSectionOptional:
            return self.optionalBeacons.count > 0 ? 44.0 : 0.0;
        default:
            return 44.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case BLUBeaconListSectionConfigurable:
            return self.configurableBeacons.count > 0 ? 44.0 : 0.000001;
        case BLUBeaconListSectionEddystone:
            return self.eddystoneBeacons.count > 0 ? 44.0 : 0.000001;
        case BLUBeaconListSectionIBeacon:
            return self.iBeacons.count > 0 ? 44.0 : 0.000001;
        case BLUBeaconListSectionOptional:
            return self.optionalBeacons.count > 0 ? 44.0 : 0.000001;
        default:
            return 44.0;
    }
    
    return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case BLUBeaconListSectionConfigurable:
            return self.configurableBeacons.count > 0 ? @"Configurable Beacons" : nil;
        case BLUBeaconListSectionEddystone:
            return self.eddystoneBeacons.count > 0 ? @"Boxes Near Me" : nil;
        case BLUBeaconListSectionIBeacon:
            return self.iBeacons.count > 0 ? @"iBeacons" : nil;
        case BLUBeaconListSectionOptional:
            return self.optionalBeacons.count > 0 ? @"Optional Beacons" : nil;
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

#pragma mark - Scanning

- (void)startScanResetTimer {
    if (self.scanResetTimer) {
        [self invalidateScanResetTimer];
    }
    self.scanResetTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(scanResetTimerDidFire:) userInfo:nil repeats:YES];
}

- (void)invalidateScanResetTimer {
    if ([self.scanResetTimer isValid]) {
        [self.scanResetTimer invalidate];
    }
    self.scanResetTimer = nil;
}

- (void)scanResetTimerDidFire:(NSTimer *)timer {
    [self resetScan];
}

- (void)resetScan
{
    if ([self.beaconManager isScanning])
    {
        NSLog(@"Resetting beacon scan");
        [self.beaconManager stopScanning];
        [self.beaconManager startScanningForBeacons];
    }
}

- (IBAction)scanForBeacons:(id)sender {
    if (self.beaconManager.isScanning) {
        [self invalidateScanResetTimer];
        [self.beaconManager stopScanning];
        [self.scanButton setTitle:@"Scan"];
    }
    else {
        [self startScanResetTimer];
        [self.beaconManager startScanningForBeacons];
        [self.scanButton setTitle:@"Stop Scanning"];
    }
}

#pragma mark - Beacon Manager Delegate

/* Core Bluetooth based scanning */
- (void)beaconManager:(BLUBeaconManager *)manager didFindBeacon:(BLUBeacon *)beacon {
    [self insertNewBeacon:beacon];
}

- (void)beaconManager:(BLUBeaconManager *)manager beacon:(BLUBeacon *)beacon didChangeDistance:(BLUDistance)distance
{
    BLUBluetoothBeacon *bBeacon = (BLUBluetoothBeacon *)beacon;
    NSIndexPath *indexPath = nil;
   /* if ([self.configurableBeacons containsObject:beacon])
    {
        NSInteger row = [self.configurableBeacons indexOfObject:beacon];
        if (row != NSNotFound && row < [self.configurableBeacons count])
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:BLUBeaconListSectionConfigurable];
        }
    }
    else */if ([self.eddystoneBeacons containsObject:beacon])
    {
        NSInteger row = [self.eddystoneBeacons indexOfObject:beacon];
        if (row != NSNotFound && row < [self.eddystoneBeacons count])
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:BLUBeaconListSectionEddystone];
        }
    }
   /* else if ([self.optionalBeacons containsObject:beacon])
    {
        NSInteger row = [self.optionalBeacons indexOfObject:beacon];
        if (row != NSNotFound && row < [self.optionalBeacons count])
        {
            indexPath = [NSIndexPath indexPathForRow:row inSection:BLUBeaconListSectionOptional];
        }
    }*/
    
    // Where the cells are configured
    
    /*
     
     if ([beacon isKindOfClass:[BLUEddystoneUIDBeacon class]]) {
     BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)beacon;
     [self refreshLabelsWithEddystoneUIDBeacon:eddystoneBeacon];
     }
     
     */
    
    if (indexPath && [beacon isKindOfClass:[BLUEddystoneUIDBeacon class]])
    {
        NSString *deviceName = [[UIDevice currentDevice] name];
        
        
        BLUBeaconCell *cell = (BLUBeaconCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)bBeacon;
        unsigned int outVal;
        NSScanner* scanner = [NSScanner scannerWithString:[eddystoneBeacon.identifier.instanceIdentifier hexStringRepresentation]];
        [scanner scanHexInt:&outVal];
        
        // Change cell color
        long distance = (long)[bBeacon.RSSI integerValue];
       /* if(distance < -80)
        {
            cell.backgroundColor = [UIColor redColor];
        }
        else if(distance < -60)
        {
            cell.backgroundColor = [UIColor yellowColor];
        }
        else*/
        {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        NSString *string = [BLUBeaconFormatter titleForBeaconDistance:beacon.distance];
        if ([string rangeOfString:@".5 meters"].location == NSNotFound) {
           cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor greenColor];
        }
        
      //  NSLog(@"Distance: %ld", distance);
        
       // NSLog(@"Refreshing2?\n");
        [self insertCheckin:deviceName beaconID:outVal];
       // cell.topLabel.text = [self getName:eddystoneBeacon];
        cell.rightLabel.text = [NSString stringWithFormat:@"%li dBm", (long)[bBeacon.RSSI integerValue]];
        if (![beacon isKindOfClass:[BLUMotionBeacon class]] &&
            ![beacon isKindOfClass:[BLULightSensorBeacon class]]) {
            cell.bottomLabel.text = [NSString stringWithFormat:@"Distance: %@", [BLUBeaconFormatter titleForBeaconDistance:beacon.distance]];
        }
    }
}

- (void)beaconManager:(BLUBeaconManager *)manager didLoseBeacon:(BLUBeacon *)beacon {
    [self removeBeacon:beacon];
}

- (void)beaconManager:(BLUBeaconManager *)manager didFailWithError:(NSError *)error {
    NSString *alertTitle = @"Beacon Manager Error";
    if (NSClassFromString(@"UIAlertController"))
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

/* Core Location based scanning */
- (void)beaconManager:(BLUBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        for (CLBeaconRegion *region in self.pendingIBeaconRegions) {
            [self.beaconManager startMonitoringForRegion:region];
            [self.beaconManager requestStateForRegion:region];
        }
        [self.pendingIBeaconRegions removeAllObjects];
    }
}

- (void)beaconManager:(BLUBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region {
    if (state == CLRegionStateInside) {
        if (![manager.rangedRegions containsObject:region]) {
            [manager startRangingBeaconsInRegion:region];
        }
    }
    else {
        if ([manager.rangedRegions containsObject:region]) {
            [manager stopRangingBeaconsInRegion:region];
        }
    }
}

- (void)beaconManager:(BLUBeaconManager *)manager didStartMonitoringForRegion:(CLBeaconRegion *)region {
    [manager requestStateForRegion:region];
}

- (void)beaconManager:(BLUBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    if (![manager.rangedRegions containsObject:region]) {
        [manager startRangingBeaconsInRegion:region];
    }
}

- (void)beaconManager:(BLUBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region {
    if ([manager.rangedRegions containsObject:region]) {
        [manager stopRangingBeaconsInRegion:region];
    }
}

- (void)beaconManager:(BLUBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (BLUIBeacon *beacon in beacons)
    {
        if([beacon isKindOfClass:[BLUEddystoneUIDBeacon class]])
        {
            BLUEddystoneUIDBeacon *eddystoneBeacon = (BLUEddystoneUIDBeacon *)beacon;
            
            if (![self.iBeacons containsObject:beacon])
            {
                [self insertNewBeacon:beacon];
            }
            else
            {
                NSInteger row = [self.iBeacons indexOfObject:beacon];
                if (row != NSNotFound && row < [self.iBeacons count])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:2];
                    BLUBeaconCell *cell = (BLUBeaconCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    cell.topLabel.text = ((BLUIBeacon *)beacon).proximityUUID.UUIDString;
                    cell.rightLabel.text = [NSString stringWithFormat:@"%li dBm", (long)[beacon.RSSI integerValue]];
                    cell.bottomLabel.text = [NSString stringWithFormat:@"Distance: %@", /*[BLUBeaconFormatter titleForBeaconDistance:beacon.distance]*/ eddystoneBeacon.name];
                }
            }
        }
    }
}

#pragma mark - iBeacon View Controller Delegate

- (void)iBeaconViewController:(BLUIBeaconViewController *)viewController didFinishWithIBeaconUUID:(NSUUID *)uuid major:(NSNumber *)major minor:(NSNumber *)minor rotationKey:(NSData *)rotationKey {
    CLBeaconRegion *region = nil;
    if (!major && !minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuid.UUIDString];
    }
    else if (!minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major.intValue identifier:[NSString stringWithFormat:@"%@-%@", uuid.UUIDString, major]];
    }
    else if (major && minor) {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major.intValue minor:minor.intValue identifier:[NSString stringWithFormat:@"%@-%@-%@", uuid.UUIDString, major, minor]];
    }
    if (!region) {
        return;
    }
    region.notifyEntryStateOnDisplay = YES;
    region.notifyOnEntry = YES;
    region.notifyOnExit  = YES;

    self.iBeaconRotationKey = rotationKey;

    if (!self.pendingIBeaconRegions) {
        self.pendingIBeaconRegions = [NSMutableSet new];
    }

    [self.pendingIBeaconRegions addObject:region];

    if ([BLUBeaconManager authorizationStatus] != kCLAuthorizationStatusAuthorized && [BLUBeaconManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [BLUBeaconManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.beaconManager requestAlwaysAuthorization];
    }
    else {
        [self.beaconManager startMonitoringForRegion:region];
        [self.beaconManager requestStateForRegion:region];
        [self.pendingIBeaconRegions removeObject:region];
    }
}

-(NSString *) getName: (BLUEddystoneUIDBeacon *) eddystoneBeacon
{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:[eddystoneBeacon.identifier.instanceIdentifier hexStringRepresentation]];
    [scanner scanHexInt:&outVal];
    
    NSString *post = [NSString stringWithFormat:@"beaconID=%d", outVal];
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
    
    return [NSString stringWithFormat:@"Box #%d: %@", outVal, (NSString *)jsonObject[0][0]];
}

-(void) insertCheckin: (NSString *) deviceName beaconID:(int) beaconID
{
  //  NSLog(@"Checking In: %@ :: %d", deviceName, beaconID);
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    
    // Check timestamp
    int lastTimestamp = lastUpdate[beaconID - 1];
    int timeInterval = 60*5;
    if(lastTimestamp == 0 || (timeStamp - lastTimestamp) > timeInterval)
    {
        NSLog(@"%d :: %d", lastTimestamp, (NSInteger)timeStamp );
        lastUpdate[beaconID - 1] = timeStamp;
    
    NSString *post = [NSString stringWithFormat:@"deviceName=%@&beaconID=%d",deviceName, beaconID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://freeman.brooksmcmillin.com/api/checkin.php"]];
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
    }

-(NSString*) NSStringFromQueryParameters: (NSDictionary*) queryParameters
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

@end
