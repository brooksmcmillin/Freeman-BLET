//
//  BLUBeaconConstants.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, BLUConfigurationType) {
    BLUConfigurationTypeNone,
    BLUConfigurationTypeSBeacon,
    BLUConfigurationTypeEddystoneBeacon,
    BLUConfigurationTypeIBeacon,
    BLUConfigurationTypeMotionBeacon,
    BLUConfigurationTypeLightSensorBeacon
};

@interface BLUBeaconConstants : NSObject

@end
