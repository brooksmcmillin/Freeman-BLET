//
//  BLUTableViewCell.m
//  blubeacon-ios-testapp
//
//  Created by Lutz Hennig on 24/03/15.
//  Copyright (c) 2015 Bluvision Inc. All rights reserved.
//

#import "BLUTableViewCell.h"

@implementation BLUTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)toggleFullSeparatorInsets:(BOOL)on
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (!on)
    {
        // Set the cell to inherit the Table View's margin settings
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:YES];
        }
        insets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    }
    else
    {
        // Prevent the cell from inheriting the Table View's margin settings
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
    // Remove seperator inset
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:insets];
    }
    // Explictly set your cell's layout margins
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:insets];
    }
}

@end
