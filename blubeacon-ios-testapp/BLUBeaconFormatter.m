//
//  BLUBeaconFormatter.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUBeaconFormatter.h"

@implementation BLUBeaconFormatter

+ (NSInteger)indexForIntervalValue:(NSNumber *)intervalValue {
    NSArray *intervalValues = [BLUBeaconFormatter intervalValues];
    NSInteger index = [intervalValues indexOfObject:intervalValue];
    if (index == NSNotFound) {
        float difference = NSIntegerMax;
        for (NSNumber *value in intervalValues) {
            float currentDifference = fabs(value.floatValue - intervalValue.floatValue);
            if (currentDifference < difference) {
                difference = currentDifference;
                index = [intervalValues indexOfObject:value];
            }
        }
    }
    return index;
}

+ (NSArray *)intervalValues {
    static NSArray *intervalValues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSInteger i = 10; i > 0; i--) {
            [tempArray addObject:@(i)];
            
        }
        for (double i = 0.9; i > 0.11; i -= 0.1) {
            [tempArray addObject:@(i)];
        }
        intervalValues = [tempArray copy];
    });
    
    return intervalValues;
}

+ (NSArray *)intervalStrings {
    static NSArray *intervals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = 10; i > 1; i--) {
            [array addObject:[NSString stringWithFormat:@"%ldHz - %ld times a second", (long)i, (long)i]];
            
        }
        [array addObject:@"1Hz - once a second"];
        
        for (double i = 0.9; i > 0.11; i -= 0.1) {
            [array addObject:[NSString stringWithFormat:@"%0.1fHz - every %0.1f seconds", i, 1.0/i]];
        }
        intervals = [array copy];
    });
    
    return intervals;
}

+ (NSInteger)indexForTxPowerValue:(NSNumber *)txPowerValue {
    NSArray *txPowerValues = [BLUBeaconFormatter txPowerValues];
    NSInteger index = [txPowerValues indexOfObject:txPowerValue];
    if (index == NSNotFound) {
        NSInteger difference = NSIntegerMax;
        for (NSNumber *value in txPowerValues) {
            NSInteger currentDifference = ABS(value.integerValue - txPowerValue.integerValue);
            if (currentDifference < difference) {
                difference = currentDifference;
                index = [txPowerValues indexOfObject:value];
            }
        }
    }
    return index;
}

+ (NSArray *)txPowerValues {
    static NSArray *txPowerValues;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *txPowers = [NSMutableArray new];
        for (int i = -50; i < 6; i++) {
            [txPowers addObject:@(i)];
        }

        txPowerValues = [txPowers copy];
    });

    return txPowerValues;
}

+ (NSArray *)txPowerStrings {
    static NSArray *txPowerStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *txPowerValues = [BLUBeaconFormatter txPowerValues];

        NSMutableArray *tempArray = [NSMutableArray new];
        for (int i = 0; i < txPowerValues.count; i++) {
            NSNumber *value = txPowerValues[i];

            NSString *prefix = @"";
            if (value.integerValue > 0) {
                prefix = @"+";
            }

            NSString *txPowerString = [NSString stringWithFormat:@"%@%@ dBm", prefix, value.stringValue];
            [tempArray addObject:txPowerString];
        }
        txPowerStrings = [tempArray copy];
    });
    
    return txPowerStrings;
}

+ (NSString *)timeoutStringFromInterval:(NSTimeInterval)timeInterval {
    NSInteger temp    = (NSInteger)timeInterval;
    NSInteger years   = ((temp / 3600) / 24) / 365;
    temp             -= years * 3600 * 24 * 365;
    NSInteger days    = (temp / 3600) / 24;
    temp             -= days * 3600 * 24;
    NSInteger hours   = temp / 3600;
    temp             -= hours * 3600;
    NSInteger minutes = temp / 60;
    
    NSString *minuteString  = minutes   == 1 ? @"minute"  : @"minutes";
    NSString *hourString    = hours     == 1 ? @"hour"    : @"hours";
    NSString *dayString     = days      == 1 ? @"day"     : @"days";
    NSString *yearString    = years     == 1 ? @"year"    : @"years";
    
    NSString *timeoutDeactivatedString = @"Don't Switch To Energy Saving";
    
    NSString *timeoutString;
    if (timeInterval <= 0) {
        // not activated
        timeoutString = timeoutDeactivatedString;
    }
    else {
        NSMutableString *string = [[NSMutableString alloc] init];
        if (years > 0)
            [string appendFormat:@"%ld %@ ", (long)years, yearString];
        if (days > 0)
            [string appendFormat:@"%ld %@ ", (long)days, dayString];
        if (hours > 0)
            [string appendFormat:@"%ld %@ ", (long)hours, hourString];
        if (minutes > 0)
            [string appendFormat:@"%ld %@", (long)minutes, minuteString];
        
        timeoutString = [string copy];
    }
    return timeoutString;
}

+ (NSString *)titleForBeaconDistance:(BLUDistance)beaconDistance {
    switch (beaconDistance) {
        case BLUDistanceFar:
            return @"> 2 meters (6.5 feet)";
        case BLUDistanceNear:
            return @"Between .5 meters and 2 meters (1.6 - 6.5 feet)";
        case BLUDistanceImminent:
            return @"< .5 meters (1.6 feet)";
        case BLUDistanceUnknown:
        default:
            return @"Unknown";
    }
}

@end
