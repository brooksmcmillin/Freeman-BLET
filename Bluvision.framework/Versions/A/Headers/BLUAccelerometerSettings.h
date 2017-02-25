//
//  BLUAccelerometerSettings.h
//  Bluvision
//
//  Copyright © 2016 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, BLUMotionAxisEnabled) {
    BLUMotionAxisEnabledX = 1 << 0,
    BLUMotionAxisEnabledY = 1 << 1,
    BLUMotionAxisEnabledZ = 1 << 2
};

@interface BLUAccelerometerSettings : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, assign) BLUMotionAxisEnabled motionAxisesEnables;
@property (nonatomic, assign) BLUMotionAxisEnabled transientAxisesEnables;

@property (nonatomic, readwrite, getter=isHighPassFilterEnabled) BOOL highPassFilterEnabled;
@property (nonatomic, readwrite, getter=isMotionThreasholdEnabled) BOOL motionThreasholdEnabled;
@property (nonatomic, readwrite, getter=isTransientThreasholdEnabled) BOOL transientThreasholdEnabled;

@property (nonatomic, assign) NSUInteger motionSensitivity;
@property (nonatomic, assign) NSUInteger transientSensitivity;

@property (nonatomic, assign) NSUInteger motionDebounce;
@property (nonatomic, assign) NSUInteger transientDebounce;

@property (nonatomic, assign) NSUInteger rate;
@property (nonatomic, assign) NSUInteger cutoff;

+ (BLUAccelerometerSettings *)defaultSettings;

@end
