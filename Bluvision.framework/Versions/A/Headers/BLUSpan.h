//
//  BLUSpan.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUSpan` objects are used to define a certain range of numeric values.
 *
 *  @discussion Each `BLUSpan` object can keep a minimum value, a maximum value or both. 
 *  If used for beacon filtering, a `BLUSpan` can be used to specify ranges of valid values.
 *  You can for example define a range of RSSI values. In that case, only beacons with an RSSI value within that range are considered valid.
 *  If only a minimum value is defined, all beacons with an RSSI value above it are considered valid.
 *  If only a maximum value is defined, all beacons with an RSSI value below it are considered valid.
 */
@interface BLUSpan : NSObject <NSSecureCoding, NSCopying>

#pragma mark - Properties
/** @name Properties */

/**
 *  The span's minimum valid value or `nil`.
 */
@property (nonatomic, readonly) NSNumber *minimumValue;

/**
 *  The span's maximum valid value or `nil`.
 */
@property (nonatomic, readonly) NSNumber *maximumValue;

#pragma mark - Initialization
/** @name Initialization */

/**
 *  Initializes a `BLUSpan` instance with a minimum and a maximum value.
 *
 *  @param minimumValue The span's minimum valid value or `nil`.
 *  @param maximumValue The span's maximum valid value or `nil`.
 *
 *  @return Returns a newly initialized `BLUSpan` instance with a minimum and a maximum value.
 */
- (instancetype)initWithMinimumValue:(NSNumber *)minimumValue maximumValue:(NSNumber *)maximumValue;

@end

NS_ASSUME_NONNULL_END
