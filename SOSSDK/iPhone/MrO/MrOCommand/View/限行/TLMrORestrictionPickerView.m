//
//  TLMrORestrictionPickerView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMrORestrictionPickerView.h"
#import "SOSDateFormatter.h"

@interface TLMrORestrictionPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (weak, nonatomic) UIPickerView *datePicker;
@property (weak, nonatomic) UIPickerView *cityPicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (strong, nonatomic) NSArray <NSString *>*dates;

@property (strong, nonatomic) NSArray <NSDictionary *>*cities;

@end

@implementation TLMrORestrictionPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    _toolBar.alpha = 0;
    [self layoutIfNeeded];

}

- (void)setPickerType:(MrORestrictionPickerType)pickerType {
    _pickerType = pickerType;
    if (pickerType == MrORestrictionPickerTypeDate) {
        _titleLabel.text = @"查询日期";
        _promptLabel.text = nil;
        _dates = [self getDates];
        UIPickerView *datePicker = [UIPickerView new];
        datePicker.dataSource = self;
        datePicker.delegate = self;
        datePicker.backgroundColor = [UIColor whiteColor];
        [_pickerContainerView addSubview:datePicker];
        [datePicker mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(_pickerContainerView);
        }];
        _datePicker = datePicker;
    }else {
        if ([_object isKindOfClass:[NSArray class]]) {
            _cities = _object;
        }
        _titleLabel.text = @"查询城市";
        _promptLabel.text = @"目前只支持以下城市限行查询";
        UIPickerView *cityPicker = [UIPickerView new];
        cityPicker.dataSource = self;
        cityPicker.delegate = self;
        cityPicker.backgroundColor = [UIColor whiteColor];
        [_pickerContainerView addSubview:cityPicker];
        [cityPicker mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(_pickerContainerView);
        }];
        _cityPicker = cityPicker;
    }
}

- (void)show {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _containerViewHeightConstraint.constant = 220;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _toolBar.alpha = 1;
            [self layoutIfNeeded];
        } completion:nil];

    });
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self hide];
}

- (IBAction)confirmBtnClicked:(id)sender {
    if (_picked) {
        if (_pickerType == MrORestrictionPickerTypeDate) {

            NSUInteger index = [_datePicker selectedRowInComponent:0];
            NSString *result = _dates[index];
            _picked(result, index);

        }else {
            NSUInteger index = [_cityPicker selectedRowInComponent:0];
            NSString *result = _cities[index][@"city"];
            _picked(result, index);
        }
    }
    [self hide];
}


#pragma mark - picker view data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _datePicker) {
        return _dates.count;
    }
    return _cities.count;
}

#pragma mark - picker view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _datePicker) {
        return _dates[row];
    }
    return _cities[row][@"city"];
}

- (NSArray <NSString *>*)getDates {
    NSMutableArray <NSString *>*dates = @[].mutableCopy;
    NSDate *today = [NSDate date];
    NSString *todayString = [[SOSDateFormatter sharedInstance] stringFromDate:today];
    today = [[SOSDateFormatter sharedInstance] dateFromString:todayString];
    for (int i=0; i<10; i++) {
        NSDate *day = [NSDate dateWithTimeInterval:i * 24 * 60 * 60 sinceDate:today];
        NSString *dayString = [[SOSDateFormatter sharedInstance] stringFromDate:day];
        [dates addObject:dayString];
    }
    return dates;
}

@end
