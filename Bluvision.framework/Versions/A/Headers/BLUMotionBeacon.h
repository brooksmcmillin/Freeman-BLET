//
//  BLUMotionBeacon.h
//
//  Copyright (c) 2015 BluVision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

@class BLUBattery;
@class BLUTemperature;

/**
 *  `BLUMotionBeacon` objects represent beacons that have been identified as Bluvision Motion beacons.
 *
 *  @discussion Motion beacon objects hold the telemetry data included in Motion advertisements.
 */
@interface BLUMotionBeacon : BLUBluetoothBeacon

#pragma mark - Properties
/** @name Properties */

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
 *  The beacon's acceleration event counter.
 */
@property (nonatomic, readonly) NSArray *eventCounter;

/**
 *  The currently measured g-force acceleration value for this beacon's x-axis.
 */
@property (nonatomic, readonly) NSNumber *xAxisAcceleration;

/**
 *  The currently measured g-force acceleration value for this beacon's y-axis.
 */
@property (nonatomic, readonly) NSNumber *yAxisAcceleration;

/**
 *  The currently measured g-force acceleration value for this beacon's z-axis.
 */
@property (nonatomic, readonly) NSNumber *zAxisAcceleration;

@end
