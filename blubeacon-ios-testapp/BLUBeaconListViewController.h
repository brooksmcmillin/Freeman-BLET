//
//  BLUBeaconListViewController.h
//  bluvision_sdk_test
//
//  Created by Lutz Hennig on 19/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bluvision/Bluvision.h>

@class BLUBeaconDetailViewController;

extern NSString * const BLUBeaconListViewControllerDidUpdateRotatingIBeaconNotification;

@interface BLUBeaconListViewController : UITableViewController

@property (nonatomic, strong) BLUBeaconDetailViewController *detailViewController;


@end

