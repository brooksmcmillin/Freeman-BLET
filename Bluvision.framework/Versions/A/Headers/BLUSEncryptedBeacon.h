//
//  BLUSEncryptedBeacon.h
//
//  Copyright © 2015 BluVision. All rights reserved.
//

#import "BLUConfigurableBeacon.h"

@class BLUSEncryptedBeacon;
@class BLUDevice;
@class BLUBattery;
@class BLUTemperature;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `BLUSEncryptedBeaconDelegate` protocol defines the methods that a delegate of a `BLUSEncryptedBeacon` object must adopt.
 *
 *  @discussion The encrypted sBeacon delegate provides all important events related to sBeacon advertisement encryption.
 *  Delegate events will be invoked on the delegate queue specified in the `BLUBeaconManager`.
 *  @see BLUBeaconManager
 */
@protocol BLUSEncryptedBeaconDelegate <NSObject>

#pragma mark - Delegate methods
/** @name Delegate methods */

/**
 *  Invoked whenever the decoding of encrypted sBeacon advertisement data has succeeded.
 *  All of the beacon's advertised values such as its identifier, temperature and battery voltage will
 *  only be valid if this method has been invoked at least once.
 *
 *  @param sEncryptedBeacon   The beacon that has successfully decoded the advertisement data.
 */
- (void)sEncryptedBeaconDidDecodeAdvertisement:(BLUSEncryptedBeacon *)sEncryptedBeacon;

/**
 *  Invoked whenever the decoding of encrypted sBeacon advertisement data has failed.
 *  Decoding can only be successful if all keys and a rotation identifier have been specified and are valid.
 *
 *  @param sEncryptedBeacon   The beacon that has failed to decode the advertisement data.
 *  @param error              The cause of the decoding failure.
 */
- (void)sEncryptedBeacon:(BLUSEncryptedBeacon *)sEncryptedBeacon didFailToDecodeAdvertisementWithError:(NSError *)error;

@optional

/**
 *  Invoked whenever the Bluetooth address of the beacon did rotate and a new peripheral has been assigned to this beacon internally.
 *
 *  @param sEncryptedBeacon         The beacon that has rotated its Bluetooth address.
 *  @param oldPeripheralIdentifier  The previous peripheral identifier of the beacon.
 *  @param peripheralIdentifier     The new peripheral identifier of the beacon.
 */
- (void)sEncryptedBeacon:(BLUSEncryptedBeacon *)sEncryptedBeacon didChangeFromPeripheralIdentifier:(NSUUID *)oldPeripheralIdentifier toPeripheralIdentifier:(NSUUID *)peripheralIdentifier;

@end

/**
 *  `BLUSEncryptedBeacon` objects represent beacons that have been identified as Bluvision encrypted sBeacons.
 *
 *  @discussion Encrypted sBeacon objects hold the telemetry data and identifiers included in encrypted sBeacon advertisements.
 *  The encrypted information is spread over multiple advertisements. The decoding of the received information will begin after
 *  a sufficient number of single advertisements has been received and only if all required security keys have been set. 
 *  The actual telemetry data of the beacon will therefore not be immediately available.
 *
 *  In addition an encrypted sBeacon will change its Bluetooth address on every rotation . Once that happens its current `BLUSEncryptedBeacon`
 *  representation may become invalid and a new instance may be found by the `BLUBeaconManager`.
 *
 *  If the change of the Bluetooth address could be recognized internally the appropriate `BLUSEncryptedBeaconDelegate` delegate method
 *  will be invoked and no new instance of `BLUSEncryptedBeacon` will be created. This is usually possible if the beacon was successfully
 *  decoded at least once.
 *  @see BLUSEncryptedBeaconDelegate
 *
 *  Encrypted sBeacons also contain device information that is only available after connecting to the beacon and reading its configuration.
 */
@interface BLUSEncryptedBeacon : BLUConfigurableBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The beacon's 64 bit numeric identifier.
 *  Available once decoding has finished.
 */
@property (nonatomic, readonly) NSNumber *identifier;

