//
//  BLUBeaconDetailViewController.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 19/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bluvision/Bluvision.h>

@interface BLUBeaconDetailViewController : UITableViewController

@property (nonatomic, strong) BLUBeaconManager  *beaconManager;
@property (nonatomic, strong) BLUBeacon         *beacon;

-(IBAction)takePicture:(UIButton *)sender;;

@end

