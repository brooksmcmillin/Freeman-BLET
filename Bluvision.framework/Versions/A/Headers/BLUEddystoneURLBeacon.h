//
//  BLUEddystoneURLBeacon.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBluetoothBeacon.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUEddystoneURLBeacon` objects represent `BLUBluetoothBeacon` objects that have been identified as EddystoneBeacon URL.
 *
 *  @discussion A `BLUEddystoneURLBeacon` object represents a recurring EddystoneBeacon URL advertisement.
 */
@interface BLUEddystoneURLBeacon : BLUBluetoothBeacon

#pragma mark - Properties
/** @name Properties */

/**
 *  The EddystoneBeacon URL broadcasted by this EddystoneBeacon or `nil`.
 *  The EddystoneBeacon URL is part of the EddystoneBeacon URL advertisement type.
 */
@property (nonatomic, readonly) NSURL *URL;

#pragma mark - Initialization
//* @name Initialization */

/**
 *  Initializes an instance of `BLUEddystoneURLBeacon` with a URL.
 *  Use this initializer to create `BLUEddystoneURLBeacon` objects for beacon configurations.
 *
 *  @param URL  The URL of the EddystoneBeacon's URL advertisement.
 *
 *  @return Returns a newly initialized `BLUEddystoneURLBeacon` instance.
 */
- (instancetype)initWithURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
