//
//  BLUSLegacyBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUConfigurableBeacon.h"

@class BLUDevice;
@class BLUBattery;
@class BLUTemperature;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUSLegacyBeacon` objects represent `BLUConfigurableBeacon` objects that have been identified as legacy Bluvision sBeacons.
 *
 *  @discussion Legacy sBeacon objects hold the telemetry data and identifiers included in sBeacon legacy advertisements.
 *  They also contain device information that is only available after connecting to the beacon and reading its configuration.
 */
@interface BLUSLegacyBeacon : BLUConfigurableBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The beacon's 32 bit numeric identifier.
 */
@property (nonatomic, readonly) NSNumber *identifier;

/**
 *  The device that is broadcasting the advertisements associated with this beacon.
 *  @see BLUDevice
 */
@property (nonatomic, readonly) BLUDevice *device;

/**
 *  The battery that is associated with this beacon.
 *  @see BLUBattery
 */
@property (nonatomic, readonly) BLUBattery *battery;

/**
 *  The ambient temperature currently measured by this beacon.
 *  @see BLUTemperature
 */
@property (nonatomic, readonly) BLUTemperature *temperature;

/**
 *  A boolean indicating whether the beacon is broadcasting manufacturer data conforming to the legacy sBeacon format.
 *  
 *  @discussion Depending on their settings some older Bluvision beacon models may be broadcasting blank advertisements in their factory state. These beacons
 *  will be represented by legacy sBeacon objects, too. Use this boolean to differentiate between beacons that actually broadcast the legacy sBeacon format
 *  and those that don't.
 */
@property (nonatomic, readonly) BOOL hasValidManufacturerData;

#pragma mark - Beacon settings
/** @name Beacon settings */

/**
 *  Sets up the beacon to enter deep sleep mode after the specified time interval. In deep sleep,
 *  the beacon will not send any broadcasts until it is physically woken up - e.g. via button tap.
 *  After being woken up the beacon will go back to sleep once the specified time interval has passed again.
 *  The beacon needs to be connected in order to execute this.
 *  This operation is only supported by certain beacon types and will return an error if sent to
 *  an unsupported device.
 *
 *  @param timeInterval  Time interval after which the beacon will go to sleep.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)setBeaconSleepTimeout:(NSTimeInterval)timeInterval completion:(nullable void (^)(NSError * __nullable error))completion;

/**
 *  Immediately enables or disables deep sleep mode on the beacon.
 *  If enabled, the beacon will enter sleep mode only once. It won't go back to sleep again after it has been woken up.
 *  If disabled, the beacon will permanently stay awake.
 *  This operation is only supported by certain beacon types and will return an error if sent to
 *  an unsupported device.
 *
 *  @param enable        `YES` to put the beacon to sleep. `NO` wake it up permanently.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)enableBeaconSleepMode:(BOOL)enable completion:(nullable void (^)(NSError * __nullable error))completion;

/**
 *  Sets the beacon's internal timer. This timer will increment every second and reset when the beacon reboots.
 *  The timer can be used to represent the current time by setting it to an appropriate Unix timestamp.
 *
 *  @param timeInterval  The time interval in seconds that the beacon's timer will be set to.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)setDeviceTime:(NSTimeInterval)timeInterval completion:(void (^)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
