//
//  SOSGeoDataTool.m
//  Onstar
//
//  Created by Coir on 21/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSGeoDataTool.h"

@implementation SOSGeoDataTool
//从电子围栏加载
+ (void)backToAddGeoMapVCWithFromVC:(UIViewController *)fromVC AndGeoFence:(NNGeoFence *)geoFence   {
    SOSGeoMapVC *vc = (SOSGeoMapVC *)fromVC.presentingViewController;
    
    if ([vc isKindOfClass:[SOSGeoMapVC class]]) {
        NNGeoFence *notiGeo = [vc.editingGeofence copy];
        notiGeo.centerPoiName = geoFence.centerPoiName;
        notiGeo.centerPoiAddress = geoFence.centerPoiAddress;
        notiGeo.centerPoiCoordinate = geoFence.centerPoiCoordinate;
    }
   
           [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_Fix), @"Geofence":geoFence}];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SOSNotifacationChangeGeo object:@{@"Type": @(SOSChangeGeoType_Update_CenterAndRadius), @"Geofence":geoFence}];
        [fromVC dismissViewControllerAnimated:YES completion:nil];
    });
}

+ (void)setGeoCenterWithPOI:(SOSPOI *)poi FromVC:(UIViewController *)fromVC		{
    UIViewController *resultVC = fromVC;
    while (resultVC.parentViewController != nil) {
        resultVC = resultVC.parentViewController;
        if ([resultVC isKindOfClass:NSClassFromString(@"BaseSearchTableVC")])    break;
    }
    // 设置围栏中心点
    NNGeoFence *geofence = [NNGeoFence new];
    geofence.centerPoiName = poi.name;
    geofence.centerPoiAddress = poi.address;
    NNCenterPoiCoordinate *gencingCoord = [NNCenterPoiCoordinate coordinateWithLongitude:poi.longitude AndLatitude:poi.latitude];
    [geofence setCenterPoiCoordinate:gencingCoord];
    [SOSGeoDataTool backToAddGeoMapVCWithFromVC:fromVC AndGeoFence:[SOSGeoDataTool getGeoFenceWithPOI:poi]];
}

+ (NNGeoFence *)getGeoFenceWithPOI:(SOSPOI *)resultPOI {
    SOSPOI *poi = resultPOI;
    NNGeoFence *previewGF = [[NNGeoFence alloc] init];
    NNCenterPoiCoordinate *gencingCoord = [NNCenterPoiCoordinate coordinateWithLongitude:resultPOI.longitude AndLatitude:resultPOI.latitude];
    [previewGF setCenterPoiCoordinate:gencingCoord];
    
    previewGF.centerPoiAddress = poi.address;
    previewGF.centerPoiName = poi.name;
    return previewGF;
}

+ (void)getGeoFencingSuccessHandler:(void (^)(NSArray *))success failureHandler:(void (^)(NSString *, NSError *))failure	{
    [SOSGeoDataTool getGeoFencingIsLBSMode:NO AndLBSDeviceID:nil SuccessHandler:success failureHandler:failure];
}

+ (void)getLBSGeoFencingWithLBSDeviceID:(NSString *)LBSDeviceID SuccessHandler:(void (^)(NSArray *))success failureHandler:(void (^)(NSString *, NSError *))failure		{
    [SOSGeoDataTool getGeoFencingIsLBSMode:YES AndLBSDeviceID:LBSDeviceID SuccessHandler:success failureHandler:failure];
}

+ (void)updateGeoFencingWithGeo:(NNGeoFence *)geo Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock		{
    if ([geo isKindOfClass:[NNLBSGeoFence class]] && geo.isLBSMode) {
        [SOSGeoDataTool updateGeoFencingWithGeo:geo isLBSMode:YES Success:successBlock Failure:failureBlock];
    }	else	{
        [SOSGeoDataTool updateGeoFencingWithGeo:geo isLBSMode:NO Success:successBlock Failure:failureBlock];
    }
}

+ (void)updateLBSGeoFencingWithGeo:(NNGeoFence *)geo Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock	{
    [SOSGeoDataTool updateGeoFencingWithGeo:geo isLBSMode:YES Success:successBlock Failure:failureBlock];
}

