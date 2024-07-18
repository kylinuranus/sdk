//
//  DatePickerView.m
//  Onstar
//
//  Created by Apple on 16/7/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "DatePickerView.h"

@implementation DatePickerView {
    NSString *outputStr;
    UIButton *finishButton;
}

- (instancetype)init {
    
    self = [super initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 300)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initDatePicker];
    }
    return self;
}

#pragma mark -初始化日期
- (void)initDatePicker
{
    [self addSubview:[self toolBarWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)]];

    _datePicker=[[UIDatePicker alloc] init];
    _datePicker.backgroundColor=[UIColor whiteColor];
    _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.frame=CGRectMake(0, 40, SCREEN_WIDTH, 260);
    _datePicker.locale = [NSLocale currentLocale];
    _datePicker.minimumDate = [[DatePickerView dateFormatter] dateFromString:@"1990-01-01"];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:10];
    NSDate *maxDate =[calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    _datePicker.maximumDate = maxDate;
    [self addSubview:_datePicker];
}

- (UIView *)toolBarWithFrame:(CGRect)frame
{
    UIView *toolBar = [[UIView alloc] initWithFrame:frame];
    toolBar.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(15, 0, 50, 40);
    exitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [exitBtn setTitle:NSLocalizedString(@"DateExit", nil) forState:UIControlStateNormal];
    [exitBtn setTitleColor:[UIColor colorWithHexString:@"107fe0"] forState:UIControlStateNormal];
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [exitBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:exitBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    title.textColor = [UIColor colorWithHexString:@"131329"];
    title.font = [UIFont systemFontOfSize:17];
    title.text = NSLocalizedString(@"Please_Select_Time", nil);
    title.textAlignment = NSTextAlignmentCenter;
    [toolBar addSubview:title];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(SCREEN_WIDTH-60-15, 0, 60, 40);
    okBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [okBtn setTitle:NSLocalizedString(@"DateConfirm", nil) forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor colorWithHexString:@"107fe0"] forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [okBtn addTarget:self action:@selector(selectDateClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:okBtn];
    
    return toolBar;
}

+ (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return dateFormatter;
}

- (void)closeClick
{
    !_exitCallback ? : _exitCallback();
}

- (void)selectDateClick
{
    !_okCallback ? : _okCallback();
}

@end

