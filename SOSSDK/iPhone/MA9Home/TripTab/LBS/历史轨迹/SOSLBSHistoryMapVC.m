//
//  SOSLBSHistoryMapVC.m
//  Onstar
//
//  Created by Coir on 28/11/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSHistoryMapVC.h"
#import "SOSLBSHistoryInfoBGView.h"

#define	 KLBSMapAnimationKey 	@"KLBSMapAnimationKey"
#define  KLBSFreamUnit			(1.f / 50.f)

@interface SOSLBSHistoryMapVC ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBGViewTopGuide;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderBGViewBottomGuide;
@property (strong, nonatomic) NSMutableArray <SOSPOI *> * poiArray;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
/// LBS 轨迹线(结构体数组)
@property (strong, nonatomic) MAPolyline *polyLine;
/// LBS 坐标点数组(结构体数组)
@property (assign, nonatomic) CLLocationCoordinate2D *coorPoints;
/// LBS 用户位置 (用于动画播放过程中标识用户位置)
@property (strong, nonatomic) SOSLBSHistoryInfoBGView *historyInfoView;

@property (strong, nonatomic) NSMutableArray <NNLBSLocationPOI *> *historyInfoArray;

@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) float playStatus;
@property (assign, nonatomic) int playingIndex;

@property (nonatomic, strong) dispatch_source_t frameRefreshTimer;

@property (assign, nonatomic) float originZoom;
@property (assign, nonatomic) CLLocationCoordinate2D originCenter;
@end

@implementation SOSLBSHistoryMapVC

- (id)initWithPoiArray:(NSArray <NNLBSLocationPOI *> *)poi_Array		{
    self = [self initWithNibName:[self className] bundle:[NSBundle SOSBundle]];
    if (self) {
        self.mapType = MapTypeLBSHistoryLocation;
        self.historyInfoArray = [NSMutableArray arrayWithArray:poi_Array];
    }
    return self;
}

- (void)viewWillLayoutSubviews	{
    [super viewWillLayoutSubviews];
    _sliderBGViewBottomGuide.constant = self.view.sos_safeAreaInsets.bottom;
}

/// 获取当前需要在地图上显示的 POI 点
- (NSArray *)poisShowingOnMap    {
    return self.poiArray;
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
//    self.fd_interactivePopDisabled = YES;
    self.navBGViewTopGuide.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.backRecordFunctionID = LBS_deviceinfo_history_searchresult_back;
    
    NSArray *poi_Array = self.historyInfoArray;
    self.poiArray = [NSMutableArray array];
    self.historyInfoArray = [NSMutableArray array];
    SOSPOI *flagPOI;
    if (poi_Array.count)    {
        for (int i = 0; i < poi_Array.count; i++) {
            NNLBSLocationPOI *lbsPOI = poi_Array[i];
            SOSPOI *tempPOI = [SOSPOI new];
            tempPOI.sosPoiType = POI_TYPE_LBS_History;
            tempPOI.longitude = lbsPOI.lng;
            tempPOI.latitude = lbsPOI.lat;
            if (flagPOI && [tempPOI isEqualToPOI:flagPOI]) {
            }    else    {
                flagPOI = tempPOI;
                [self.poiArray addObject:flagPOI];
                lbsPOI.imei = self.LBSDataInfo.deviceid;
                [self.historyInfoArray addObject:lbsPOI];
            }
        }
    }
    
    if (!self.poiArray.count)         return;
    
    self.playingIndex = 0;
    self.playStatus = 0.f;
    self.historyInfoView = [[NSBundle SOSBundle] loadNibNamed:@"SOSLBSHistoryInfoBGView" owner:self options:nil][0];
    self.historyInfoView.frame = CGRectMake(0, 0, 167, 110);
    self.historyInfoView.hidden = YES;
    self.historyInfoView.historyPOI = self.historyInfoArray[0];
    [self.view addSubview:self.historyInfoView];
    
    self.coorPoints = malloc(sizeof(CLLocationCoordinate2D) * self.poiArray.count * 2);
    for (int i = 0; i < self.poiArray.count; i++) {
        SOSPOI *poi = self.poiArray[i];
        CLLocationCoordinate2D tempMapPoint = CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue);
        self.coorPoints[i] = tempMapPoint;
    }
    self.polyLine = [MAPolyline polylineWithCoordinates:self.coorPoints count:self.poiArray.count];
    [self.mapView addOverlay:self.polyLine];
    [self.mapView addPoiPoints:self.poisShowingOnMap];
}