/// 获取电子围栏
+ (void)getGeoFencingIsLBSMode:(BOOL)isLBSMode AndLBSDeviceID:(NSString *)LBSDeviceID SuccessHandler:(void(^)(NSArray * fences))success failureHandler:(void(^)( NSString *responseStr, NSError *error))failure      {
    NSString *url = nil;
    if (isLBSMode) {
        url = [NSString stringWithFormat:(@"%@" LBSGetGEOURL), BASE_URL, LBSDeviceID];

    }	else	{
        url = [NSString stringWithFormat:(@"%@" NEW_GEOFENCE), BASE_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

    }
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSArray * fenceList = @[];
        if (isLBSMode) {
            NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
            if (dic.count) {
                NNLBSGeoFence *lbsGeofence = [NNLBSGeoFence mj_objectWithKeyValues:dic];
                // 车辆电子围栏与 LBS 电子围栏 范围 单位不同
                lbsGeofence.range = [NSString stringWithFormat:@"%.2f", lbsGeofence.range.floatValue / 1000];
                lbsGeofence.isLBSMode = YES;
                lbsGeofence.isNewToAdd = NO;
                lbsGeofence.isEditStatus = NO;
                if (lbsGeofence.Id.intValue)	fenceList = @[lbsGeofence];
            }
        }	else	{
            NSArray *dicArray = [Util arrayWithJsonString:returnData];
            if (dicArray.count) {
                NNGeoFence *geofence = [NNGeoFence mj_objectWithKeyValues:dicArray[0]];
                geofence.isLBSMode = NO;
                geofence.isNewToAdd = NO;
                geofence.isEditStatus = NO;
                fenceList = @[geofence];
            }	else	{
                fenceList = @[];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)    success(fenceList);
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (statusCode == 508) {
            NSDictionary *resDic = responseStr.mj_JSONObject;
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"404"]) {
                    dispatch_async_on_main_queue(^{
                        if (success)    success(@[]);
                    });
                    return;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure)    failure(responseStr,error);
        });
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 增加/更新/删除 电子围栏
+ (void)updateGeoFencingWithGeo:(NNGeoFence *)geo isLBSMode:(BOOL)isLBSMode  Success:(SOSSuccessBlock)successBlock Failure:(SOSFailureBlock)failureBlock   {
    NSString *url;
    BOOL isDeleteMode = [geo.operationType isEqualToString:@"DELETE"];
    NNGeoFence *tempGeo = [geo copy];
    if (isLBSMode)     {
        // 车辆电子围栏与 LBS 电子围栏 范围 单位不同
        tempGeo.range = @(geo.range.floatValue * 1000).stringValue;
        if (isDeleteMode)		url = [NSString stringWithFormat:@"%@%@", BASE_URL, LBSDeleteGEOURL];
        else		 			url = [NSString stringWithFormat:@"%@%@", BASE_URL, LBSUpdateGEOURL];
    }	else		{
        url = [NSString stringWithFormat:(@"%@" NEW_GEOFENCE), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }
    NSString *parameters;
    if  (isDeleteMode && isLBSMode)   	{
        NNLBSGeoFence *LBSGeo = (NNLBSGeoFence *)tempGeo;
        parameters = @{@"deviceId": LBSGeo.deviceId, @"idpuserId":[CustomerInfo sharedInstance].userBasicInfo.idpUserId}.mj_JSONString;
    }	else	{
        parameters = tempGeo.mj_JSONString;
    }

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:parameters successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(successBlock)        successBlock(operation, responseStr);
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock)       failureBlock(statusCode, responseStr, error);
        });
    }];
    if (isLBSMode)			[operation setHttpMethod:@"POST"];
    else					[operation setHttpMethod:@"PUT"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}

