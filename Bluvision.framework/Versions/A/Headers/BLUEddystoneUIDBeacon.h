//
//  BLUEddystoneUIDBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

NS_ASSUME_NONNULL_BEGIN

@class BLUEddystoneIdentifier;

/**
 *  `BLUEddystoneUIDBeacon` objects represent `BLUBluetoothBeacon` objects that have been identified as EddystoneBeacon UID.
 *
 *  @discussion A `BLUEddystoneUIDBeacon` object represents a recurring EddystoneBeacon UID advertisement.
 */
@interface BLUEddystoneUIDBeacon : BLUBluetoothBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The EddystoneBeacon identifier broadcasted by this EddystoneBeacon or `nil`.
 *  The EddystoneBeacon identifier is part of the EddystoneBeacon UID advertisement type.
 */
@property (nonatomic, readonly) BLUEddystoneIdentifier *identifier;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes an instance of `BLUEddystoneUIDBeacon` with a Identifier.
 *  Use this initializer to create `BLUEddystoneUIDBeacon` objects for beacon configurations.
 *
 *  @param identifier The unique identifier of the EddystoneBeacon's UID advertisement.
 *
 *  @return Returns a newly initialized `BLUEddystoneUIDBeacon` instance.
 */
- (instancetype)initWithIdentifier:(BLUEddystoneIdentifier *)identifier;

@end

NS_ASSUME_NONNULL_END
