//
//  BLUIBeaconEncryptionSettings.h
//
//  Copyright © 2015 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the dictionary key used to store the settings' rotation list major array.
 */
extern NSString * const BLUIBeaconRotationListMajorKey;

/**
 *  Defines the dictionary key used to store the settings' rotation list minor array.
 */
extern NSString * const BLUIBeaconRotationListMinorKey;

/**
 *  Defines the rotation modes that an iBeacon can be setup with.
 */
typedef NS_ENUM(NSInteger, BLUIBeaconRotationMode) {
    /**
     *  The iBeacon rotation mode could not be determined.
     *  For security reasons a beacon's current rotation mode can't be read as part of its configuration.
     *  In that case the settings' rotation mode will be set to this value.
     */
    BLUIBeaconRotationModeUnknown = 0,
    /**
     *  iBeacon rotation will encrypt a custom length rotation identifier using a specified rotation key.
     *  In this mode the iBeacon will broadcast encrypted major and minor values from which the rotation identifier can be decoded
     *  if the correct encryption key and rotation identifier bit length are specified.
     *  The maximum length of a rotation identifier is 32 bits. At that length, the iBeacon won't be rotating the identifier but instead
     *  only encrypt it.
     *  If the rotation identifier is supposed to be rotated, a shorter identifier must be used as additional space is needed for
     *  the calculation of rotation cycles (e.g. a 24 bit identifier with an 8 bit rotation counter).
     *  The rotation identifier's desired bit length must be correctly specified upon beacon creation and decoding.
     */
    BLUIBeaconRotationModeKeyEncryption,
    /**
     *  iBeacon rotation will be using a static list of major and minor values.
     *  The beacon will rotate from one value to the next in the same order as in the list that you specified upon beacon creation.
     */
    BLUIBeaconRotationModeList
};

/**
 *  `BLUIBeaconEncryptionSettings` objects represent the iBeacon encryption settings of a beacon configuration.
 *
 *  @discussion iBeacon encryption settings control the encryption of a beacon's iBeacon advertisements.
 */
@interface BLUIBeaconEncryptionSettings : NSObject

#pragma mark - General properties
/** @name General properties */

/**
 *  The beacon's desired rotation mode.
 *  For security reasons this value can not be read back from the beacon after it was written to it.
 *  @see BLUIBeaconRotationMode
 */
@property (nonatomic, assign) BLUIBeaconRotationMode rotationMode;

/**
 *  A boolean specifying whether iBeacon rotation will be enabled when these settings are written to a beacon.
 *
 *  For security reasons this value can't be read as part of its configuration.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;


#pragma mark - List rotation properties
/** @name List rotation properties */

/**
 *  A dictionary of two `NSArrays` containing the beacon's major and minor rotation values.
 *  The contained arrays must both have the same count and contain numbers within a valid range for iBeacon major and minor values.
 *  @see BLUIBeaconRotationListMajorKey
 *  @see BLUIBeaconRotationListMinorKey
 *
 *  This dictionary is only available when the beacon has been setup to use the `BLUIBeaconRotationModeList` rotation mode.
 *  For security reasons this dictionary can not be read back from the beacon once it was written to it.
 */
@property (nonatomic, copy, nullable) NSDictionary *rotationList;

#pragma mark - Key encryption properties
/** @name Key encryption properties */

/**
 *  A 128bit key represented by NSData and used to encrypt and rotate a beacon's rotation identifier.
 *
 *  This key is only available for user generated sBeacon encryption settings and if the settings have been 
 *  setup to use the `BLUIBeaconRotationModeKeyEncryption` rotation mode.
 *  For security reasons this key can not be read back from the beacon once it was written to it.
 */
@property (nonatomic, copy, nullable) NSData *rotationKey;

/**
 *  A number representing the beacon's rotation identifier.
 *
 *  This value is only available for user generated sBeacon encryption settings and if the settings have been
 *  setup to use the `BLUIBeaconRotationModeKeyEncryption` rotation mode.
 *  For security reasons this value can not be read back from the beacon once it was written to it.
 */
