//
//  BLUAccelerometerSettingsTableViewController.h
//  blubeacon-ios-testapp
//
//  Created by Jason Clary on 3/11/16.
//  Copyright © 2016 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLUAccelerometerSettings;
@class BLUSBeacon;

@interface BLUAccelerometerSettingsTableViewController : UITableViewController

@property (nonatomic, strong) BLUAccelerometerSettings *accelerometerSettings;
@property (nonatomic, strong) BLUSBeacon *beacon;

@end
