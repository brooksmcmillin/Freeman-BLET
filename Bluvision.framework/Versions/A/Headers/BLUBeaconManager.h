//
//  BLUBeaconManager.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUDistance.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class BLUBeaconManager;
@class BLUBeaconFilter;
@class BLUBeacon;

/**
 *  The `BLUBeaconManagerDelegate` protocol defines the methods that a delegate of a `BLUBeaconManager` object must adopt.
 * 
 *  @discussion The beacon manager delegate provides events for all types of beacon discovery. CoreLocation and CoreBluetooth monitoring 
 *  will invoke the same methods. For example if `beaconManager:didRangeBeacons:inRegion:` is invoked, then `beaconManager:beacon:didChangeDistance:`
 *  will be invoked with the same beacon object.
 *
 *  For more information on iBeacon monitoring see Apple's Core Location documentation. It is not required to adopt all
 *  Core Location delegate methods as the framework provides them in lieu of their absence.
 *
 */
@protocol BLUBeaconManagerDelegate <NSObject>

@optional

#pragma mark - Beacon Monitoring
/** @name Beacon Monitoring */

/**
 *  Tells the delegate that the state of the beacon manager's CBCentralManager has changed.
 *
 *  @param manager The beacon manager providing this information.
 *  @param state   The new state of the central manager.
 */
- (void)beaconManager:(BLUBeaconManager *)manager centralManagerDidChangeState:(CBCentralManagerState)state;

/**
 *  Tells the delegate that the beacon manager encountered an error.
 *
 *  @param manager The beacon manager providing this information.
 *  @param error   The cause of the failure.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didFailWithError:(nullable NSError *)error;

/**
 *  Invoked when the beacon manager finds a beacon for the first time. This will only be invoked once for the lifetime of a beacon
 *
 *  @param manager The beacon manager providing this information.
 *  @param beacon  The `BLUBeacon` subclass that was found.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didFindBeacon:(BLUBeacon *)beacon;

/**
 *  Invoked when the beacon manager loses sight of a beacon. This will only be invoked once at the end of the lifetime of a beacon.
 *
 *  @param manager The beacon manager providing this information.
 *  @param beacon  The `BLUBeacon` subclass that was found.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didLoseBeacon:(BLUBeacon *)beacon;

/**
 *  Tells the delegate that a monitored beacon has a change in distance.
 *
 *  @param manager  The beacon manager providing this information.
 *  @param beacon   The `BLUBeacon` subclass whose distance has changed.
 *  @param distance The new distance value.
 */
- (void)beaconManager:(BLUBeaconManager *)manager beacon:(BLUBeacon *)beacon didChangeDistance:(BLUDistance)distance;

#pragma mark - CoreLocation Based Monitoring
/** @name CoreLocation Based Monitoring */

/**
 *  Tells the delegate that the authorization status for the application changed.
 *
 *  @param manager The beacon manager providing this information.
 *  @param status  The new authorization status for the application.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

/**
 *  Tells the delegate that the user entered the specified region.
 *
 *  @param manager The beacon manager providing this information.
 *  @param region  The region that was entered
 */