@property (nonatomic, copy, nullable) NSNumber *rotationIdentifier;

/**
 *  A number representing the beacon's rotation identifier length in bits.
 *
 *  This value is only available for user generated sBeacon encryption settings and if the settings have been
 *  setup to use the `BLUIBeaconRotationModeKeyEncryption` rotation mode.
 *  For security reasons this value can not be read back from the beacon once it was written to it.
 */
@property (nonatomic, copy, nullable) NSNumber *rotationIdentifierBitLength;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUIBeaconEncryptionSettings` instance with default values.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @discussion The default settings are set to `BLUIBeaconRotationModeKeyEncryption` mode with a 24 bit rotation identifier set 
 *  to 0xABCDEF and the default rotation key.
 *
 *  @return Returns a newly initialized iBeacon encryption settings instance with default values.
 */
+ (instancetype)defaultSettings;

/**
 *  Initializes a `BLUIBeaconEncryptionSettings` instance with values that will disable iBeacon rotation.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @discussion The disabled settings will deactivate iBeacon rotation when written to a beacon.
 *
 *  @return Returns a newly initialized iBeacon encryption settings instance with disabled values.
 */
+ (instancetype)disabledSettings;

/**
 *  Initializes a `BLUIBeaconEncryptionSettings` instance with a rotation list constructed by incrementing the
 *  specified major and minor start values.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @param majorStart           The iBeacon rotation list's major start value.
 *  @param minorStart           The iBeacon rotation list's minor start value.
 *  @param majorMinorIncrement  The major and minor values in the rotation list will be incremented by this value.
 *  @param rotationCount        The total count of major and minor values the beacon's rotation list will contain.
 *
 *  @return Returns a newly initialized iBeacon encryption settings instance using the `BLUIBeaconRotationModeList` rotation
 *  mode with a rotation list constructed by incrementing the specified major and minor start values.
 */
+ (instancetype)encryptionSettingsWithMajorRotationStartValue:(NSNumber *)majorStart minorRotationStartValue:(NSNumber *)minorStart increment:(NSNumber *)majorMinorIncrement rotationCount:(NSNumber *)rotationCount;

/**
 *  Initializes a `BLUIBeaconEncryptionSettings` instance for iBeacon key encryption with the specified rotation identifier and key.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @param rotationIdentifier           The iBeacon's rotation identifier with a maximum length of 32 bits.
 *  @param rotationIdentifierBitLength  The length of the iBeacon's rotation identifier in bits with a maximum value of 32.
 *  @param rotationKey                  The 128bit key used to encrypt the iBeacon's rotation identifier.
 *
 *  @return Returns a newly initialized iBeacon encryption settings instance using the `BLUIBeaconRotationModeKeyEncryption` rotation 
 *  mode with the specified rotation identifier and key.
 */
+ (instancetype)encryptionSettingsWithRotationIdentifier:(NSNumber *)rotationIdentifier rotationIdentifierBitLength:(NSNumber *)rotationIdentifierBitLength rotationKey:(NSData *)rotationKey;

#pragma mark - Key generation
/** @name Key generation */

/**
 *  Returns a default 128bit encryption key that can be used to setup `BLUIBeaconEncryptionSettings` with the
 *  `BLUIBeaconRotationModeKeyEncryption` rotation mode.
 *
 *  @return NSData containing a 128bit rotation identifier encryption key.
 */
+ (NSData *)defaultKeyForIBeaconRotation;

/**
 *  Creates and returns a 128bit encryption key that can be used to setup `BLUIBeaconEncryptionSettings` with the
 *  `BLUIBeaconRotationModeKeyEncryption` rotation mode.
 *  The created key will be random each time this method is called. Please do always keep a reference to your created keys.
 *
 *  @return NSData containing a random 128bit rotation identifier encryption key.
 */
+ (NSData *)randomKeyForIBeaconRotation;

@end

NS_ASSUME_NONNULL_END
