//
//  SOSGPSRoutePlanViewController.m
//  Onstar
//
//  Created by onstar on 2018/4/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSGPSRoutePlanViewController.h"
#import "SOSGPSNavPointInfoView.h"
#import "BaseMapView.h"
#import "UIView+iOS11.h"

@interface SOSGPSRoutePlanViewController ()
@property (nonatomic, strong) BaseMapView *mapView;

@end

@implementation SOSGPSRoutePlanViewController
{
    SOSGPSNavPointInfoView *bottomView ;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"导航结束";
    [self initMapView];
    [self initBottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showNaviRoutesWithNaviRoute:self.naviRoute];
    [self showAnnotationsWithNaviRoute:self.naviRoute];
}

- (void)viewWillLayoutSubviews {
    [bottomView mas_updateConstraints:^(MASConstraintMaker *make){
        make.height.mas_equalTo(80 + self.view.sos_safeAreaInsets.bottom);
    }];
    
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[BaseMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height)];
        [self.view addSubview:self.mapView];
    }
}

- (void)initBottomView {
    NSString *dateFormat = @"HH:mm";
    if (!self.gpsBeginDate.isToday) {
        dateFormat = @"YYYY/MM/dd HH:mm";
    }
    bottomView = [SOSGPSNavPointInfoView viewFromXib];
    bottomView.startTimeLabel.text = [self.gpsBeginDate stringWithFormat:dateFormat];
    bottomView.endTimeLabel.text = [[NSDate date] stringWithFormat:dateFormat];
    bottomView.startLocationLabel.text = self.beginPoi.address;
    bottomView.endLocationLabel.text = self.endPoi.address;

    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}


- (void)showAnnotationsWithNaviRoute:(AMapNaviRoute *)aRoute
{
    SOSPOI *beginPoi = [[SOSPOI alloc] init];
    beginPoi.latitude = [NSString stringWithFormat:@"%f",aRoute.routeStartPoint.latitude];
    beginPoi.longitude = [NSString stringWithFormat:@"%f",aRoute.routeStartPoint.longitude];
    beginPoi.sosPoiType = POI_TYPE_ROUTE_BEGIN;
    SOSPOI *endPoi = [[SOSPOI alloc] init];
    endPoi.latitude = [NSString stringWithFormat:@"%f",aRoute.routeEndPoint.latitude];
    endPoi.longitude = [NSString stringWithFormat:@"%f",aRoute.routeEndPoint.longitude];
    endPoi.sosPoiType = POI_TYPE_ROUTE_END;
//    [self.mapView showPoiPoints: animated:NO];
    [self.mapView addPoiPoints:@[beginPoi, endPoi]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNaviRoutesWithNaviRoute:(AMapNaviRoute *)aRoute
{
    if (!aRoute) {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    //将路径显示到地图上
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    free(coords);
    [self.mapView addOverlay:polyline];
    [self.mapView showPolylines:@[polyline]];
  
}


@end