- (void)setUpWithDate:(NSString *)dateStr StartTime:(NSString *)startTime AndEndTime:(NSString *)endTime	{
    [self viewDidLoad];
    self.currentDateLabel.text = dateStr;
    self.startTimeLabel.text = startTime;
    self.endTimeLabel.text = endTime;
}

- (void)viewWillAppear:(BOOL)animated	{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.LBSDataInfo.devicename;
}

- (void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];
    [self.mapView showPoiPoints:self.poisShowingOnMap animated:NO];
    self.originZoom = self.mapView.zoomLevel;
    self.originCenter = self.mapView.centerCoordinate;
    [self sliderValueChanged:self.valueSlider];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    if (self.poiArray.count < 2)    return;
    if (self.originCenter.latitude != self.mapView.centerCoordinate.latitude || self.originCenter.longitude != self.mapView.centerCoordinate.longitude || self.originZoom != self.mapView.zoomLevel) {
        [self.mapView showPoiPoints:self.poiArray animated:NO];
    }
    if (self.frameRefreshTimer && self.playButton.selected == YES)     {
        self.playButton.selected = NO;
        dispatch_suspend(self.frameRefreshTimer);
    }
    self.isAnimating = NO;
    self.historyInfoView.hidden = NO;
    self.playingIndex = (self.poiArray.count - 1) * slider.value / 1;
    self.playStatus = ((self.poiArray.count - 1) * slider.value) - self.playingIndex;
    self.historyInfoView.historyPOI = self.historyInfoArray[_playingIndex];
    [self reBuildFrameAnimation];
}

- (void)setUpTimer 	{
    if (self.poiArray.count == 1)		return;
    __weak __typeof(self) weakSelf = self;
    if (self.frameRefreshTimer)     dispatch_cancel(self.frameRefreshTimer);
    self.frameRefreshTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue() );
    dispatch_source_set_timer(self.frameRefreshTimer, dispatch_walltime(NULL, 0), KLBSFreamUnit * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(weakSelf.frameRefreshTimer, ^{
        [weakSelf reBuildFrameAnimation];
    });
    dispatch_resume(self.frameRefreshTimer);
}

- (IBAction)playButtonTapped 	{
    if (self.poiArray.count == 1)        return;
    NSString *funID = nil;
    // 初始状态,开始播放
    if (self.playingIndex == 0 && self.playStatus == 0) {
        funID = LBS_deviceinfo_history_searchresult_play;
        self.playButton.selected = YES;
        self.historyInfoView.hidden = NO;
        [self setUpTimer];
        self.isAnimating = YES;
        if (self.poiArray.count > 3) {
            [self.mapView showPoiPoints:@[self.poiArray[0], self.poiArray[1], self.poiArray[2]] animated:NO];
        }    else    {
            [self.mapView showPoiPoints:self.poiArray animated:NO];
        }
        
    }	else	{
        // 播放状态,暂停播放
        if (self.playButton.isSelected == YES)     {
            funID = LBS_deviceinfo_history_searchresult_stop;
            self.isAnimating = NO;
            self.playButton.selected = NO;
            if (self.frameRefreshTimer)     dispatch_suspend(self.frameRefreshTimer);
        //暂停状态,恢复播放
        }    else if (self.playButton.isSelected == NO)   {
            funID = LBS_deviceinfo_history_searchresult_play;
            // 已播放完毕,重置进度
            if (self.valueSlider.value >= 1) {
                self.playingIndex = 0;
                self.playStatus = 0.f;
                // 地图显示切换到前几个点
                if (self.poiArray.count == 2) {
                    [self.mapView showPoiPoints:@[self.poiArray[0], self.poiArray[1]] animated:NO];
                }    else    {
                    [self.mapView showPoiPoints:@[self.poiArray[0], self.poiArray[1], self.poiArray[2]] animated:NO];
                }
            }
            self.isAnimating = YES;
            self.playButton.selected = YES;
            self.historyInfoView.hidden = NO;
            if (self.frameRefreshTimer)     dispatch_resume(self.frameRefreshTimer);
            else                            [self setUpTimer];
        }
    }
    [SOSDaapManager sendActionInfo:funID];
}

