//
//  DatePickerView.h
//  Onstar
//
//  Created by Apple on 16/7/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) void(^exitCallback)(void);
@property (nonatomic, copy) void(^okCallback)(void);

+ (NSDateFormatter *)dateFormatter;

@end
