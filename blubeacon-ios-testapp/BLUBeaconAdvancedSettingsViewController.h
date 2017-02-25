//
//  BLUBeaconAdvancedSettingsViewController.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bluvision/Bluvision.h>
#import "BLUBeaconConstants.h"

@interface BLUBeaconAdvancedSettingsViewController : UITableViewController
@property (nonatomic, copy) id                         configurationBeacon;
@property (nonatomic, strong) BLUBeaconAdvancedSettings  *advancedSettings;
@end
