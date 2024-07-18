//
//  SOSLBSHistoryVC.m
//  Onstar
//
//  Created by Coir on 24/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSDateSlider.h"
#import "SOSLBSHistoryVC.h"
#import "PDTSimpleCalendar.h"
#import "SOSLBSHistoryMapVC.h"

@interface SOSLBSHistoryVC ()	<PDTSimpleCalendarViewDelegate, SOSDateSliderDelegate>

@property (weak, nonatomic) IBOutlet UIView *calenderBGView;
@property (weak, nonatomic) IBOutlet UIView *bottomBGView;
@property (weak, nonatomic) IBOutlet UIView *timeSelectBGView;
@property (weak, nonatomic) IBOutlet UIView *dateSliderBGView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (strong, nonatomic) PDTSimpleCalendarViewController *calendarVC;
@property (strong, nonatomic) SOSDateSlider *dateSlider;

@property (assign, nonatomic) SOSLBSHistoryTimeEditType operationType;
//@property (strong, nonatomic) NSMutableArray <SOSLBSHistoryChildVC *> *childVCArray;


@end

@implementation SOSLBSHistoryVC

- (void)viewDidLoad     {
    [super viewDidLoad];
    [self configSelf];
}

- (void)configSelf    {
    self.title = @"选择时间";
    [self configCalenderView];
}

- (void)configCalenderView	{
    self.calendarVC = [[PDTSimpleCalendarViewController alloc] init];
    self.calendarVC.delegate = self;
    self.calendarVC.firstDate = [NSDate dateWithString:@"2017-01-01" format:@"YYYY-MM-DD"];
    self.calendarVC.lastDate = [NSDate dateWithTimeIntervalSinceNow:20 * 24 * 2600];
    self.calendarVC.weekdayHeaderEnabled = YES;
    self.calendarVC.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
    
    [self addChildViewController:self.calendarVC];
    [self.calenderBGView addSubview:self.calendarVC.view];
    __weak __typeof(self) weakSelf = self;
    [self.calendarVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.calenderBGView);
    }];
    
    self.dateSlider = [SOSDateSlider viewFromXib];
    [self.dateSliderBGView addSubview:self.dateSlider];
    [self.dateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.dateSliderBGView);
    }];
    self.dateSlider.minValue = 0.f;
    self.dateSlider.maxValue = 60 * 60 * 24;
    self.dateSlider.delegate = self;
}

#pragma mark - Slider Delegate
- (void)sliderValueChanged:(SOSDateSlider *)slider	{
    int startHour = (slider.startValue / 3600);
    int startMin = ((int)slider.startValue % 3600) / 60;
    NSString *startTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)startHour, (long)startMin];
    int endHour = (slider.endtValue / 3600);
    int endMin = ((int)slider.endtValue % 3600) / 60;
    NSString *endTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)endHour, (long)endMin];
    self.startTimeLabel.text = startTime;
    self.endTimeLabel.text = endTime;
}


#pragma mark - Calendar Delegate
- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date	{
    if ([date isToday]) {
        self.dateSlider.maxValue = [NSDate date].hour * 3600 + [NSDate date].minute * 60 + [NSDate date].second;
        [self.dateSlider reset];
    }	else	{
        self.dateSlider.maxValue = 60 * 60 * 24;
        [self.dateSlider reset];
    }
}

- (BOOL)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller shouldUseCustomColorsForDate:(NSDate *)date	{
    return NO;
}

- (IBAction)searchButtonTapped {
    [SOSDaapManager sendActionInfo:LBS_deviceinfo_history_customTab_search];

    NSString *selectedDay = [[SOSDateFormatter sharedInstance] style1_stringFromDate:self.calendarVC.selectedDate];
    NSString *startTime = [selectedDay stringByAppendingFormat:@" %@:00", self.startTimeLabel.text];
    NSString *endTime = [selectedDay stringByAppendingFormat:@" %@:00", self.endTimeLabel.text];
    
    [[LoadingView sharedInstance] startIn:self.view];
    // startTime/endTime 格式 yyyy-MM-dd HH:mm:ss
    [SOSLBSDataTool getHistoryDeviceLocationWithLBSTrackingID:self.LBSDataInfo.deviceid StartTime:startTime AndEndTime:endTime Success:^(NSArray<NNLBSLocationPOI *> *deviceLocationArray) {
        [[LoadingView sharedInstance] stop];
        if (deviceLocationArray.count) {
            dispatch_async_on_main_queue(^{
                SOSLBSHistoryMapVC *mapVC = [[SOSLBSHistoryMapVC alloc] initWithPoiArray:deviceLocationArray];
                [mapVC setUpWithDate:selectedDay StartTime:self.startTimeLabel.text AndEndTime:self.endTimeLabel.text];
                mapVC.LBSDataInfo = self.LBSDataInfo;
                [self.navigationController pushViewController:mapVC animated:YES];
            });
        }    else    [Util toastWithMessage:@"暂无相应轨迹信息"];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [[LoadingView sharedInstance] stop];
        [Util toastWithMessage:responseStr];
    }];
}

@end

