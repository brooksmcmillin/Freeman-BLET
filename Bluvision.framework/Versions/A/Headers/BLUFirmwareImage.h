//
//  BLUFirmwareImage.h
//
//  Copyright (c) 2015 BluVision. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLUConfigurableBeacon;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `BLUFirmwareImage` objects are used to update a beacon's firmware.
 *
 *  @discussion A firmware image instance can be created from any valid firmware file provided as NSData.
 *  The firmware image object can be used to start a firmware update by calling `updateFirmwareWithImage:progress:completion:`
 *  on a `BLUConfigurableBeacon` instance.
 *  
 *  There are two possible types of firmware images: Normal firmware and loader images. Certain normal images are too large 
 *  in size to be installed onto a beacon directly. In such a case a loader image needs to be installed first to free up enough
 *  space on the beacon for the installation of the targeted firmware.
 *  Normal firmware images are considered invalid for beacons that require a loader image first. Please make sure to provide the firmware
 *  files for a beacon in the correct sequence.
 */
@interface BLUFirmwareImage : NSObject

#pragma mark - Initialization
/** @name Initialization */

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 *  Initializes an instance of BLUFirmwareImage for the specified configurable beacon with the provided firmware data.
 *
 *  @param firmwareData An NSData object containing the firmware update image.
 *  @param configurableBeacon A BLUConfigurableBeacon object representing the beacon that will be updated.
 *
 *  @return Returns a newly initialized BLUFirmwareImage instance or `nil` if the data does not contain
 *  a valid firmware image for the given beacon.
 */
+ (BLUFirmwareImage *)firmwareImageForData:(NSData *)firmwareData configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon;

/**
 *  Returns all firmware images for the specified configurable beacon that are contained in the provided firmware data.
 *
 *  @param firmwareData An NSData object containing the firmware update image.
 *  @param configurableBeacon A BLUConfigurableBeacon object representing the beacon that the firmware images are needed for.
 *
 *  @return Returns an array of `BLUFirmwareImage` instances or `nil` if the data does not contain
 *  any firmware images for the given beacon. The array contains all compatible firmware images within the provided data -
 *  regardless of their size and validity.
 */
+ (NSArray <BLUFirmwareImage *> *)firmwareImagesForData:(NSData *)firmwareData configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon;

/**
 *  Reads a firmware file provided as NSData and returns its firmware revision if the data is
 *  compatible with the specified configurable beacon.
 *
 *  @param firmwareData  An NSData object containing the firmware update image.
 *  @param configurableBeacon A BLUConfigurableBeacon object that the firmware revision is needed for.
 *
 *  @return Returns the firmware revision of the specified data or `nil` if the data does not contain
 *  a valid firmware image for the given beacon.
 */
+ (NSNumber *)firmwareRevisionForData:(NSData *)firmwareData configurableBeacon:(BLUConfigurableBeacon *)configurableBeacon;



#pragma mark - Properties
/** @name Properties*/

/**
 *  The title of the firmware image.
 */
@property (nonatomic, readonly) NSString *firmwareName;

/**
 *  The description of the firmware image.
 */
@property (nonatomic, readonly) NSString *firmwareDescription;

/**
 *  The size of the firmware image in bytes.
 */
@property (nonatomic, readonly) NSNumber *size;

/**
 *  The revision number of the firmware image.
 */
@property (nonatomic, readonly) NSNumber *revisionNumber;

/**
 *  The revision string of the firmware image.
 */
@property (nonatomic, readonly) NSString *revisionString;

/**
 *  A boolean specifying whether the firmware image is a loader image.
 *  Certain firmware images are too large in size to be installed onto a beacon directly. In such a case a loader
 *  image needs to be installed first to clear enough space on the beacon for the installation of the targeted firmware.
 */
@property (nonatomic, readonly) BOOL isLoaderImage;

@end

NS_ASSUME_NONNULL_END
