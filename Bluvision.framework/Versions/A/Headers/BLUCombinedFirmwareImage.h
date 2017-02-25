//
//  BLUCombinedFirmwareImage.h
//
//  Copyright © 2015 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLUDevice.h"

@class BLUCombinedFirmwarePackage;
@class BLUSBeacon;

@interface BLUCombinedFirmwareImage : NSObject

@property (nonatomic, readonly) NSArray *firmwarePackages;

- (NSArray *)firmwarePackagesForFirmwareInfoArray:(NSArray *)infoArray deviceType:(BLUDeviceType)deviceType;
- (NSArray *)firmwarePackagesForBeacon:(BLUSBeacon *)beacon;

- (BLUCombinedFirmwarePackage *)firmwarePackageForFirmwareInfoArray:(NSArray *)infoArray deviceType:(BLUDeviceType)deviceType;
- (BLUCombinedFirmwarePackage *)firmwarePackageForBeacon:(BLUSBeacon *)beacon;

- (BLUCombinedFirmwarePackage *)legacyPackageForFirmwareInfoArray:(NSArray *)infoArray deviceType:(BLUDeviceType)deviceType oldLoaderVersion:(NSNumber *)oldLoaderVersion;
- (BLUCombinedFirmwarePackage *)loaderFirmwarePackageForBeacon:(BLUSBeacon *)beacon;

- (BLUCombinedFirmwarePackage *)loaderFirmwarePackageForFirmwareInfoArray:(NSArray *)infoArray deviceType:(BLUDeviceType)deviceType;
- (BLUCombinedFirmwarePackage *)legacyPackageForBeacon:(BLUSBeacon *)beacon;


- (instancetype)initWithData:(NSData *)firmwareData;
+ (BOOL)isValidFirmwareDataForImage:(NSData *)data;
@end

