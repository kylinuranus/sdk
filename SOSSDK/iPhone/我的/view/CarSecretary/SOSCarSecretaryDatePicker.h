//
//  SOSCarSecretaryDatePicker.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SOSCarSecretaryDatePickerType) {
    SOSCarSecretaryDatePickerTypeDate,
    SOSCarSecretaryDatePickerTypeDay,
    SOSDatePickerTypeHM//时分
};

@interface SOSCarSecretaryDatePicker : UIView

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) SOSCarSecretaryDatePickerType pickerType;

@property (copy, nonatomic) NSString *selectedDate;
@property (strong, nonatomic) NSArray<NSString *> *days;
//
@property (strong, nonatomic) NSArray<NSString *> *hours;
@property (copy, nonatomic) NSString *selectedHourMinute;
@property (strong, nonatomic) NSArray<NSString *> *minutes;

@property (copy, nonatomic) void(^picked)(NSString *result);
@property (copy, nonatomic) void(^cancel)(NSString *result);

- (void)show;
- (void)hide;

@end
