//
//  SOSGPSWalkNaviViewController.m
//  Onstar
//
//  Created by onstar on 2018/4/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSGPSWalkNaviViewController.h"
#import "SOSMapHeader.h"
#import "SOSGPSRoutePlanViewController.h"

@interface SOSGPSWalkNaviViewController ()<AMapNaviWalkManagerDelegate,AMapNaviWalkViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) AMapNaviWalkManager *walkManager;
@property (nonatomic, strong) SOSPOI *startPoint;
@property (nonatomic, strong) SOSPOI *endPoint;
@property (nonatomic, strong) AMapNaviWalkView *driveView;
@property (nonatomic, strong) NSDate *gpsBeginDate;
@end

@implementation SOSGPSWalkNaviViewController

#pragma mark - Life Cycle

- (instancetype)initWithStartPoint:(id)startPoint endPoint:(id)endPoint drivingStrategy:(NSInteger)drivingStrategy
{
    self = [super init];
    if (self) {
        self.startPoint = startPoint;
        self.endPoint = endPoint;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initDriveView];
    
    [self initWalkManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self calculateRoute];
}

- (void)viewWillLayoutSubviews
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        interfaceOrientation = self.interfaceOrientation;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Initalization

- (void)initWalkManager
{
    if (self.walkManager == nil)
    {
        self.walkManager = [AMapNaviWalkManager sharedInstance];
        [self.walkManager setDelegate:self];
        [self.walkManager setAllowsBackgroundLocationUpdates:YES];
        [self.walkManager setPausesLocationUpdatesAutomatically:NO];
        [self.walkManager setIsUseInternalTTS:YES];
        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.walkManager addDataRepresentative:self.driveView];
    }
}



- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviWalkView alloc] initWithFrame:self.contentView.bounds];
        [self.driveView setShowMoreButton:NO];
        [self.driveView setShowCompass:YES];
        self.driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.driveView setDelegate:self];
        
        [self.contentView addSubview:self.driveView];
        __weak __typeof(self) weakSelf = self;
        [self.driveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.contentView);
        }];
    }
}

#pragma mark - Route Plan

- (void)calculateRoute
{
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:[self.startPoint.latitude doubleValue] longitude:[self.startPoint.longitude doubleValue]];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:[self.endPoint.latitude doubleValue] longitude:[self.endPoint.longitude doubleValue]];
    [self.walkManager calculateWalkRouteWithStartPoints:@[startPoint]
                                              endPoints:@[endPoint]];
}

#pragma mark - AMapNaviDriveManager Delegate
- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    //显示路径或开启导航
    [self.walkManager startGPSNavi];
    self.gpsBeginDate = [NSDate date];
}


/**
 * @brief 导航到达目的地后的回调函数
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerOnArrivedDestination:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"AMapNaviWalkManager 导航结束");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SOSGPSRoutePlanViewController *vc = [SOSGPSRoutePlanViewController new];
        vc.naviRoute = walkManager.naviRoute;
        vc.gpsBeginDate = self.gpsBeginDate;
        vc.beginPoi = self.startPoint;
        vc.endPoi = self.endPoint;
        [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
    });
}



- (void)walkViewCloseButtonClicked:(AMapNaviWalkView *)walkView{
    //停止导航
    [self.walkManager stopNavi];
    [self.navigationController popViewControllerAnimated:YES];
}

///**
// * @brief 导航界面更多按钮点击时的回调函数
// * @param walkView 步行导航界面
// */
//- (void)walkViewMoreButtonClicked:(AMapNaviWalkView *)walkView {
//    SOSGPSRoutePlanViewController *vc = [SOSGPSRoutePlanViewController new];
//    vc.naviRoute = self.walkManager.naviRoute;
//    [self.navigationController pushViewController:vc wantToRemoveViewController:self animated:YES];
//}


@end
