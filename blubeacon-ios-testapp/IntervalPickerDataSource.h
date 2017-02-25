//
//  IntervalPickerDataSource.h
//  BluZone
//
//  Created by Jason Clary on 10/15/15.
//  Copyright © 2015 Jason Clary. All rights reserved.
//

@import UIKit;

@class IntervalPickerDataSource;

@protocol IntervalPickerDataSourceDelegate <NSObject>

- (void)intervalPicker:(IntervalPickerDataSource *)intervalPicker didSelectInterval:(NSNumber *)interval picker:(UIPickerView *)picker;

@end

@interface IntervalPickerDataSource : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<IntervalPickerDataSourceDelegate> delegate;

@end
