//
//  SOSCarSecretaryDatePicker.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryDatePicker.h"
#import "SOSDateFormatter.h"

@interface SOSCarSecretaryDatePicker ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UIPickerView *dayPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@end

@implementation SOSCarSecretaryDatePicker

- (void)awakeFromNib {
    [super awakeFromNib];
//    _toolBar.alpha = 0.f;
    self.alpha = 0;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIView *hideView = [UIView new];
    hideView.backgroundColor = [UIColor clearColor];
    [self addSubview:hideView];
    [self sendSubviewToBack:hideView];
    [hideView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];

    hideView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [hideView addGestureRecognizer:tapGes];
    
    
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [_pickerContainerView addSubview:datePicker];
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(_pickerContainerView);
    }];
    _datePicker = datePicker;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setPickerType:(SOSCarSecretaryDatePickerType)pickerType {
    _pickerType = pickerType;
   
         if (pickerType == SOSCarSecretaryDatePickerTypeDate) {
        //        UIDatePicker *datePicker = [UIDatePicker new];
        //        datePicker.datePickerMode = UIDatePickerModeDate;
        //        [_pickerContainerView addSubview:datePicker];
        //        [datePicker mas_makeConstraints:^(MASConstraintMaker *make){
        //            make.edges.equalTo(_pickerContainerView);
        //        }];
        //        _datePicker = datePicker;
                _dayPicker.hidden = YES;
                _datePicker.hidden = NO;
            }else {
                if (!_dayPicker) {
                    UIPickerView *dayPicker = [UIPickerView new];
                    dayPicker.dataSource = self;
                    dayPicker.delegate = self;
                    [_pickerContainerView addSubview:dayPicker];
                    [dayPicker mas_makeConstraints:^(MASConstraintMaker *make){
                        make.edges.equalTo(_pickerContainerView);
                    }];
                    _dayPicker = dayPicker;
                }
                _datePicker.hidden = YES;
                _dayPicker.hidden = NO;
                
            }
    if (pickerType == SOSDatePickerTypeHM) {
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (void)setDays:(NSArray<NSString *> *)days {
    _days = days;
    [_dayPicker reloadAllComponents];
}

- (void)setSelectedDate:(NSString *)selectedDate {
    _selectedDate = selectedDate;
    if (_pickerType == SOSCarSecretaryDatePickerTypeDate) {
        _datePicker.date = [[SOSDateFormatter sharedInstance] style1_dateFromString:selectedDate];
    }else {
        
            [_days enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj hasSuffix:@"日"]) {
                    obj = [obj substringToIndex:obj.length-1];
                }
                if ([obj isEqualToString:selectedDate]) {
                    [_dayPicker selectRow:idx inComponent:0 animated:YES];
                    *stop = YES;
                }
            }];
    }
}
////
- (void)setHours:(NSArray<NSString *> *)hours {
    _hours = hours;
}
- (void)setMinutes:(NSArray<NSString *> *)mins {
    _minutes = mins;
    [_dayPicker reloadAllComponents];
}
- (void)setSelectedHourMinute:(NSString *)selectedhm {
    _selectedHourMinute = selectedhm;
    NSArray * hms = [_selectedHourMinute componentsSeparatedByString:@"/"];
            [_hours enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
if ([obj isEqualToString:[hms objectAtIndex:0]]) {
                   [_dayPicker selectRow:idx inComponent:0 animated:YES];
                   *stop = YES;
               }
            }];
    
    [_minutes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isEqualToString:[hms objectAtIndex:1]]) {
                       [_dayPicker selectRow:idx inComponent:1 animated:YES];
                       *stop = YES;
                   }
                }];
        
}

- (void)show {
    if (!self.superview) {
        UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
        [keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(keyWindow);
        }];
    }
    _containerViewHeightConstraint.constant = 216;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.alpha = 1;
    } completion:nil];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        _containerViewHeightConstraint.constant = 0;
        [self layoutIfNeeded];
//        [self removeFromSuperview];
    }];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self hide];
}

- (IBAction)confirmBtnClicked:(id)sender {
    if (_picked) {
        if (_pickerType == SOSCarSecretaryDatePickerTypeDate) {
            NSString *result = [[SOSDateFormatter sharedInstance] style1_stringFromDate:_datePicker.date];
            _picked(result);
            
        }else {
            if (_pickerType == SOSDatePickerTypeHM) {
                NSUInteger hIndex = [_dayPicker selectedRowInComponent:0];
                NSUInteger mIndex = [_dayPicker selectedRowInComponent:1];
                NSString *result = [NSString stringWithFormat:@"%@/%@",_hours[hIndex],_minutes[mIndex]];
                _picked(result);
            }else{
                NSUInteger index = [_dayPicker selectedRowInComponent:0];
                NSString *result = _days[index];
                if ([result hasSuffix:@"日"]) {
                    result = [result substringToIndex:result.length-1];
                }
                _picked(result);
            }
            
        }
    }
    [self hide];
}

#pragma mark - picker view data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_pickerType == SOSDatePickerTypeHM) {
        return 2;
    }
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
     if (_pickerType == SOSDatePickerTypeHM) {
           return 60.0f;
       }
    return 90.0f;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_pickerType == SOSDatePickerTypeHM) {
        if (component == 0) {
            return _hours.count;
        }else{
            return _minutes.count;
        }
       }
    return _days.count;
}

#pragma mark - picker view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (_pickerType == SOSDatePickerTypeHM) {
           if (component == 0) {
               return _hours[row];
           }else{
               return _minutes[row];
           }
       }
    return _days[row];
}


@end
