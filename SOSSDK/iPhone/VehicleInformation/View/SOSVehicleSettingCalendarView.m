//
//  SOSVehicleSettingCalendarView.m
//  Onstar
//
//  Created by Creolophus on 2020/2/20.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleSettingCalendarView.h"
#import <FSCalendar/FSCalendar.h>
#import "NSDate+DateTools.h"

@interface SOSVehicleSettingCalendarView ()<FSCalendarDataSource, FSCalendarDelegate>
@property (strong, nonatomic) FSCalendar *calendar;
@end

@implementation SOSVehicleSettingCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(15, 0, 230, 300)];
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.headerHeight = 70;
        calendar.weekdayHeight = 40;
        calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
        calendar.appearance.headerDateFormat = @"yyyy 年 MM 月";
        calendar.appearance.headerTitleColor = SOSUtil.defaultLabelBlack;
        calendar.appearance.headerTitleFont = [UIFont boldSystemFontOfSize:16];
        calendar.appearance.weekdayTextColor = SOSUtil.defaultSubLabelBlack;
        calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12];
        calendar.appearance.selectionColor = SOSUtil.defaultLabelLightBlue;
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        calendar.today = nil;
        calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        [self addSubview:calendar];
        
        calendar.calendarHeaderView.scrollDirection = UICollectionViewScrollDirectionVertical;
        UIButton *previous = [UIButton buttonWithType:UIButtonTypeCustom];
        [previous setImage:[UIImage imageNamed:@"calendar_arrow_left_22x22"] forState:UIControlStateNormal];
        [previous addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previous];
        [previous mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(calendar.calendarHeaderView).offset(3.5);
            make.left.equalTo(@35);
        }];
        
        UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
        [next setImage:[UIImage imageNamed:@"calendar_arrow_right_22x22"] forState:UIControlStateNormal];
        [next addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:next];
        [next mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(calendar.calendarHeaderView).offset(3.5);
            make.right.equalTo(@-35);
        }];

//        calendar.calendarHeaderView.scrollEnabled = NO;
        self.calendar = calendar;
    }
    return self;
}

- (void)setSelectDate:(NSDate *)selectDate {
    _selectDate = selectDate;
    [_calendar selectDate:selectDate];
}

//上一月按钮点击事件
- (void)previousClicked:(id)sender {
    
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [currentMonth dateBySubtractingMonths:1];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

//下一月按钮点击事件
- (void)nextClicked:(id)sender {
    
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [currentMonth dateByAddingMonths:1];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}


- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    _selectDate = date;
    NSLog(@"选择了%@", date);
}

@end
