//
//  BLUBeaconConfigurationViewController.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 25/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bluvision/Bluvision.h>
#import "BLUBeaconConstants.h"

@interface BLUBeaconConfigurationViewController : UITableViewController
@property (nonatomic, strong) BLUConfigurableBeacon *configurableBeacon;
@property (nonatomic, assign) BLUConfigurationType  configurationType;

@property (nonatomic, strong) BLUBeaconConfiguration *scheduledConfiguration;
@property (nonatomic, strong) BLUAccelerometerSettings *accelerometerSettings;

@end
