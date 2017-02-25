//
//  BLUAccelerometerData.h
//  Bluvision
//
//  Created by Jason Clary on 3/21/16.
//  Copyright © 2016 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLUAccelerometerData : NSObject

@property (nonatomic, readonly) NSNumber *xAxisAcceleration;
@property (nonatomic, readonly) NSNumber *yAxisAcceleration;
@property (nonatomic, readonly) NSNumber *zAxisAcceleration;

@property (nonatomic, readonly) NSNumber *xAxisPositiveCounter;
@property (nonatomic, readonly) NSNumber *yAxisPositiveCounter;
@property (nonatomic, readonly) NSNumber *zAxisPositiveCounter;

@property (nonatomic, readonly) NSNumber *xAxisNegitiveCounter;
@property (nonatomic, readonly) NSNumber *yAxisNegitiveCounter;
@property (nonatomic, readonly) NSNumber *zAxisNegitiveCounter;

@end
