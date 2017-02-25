//
//  BLUBeaconFilter.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import "BLUDistance.h"
#import "BLUSpan.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUBeaconFilter` objects are used to filter `BLUBeaconManager` scan results.
 *
 *  @discussion You can use beacon filters to filter discovered beacons by certain criteria. Each filter object can contain multiple criteria at once. 
 *  After a filter has been setup, it can be applied to a beacon manager object. Subsequently, the beacon manager's `foundBeacons` set will only
 *  contain those beacon objects that are matching all of the filters applied to the manager.
 */
@interface BLUBeaconFilter : NSObject

#pragma mark - Properties
/** @name Properties */

/**
 *  An array of sBeacon identifiers as `NSNumber` that you are looking for.
 */
@property (nonatomic, nullable, copy) NSArray <NSNumber *> *sBeaconIds;

/**
 *  An array of iBeacon proximity UUIDs and/or EddystoneBeacon UIDs as `NSUUID` that you are looking for.
 */
@property (nonatomic, nullable, copy) NSArray <NSUUID *> *UUIDs;

/**
 *  An array of Eddystone Namespace Identifiers as 'NSData' that you are looking for.
 */
@property (nonatomic, nullable, copy) NSArray <NSData *> *eddystoneNamespaceIdentifiers;

/**
 *  An array of Eddystone Instance Identifiers as 'NSData' that you are lookcing for.
 */
@property (nonatomic, nullable, copy) NSArray <NSData *> *eddystoneInstanceIdentifiers;

/**
 *  An array of EddystoneBeacon URLs that you are as `NSURL` looking for.
 */
@property (nonatomic, nullable, copy) NSArray <NSURL *> *URLs;

/**
 *  A span of RSSI values that your beacon's advertisements are supposed to be within.
 *  
 *  @discussion BLUSpan objects hold a minimum and a maximum valid value. You can either setup both or only one of those.
 */
@property (nonatomic, nullable, copy) BLUSpan *rssiSpan;

/**
 *  A span of temperature values in degrees Celsius that your beacon's measurements are supposed to be within.
 *
 *  @discussion BLUSpan objects hold a minimum and a maximum valid value. You can either setup both or only one of those.
 */
@property (nonatomic, nullable, copy) BLUSpan *temperatureCelsiusSpan;

/**
 *  A span of temperature values in degrees Fahrenheit that your beacon's measurements are supposed to be within.
 *
 *  @discussion BLUSpan objects hold a minimum and a maximum valid value. You can either setup both or only one of those.
 */
@property (nonatomic, nullable, copy) BLUSpan *temperatureFahrenheitSpan;

/**
 *  A span of battery voltage values in Volts that your beacon's battery voltage is supposed to be within.
 *
 *  @discussion BLUSpan objects hold a minimum and a maximum valid value. You can either setup both or only one of those.
 */
@property (nonatomic, nullable, copy) BLUSpan *batteryVoltageSpan;

/**
 *  A span of battery percentage values in percent that your beacon's battery level is supposed to be within.
 *
 *  @discussion BLUSpan objects hold a minimum and a maximum valid value. You can either setup both or only one of those.
 */
@property (nonatomic, nullable, copy) BLUSpan *batteryPercentageSpan;

/**
 *  A distance value that you are looking for.
 */
@property (nonatomic, assign) BLUDistance distance;

@end

NS_ASSUME_NONNULL_END
