//
//  BLUBeaconGlobalSettings.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUBeaconGlobalSettings` objects represent the global settings of a beacon configuration.
 *
 *  @discussion Global beacon settings are general time intervals that control the advertisement pattern of a configurable beacon.
 *  These values can be read from a connected beacon or written to it.
 */
@interface BLUBeaconGlobalSettings : NSObject <NSSecureCoding, NSCopying>

#pragma mark - Properties
/** @name Properties */

/**
 *  The time in seconds that the beacon needs to stay inactive before it switches to energy saving mode.
 *  The beacon will internally restart this timeout whenever its inactivity is interrupted.
 *  This can happen for example when active scans or connection attempts occur.
 */
@property (nonatomic, assign) NSTimeInterval energySavingTimeout;

/**
 *  The beacon's advertisement interval in seconds when in disconnect mode.
 *  Disconnect mode will be active for a defined time interval after the beacon has been disconnected.
 *  In that mode, the beacon will broadcast all advertisements using this interval.
 */
@property (nonatomic, assign) NSTimeInterval disconnectAdvertisementInterval;

/**
 *  The time in seconds that the beacon will stay in disconnect mode after it has been disconnected.
 *  Unless interrupted, the beacon will return to its normal advertisement mode after reaching this timeout.
 */
@property (nonatomic, assign) NSTimeInterval disconnectAdvertisementIntervalTimeout;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUBeaconGlobalSettings` instance with default values.
 *  These global settings can be added as part of a scheduled beacon configuration.
 *
 *  @discussion The default settings are set to an energySavingTimeout of 1 hour (3600 seconds),
 *  disconnectAdvertisementInterval of 0.2, and a disconnectAdvertismentIntervalTimeout of 10 seconds.
 *
 *  @return Returns a newly initialized global settings instance with default values.
 */
+ (BLUBeaconGlobalSettings *)defaultGlobalSettings;

@end

NS_ASSUME_NONNULL_END
