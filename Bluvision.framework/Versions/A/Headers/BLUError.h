//
//  BLUError.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Bluvision's own error domain.
 */
FOUNDATION_EXPORT NSString *const kBluvisionErrorDomain;

/**
 *  Key for obtaining a `CLRegion` object from NSError's `userInfo` dictionary if 
 *  CoreLocation monitoring or ranging has failed for that region.
 */
FOUNDATION_EXPORT NSString *const kBLUErrorRegionKey;

/**
 *  Defines the `NSError` error codes used throughout this framework.
 */
typedef NS_ENUM(NSUInteger, BLUErrorCode){
    /**
     *  The cause of the error is unknown.
     */
    BLUErrorCodeUnknown = 5000,
    /**
     *  The error originated in a `BLUBeaconManager` instance.
     */
    BLUErrorCodeBeaconManager,
    /**
     *  The error originated in a `BLUConfigurableBeacon` instance.
     */
    BLUErrorCodeConfigurableBeacon,
    /**
     *  The error was encountered during a beacon firmware update.
     */
    BLUErrorCodeFirmwareUpdate,
    /**
     *  A password is required error
     */
    BLUErrorCodePasswordRequired,
    /**
     *  No password is required error
     */
    BLUErrorCodeNoPasswordRequired,
    /**
     *  Authentication did fail during initialization
     */
    BLUErrorCodeEncryptionStatus,
    /**
     *  The error was encountered while decoding encrypted advertisements.
     */
    BLUErrorCodeAdvertisementEncryption
};

