//
//  BLUEddystoneTLMBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

@class BLUBattery;
@class BLUTemperature;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUEddystoneTLMBeacon` objects represent `BLUBluetoothBeacon` objects that have been identified as EddystoneBeacon TLM.
 *
 *  @discussion A `BLUEddystoneTLMBeacon` object represents a recurring EddystoneBeacon TLM advertisement.
 */
@interface BLUEddystoneTLMBeacon : BLUBluetoothBeacon

#pragma mark - Telemetry properties
/** @name Telemetry properties */
/**
 *  Battery information about this EddystoneBeacon or `nil`.
 *  Battery information is part of the EddystoneBeacon TLM advertisement type.
 */
@property (nonatomic, readonly) BLUBattery *battery;

/**
 *  The ambient temperature currently measured by this beacon.
 *  The ambient temperature is part of the EddystoneBeacon TLM advertisement type.
 *  @see BLUBattery
 */
@property (nonatomic, readonly) BLUTemperature *temperature;

/**
 *  The number of advertisements sent by the beacon since its power-up or last reboot.
 *  The number of sent advertisements is part of the EddystoneBeacon TLM advertisement type.
 */
@property (nonatomic, readonly) NSUInteger frameCount;

/**
 *  The time interval elapsed since the beacon's power-up or last reboot.
 *  Measured in seconds with a 0.1 second resolution.
 *  The beacon's uptime is part of the EddystoneBeacon TLM advertisement type.
 */
@property (nonatomic, readonly) NSTimeInterval uptime;

@end

NS_ASSUME_NONNULL_END
