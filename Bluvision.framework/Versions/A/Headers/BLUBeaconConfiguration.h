//
//  BLUBeaconConfiguration.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLUIBeacon;
@class BLUSBeacon;
@class BLUSLegacyBeacon;
@class BLUEddystoneUIDBeacon;
@class BLUEddystoneURLBeacon;
@class BLUEddystoneTLMBeacon;
@class BLUEddystoneBeaconAdvancedSettings;
@class BLUBeaconGlobalSettings;
@class BLUBeaconAdvancedSettings;
@class BLUBeaconOptionalAdvancedSettings;
@class BLUBeaconMotionAdvancedSettings;
@class BLUBeaconEncryptionSettings;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The 16 byte default UUID string containng 0's for beacon configurations.
 */
FOUNDATION_EXPORT NSString *const kBLUBeaconConfigurationDefaultUUID;

/**
 *  `BLUBeaconConfiguration` objects define all settings of a configurable beacon object.
 *
 *  @discussion The settings included in a `BLUBeaconConfiguration` object can represent the current settings of a configurable beacon.
 *  A configuration object can also be used to schedule a change of settings on a configurable beacon.
 *  Beacon configurations consist of three parts:
 *  A beacon object for each configurable beacon type. iBeacon, EddystoneUIDBeacon, EddystoneURLBeacon and sBeacon.
 *  An advanced settings object for each advertisement type the configurable beacon can be setup with.
 *  A global settings object that keeps general beacon settings.
 */
@interface BLUBeaconConfiguration : NSObject <NSSecureCoding, NSCopying>

#pragma mark - Beacon configurations
/** @name Beacon configurations */

/**
 *  The current iBeacon setup of the configuration.
 *  @see BLUIBeacon
 */
@property (nonatomic, copy) BLUIBeacon *iBeacon;

/**
 *  The current EddystoneUIDBeacon setup of the configuration.
 *  @see BLUEddystoneUIDBeacon
 */
@property (nonatomic, copy) BLUEddystoneUIDBeacon *eddystoneUIDBeacon;

/**
 *  The current EddystoneURLBeacon setup of the configuration.
 *  @see BLUEddystoneURLBeacon
 */
@property (nonatomic, copy) BLUEddystoneURLBeacon *eddystoneURLBeacon;

/**
 *  The current sBeacon legacy setup of the configuration.
 *  @see BLUSLegacyBeacon
 */
@property (nonatomic, copy) BLUSLegacyBeacon *sLegacyBeacon;

/**
 *  The current sBeacon setup of the configuration.
 *  @see BLUSBeacon
 */
@property (nonatomic, copy) BLUSBeacon *sBeacon;

#pragma mark - Global settings
/** @name Global settings */

/**
 *  The current global settings of the configuration.
 *  @see BLUBeaconGlobalSettings
 */
@property (nonatomic, copy) BLUBeaconGlobalSettings *globalSettings;

/**
 * Sets the device's pairing RSSI, default is set to -60dB. A lower value will allow connections at greater distances
 */
@property (nonatomic, copy) NSNumber *pairingRSSI;

/**
 * Sets the device's sleep timeout in seconds. Once this timeout has passed the beacon will enter deep sleep mode
 * If set to 0, deep sleep mode will be permanently disabled
 * Deep sleep is not supported by all device types and will be ignored on unsupported platforms
 */
@property (nonatomic, copy) NSNumber *sleepTimeout;

#pragma mark - Advanced settings
/** @name Advanced settings */

/**
 *  The current advanced settings for iBeacon advertisements of the configuration.
 *  @see BLUBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUBeaconAdvancedSettings *iBeaconAdvancedSettings;

/**
 *  The current advanced settings for EddystoneBeacon UID advertisements of the configuration.
 *  @see BLUEddystoneBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUEddystoneBeaconAdvancedSettings *eddystoneBeaconUIDAdvancedSettings;

/**
 *  The current advanced settings for EddystoneBeacon URL advertisements of the configuration.
 *  @see BLUEddystoneBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUEddystoneBeaconAdvancedSettings *eddystoneBeaconURLAdvancedSettings;

/**
 *  The current advanced settings for EddystoneBeacon TLM advertisements of the configuration.
 *  @see BLUBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUEddystoneBeaconAdvancedSettings *eddystoneBeaconTLMAdvancedSettings;

/**
 *  The current advanced settings for sBeacon v2 advertisements of the configuration.
 *  @see BLUBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUBeaconAdvancedSettings *sBeaconV2AdvancedSettings;

/**
 *  The current advanced settings for sBeacon v1 advertisements of the configuration.
 *  @see BLUBeaconAdvancedSettings
 */
@property (nonatomic, copy) BLUBeaconAdvancedSettings *sBeaconV1AdvancedSettings;

#pragma mark - Optional advanced settings
/** @name Optional advanced settings */

/**
 *  The current optional advanced settings for motion beacon advertisements of the configuration.
 *  @see BLUBeaconMotionAdvancedSettings
 */
@property (nonatomic, copy) BLUBeaconOptionalAdvancedSettings *motionBeaconAdvancedSettings;

/**
 *  The current optional advanced settings for light sensor beacon advertisements of the configuration.
 *  @see BLUBeaconOptionalAdvancedSettings
 */
@property (nonatomic, copy) BLUBeaconOptionalAdvancedSettings *lightSensorBeaconAdvancedSettings;

#pragma mark - Encryption settings
/** @name Encryption settings */

/**
 *  The current advertisement encryption settings of the configuration.
 *  @see BLUBeaconEncryptionSettings
 *
 *  If the configuration has been read from a beacon the encryption settings will be set to disabled values.
 *  For security reasons these settings can not be read back from a beacon.
 *
 *  If you want to use beacon advertisement encryption, please remember to manually setup the right encryption
 *  settings each time before you write the configuration to a beacon. By default, advertisement encryption will be disabled.
 */
@property (nonatomic, copy) BLUBeaconEncryptionSettings *encryptionSettings;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUBeaconConfiguration` instance with default values.
 *  This configuration can be written to a configurable beacon.
 *
 *  @return Returns a newly initialized configuration instance with default values.
 */
+ (BLUBeaconConfiguration *)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