/// 获取图片验证码
+ (void)getImgCodeForUrl:(nonnull NSString*)imgUrl responseSuccess:(void (^)(UIImage *img, NSString *imgToken))successBlock responseFailure:(SOSFailureBlock)failureBlock{
    //
    
    NSString *url = [BASE_URL stringByAppendingString:imgUrl];
    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (operation.statusCode == 200) {
            NSDictionary *resDic = [returnData mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSData *data = [NSData dataWithBase64EncodedString:resDic[@"imgVerifCode"]];
                NSString *token = resDic[@"imgVerifCodeToken"];
                if (data) {
                    UIImage *img = [UIImage imageWithData:data];
                    if (successBlock)    successBlock(img, token);
                    return;
                }
            }
        }
        if (successBlock)    successBlock(nil, nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSDictionary *resDic = responseStr.mj_JSONObject;
        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
            //                NSString *code = resDic[@"errorCode"];
            NSString *msg = resDic[@"description"];
            if ([msg isKindOfClass:[NSString class]])     [Util showErrorHUDWithStatus:msg];
        }
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [sosOperation setHttpMethod:@"GET"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 获取短信验证码
+ (void)getSMSCodeForUrl:(nonnull NSString *)smsUrl withImgCode:(NSString *)imgCode imgToken:(NSString *)imgToken andPhoneNum:(NSString *)phone responseSuccess:(void (^)(NSString *SMSCode, NSString *SMSToken))successBlock responseFailure:(SOSFailureBlock)failureBlock        {

    NSString *url = [BASE_URL stringByAppendingString:smsUrl];
    NSDictionary *parameterDic = @{@"imgVerifCode": imgCode.lowercaseString, @"imgVerifCodeToken": imgToken, @"phoneNumber": phone};
    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:parameterDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (operation.statusCode == 200) {
            NSDictionary *resDic = [returnData mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"msgVerifyCode"];
//                NSString *returnPhone = resDic[@"phoneNumber"];
                NSString *token = resDic[@"phoneVerifytoken"];
                if (code && code.length) {
                    if (successBlock)    successBlock(code, token);
                    return;
                }
            }
        }
        if (successBlock)    successBlock(nil, nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            NSDictionary *resDic = responseStr.mj_JSONObject;
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
//                NSString *code = resDic[@"errorCode"];
                NSString *msg = resDic[@"description"];
                if ([msg isKindOfClass:[NSString class]]) 	[Util showErrorHUDWithStatus:msg];
            }
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [sosOperation setHttpMethod:@"POST"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

/// 校验短信验证码
+ (void)verifySMSCodeWithSMSCode:(NSString *)smsCode SMSToken:(NSString *)smsToken Success:(void (^)(NSString *authToken))successBlock Failure:(SOSFailureBlock)failureBlock        {
    NSString *url = [BASE_URL stringByAppendingString:SOSSmartDevice_verifySMSCodeURL];
    NSDictionary *parameterDic = @{@"msgVerifCode": smsCode.lowercaseString, @"msgVerifToken": smsToken, @"equipmentType": @"LBS"};
    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:parameterDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (operation.statusCode == 200) {
            NSDictionary *resDic = [returnData mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *token = resDic[@"authToken"];
                if (token && token.length) {
                    if (successBlock)    successBlock(token);
                    return;
                }
            }
        }
        if (successBlock)    successBlock(nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSDictionary *resDic = responseStr.mj_JSONObject;
        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
            //                NSString *code = resDic[@"errorCode"];
            NSString *msg = resDic[@"description"];
            if ([msg isKindOfClass:[NSString class]])     [Util showErrorHUDWithStatus:msg];
        }
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [sosOperation setHttpMethod:@"PUT"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}
+ (void)replenishVerifySMSCodeWithMobile:(NSString *)mobile SMSCode:(NSString *)smsCode Success:(void (^)(NSString *authToken))successBlock Failure:(SOSFailureBlock)failureBlock        {
    NSString *url = [BASE_URL stringByAppendingString:SOSReplenishMobile_verifySMSCodeURL];
    
    NSDictionary *parameterDic = @{@"accountNumber":NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId), @"destType":@"S", @"idpUserID": NONil([CustomerInfo sharedInstance].userBasicInfo.idpUserId),@"mobilePhoneNumber":mobile,@"secCode":smsCode,@"subscriberID":NONil([CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId)};
    
    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:parameterDic.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (successBlock)    successBlock(nil);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        if (failureBlock)    failureBlock(statusCode, responseStr, error);
    }];
    [sosOperation setHttpMethod:@"PUT"];
    NSString *idpid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    [sosOperation setHttpHeaders:@{@"client-user-id": (idpid ? idpid : @"")}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

+ (BOOL)checkGeoInfoWithGeofence:(NNGeoFence *)geofence    {
    //check geo-fencing name
    if (!geofence.isLBSMode && [Util trimString:geofence.geoFencingName].length < 1) {
        [Util toastWithMessage:@"请设置围栏名称"];
        return NO;
    }
    if ([Util trimString:geofence.mobilePhone].length == 0) {
        [Util toastWithMessage:@"手机号码格式错误"];
        return NO;
    }
    return  YES;
}

@end
