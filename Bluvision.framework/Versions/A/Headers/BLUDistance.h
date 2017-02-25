//
//  BLUDistance.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Bluvision_BLUDistance_h
#define Bluvision_BLUDistance_h

/**
 *  Defines levels of distance for beacon advertisements.
 *  These values are used to give a distance estimate for `BLUBeacon` objects.
 *  Their calculation is based on the beacon's transmission power and RSSI values.
 *  Accurate results can only be expected in direct line-of-sight environments with 
 *  minimal signal interference.
 */
typedef NS_ENUM(NSUInteger, BLUDistance){
    /**
     *  The current beacon distance could not be calculated.
     */
    BLUDistanceUnknown,
    /**
     *  The beacon is not more than 0.5 meters away from the receiver.
     */
    BLUDistanceImminent,
    /**
     *  The beacon is between 0.5 and 2 meters away from the receiver.
     */
    BLUDistanceNear,
    /**
     *  The beacon is more than 2 meters away from the receiver.
     */
    BLUDistanceFar
};

#endif
