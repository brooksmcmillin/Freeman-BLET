//
//  BLUTextFieldCell.h
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 25/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUTableViewCell.h"

@interface BLUTextFieldCell : BLUTableViewCell
@property (nonatomic, weak) IBOutlet UILabel     *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end