- (void)reBuildFrameAnimation	{
    NSArray <NNGpsLocationCoordinate *> *locationPointArray = [self pointsForCoordinates:self.coorPoints count:self.poiArray.count];
    if (locationPointArray.count < 2 || (_playingIndex && (locationPointArray.count <= (_playingIndex + 1) ) ) )		{
        if (self.isAnimating) {
            // 播放完毕
            self.playButton.selected = NO;
            if (self.frameRefreshTimer)     {
                dispatch_suspend(self.frameRefreshTimer);
            }
            self.historyInfoView.hidden = YES;
            self.isAnimating = NO;
        }
        return;
    };
    
    NNGpsLocationCoordinate *locationPoint = locationPointArray[_playingIndex];
    NNGpsLocationCoordinate *nextPoint = locationPointArray[_playingIndex + 1];
    
    double targetLon = locationPoint.longitude.doubleValue + (nextPoint.longitude.doubleValue - locationPoint.longitude.doubleValue) * self.playStatus;
    double targetLat = locationPoint.latitude.doubleValue + (nextPoint.latitude.doubleValue - locationPoint.latitude.doubleValue) * self.playStatus;
    NNGpsLocationCoordinate *targetPoint = [NNGpsLocationCoordinate locationWithLatitude:targetLat Longitude:targetLon];
    
    if (self.isAnimating) 	{
        self.valueSlider.value = (self.playingIndex + self.playStatus) / (float)(self.poiArray.count - 1);
    }
    self.historyInfoView.frame = CGRectMake(targetPoint.longitude.doubleValue - _historyInfoView.width / 2,
                                                   targetPoint.latitude.doubleValue - _historyInfoView.height + 3,
                                                   _historyInfoView.width, _historyInfoView.height);
    if (_playStatus >= 1) {
        _playStatus = 0;
        _playingIndex ++;
        int mapIndex = (_playingIndex + 1) / 3;
        if (self.historyInfoArray.count < _playingIndex + 1)	return;
        self.historyInfoView.historyPOI = self.historyInfoArray[_playingIndex];
        self.historyInfoView.hidden = NO;
        if (mapIndex == 0) {
            if (locationPointArray.count == 2) {
                [self.mapView showPoiPoints:@[self.poiArray[0], self.poiArray[1]]];
            }	else	{
                [self.mapView showPoiPoints:@[self.poiArray[0], self.poiArray[1], self.poiArray[2]]];
            }
        } 	else if (self.poiArray.count > mapIndex * 3 + 2) {
            [self.mapView showPoiPoints:@[self.poiArray[(mapIndex * 3) - 1], self.poiArray[(mapIndex * 3)],
                                          self.poiArray[(mapIndex * 3) + 1], self.poiArray[(mapIndex * 3) + 2]] animated:NO];
        }    else    {
            [self.mapView showPoiPoints:@[self.poiArray[self.poiArray.count - 4], self.poiArray[self.poiArray.count - 3],
                                          self.poiArray[self.poiArray.count - 2], self.poiArray[self.poiArray.count - 1]] animated:NO];
        }
    }    else    {
        _playStatus = _playStatus + KLBSFreamUnit;
    }
}

/// 经纬度转屏幕坐标
- (NSArray <NNGpsLocationCoordinate *> *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count		{
    /* 申请屏幕坐标存储空间. */
    NSMutableArray *tempPointArray = [NSMutableArray array];
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)		{
        CGPoint point = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.view];
        NNGpsLocationCoordinate *locationPoint = [NNGpsLocationCoordinate locationWithLatitude:point.y Longitude:point.x];
        [tempPointArray addObject:locationPoint];
    }
    return tempPointArray;
}

#pragma mark - MapView Delegate
/// 用户点击地图 POI 点
- (void)mapDidSelectedPoiPoint:(SOSPOI *)poi    {
    // 不进行任何操作
}

- (void)mapWillMoveByUser:(BOOL)wasUserAction    {
    if (wasUserAction) {
        self.historyInfoView.hidden = YES;
    }
}

//- (void)mapDidMoveByUser:(BOOL)wasUserAction    {
//    if (wasUserAction) {
//    }
//}

- (void)mapWillZoomByUser:(BOOL)wasUserAction    {
    if (wasUserAction) {
        self.historyInfoView.hidden = YES;
    }
}

//- (void)mapDidZoomByUser:(BOOL)wasUserAction    {
//    if (wasUserAction && self.isAnimating) {
//    }
//}

- (void)dealloc		{
    NSLog(@"-----------------   LBS History VC dealloc");
    if (self.frameRefreshTimer)     {
        // 处于暂停状态的Timer必须先恢复才能销毁
        if (self.playButton.isSelected == NO) {
            dispatch_resume(self.frameRefreshTimer);
        }
        dispatch_cancel(self.frameRefreshTimer);
    }
}

@end
