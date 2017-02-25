//
//  BLUBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUDistance.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Emitted power value of a beacon at zero meters from its antenna. Measured in dBm.
 */
typedef NSInteger BLUTransmissionPower;

/**
 *  `BLUBeacon` objects represent a recurring beacon advertisement of any kind.
 *
 *  @discussion `BLUBeacon` is a generic beacon super class representing the basic values of any beacon advertisement.
 *  Its various subclasses like `BLUSBeacon`, `BLUSLegacyBeacon`, `BLUEddystoneUIDBeacon`, `BLUEddystoneURLBeacon`, `BLUEddystoneTLMBeacon`, `BLUIBeacon` are used to provide
 *  in-depth information about their represented beacon types.
 */
@interface BLUBeacon : NSObject <NSSecureCoding, NSCopying>

#pragma mark - Generic beacon properties
/** @name Generic beacon properties */

/**
 *  Received signal strength indication for the last received advertisement of a beacon.
 *  Represents the power of the received radio signal. Measured in dBm.
 */
@property (nonatomic, readonly) NSNumber *RSSI;

/**
 *  Beacon distance estimate for the last received advertisement of a beacon.
 */
@property (nonatomic, readonly) BLUDistance distance;

/**
 *  The time interval in seconds that needs to pass after the last discovery before the beacon is considered lost.
 *  Must be greater that 1.0 seconds.
 *  Default value: 30.0 seconds.
 */
@property (nonatomic, copy) NSNumber *visibilityTimeoutInterval;

/**
 *  The date of a beacon's last discovery.
 */
@property (nonatomic, readonly) NSDate *lastSeenDate;

/**
 *  A boolean indicating whether a beacon's last discovery happened within its specified visibilityTimeoutInterval.
 */
@property (nonatomic, readonly) BOOL isVisible;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
