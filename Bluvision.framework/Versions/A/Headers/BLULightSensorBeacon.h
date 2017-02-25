//
//  BLULightSensorBeacon.h
//
//  Copyright (c) 2015 BluVision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

@class BLUBattery;
@class BLUTemperature;

/**
 *  `BLULightSensorBeacon` objects represent beacons that have been identified as Bluvision light sensor beacons.
 *
 *  @discussion Light sensor beacon objects hold the telemetry data and identifier included in light sensor advertisements.
 */
@interface BLULightSensorBeacon : BLUBluetoothBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The beacon's 64 bit numeric identifier.
 */
@property (nonatomic, readonly) NSNumber *identifier;

/**
 *  The ambient light currently measured by this beacon in lumens.
 */
@property (nonatomic, readonly) NSNumber *lumens;

@end
