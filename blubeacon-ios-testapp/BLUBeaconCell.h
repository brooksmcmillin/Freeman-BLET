//
//  BLUBeaconCell.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 23/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLUBeaconCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UILabel *topLabel;
@property (nonatomic, weak) IBOutlet UILabel *bottomLabel;
@end
