//
//  BLUSBeaconEncryptionSettings.h
//
//  Copyright © 2015 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines a dictionary key used for storing an sBeacon advertisement encryption public key.
 */
extern NSString * const BLUSBeaconEncryptionKeyDictionaryPublicKey;

/**
 *  Defines a dictionary key used for storing an sBeacon advertisement encryption private key.
 */
extern NSString * const BLUSBeaconEncryptionKeyDictionaryPrivateKey;

/**
 *  Defines a dictionary key used for storing an sBeacon advertisement encryption rotation key.
 */
extern NSString * const BLUSBeaconEncryptionKeyDictionaryRotationKey;

/**
 *  Defines a dictionary key used for storing an sBeacon advertisement encryption checksum key.
 */
extern NSString * const BLUSBeaconEncryptionKeyDictionaryChecksumKey;

/**
 *  `BLUSBeaconEncryptionSettings` objects represent the sBeacon encryption settings of a beacon configuration.
 *
 *  @discussion sBeacon encryption settings control the encryption of a beacon's sBeacon advertisements.
 */
@interface BLUSBeaconEncryptionSettings : NSObject <NSSecureCoding, NSCopying>

#pragma mark - General properties
/** @name General properties */

/**
 *  A boolean specifying whether sBeacon encryption will be enabled when these settings are written to a beacon.
 *
 *  For security reasons this value can't be read as part of its configuration.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

#pragma mark - Encryption key properties
/** @name Encryption key properties */

/**
 *  The 512bit ECC secp256k1 public key used for encrypting the advertisement.
 *
 *  For security reasons this value can't be read as part of its configuration.
 */
@property (nonatomic, copy) NSData *publicKey;

/**
 *  The 128bit AES CFB key used to encrypt the beacon's identifier. Is used internally to predict the next encryption cycle.
 *
 *  For security reasons this value can't be read as part of its configuration.
 */
@property (nonatomic, copy) NSData *rotationKey;

/**
 *  The 128bit AES CFB key used to encrypt the beacon's advertisement checksum. Used to verify the decryption process.
 *
 *  For security reasons this value can't be read as part of its configuration.
 */
@property (nonatomic, copy) NSData *checksumKey;


#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUSBeaconEncryptionSettings` instance with default values.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @discussion The default settings are set with default encryption keys.
 *
 *  @return Returns a newly initialized sBeacon encryption settings instance with default values.
 */
+ (instancetype)defaultSettings;

/**
 *  Initializes a `BLUSBeaconEncryptionSettings` instance with values that will disable sBeacon encryption.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @discussion The disabled settings will deactivate sBeacon encryption when written to a beacon.
 *
 *  @return Returns a newly initialized sBeacon encryption settings instance with disabled values.
 */
+ (instancetype)disabledSettings;

/**
 *  Initializes a `BLUSBeaconEncryptionSettings` instance with the specified encryption keys.
 *  These settings can be added as part of a scheduled beacon configuration's `BLUBeaconEncryptionSettings`.
 *  @see BLUBeaconEncryptionSettings
 *
 *  @param publicKey        A 512bit ECC secp256k1 public key used for encrypting the advertisement.
 *  @param rotationKey      A 128bit AES CFB key used to encrypt the beacon's identifier. Is used internally to predict the next encryption cycle.
 *  @param checksumKey      A 128bit AES CFB key used to encrypt the beacon's advertisement checksum. Used to verify the decryption process.
 *
 *  @return Returns a newly initialized sBeacon encryption settings instance with the specified encryption keys.
 */
+ (instancetype)encryptionSettingsWithPublicKey:(NSData *)publicKey rotationKey:(NSData *)rotationKey checksumKey:(NSData *)checksumKey;

#pragma mark - Key generation
/** @name Key generation */

/**
 *  Returns a key dictionary containing four default keys that can be used to setup sBeacon advertisement encryption on a beacon.
 *
 *  You can use the `BLUSBeaconEncryptionKeyDictionaryPublicKey`, `BLUSBeaconEncryptionKeyDictionaryPrivateKey`,
 *  `BLUSBeaconEncryptionKeyDictionaryRotationKey` and `BLUSBeaconEncryptionKeyDictionaryChecksumKey` keys to retrieve the
 *  dictionary values.
 *
 *  @return A dictionary containing NSData objects representing sBeacon advertisement encryption keys.
 */
+ (NSDictionary *)defaultKeysForSBeaconEncryption;

/**
 *  Creates and returns a key dictionary containing all four keys required to setup sBeacon advertisement encryption on a beacon.
 *  The created keys will be random each time this method is called. Please do always keep a reference to your used keys.
 *
 *  You can use the `BLUSBeaconEncryptionKeyDictionaryPublicKey`, `BLUSBeaconEncryptionKeyDictionaryPrivateKey`,
 *  `BLUSBeaconEncryptionKeyDictionaryRotationKey` and `BLUSBeaconEncryptionKeyDictionaryChecksumKey` keys to retrieve the
 *  dictionary values.
 *
 *  @return A dictionary containing NSData objects representing sBeacon advertisement encryption keys.
 */
+ (NSDictionary *)randomKeysForSBeaconEncryption;

@end

NS_ASSUME_NONNULL_END
