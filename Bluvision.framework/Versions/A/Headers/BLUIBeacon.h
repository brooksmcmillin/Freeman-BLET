//
//  BLUIBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBeacon.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  Defines the accuracy value of CoreLocation's iBeacon ranging events.
 *  Used as a light wrapper around CLLocationAccuracy.
 *  For more information on iBeacon ranging see Apple's CoreLocation documentation.
 */
typedef double BLULocationAccuracy;

/**
 *  `BLUIBeacon` objects represent an Apple iBeacon.
 *
 *  @discussion A `BLUIBeacon` can be used in two different ways:
 *  It can represent a light wrapper around a CoreLocation CLBeacon object during a scan for iBeacons.
 *  It can be used to create an iBeacon configuration for setting up a configurable beacon.
 */
@interface BLUIBeacon : BLUBeacon

#pragma mark - Properties
/** @name properties */

/**
 *  The iBeacon's proximity UUID.
 */
@property (nonatomic, readonly) NSUUID *proximityUUID;

/**
 *  The iBeacon's major value.
 */
@property (nonatomic, readonly) NSNumber *major;

/**
 *  The iBeacon's minor value.
 */
@property (nonatomic, readonly) NSNumber *minor;

/**
 *  The accuracy of the last received iBeacon ranging event.
 */
@property (nonatomic, readonly) BLULocationAccuracy accuracy;

#pragma mark - Rotation properties
/** @name Rotation properties */

/**
 *  A 128bit key represented by NSData and used to encrypt and rotate the beacon's rotation identifier.
 *  
 *  This key is only available when iBeacon decoding has been enabled for this beacon.
 *  For security reasons this key can not be read back from the beacon once it was written to it.
 *  @see BLUIBeaconEncryptionSettings
 *
 *  It is also not available for beacons that have been found via Core Location iBeacon monitoring.
 */
@property (nonatomic, readonly, nullable) NSData *rotationKey;

/**
 *  A number representing the beacon's rotation identifier.
 *
 *  This value is only available if the beacon was found via Core Location iBeacon monitoring and iBeacon decoding was enabled.
 *  For security reasons this value can not be read back from the beacon once it was written to it.
 *  @see BLUIBeaconEncryptionSettings
 *
 *  The value will only be valid if the correct rotation key and identifier bit length were specified when decoding was enabled.
 */
@property (nonatomic, readonly, nullable) NSNumber *rotationIdentifier;

/**
 *  A boolean specifying whether rotation identifier decoding has been enabled for this beacon.
 */
@property (nonatomic, readonly, getter=isDecoding) BOOL decoding;


#pragma mark - Initalization
/** @name Initialization */

/**
 *  Initializes a `BLUIBeacon` instance with a proximity UUID, a major and a minor value.
 *
 *  @param proximityUUID The iBeacon's proximity UUID.
 *  @param major         The iBeacon's major value.
 *  @param minor         The iBeacon's minor value.
 *
 *  @return Returns a newly initialized `BLUIBeacon` instance.
 */
- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor;

#pragma mark - Rotation identifier decoding
/** @name Rotation identifier decoding */

/**
 *  Toggles the decoding of the beacon's encrypted rotation identifier using the specified rotation key and rotation identifier bit length.
 *  Rotation identifier decoding should only be enabled for beacons that have been retrieved using Core Location monitoring and that were
 *  previously setup to use the `BLUIBeaconRotationModeKeyEncryption` rotation mode. 
 *
 *  The decoded value will be stored in the beacon's `rotationIdentifier` property. Its value will only be valid if you specify the
 *  same rotation key and bit length that was used to setup the beacon's identifier rotation.
 *  
 *  @param enable               `YES` to enable, `NO` to disable major and minor decoding.
 *  @param rotationKey          NSData containing the 128bit rotation key that the beacon has been setup with.
 *  @param identifierBitLength  An NSNumber representing the length in bits of the rotation identifier that the beacon has been setup with.
 */
- (void)enableIBeaconDecoding:(BOOL)enable withRotationKey:(NSData *)rotationKey identifierBitLength:(NSNumber *)identifierBitLength;

@end

NS_ASSUME_NONNULL_END
