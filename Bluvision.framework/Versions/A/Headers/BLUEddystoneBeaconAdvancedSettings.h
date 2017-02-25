//
//  BLUEddystoneBeaconAdvancedSettings.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUBeaconAdvancedSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @discussion BLUEddystoneBeaconAdvancedSettings allow for interleaving of advertisements that are connectable and non connectable.
 *  Setting a connection rate > 0 means that this beacon can be connected to and Follow the Eddystone Beacon GATT.
 *  Setting a non connection rate allows this beacon to interleave both connection and non connection advertisements as a ratio. 
 *  i.e. for a connection rate of 1 and a non connection rate of 3 would mean that for every 3 advertisments 1 of them is connectable.
 */
@interface BLUEddystoneBeaconAdvancedSettings : BLUBeaconAdvancedSettings

#pragma mark - Properties
/** @name Properties */

/**
 *  The connection rate for the Eddystone Beacon
 */
@property (nonatomic, assign) NSInteger connectionRate;

/**
 *  The non connection rate for the Eddystone Beacon
 */
@property (nonatomic, assign) NSInteger nonConnectionRate;

/**
 *  A boolean to represent that the beacon is connectable
 */
@property (nonatomic, readonly, getter=isConnectable) BOOL connectable;

@end

NS_ASSUME_NONNULL_END
