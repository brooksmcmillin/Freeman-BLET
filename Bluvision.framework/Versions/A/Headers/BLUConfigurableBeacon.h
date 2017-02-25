//
//  BLUConfigurableBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

@class BLUConfigurableBeacon;
@class BLUBeaconConfiguration;
@class BLUFirmwareImage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the possible connection states of a configurable beacon object.
 */
typedef NS_ENUM(NSUInteger, BLUConfigurableBeaconConnectionState){
    /**
     *  The beacon is currently not connected.
     */
    BLUConfigurableBeaconConnectionStateDisconnected,
    /**
     *  The beacon is currently connecting.
     */
    BLUConfigurableBeaconConnectionStateConnecting,
    /**
     *  The beacon is currently discovering services and characteristics.
     */
    BLUConfigurableBeaconConnectionStateDiscovering,
    /**
     *  The beacon is currently trying to authenticate the connected user.
     */
    BLUConfigurableBeaconConnectionStateAuthenticating,
    /**
     *  The beacon is currently connected.
     */
    BLUConfigurableBeaconConnectionStateConnected,
    /**
     *  The beacon is currently handling a read operation.
     */
    BLUConfigurableBeaconConnectionStateReading,
    /**
     *  The beacon is currently handling a write operation.
     */
    BLUConfigurableBeaconConnectionStateWriting,
    /**
     *  The beacon's firmware is currently being updated.
     */
    BLUConfigurableBeaconConnectionStateUpdatingFirmware
};

/**
 *  Defines options for writing a configuration to a configurable beacon.
 */
typedef NS_ENUM(NSUInteger, BLUBeaconConfigurationOptions){
    /**
     *  Only write those configuration values to a beacon that do not match its current settings.
     */
    BLUBeaconConfigurationOptionsChangedValues,
    /**
     *  Write all configuration values to the beacon. Override matching settings as well.
     */
    BLUBeaconConfigurationOptionsAllValues
};

/**
 *  The `BLUConfigurableBeaconDelegate` protocol defines the methods that a delegate of a `BLUConfigurableBeacon` object must adopt.
 *
 *  @discussion The configurable beacon delegate provides all important events related to beacon connection and configuration.
 */
@protocol BLUConfigurableBeaconDelegate <NSObject>

#pragma mark - Delegate methods
/** @name Delegate methods */

/**
 *  Invoked when a connection to the beacon has been established.
 *
 *  @param configurableBeacon The beacon that has been connected.
 */
- (void)configurableBeaconDidConnect:(BLUConfigurableBeacon *)configurableBeacon;

@optional
/**
 *  Invoked whenever the connection state of the beacon has changed.
 *
 *  @param configurableBeacon The beacon that just changed its connection state.
 *  @param state              The new connection state of the beacon.
 */
- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didChangeState:(BLUConfigurableBeaconConnectionState)state;

@optional

/**
 *  Invoked whenever the connection to the beacon has been canceled.
 *
 *  @param configurableBeacon The beacon that has been disconnected.
 *  @param error              The cause of the disconnection. Will be `nil` if the beacon was disconnected on purpose.
 */
- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didDisconnectWithError:(nullable NSError *)error;

/**
 *  Invoked whenever a new configuration was written to a beacon.
 *
 *  @param configurableBeacon The beacon the configuration was written to.
 *  @param configuration      The configuration that has been written to the beacon.
 *                            This can differ from the configuration that was originally scheduled to be written if certain scheduled values were invalid.
 */
- (void)configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon didChangeConfiguration:(BLUBeaconConfiguration *)configuration;

@end

/**
 *  `BLUConfigurableBeacon` objects represent beacons that have been identified as configurable by this framework.
 *
 *  @discussion Configurable beacons can be interacted with in various ways. They can be connected and disconnected.
 *  Their current configurations can be read in detail. New configurations can be written to them.
 */
@interface BLUConfigurableBeacon : BLUBluetoothBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The delegate object you want to receive `BLUConfigurableBeacon` events.
 *  @see BLUConfigurableBeaconDelegate
 */
@property (nonatomic, weak, nullable) id<BLUConfigurableBeaconDelegate> delegate;

/**
 *  The beacon's current connection state.
 *  @see BLUConfigurableBeaconConnectionState
 */
@property (nonatomic, readonly) BLUConfigurableBeaconConnectionState connectionState;

/**
 *  The beacon's current configuration. This is only available after the beacon has been connected and read at least once during its lifetime.
 *  @see BLUBeaconConfiguration
 */
@property (nonatomic, readonly) BLUBeaconConfiguration *configuration;

#pragma mark - Connection methods
/** @name Connection Methods */

