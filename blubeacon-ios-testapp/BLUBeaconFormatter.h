//
//  BLUBeaconFormatter.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bluvision/Bluvision.h>

@interface BLUBeaconFormatter : NSObject

+ (NSInteger)indexForIntervalValue:(NSNumber *)intervalValue;
+ (NSArray *)intervalValues;
+ (NSArray *)intervalStrings;

+ (NSInteger)indexForTxPowerValue:(NSNumber *)txPowerValue;
+ (NSArray *)txPowerValues;
+ (NSArray *)txPowerStrings;

+ (NSString *)timeoutStringFromInterval:(NSTimeInterval)timeInterval;

+ (NSString *)titleForBeaconDistance:(BLUDistance)beaconDistance;

@end
