//
//  GPSNaviViewController.m
//  AMapNaviKit
//
//  Created by liubo on 7/29/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "GPSNaviViewController.h"
#import "SOSGPSRoutePlanViewController.h"
#import "FootPrintDataOBJ.h"
@interface GPSNaviViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate>


@property (nonatomic, strong) AMapNaviDriveView *driveView;
@property (nonatomic, strong) NSDate *gpsBeginDate;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *demoFuncBGView;

@property (nonatomic, strong) NSNumber *isRaning;
@property (nonatomic, assign) AMapNaviBroadcastMode broadCastMode;

@end

@implementation GPSNaviViewController

#pragma mark - Life Cycle


- (instancetype)initWithStartPoint:(id)startPoint endPoint:(id)endPoint drivingStrategy:(NSInteger)drivingStrategy    {
    self = [super init];
    if (self) {
        self.startPoint = startPoint;
        self.endPoint = endPoint;
        self.drivingStrategy = drivingStrategy;
            SOSPOI * opPoi = [SOSPOI mj_objectWithKeyValues:endPoint];
            NSDictionary * ftDic = @{@"poiId":NONil(opPoi.pguid),@"printTime":[Util SOS_stringDate],@"longitude":opPoi.longitude,@"latitude":opPoi.latitude,@"poiName":NONil(opPoi.name),@"poiAddress":NONil(opPoi.address),@"source":@"AMAP"};
            [FootPrintDataOBJ uploadFootPrintByDic:ftDic];
    }
    return self;
}

- (void)viewDidLoad    {
    [super viewDidLoad];
        
    [self initDriveView];
    [self initDriveManager];
}

- (void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:animated];
    
    self.fd_prefersNavigationBarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated	{
    [super viewDidAppear:animated];
    [self calculateRoute];
}

- (BOOL)prefersStatusBarHidden    {
    return YES;
}

- (void)dealloc    {
    [[AMapNaviDriveManager sharedInstance] stopNavi];
    [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self.driveView];
    [[AMapNaviDriveManager sharedInstance] setDelegate:nil];
    
    BOOL success = [AMapNaviDriveManager destroyInstance];
    NSLog(@"单例是否销毁成功 : %d",success);
    
    [self.driveView removeFromSuperview];
    self.driveView.delegate = nil;
}

#pragma mark - Initalization

- (void)initDriveManager    {
    //请在 dealloc 函数中执行 [AMapNaviDriveManager destroyInstance] 来销毁单例
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];
    
    [[AMapNaviDriveManager sharedInstance] setAllowsBackgroundLocationUpdates:YES];
    [[AMapNaviDriveManager sharedInstance] setPausesLocationUpdatesAutomatically:NO];
    [[AMapNaviDriveManager sharedInstance] setIsUseInternalTTS:YES];
    //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self.driveView];
}

- (void)initDriveView    {
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:self.containerView.bounds];
        self.driveView.showMoreButton = NO;
        self.driveView.showCompass = YES;
        self.driveView.delegate = self;
        
        [self.containerView addSubview:self.driveView];
        __weak __typeof(self) weakSelf = self;
        [self.driveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.containerView);
        }];
    }
}

#pragma mark - Route Plan

- (void)calculateRoute    {
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:[self.startPoint.latitude doubleValue] longitude:[self.startPoint.longitude doubleValue]];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:[self.endPoint.latitude doubleValue] longitude:[self.endPoint.longitude doubleValue]];
    //进行路径规划
    [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithStartPoints:@[startPoint]
                                                endPoints:@[endPoint]
                                                wayPoints:nil
                                          drivingStrategy:self.drivingStrategy];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error    {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager    {
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后开始GPS导航
    [[AMapNaviDriveManager sharedInstance] startGPSNavi];
    self.gpsBeginDate = [NSDate date];
}

/**
 * @brief 模拟导航到达目的地后的回调函数
 * @param driveManager 驾车导航管理类
 */
- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager    {
    
}

/**
 * @brief GPS导航到达目的地后的回调函数
 * @param driveManager 驾车导航管理类
 */
- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager    {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"到达目的地");
        SOSGPSRoutePlanViewController *vc = [SOSGPSRoutePlanViewController new];
        vc.naviRoute = driveManager.naviRoute;
        vc.gpsBeginDate = self.gpsBeginDate;
        vc.beginPoi = self.startPoint;
        vc.endPoi = self.endPoint;
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
    });
    
}


#pragma mark - AMapNaviWalkViewDelegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView    {
    //停止导航
    [[AMapNaviDriveManager sharedInstance] stopNavi];
    [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self.driveView];
    [self navAction];
}

- (void)navAction {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * @brief 导航界面更多按钮点击时的回调函数
 * @param driveView 驾车导航界面
 */
//- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView {
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        SOSGPSRoutePlanViewController *vc = [SOSGPSRoutePlanViewController new];
//        vc.naviRoute = [AMapNaviDriveManager sharedInstance].naviRoute;
//        vc.gpsBeginDate = self.gpsBeginDate;
//        vc.beginPoi = self.startPoint;
//        vc.endPoi = self.endPoint;
//        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
//
//    });
//}


/*
#pragma mark - Demo Func

- (IBAction)zoom:(UIButton *)sender {
    if (sender.tag == 101) 			self.driveView.mapZoomLevel = self.driveView.mapZoomLevel + 1;
    else if (sender.tag == 102)		self.driveView.mapZoomLevel = self.driveView.mapZoomLevel - 1;
}

- (IBAction)showTraffic:(UIButton *)sender {
    self.driveView.mapShowTraffic = !self.driveView.mapShowTraffic;
}

- (IBAction)switchDayAndNight:(UIButton *)sender {
    self.driveView.mapViewModeType = (self.driveView.mapViewModeType == AMapNaviViewMapModeTypeDay);
}

- (IBAction)changeTrackingMode {
    self.driveView.trackingMode = self.driveView.trackingMode == AMapNaviViewTrackingModeMapNorth;
}

- (IBAction)showMode:(id)sender {
    self.driveView.showMode = (self.driveView.showMode + 1) % 3;
}

- (IBAction)speak:(id)sender {
    [[AMapNaviDriveManager sharedInstance] readNaviInfoManual];
}

- (IBAction)startAndPause {
    if (self.isRaning.boolValue == NO) {
        [[AMapNaviDriveManager sharedInstance] setEmulatorNaviSpeed:100];
        if (self.isRaning == nil) 	self.isRaning = @([[AMapNaviDriveManager sharedInstance] startEmulatorNavi]);
        else	{
            [[AMapNaviDriveManager sharedInstance] resumeNavi];
            self.isRaning = @(YES);
        }
        [Util toastWithMessage:@"Emulator Navi Start"];
    }	else	{
        [[AMapNaviDriveManager sharedInstance] pauseNavi];
        self.isRaning = @(NO);
        [Util toastWithMessage:@"Emulator Navi Pause"];
    }
}

- (IBAction)getCurrentInfo {
    AMapNaviRoute *route = [AMapNaviDriveManager sharedInstance].naviRoute;
    
    NSLog(@"%@", route);
    
}

- (IBAction)stop {
    [[AMapNaviDriveManager sharedInstance] stopNavi];
    self.isRaning = nil;
    [Util toastWithMessage:@"Emulator Navi Stop"];
}

- (IBAction)switchBroadCastMode {
    if (self.broadCastMode != AMapNaviBroadcastModeConcise)     {
        self.broadCastMode = AMapNaviBroadcastModeConcise;
        [Util toastWithMessage:@"已切换为 简洁播报"];
    }    else     {
        self.broadCastMode = AMapNaviBroadcastModeDetailed;
        [Util toastWithMessage:@"已切换为 详细播报"];
    }
    [[AMapNaviDriveManager sharedInstance] setBroadcastMode:self.broadCastMode];
}

- (IBAction)mute {
    [AMapNaviDriveManager sharedInstance].isUseInternalTTS = ![AMapNaviDriveManager sharedInstance].isUseInternalTTS;
    
    [Util toastWithMessage:[AMapNaviDriveManager sharedInstance].isUseInternalTTS ? @"静音模式已关闭" : @"静音模式已打开"];
}
*/
@end

