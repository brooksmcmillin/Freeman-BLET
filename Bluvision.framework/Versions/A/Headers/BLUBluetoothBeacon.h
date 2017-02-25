//
//  BLUCoreBluetoothBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBeacon.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUBluetoothBeacon` objects represent a `BLUBeacon` object received via CoreBluetooth scanning.
 *
 *  @discussion BLUBluetoothBeacon is a generic beacon super class representing the basic values of any beacon advertisement
 *  discovered using CoreBluetooth.
 *  Its various subclasses like `BLUSBeacon` or `BLUEddystoneUIDBeacon` are used to provide
 *  in-depth information about the represented beacon types.
 */
@interface BLUBluetoothBeacon : BLUBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The local name of the beacon's CoreBluetooth peripheral.
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  Emitted power value of a beacon at zero meters from its antenna. Measured in dBm.
 */
@property (nonatomic, readonly) BLUTransmissionPower transmissionPower;

/**
 *  The beacon's peripheral identifier. This value is uniquely assigned by iOS and will differ across installations.
 */
@property (nonatomic, readonly) NSUUID *peripheralIdentifier;

@end

NS_ASSUME_NONNULL_END