/**
 *  Initiates a connection attempt to the beacon.
 */
- (void)connect;

/**
 *  Initiates a forced connection attempt to the beacon.
 *  This option ignores all errors during a connection attempt.
 *
 *  @param password          The password that will be used to connect to the beacon.
 *  @param timeoutInterval   The amount of seconds the connection attempt can last before it is considered failed.
 *  @param retryCount        The amount of connection attempts the framework will start before considering the connection failed.
 */
- (void)forceConnectWithPassword:(nullable NSString *)password timeoutInterval:(NSTimeInterval)timeoutInterval retryCount:(NSUInteger)retryCount;

/**
 *  Initiates an advanced connection attempt to the beacon. Use this method to connect to password protected beacons.
 *
 *  @param password          The password that will be used to connect to the beacon.
 *  @param timeoutInterval   The amount of seconds the connection attempt can last before it is considered failed.
 *  @param retryCount        The amount of connection attempts the framework will start before considering the connection failed.
 */
- (NSError *)connectWithPassword:(nullable NSString *)password timeoutInterval:(NSTimeInterval)timeoutInterval retryCount:(NSUInteger)retryCount;

#pragma mark - Disconnection methods
/** @name Disconnection methods*/

/**
 *  Disconnects the beacon after all currently running operations have been finished.
 */
- (void)disconnect;

/**
 *  Disconnects the beacon immediately. Cancels all running operations.
 */
- (void)forceDisconnect;

#pragma mark - Beacon settings
/** @name Beacon settings */

/**
 *  Flashes the beacon speaker and/or LED on supported Bluvision beacon models.
 *  The beacon needs to be connected in order to execute this.
 *
 *  @param enableSpeaker `YES` to enable the speaker. `NO` to ignore it.
 *  @param enableLED     `YES` to enable the LED. `NO` ignore it.
 */
- (void)enableBeaconSpeaker:(BOOL)enableSpeaker andLED:(BOOL)enableLED;

/**
 *  Sets a new password on the beacon.
 *  If a valid password is specified, the beacon will be locked and only be accessible by connecting with that password.
 *  If no password is specified, the password protection of the beacon will be removed.
 *  The beacon needs to be connected in order to execute this.
 *
 *  @param password         The password the beacon will be protected with or `nil`.
 *  @param completion       The completion block that will be executed once the password operation has finished.
 */
- (void)setNewBeaconPassword:(nullable NSString *)password completion:(nullable void (^)(NSError  * __nullable error))completion;

#pragma mark - Configuration
/** @name Configuration */

/**
 *  Sets a new configuration on the beacon.
 *  The configuration can either be written completely or by just overriding the changed beacon settings.
 *  The beacon needs to be connected in order to execute this.
 *
 *  @param configuration         The scheduled configuration that will be written to the beacon.
 *  @param options               The options specifying the type of the write operation.
 *  @param completion            The completion block that will be executed once the configuration operation has finished.
 */
- (void)setConfiguration:(BLUBeaconConfiguration *)configuration options:(BLUBeaconConfigurationOptions)options completion:(nullable void(^)(BLUBeaconConfiguration * __nullable writtenConfiguration, NSError * __nullable error))completion;

/**
 *  Writes the default configuration to the beacon.
 *  The default configuration will disable all beacon advertisements except for sBeacon.
 *  The beacon needs to be connected in order to execute this.
 *
 *  @param completion The completion block that will be executed once the configuration operation has finished.
 */
- (void)restoreDefaultSettingsWithCompletion:(nullable void (^)(BOOL success, NSError * __nullable error))completion;

#pragma mark - Firmware updates
/** @name Firmware updates */

/**
 *  Updates the connected configurable beacon with new firmware provided as NSData.
 *
 *  @param firmwareImage An BLUFirmwareImage object containing the firmware update image.
 *  @param progress      A float for percentage ranging from 0.0 to 100.0.
 *  @param completion    A completion block that will be executed once when the firmware has been updated.
 */
- (void)updateFirmwareWithImage:(BLUFirmwareImage *)firmwareImage progress:(nullable void (^)(float percentComplete))progress completion:(nullable void (^)(BOOL success, NSError * __nullable error))completion;

/**
 *  Checks if a provided firmware image can be installed directly or needs to be updated in a two-step process.
 *
 *  @param firmwareImage An BLUFirmwareImage object containing the firmware update image.
 *
 *  @return A boolean specifying whether a loader image needs to be installed before installing the specified image.
 */
- (BOOL)requiresLoaderImageForFirmwareImage:(BLUFirmwareImage *)firmwareImage;

@end

NS_ASSUME_NONNULL_END
