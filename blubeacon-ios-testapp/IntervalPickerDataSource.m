//
//  IntervalPickerDataSource.m
//  BluZone
//
//  Created by Jason Clary on 10/15/15.
//  Copyright © 2015 Jason Clary. All rights reserved.
//

#import "IntervalPickerDataSource.h"

@interface IntervalPickerDataSource ()

@property (nonatomic, strong) NSArray *seconds;
@property (nonatomic, strong) NSArray *miliseconds;

@end

@implementation IntervalPickerDataSource

- (instancetype)init {
    self = [super init];

    if (!self) {
        return nil;
    }

    self.seconds = @[@0,@1,@2,@3];

    NSMutableArray *mutableMilis = [NSMutableArray new];
    for (NSUInteger i = 0; i < 100; i++) {
        [mutableMilis addObject:@(i)];
    }

    self.miliseconds = [NSArray arrayWithArray:mutableMilis];

    return self;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.seconds.count;
    }

    if (component == 2) {
        return self.miliseconds.count;
    }

    return 1;

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [NSString stringWithFormat:@"%@",self.seconds[row]];
    }

    if (component == 1) {
        return @".";
    }

    if (component == 2) {
        return [self mantissaStringForNumber:self.miliseconds[row]];
    }

    return @"Seconds";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.delegate respondsToSelector:@selector(intervalPicker:didSelectInterval:picker:)] && (component == 0 || component == 2)) {
        NSUInteger secondsIndex = [pickerView selectedRowInComponent:0];
        NSUInteger milisecondsIndex = [pickerView selectedRowInComponent:2];

        NSNumber *second = self.seconds[secondsIndex];
        NSNumber *milisecond = self.miliseconds[milisecondsIndex];
        NSNumber *interval = @([[NSString stringWithFormat:@"%@.%@",second,[self mantissaStringForNumber:milisecond]] doubleValue]);

        [self.delegate intervalPicker:self didSelectInterval:interval picker:pickerView];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component < 2) {
        return 25;
    }

    if (component == 2) {
        return 45;
    }

    return 200;
}

#pragma mark - Helpers

- (NSString *)mantissaStringForNumber:(NSNumber *)number {
    return [NSString stringWithFormat:@"%@%@",[number integerValue] < 10 ? @"0" : @"", number];
}
@end
