//
//  SOSRouteTool.m
//  Onstar
//
//  Created by Coir on 31/01/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"
#import "SOSRouteTool.h"
#import "BaseSearchOBJ.h"
#import "SOSTripRouteVC.h"
#import "SOSCustomAlertView.h"
#import "SOSFlexibleAlertController.h"

@implementation SOSRouteInfo
+ (instancetype)initWithLength:(NSInteger)length Time:(NSInteger)time		{
    SOSRouteInfo *routeInfo = [SOSRouteInfo new];
    routeInfo.routeLength = length;
    routeInfo.routeTime = time;
    return routeInfo;
}
@end


typedef void (^SOSRouteSuccessBlock)(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes);
typedef void (^SOSRouteFailureBlock)(NSString *code);

@interface SOSRouteTool	()	<RouteDelegate, ErrorDelegate>

@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;
@property (nonatomic, copy) SOSRouteSuccessBlock successBlock;
@property (nonatomic, copy) SOSRouteFailureBlock failureBlock;
@property (nonatomic, strong) SOSPOI *beginPoi;
@property (nonatomic, strong) SOSPOI *destinationPoi;
@property (nonatomic, assign) DriveStrategy lastOpStrategy;
@property (nonatomic, assign) BOOL needAlert;

@end

@implementation SOSRouteTool

+ (void)changeRoutePOIDoneFromVC:(UIViewController *)fromVC WithType:(SelectPointOperation)type ResultPOI:(SOSPOI *)poi		{
    SOSTripRouteVC *vc = (SOSTripRouteVC *)fromVC.navigationController.presentingViewController;
    if (vc && [vc isKindOfClass:[SOSTripRouteVC class]]) {
        if (type == OperationType_set_Route_Begin_POI)    {
            [vc routePOIChangedWithBeginPOI:poi AndEndPOI:nil];
        }    else    {
            [vc routePOIChangedWithBeginPOI:nil AndEndPOI:poi];
        }
    }
    [fromVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchWithBeginPOI:(SOSPOI *)beginPOI AndDestinationPoi:(SOSPOI *)destinationPoi WithStrategy:(DriveStrategy)strategy Success:(void(^)(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes))success failure:(void (^)(NSString *))failure		{
    [self searchWithBeginPOI:beginPOI AndDestinationPoi:destinationPoi WithStrategy:strategy NeedAlertError:YES Success:success failure:false];
}

- (void)searchWithBeginPOI:(SOSPOI *)beginPOI AndDestinationPoi:(SOSPOI *)destinationPoi WithStrategy:(DriveStrategy)strategy NeedAlertError:(BOOL)needAlert Success:(void(^)(SOSRouteSearchResultType resultType, SOSRouteInfo *routeInfo, NSArray *polylines, NSArray *routes))success failure:(void (^)(NSString *))failure	{
    if (!_searchOBJ) {
        _searchOBJ = [[BaseSearchOBJ alloc] init];
        _searchOBJ.routeDelegate = self;
        _searchOBJ.errorDelegate = self;
    }
    self.beginPoi = beginPOI;
    self.destinationPoi = destinationPoi;
    self.needAlert = needAlert;
    AMapGeoPoint *beginPoint = [AMapGeoPoint locationWithLatitude:beginPOI.latitude.floatValue longitude:beginPOI.longitude.floatValue];
    AMapGeoPoint *destinationPoint = [AMapGeoPoint locationWithLatitude:destinationPoi.latitude.floatValue longitude:destinationPoi.longitude.floatValue];
    
    self.lastOpStrategy = strategy;
    [_searchOBJ routeSearchWithStrategy:strategy Origin:beginPoint Destination:destinationPoint];
    if (success)    self.successBlock = success;
    if (failure)	self.failureBlock = failure;
}

- (void)routePolylines:(NSArray *)polylines RouteInfos:(SOSMapPath *)mapPath    {
    [[LoadingView sharedInstance] stop];
    SOSRouteInfo *routeInfo = [SOSRouteTool getRouteInfoWithRoutes:mapPath];
    routeInfo.strategy = self.lastOpStrategy;
    if (self.lastOpStrategy == DriveStrategyWalk) {
        if (self.needAlert == NO) {
            if (self.successBlock) self.successBlock(SOSRouteSearchResultType_Walk_Normal, routeInfo, polylines, mapPath.steps);
            return;
        }
        //进入步行导航模式
        if (routeInfo.routeLength < 20) {
            //距车小于 20M ,规划失败
            [Util showAlertWithTitle:@"步行规划失败" message:@"您距离车辆位置较近,无需步行规划,您可以使用闪灯鸣笛功能确认车辆位置." completeBlock:^(NSInteger buttonIndex) {
                [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_shortdistancefail_iknow];
                if (self.failureBlock) self.failureBlock(nil);
            } cancleButtonTitle:nil otherButtonTitles:@"知道了", nil];
        }	else if (routeInfo.routeLength > 2000)	{
            //距车大于 2000M ,提示用户是否继续步行
            [Util showAlertWithTitle:@"超出最佳步行距离" message:@"您距离车辆位置较远,推荐您使用驾车线路规划,您是否使用驾车线路规划?" completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //步行规划
                    [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_longdistancealert_bywalk];
                    if (self.successBlock) self.successBlock(SOSRouteSearchResultType_Walk_Normal, routeInfo, polylines, mapPath.steps);
                }    else if (buttonIndex == 1)    {
                    //驾车规划
                    [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_longdistancealert_bydriving];
                    [Util showLoadingView];
                    [self searchWithBeginPOI:self.beginPoi AndDestinationPoi:self.destinationPoi WithStrategy:DriveStrategyTimeFirst Success:self.successBlock failure:self.failureBlock];
                }
            } cancleButtonTitle:@"步行规划" otherButtonTitles:@"驾车规划", nil];
        }    else if (20 <= routeInfo.routeLength && routeInfo.routeLength <= 2000)        {
            //距车距离正常,显示步行路线
            if (self.successBlock) self.successBlock(SOSRouteSearchResultType_Walk_Normal, routeInfo, polylines, mapPath.steps);
        }
    }	else	{
        //正常驾车路径规划
        if (self.successBlock) self.successBlock(SOSRouteSearchResultType_Drive_Normal, routeInfo, polylines, mapPath.steps);
    }
}

