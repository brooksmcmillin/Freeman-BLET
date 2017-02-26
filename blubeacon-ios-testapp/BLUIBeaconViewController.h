//
//  BLUIBeaconViewController.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 30/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Bluvision/Bluvision.h>
@class BLUIBeaconViewController;

@protocol BLUIBeaconViewControllerDelegate <NSObject>
- (void)iBeaconViewController:(BLUIBeaconViewController *)viewController didFinishWithIBeaconUUID:(NSUUID *)uuid major:(NSNumber *)major minor:(NSNumber *)minor rotationKey:(NSData *)rotationKey;
@end

@interface BLUIBeaconViewController : UITableViewController
@property (nonatomic, weak)   id<BLUIBeaconViewControllerDelegate> delegate;
@end
