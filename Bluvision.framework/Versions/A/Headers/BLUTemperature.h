//
//  BLUTemperature.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUTemperature` objects wrap information about the temperature measured by a beacon.
 *
 *  @discussion Each `BLUSBeacon`, `BLUSLegacyBeacon` or `BLUEddystoneTLMBeacon` object keeps a reference to a `BLUTemperature` object.
 *  The measured ambient temperature is a part of both the sBeacon and the EddystoneBeacon TLM advertisement formats.
 */
@interface BLUTemperature : NSObject

#pragma mark - Methods
/** @name Methods */

/**
 *  @return Returns the beacon's last measured ambient temperature in degrees Celsius.
 */
- (float)degreesCelsius;

/**
 *  @return Returns the beacon's last measured ambient temperature in degrees Fahrenheit.
 */
- (float)degreesFahrenheit;

@end

NS_ASSUME_NONNULL_END
