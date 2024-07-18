//
//  SOSSocialService.m
//  Onstar
//
//  Created by onstar on 2019/4/22.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialService.h"
#import "SOSUserLocation.h"
#import "SOSSocialLocationViewController.h"

@interface SOSSocialService ()<GeoDelegate>

@property (nonatomic, strong) BaseSearchOBJ *searchOBJ;

@end

@implementation SOSSocialService
{
    dispatch_source_t statusTimer;
    dispatch_source_t locationTimer;
}


static SOSSocialService *serv = nil;
+ (instancetype)shareInstance     {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (serv == nil) {
            serv = [[self alloc] init];
        }
    });
    return serv;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchOBJ = [BaseSearchOBJ new];
        _searchOBJ.geoDelegate = self;
    }
    return self;
}

//轮询被接人是否接受状态   同意了在主页及waiting页面弹框
- (void)startObserverAcceptStatus {

    if (!statusTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0); // 全局子线程
        statusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(statusTimer, DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(statusTimer, ^{
            [self selectStatus];
        });
        
        // 启动timer
        dispatch_resume(statusTimer);
    }else {
        NSLog(@"timer 已存在")
    }
    
//    // 暂停timer
//    dispatch_suspend(timer);
//    // 取消timer
//    dispatch_source_cancel(timer);

}

//停止轮询
- (void)endObserverAcceptStatus{
    NSLog(@"endObserverAcceptStatus")
    if (statusTimer) {
        dispatch_source_cancel(statusTimer);
        statusTimer = nil;
    }
}


//上报地理位置
- (void)startUploadLocationService {
    [self startUploadLocationServiceWithPoi:nil];
}

- (void)startUploadLocationServiceWithPoi:(SOSPOI *)poi {
    if (!locationTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0); // 全局子线程
        locationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(locationTimer, DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(locationTimer, ^{
            [self uploadLocation];
        });
        
        // 启动timer
        dispatch_resume(locationTimer);
    }else {
        NSLog(@"timer 已存在")
    }
}


//停止上报地理位置
- (void)endUploadLocationService {
    NSLog(@"停止上报地理位置");
    if (locationTimer) {
        dispatch_source_cancel(locationTimer);
        locationTimer = nil;
    }
}

- (void)selectStatus {
    NSLog(@"selectStatus");
    [SOSSocialService selectOrderSuccess:^(SOSSocialOrderInfoResp * _Nonnull resp) {
        if ([resp.statusName isEqualToString:@"PASSENGERCONFIRM"]) {
            //弹框
            self.orderInfoResp = resp;
            UIViewController *topVc = [SOS_APP_DELEGATE fetchMainNavigationController].topViewController;
            if (topVc.navigationController.childViewControllers.count == 1 ||
                [topVc isKindOfClass:NSClassFromString(@"SOSSocialWaitingViewController")]) {
                //show alert
                [self showAcceptAlert];
            }
            [self endObserverAcceptStatus];
        }
    } Failed:^(NSString * _Nonnull responseStr, NSError * _Nonnull error) {

    }];
}

- (void)showAcceptAlert {
    if (self.showingAlert) {
        return;
    }
    self.showingAlert = YES;
    [Util showAlertWithTitle:@"我来接" message:@"好友发来了接送地！" completeBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSLog(@"查看");
            [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
            [Util showLoadingView];
            NSArray *locationAry = [self.orderInfoResp.destinationLocation componentsSeparatedByString:@","];
            NSString *longitude = locationAry.firstObject;
            NSString *latitude = locationAry.lastObject;
            [self.searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:latitude.floatValue longitude:longitude.floatValue]];
            [SOSDaapManager sendActionInfo:Pipup_Pop_detail];
        }else {
            [SOSDaapManager sendActionInfo:Pipup_Pop_ignore];
        }
        self.orderInfoResp = nil;
        self.showingAlert = NO;
    } cancleButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
}


- (void)uploadLocation {
    [self uploadLocationWithPoi:nil];
}

- (void)uploadLocationWithPoi:(SOSPOI *)poi {
    NSLog(@"uploadLocation");
    [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyNearestTenMeters NeedReGeocode:NO isForceRequest:YES NeedShowAuthorizeFailAlert:NO success:^(SOSPOI *currentPoi) {
        //定位成功
        if (poi && [self checkLocationWithCurrentPoi:poi desPoi:currentPoi]) {
            //对比距离<500米 车机完成页面 发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotificationCarGPSFinish object:nil];
        }
        
        //上报地理位置
        [SOSSocialService uploadLocationWithParams:@{@"currentLocation":[NSString stringWithFormat:@"%.6f,%.6f",currentPoi.longitude.doubleValue,currentPoi.latitude.doubleValue]} success:nil Failed:nil];
    } Failure:nil];
}


- (void)reverseGeocodingResults:(NSArray *)results  {
    [Util hideLoadView];
    if (results == nil || results.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util toastWithMessage:@"地图服务失败,请稍后再试"];
        });
        
        return;
    }
    dispatch_async_on_main_queue(^{
        SOSPOI *resultPOI = results[0];
        SOSSocialLocationViewController *vc = [[SOSSocialLocationViewController alloc] initWithPOI:resultPOI];
        vc.mapType = MapTypeShowPoiPoint;
        [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        
    });
}

- (BOOL)checkLocationWithCurrentPoi:(SOSPOI *)currentPoi desPoi:(SOSPOI *)desPoi {
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(currentPoi.latitude.doubleValue, currentPoi.longitude.doubleValue));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(desPoi.latitude.doubleValue, desPoi.longitude.doubleValue));
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1, point2);
    
    return distance < 500;
}


//api

//根据idpuserid创建订单
+ (void)createOrderSuccess:(void (^)(SOSSocialOrderShareInfoResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
     NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, SOSSocialCreateOrder];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSSocialOrderShareInfoResp *response = [SOSSocialOrderShareInfoResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(response);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

//根据idpuserid查询订单
+ (void)selectOrderSuccess:(void (^)(SOSSocialOrderInfoResp *urlRequest))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, SOSSocialSelectOrder];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        SOSSocialOrderInfoResp *response = [SOSSocialOrderInfoResp mj_objectWithKeyValues:dic];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion(response);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

//更新订单信息 上报地理位置
+ (void)uploadLocationWithParams:(NSDictionary *)params success:(void (^)(void))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, SOSSocialSelectOrder];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion();
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

//更新订单信息
+ (void)changeStatusWithParams:(NSDictionary *)params success:(void (^)(void))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, SOSSocialChangeState];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        //        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            if (completion && operation.statusCode == 200) {
                completion();
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

//获取星友圈url
+ (void)getUrlWithUrl:(NSString *)url token:(NSString *)token success:(void (^)(NSString *url))completion Failed:(void(^)(NSString *responseStr, NSError *error))failCompletion{
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async_on_main_queue(^{
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            NSString *webUrl = [dic objectForKey:@"url"];
            if (completion && operation.statusCode == 200) {
                completion(webUrl);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failCompletion) {
                failCompletion(responseStr,error);
            }
        });
    }];
    
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpHeaders:@{@"pickupToken":token}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}




@end
