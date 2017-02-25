//
//  BLUPickerCell.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 26/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUTableViewCell.h"

@interface BLUPickerCell : BLUTableViewCell
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@end