/**
 *  The device that is broadcasting the advertisements associated with this beacon.
 *  @see BLUDevice
 */
@property (nonatomic, readonly) BLUDevice *device;

/**
 *  The battery that is associated with this beacon.
 *  Available once decoding has finished.
 *  @see BLUBattery
 */
@property (nonatomic, readonly) BLUBattery *battery;

/**
 *  The ambient temperature currently measured by this beacon.
 *  Available once decoding has finished.
 *  @see BLUTemperature
 */
@property (nonatomic, readonly) BLUTemperature *temperature;

#pragma mark - Encryption properties
/** @name Encryption properties */

/**
*  The delegate object you want to receive `BLUSEncryptedBeacon` events.
*  @see BLUSEncryptedBeaconDelegate
*/
@property (nonatomic, weak) id<BLUSEncryptedBeaconDelegate> encryptionDelegate;

/**
 *  NSData containing the 256bit ECC secp256k1 private key associated with the public key that the beacon has been setup with.
 *  This key is required for the beacon's decoding process to begin.
 */
@property (nonatomic, copy) NSData *privateKey;

/**
 *  NSData containing the 128bit AES CFB key used for the beacon's identifier rotation.
 *  This key is required for the beacon's decoding process to begin.
 */
@property (nonatomic, copy) NSData *rotationKey;

/**
 *  NSData containing the 128bit AES CFB key used for the beacon's checksum verification.
 *  This key is required for the beacon's decoding process to begin.
 */
@property (nonatomic, copy) NSData *checksumKey;

/**
 *  NSNumber containing the rotation interval for the beacon's encryption.
 *  This value is required for the beacon's decoding process to begin.
 */
@property (nonatomic, strong) NSNumber *rotationInterval;

/**
 *  A boolean specifying whether the beacon is currently processing incoming advertisements.
 *  If this is set to `NO` then the decoding process has either finished or at least one of the beacon's
 *  required security keys is missing.
 */
@property (nonatomic, readonly, getter=isDecoding) BOOL decoding;

/**
 *  A boolean specifying whether the beacon has finished decoding the beacon's encrypted advertisement data at least once.
 *  Once this is set to `YES` the beacon's properties will be valid.
 *  If this does not get set to `YES` at all then the specified security keys may not be valid.
 */
@property (nonatomic, readonly, getter=isDecoded) BOOL decoded;

#pragma mark - Beacon settings
/** @name Beacon settings */

/**
 *  Sets up the beacon to enter deep sleep mode after the specified time interval. In deep sleep,
 *  the beacon will not send any broadcasts until it is physically woken up - e.g. via button tap.
 *  After being woken up the beacon will go back to sleep once the specified time interval has passed again.
 *  The beacon needs to be connected in order to execute this.
 *  This operation is only supported by certain beacon types and will return an error if sent to
 *  an unsupported device.
 *
 *  @param timeInterval  Time interval after which the beacon will go to sleep.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)setBeaconSleepTimeout:(NSTimeInterval)timeInterval completion:(nullable void (^)(NSError * __nullable error))completion;

/**
 *  Immediately enables or disables deep sleep mode on the beacon.
 *  If enabled, the beacon will enter sleep mode only once. It won't go back to sleep again after it has been woken up.
 *  If disabled, the beacon will permanently stay awake.
 *  This operation is only supported by certain beacon types and will return an error if sent to
 *  an unsupported device.
 *
 *  @param enable        `YES` to put the beacon to sleep. `NO` wake it up permanently.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)enableBeaconSleepMode:(BOOL)enable completion:(nullable void (^)(NSError * __nullable error))completion;

/**
 *  Sets the beacon's internal timer. This timer will increment every second and reset when the beacon reboots.
 *  The timer can be used to represent the current time by setting it to an appropriate Unix timestamp.
 *
 *  @param timeInterval  The time interval in seconds that the beacon's timer will be set to.
 *  @param completion    The completion block that will be executed once the operation has finished.
 */
- (void)setDeviceTime:(NSTimeInterval)timeInterval completion:(void (^)(BOOL success, NSError *error))completion;

NS_ASSUME_NONNULL_END

@end