- (void)beaconManager:(BLUBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region;

/**
 *  Tells the delegate that the user left the specified region.
 *
 *  @param manager The beacon manager providing this information.
 *  @param region  The region that was exited.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region;

/**
 *  Tells the delegate about the state of the specified region.
 *
 *  @param manager The beacon manager providing this information.
 *  @param state   The state of the specified region. For a list of possible values, see the `CLRegionState` type.
 *  @param region  The region whose state was determined.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region;

/**
 *  Tells the delegate that a new region is being monitored.
 *
 *  @param manager The beacon manager providing this information.
 *  @param region  The region that is being monitored.
 */
- (void)beaconManager:(BLUBeaconManager *)manager didStartMonitoringForRegion:(CLBeaconRegion *)region;

/**
 *  Tells the delegate that one or more beacons are in range.
 *
 *  @param manager The beacon manager providing this information
 *  @param beacons An array of `BLUIBeacon` objects currently in range.
 *  @param region  The region containing the parameters that were used to locate the beacons. 
 */
- (void)beaconManager:(BLUBeaconManager *)manager didRangeBeacons:(__kindof NSArray <BLUBeacon *> *)beacons inRegion:(CLBeaconRegion *)region;

@end

/**
 *  `BLUBeaconManager` objects are used to manage the discovery of beacons.
 * 
 *  @discussion The beacon manager is responsible for discovering beacons though CoreBluetooth,
 *  as well as providing a light wrapper around CoreLocation.
 *  If your application requires the use of iBeacons and monitoring iBeacon regions
 *  please see Apple's Core Location documentation.
 */
@interface BLUBeaconManager : NSObject

#pragma mark - Delegate properties
/** @name Delegate properties*/

/**
 *  The delegate object you want to receive `BLUBeaconManager` events.
 */
@property (nonatomic, nullable ,weak) id<BLUBeaconManagerDelegate> delegate;

/**
 *  The `NSOperationQueue` for all delegates and callbacks to be dispatched to.
 */
@property (nonatomic, readonly) NSOperationQueue *delegateQueue;

#pragma mark - CoreBluetooth properties
/** @name CoreBluetooth properties */

/**
 *  The state of the beacon manager's CoreBluetooth Central Manager.
 */
@property (nonatomic, readonly) CBCentralManagerState centralManagerState;

#pragma mark - CoreLocation region properties
/** @name CoreLocation region properties */

/**
 *  The set of regions monitored by the beacon manager.
 */
@property (nonatomic, readonly) NSSet <CLBeaconRegion *> *monitoredRegions;

/**
 *  The set of regions ranged by the beacon manager.
 */
@property (nonatomic, readonly) NSSet <CLBeaconRegion *> *rangedRegions;

#pragma mark - Beacon properties
/** @name Beacon properties */

/**
 *  The set of found beacons that match any applied filters.
 */
@property (nonatomic, readonly) NSSet <__kindof BLUBeacon *> *foundBeacons;

/**
 *  The set of all beacons.
 */
@property (nonatomic, readonly) NSSet <__kindof BLUBeacon *> *allBeacons;

#pragma mark - Filter properties
/** @name Filter properties*/

/**
 *  The set of applied filters to the beacon manager.
 */
@property (nonatomic, readonly) NSSet <BLUBeaconFilter *> *appliedFilters;

/**
 *  Weather or not the beacon manager is currently scanning
 */
@property (nonatomic, readonly, getter=isScanning) BOOL scanning;

#pragma mark - Initialization
/** @name Initialization */

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 *  Initializes an instance of beacon manager with the specified delegate object.
 *
 *  @param delegate The delegate to receive beacon manager events.
 *
 *  @return Returns a newly initialized beacon manager.
 */
- (instancetype)initWithDelegate:(nullable id<BLUBeaconManagerDelegate>)delegate;

/**
 *  Initializes an instance of beacon manager with the specified delegate object and delegate queue.
 *
 *  @param delegate      The delegate to receive beacon manager events.
 *  @param delegateQueue The queue to dispatch all delegate events on. If the value is `nil`, the beacon manager dispatches events using the main queue.
 *  @param options       An optional dictionary containing initialization options for the beacon manager's instance of CBCentralManager.
 *
 *  @return Returns a newly initialized beacon manager instance.
 */
- (instancetype)initWithDelegate:(nullable id<BLUBeaconManagerDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)delegateQueue options:(nullable NSDictionary *)options NS_DESIGNATED_INITIALIZER;

#pragma mark - CoreLocation based scanning
/** @name CoreLocation based scanning */

/**
 *  Starts monitoring the specified region.
 *
 *  @param region The region object that defines the boundary to monitor.
 */
- (void)startMonitoringForRegion:(CLBeaconRegion *)region;

/**
 *  Stops monitoring the specified region.
 *
 *  @param region The region object currently being monitored.
 */
- (void)stopMonitoringForRegion:(CLBeaconRegion *)region;

/**
 *  Starts the delivery of notifications for beacons in the specified beacon region.
 *
 *  @param region The region object that defines the identifying information for the targeted beacons.
 */
- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region;

/**
 *  Stops the delivery of notifications for the specified beacon region.
 *
 *  @param region The region that identifies the beacons.
 */
- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region;

/**
 *  Retrieves the state of a region.
 *
 *  @param region The region whose state you want to know.
 */
- (void)requestStateForRegion:(CLBeaconRegion *)region;

#pragma mark - CoreLocation Authorization
/** @name CoreLocation Authorization */

/**
 *  Returns the app's authorization status for using location services.
 *
 *  @return A value indicating whether the app is authorized to use location services.
 */
+ (CLAuthorizationStatus)authorizationStatus;

/**
 *  Requests permission to use location services while the app is in the foreground.
 */
- (void)requestWhenInUseAuthorization;

/**
 *  Requests permission to use location services whenever the app is running.
 */
- (void)requestAlwaysAuthorization;

#pragma mark Bluetooth based scanning
/** @name Bluetooth based scaning */

/**
 *  Begins scanning for beacons via bluetooth.
 *
 *  @discussion When a beacon is first discovered the `beaconManager:didFindBeacon:` method will be invoked.
 *  Whenever that beacon's ranging information changes `beaconManager:beacon:didChangeDistance:` will be called.
 *  After the beacon has not been seen for some time `beaconManager:didLoseBeacon:` will be invoked notifying you that the beacon cannot be seen.
 *
 */
- (void)startScanningForBeacons;

/**
 *  Begins scanning for beacon via bluetooth with the specified time interval. Scanning will stop once this interval has been reached.
 *
 *  @param interval The time interval which scanning will happen for.
 */
- (void)startScanningForBeaconsWithInterval:(NSTimeInterval)interval;

/**
 *  Stops the scanning for bluetooth beacons.
 */
- (void)stopScanning;

#pragma mark - Filtering
/** @name Filtering */

/**
 *  Adds a filter to the scanning of beacon. If a beacon does not match any applied filters,
 *  then you will not be notified of any beacon related discovery delegate methods
 *
 *  @param filter The filter to add
 */
- (void)addFilter:(BLUBeaconFilter *)filter;

/**
 *  Removes a filter that has been previously applied.
 *
 *  @param filter The filter to remove
 */
- (void)removeFilter:(BLUBeaconFilter *)filter;

/**
 *  Removes all applied filters.
 */
- (void)removeAllFilters;

#pragma mark - Associating beacons
/** @name Associating beacons */

/**
 *  A single beacon object might be associated with multiple other beacon objects.
 *  For example. A Bluvision beacon might be set up to broadcast sBeacon and EddystoneBeacons at the same time.
 *  Using this method you can find out all the different beacon objects associated with a specified beacon.
 *
 *  @param beacon The beacon object to get associated beacons for
 *
 *  @return An array of beacons associated with the specified beacon.
 */
- (nullable NSArray <__kindof BLUBeacon *> *)associatedBeaconsForBeacon:(BLUBeacon *)beacon;

@end

NS_ASSUME_NONNULL_END
