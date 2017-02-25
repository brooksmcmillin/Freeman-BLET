//
//  BLUBeaconEncryptionSettings.h
//
//  Copyright © 2015 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLUSBeaconEncryptionSettings.h"
#import "BLUIBeaconEncryptionSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the time synchronization method used for advertisement encryption and rotation.
 */
typedef NS_ENUM(NSInteger, BLUBeaconEncryptionSyncMode) {
    /**
     *  The encryption cycle will use the beacon's internal system time.
     */
    BLUBeaconEncryptionSyncModeNone = -1,
    /**
     *  The encryption synchronization mode could not be determined.
     *  For security reasons a beacon's sync mode can't be read as part of its configuration.
     *  In this case the mode will be set to this value.
     */
    BLUBeaconEncryptionSyncModeUnknown = 0,
    /**
     *  The encryption cycle will use your iOS device's current date and time.
     */
    BLUBeaconEncryptionSyncModeSyncToCurrentTime,
    /**
     *  The encryption cycle will be synchronized to the iBeacon encryption settings to start rotating with the first value of
     *  the iBeacon rotation major and minor list.
     */
    BLUBeaconEncryptionSyncModeStartAtFirstValue
};

/**
 *  `BLUBeaconEncryptionSettings` objects represent the encryption settings of a beacon configuration.
 *
 *  @discussion Encryption settings control the encryption modes used for a beacon's advertisements.
 */
@interface BLUBeaconEncryptionSettings : NSObject <NSSecureCoding, NSCopying>

#pragma mark - General properties
/** @name General properties */

/**
 *  The beacon's desired encryption time synchroization mode.
 *
 *  For security reasons a beacon's sync mode can't be read as part of its configuration.
 *  @see BLUBeaconEncryptionSyncMode
 */
@property (nonatomic, assign) BLUBeaconEncryptionSyncMode encryptionSyncMode;

/**
 *  The beacon's desired rotation interval in seconds.
 *
 *  @discussion If this value is set to 0 these settings will disable all advertisement encryption 
 *  on beacons they are written to.
 *  
 *  The minimum allowed rotation interval are 120 seconds. Lower values will be auto-corrected as they could cause 
 *  a beacon to always rotate before a connection can be established - thereby rendering the beacon unconnectable.
 */
@property (nonatomic, assign) NSTimeInterval rotationInterval;

#pragma mark - Advertisement type properties
/** @name Advertisement type properties */

/**
 *  The beacon's desired sBeacon encryption settings.
 *  @see BLUSBeaconEncryptionSettings
 */
@property (nonatomic, copy) BLUSBeaconEncryptionSettings *sBeaconEncryptionSettings;

/**
 *  The beacon's desired iBeacon encryption settings.
 *  @see BLUIBeaconEncryptionSettings
 */
@property (nonatomic, copy) BLUIBeaconEncryptionSettings *iBeaconEncryptionSettings;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUBeaconEncryptionSettings` instance with default values.
 *  These settings can be added as part of a scheduled beacon configuration.
 *
 *  @discussion The default settings are set to a time synchronization mode of `BLUBeaconEncryptionSyncModeNone`, a time interval of
 *  300 seconds and the default configurations of `BLUSBeaconEncryptionSettings` and `BLUIBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSyncMode
 *  @see BLUSBeaconEncryptionSettings
 *  @see BLUIBeaconEncryptionSettings
 *
 *  @return Returns a newly initialized encryption settings instance with default values.
 */
+ (instancetype)defaultEncryptionSettings;

/**
 *  Initializes a `BLUBeaconEncryptionSettings` instance with the specified encryption time synchronization mode, rotation interval and
 *  default sBeacon and iBeacon encryption settings.
 *  These settings can be added as part of a scheduled beacon configuration.
 *
 *  @discussion The default settings are set to the default configurations of `BLUSBeaconEncryptionSettings` and `BLUIBeaconEncryptionSettings`.
 *  @see BLUSBeaconEncryptionSettings
 *  @see BLUIBeaconEncryptionSettings
 *
 *  @param encryptionSyncMode   The time synchronization mode that shall be used for the beacon's advertisement encryption.
 *  @param rotationInterval     The encryption's rotation interval in seconds.
 *
 *  @return Returns a newly initialized encryption settings instance with the specified encryption time synchronization mode, rotation interval and
 *  default sBeacon and iBeacon encryption settings.
 */
+ (instancetype)encryptionSettingsWithEncryptionSyncMode:(BLUBeaconEncryptionSyncMode)encryptionSyncMode rotationInterval:(NSTimeInterval)rotationInterval;

@end

NS_ASSUME_NONNULL_END
