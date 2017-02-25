//
//  BLUDevice.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines the possible device types of a Bluvision beacon.
 */
typedef NS_ENUM(uint8_t, BLUDeviceType){
    /**
     *  An unknown device. 
     *  This is the default value for a `BLUDevice` instance before the actual device type has been determined.
     */
    BLUDeviceTypeUnknown        = 0xFF,
    /**
     *  A BEEKS Pro.
     */
    BLUDeviceTypeTag24mm        = 0x01,
    /**
     *  A BEEKS Extend.
     */
    BLUDeviceTypeTag27mm        = 0x02,
    /**
     *  ...
     */
    BLUDeviceTypeTagAA          = 0x03,
    /**
     *  An HQ Beacon.
     */
    BLUDeviceTypeTagHQ          = 0x10,
    /**
     *  <#Description#>
     */
    BLUDeviceTypeTagCC24mm      = 0x21,
    /**
     *  <#Description#>
     */
    BLUDeviceTypeTagCC27mm      = 0x22,
    /**
     *  An iBEEK.
     */
    BLUDeviceTypeTagCCaa        = 0x23,
    /**
     *  A USB BEEK
     */
    BLUDeviceTypeUSB            = 0x26,
    /**
     *  A Nano USB BEEK
     */
    BLUDeviceTypeNanoUSB        = 0x27,
    /**
     *  A BluFi WiFi Sensor.
     */
    BLUDeviceTypeBle2Wifi       = 0x28,

};

/**
 *  Defines the capabilities of a Bluvision beacon.
 */
typedef NS_OPTIONS(uint8_t, BLUDeviceCapabilities){
    /**
     *  The beacon has no special capabilities.
     */
    BLUDeviceCapabilitiesNone   = 0,
    /**
     *  The beacon has a speaker and can play melodies.
     */
    BLUDeviceCapabilitiesBuzzer = 1 << 0,
    /**
     *  The beacon has an LED.
     */
    BLUDeviceCapabilitiesLed    = 1 << 1,
    /**
     *  The beacon has an accelerometer.
     */
    BLUDeviceCapabilitiesAccel  = 1 << 2,
    /**
     *  The beacon has an external temperature sensor.
     */
    BLUDeviceCapabilitiesExternalTemperatureSensor = 1 << 3
};

/**
 *  Defines the sensors available on a Bluvision beacon.
 */
typedef NS_OPTIONS(uint16_t, BLUDeviceSensors) {
    /**
     *  The beacon has an accelerometer.
     */
    BLUDeviceSensorAccel   = 1 << 0,
    /**
     *  The beacon has a temperature sensor.
     */
    BLUDeviceSensorTemperature = 1 << 1,
    /**
     *  The beacon has a magnetic sensor.
     */
    BLUDeviceSensorMag    = 1 << 2,
    /**
     *  The beacon has a gyroscope.
     */
    BLUDeviceSensorGyro  = 1 << 3,
    /**
     *  The beacon has a pressure sensor.
     */
    BLUDeviceSensorPressure = 1 << 4,
    /**
     *  The beacon has a humidity sensor.
     */
    BLUDeviceSensorHumidity = 1 << 5,
    /**
     *  The beacon has a PIR sensor.
     */
    BLUDeviceSensorPIR = 1 << 6,
    /**
     *  The beacon has a light sensor.
     */
    BLUDeviceSensorLight = 1 << 7
};

typedef NS_ENUM(uint8_t, BLULightSensorSensivity) {
    BLULightSensorSensivityNone = 0xFF,
    BLULightSensorSensivityLowest = 0x0,
    BLULightSensorSensivityLow = 0x01,
    BLULightSensorSensivityMedium = 0x02,
    BLULightSensorSensivityDefault = 0x03,
    BLULightSensorSensivityHigh = 0x06,
    BLULightSensorSensivityHighest = 0x07
};

/**
 *  `BLUDevice` objects represent information about the physical device broadcasting Bluvision's sBeacon advertisements.
 *
 *  @discussion Each `BLUSBeacon` and `BLUSLegacyBeacon` object keeps a reference to a `BLUDevice` object. The device information can only be obtained after
 *  the `BLUSBeacon` or `BLUSLegacyBeacon` has been connected at least once during its lifetime.
 */
@interface BLUDevice : NSObject <NSCopying, NSSecureCoding>

#pragma mark - Properties
/** @name Properties */

/**
 *  The type of the device.
 */
@property (nonatomic, readonly) BLUDeviceType type;

/**
 *  The special capabilities of the device.
 */
@property (nonatomic, readonly) BLUDeviceCapabilities capabilities;

/**
 *  The sensors available on the device.
 */
@property (nonatomic, readonly) BLUDeviceSensors sensors;

/**
 *  The current firmware revision installed on the device.
 */
@property (nonatomic, readonly) NSNumber *firmwareRevision;

#pragma mark - Helper methods
/** @name Helper methods */

/**
 *  Requests a description string for the device's type.
 *
 *  @return Returns a description string for the device's type.
 */
- (NSString *)typeString;

@end

NS_ASSUME_NONNULL_END