+ (SOSRouteInfo *)getRouteInfoWithRoutes:(SOSMapPath *)mapPath		{
    NSInteger totalLength = mapPath.distance;
    long driveTime = mapPath.duration / 60 ? : 1;
    return [SOSRouteInfo initWithLength:totalLength Time:driveTime];
}

- (void)baseSearch:(id)searchOption Error:(NSString*)errCode     {
    [[LoadingView sharedInstance] stop];
//    if (![searchOption isKindOfClass:[AMapWalkingRouteSearchRequest class]]) {
//        [Util toastWithMessage:errCode];
//    }
    if (self.failureBlock) 	self.failureBlock(errCode);
}

- (void)handleWalkingRouteError:(NSString *)errCode	{
    if ([errCode isEqualToString:@"无法步行到达"]) {
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"无法步行到达" message:@"无法计算步行路径,\n是否切换驾车路线?" customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"取消" style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_nowalkpathfail_cancel];
        }];
        SOSAlertAction *driveAction = [SOSAlertAction actionWithTitle:@"驾车规划" style:SOSAlertActionStyleActionSheetDefault handler:^(SOSAlertAction * _Nonnull action) {
            //驾车规划
            [Util showLoadingView];
            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_nowalkpathfail_bydriving];
            [self searchWithBeginPOI:self.beginPoi AndDestinationPoi:self.destinationPoi WithStrategy:DriveStrategyTimeFirst Success:self.successBlock failure:self.failureBlock];
        }];
        [vc addActions:@[cancelAction, driveAction]];
        [vc show];
    }    else    {
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:nil title:@"步行规划失败" message:@"您当前的GPS信号弱,请步行至开阔地带,再尝试步行规划功能" customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:^(SOSAlertAction * _Nonnull action) {

            [SOSDaapManager sendActionInfo:Map_carlocation_lastmilnavigation_GPSfail_iknow];
        }];
        [vc addActions:@[cancelAction]];
        [vc show];
    }
}

@end
