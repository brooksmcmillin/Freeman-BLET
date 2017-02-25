//
//  BLUBeaconOptionalAdvancedSettings.h
//
//  Copyright (c) 2015 BluVision. All rights reserved.
//

#import "BLUBeaconAdvancedSettings.h"

/**
 *  `BLUBeaconOptionalAdvancedSettings` objects represent the advanced settings for each optional advertisement type of a beacon configuration.
 *
 *  @discussion Optional advanced beacon settings represent advertisement types that can but may not be available on a given beacon.
 */
@interface BLUBeaconOptionalAdvancedSettings : BLUBeaconAdvancedSettings

#pragma mark - Properties
/** @name Properties */

/**
 *  A boolean that specifies whether the advertisement type represented by these settings is available for configuration on the given beacon.
 */
@property (nonatomic, assign) BOOL available;

@end
