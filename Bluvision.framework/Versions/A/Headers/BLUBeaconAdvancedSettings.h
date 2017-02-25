//
//  BLUBeaconAdvancedSettings.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUBeaconAdvancedSettings` objects represent the advanced settings for each advertisement type of a beacon configuration.
 *
 *  @discussion Advanced beacon settings control the advertisement rate and transmission power of a beacon advertisement.
 */
@interface BLUBeaconAdvancedSettings : NSObject <NSSecureCoding, NSCopying>

#pragma mark - Interval properties
/** @name Interval properties */

/**
 *  The standard advertisement interval of a configurable beacon in seconds.
 *  
 *  @discussion This defines the number of advertisements broadcasted within a certain period of time.
 *  For example:
 *  An advertisement interval of 0.1 seconds will result in the beacon broadcasting 10 advertisements per second (10Hz).
 *  An advertisement interval of 5 seconds will result in the beacon broadcasting only once every 5 seconds (0.2Hz).
 *  Lower advertisement intervals will result in a reduced beacon battery life.
 *  Setting the Interval to 0 will disable broadcasts for the beacon associated with the advanced settings
 */
@property (nonatomic, assign) NSTimeInterval advertisementInterval;

/**
 *  The energy saving advertisement interval of a configurable beacon in seconds.
 *  This advertisement interval will be used after a beacon has reached its energy saving timeout interval due to inactivity.
 */
@property (nonatomic, assign) NSTimeInterval energySavingAdvertisementInterval;

#pragma mark - Transmission power properties
/** @name Transmission power properties */

/**
 *  The standard transmission power of a configurable beacon in dBm.
 *
 *  @discussion Bluvision beacons can broadcast with a power between -50dBm and +5dBm. 
 *  A higher dBm value will result in an increased beacon advertisement range.
 *  For example: 
 *  A transmission power of -50dBm will result in an estimated beacon range of 1 meter.
 *  A transmission power of +5dBm will result in an estimated range of up to 80 meters.
 *  Higher transmission powers will result in a reduced beacon battery life.
 */
@property (nonatomic, assign) NSInteger transmissionPower;

/**
 *  The energy saving transmission power of a configurable beacon in dBm.
 *  This transmission power will be used after a beacon has reached its energy saving timeout interval due to inactivity.
 */
@property (nonatomic, assign) NSInteger energySavingTransmissionPower;

#pragma mark - Broadcasts enabled
/** @name Broadcasts enabled */

/**
 *  Boolean flag indicating whether a beacon advertisement is currently enabled or not.
 *  
 *  @discussion When reading the current configuration from a beacon, this flag provides quick access to the information if a 
 *  beacon advertisement type (e.g. sBeacon or iBeacon) is currently enabled and being broadcasted.
 *  The same information can be obtained by checking the advertisement intervals for each beacon type. 
 *  If the advertisement interval is zero, the advertisement is currently disabled.
 */
@property (nonatomic, readonly, getter=isEnabled) BOOL enabled;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUBeaconAdvancedSettings` instance with default values.
 *  These advanced settings can be added as part of a scheduled beacon configuration.
 *  
 *  @discussion The default settings are set to an advertisementInterval of 1.0, transmissionPower of 0dB,
 *  energySavingAdvertisementInterval of 0.5, and a energySavingTransmissionPower of 0dB.
 *
 *  @return Returns a newly initialized advanced settings instance with default values.
 */
+ (instancetype)defaultAdvancedSettings;

@end

NS_ASSUME_NONNULL_END
