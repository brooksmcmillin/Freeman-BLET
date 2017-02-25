//
//  BLUBattery.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the possible battery models powering Bluvision beacons.
 *  Information about each battery model can be obtained from its manufacturer's specifications.
 */
typedef NS_ENUM(NSUInteger, BLUBatteryType){
    /**
     *  An unknown battery type.
     *  This is the default value for a `BLUBattery` instance before the actual battery type has been determined.
     */
    BLUBatteryTypeUnknown = 0xFF,
    /**
     *  A battery of type CR2016.
     */
    BLUBatteryTypeCR2016  = 0x00,
    /**
     *  A battery of type CR2032.
     */
    BLUBatteryTypeCR2032  = 0x01,
    /**
     *  A battery of type CR2477.
     */
    BLUBatteryTypeCR2477  = 0x02,
    /**
     *  A battery of type ER14505.
     */
    BLUBatteryTypeER14505 = 0x03,
    /**
     *  An AC power source.
     */
    BLUBatteryTypeAC      = 0xF0,
    /**
     *  A USB power source.
     */
    BLUBatteryTypeUSB     = 0xF1
};

/**
 *  `BLUBattery` objects represent information about the battery powering a beacon.
 *
 *  @discussion Each `BLUSBeacon`, `BLUSLegacyBeacon` or `BLUEddystoneTLMBeacon` object keeps a reference to a `BLUBattery` object.
 *  The battery type can only be obtained for `BLUSBeacon` and `BLUSLegacyBeacon` objects as this information needs to be read from the connected beacon.
 *  All other values don't require a connection.
 */
@interface BLUBattery : NSObject

#pragma mark - Properties
/** @name Properties */

/**
 *  The battery's type.
 *  @see BLUBatteryType
 */
@property (nonatomic, readonly) BLUBatteryType batteryType;

/**
 *  The currently estimated battery percentage. Based on the battery's voltage.
 */
@property (nonatomic, readonly) float estimatedPercentRemaining;

/**
 *  The currently measured beacon battery voltage in Volts.
 */
@property (nonatomic, readonly) float voltage;

#pragma mark - Helper methods
/** @name Helper methods */

/**
 *  Requests a description string for the battery's type.
 *
 *  @return Returns a description string for the battery's type.
 */
- (NSString *)batteryTypeString;

@end

NS_ASSUME_NONNULL_END
