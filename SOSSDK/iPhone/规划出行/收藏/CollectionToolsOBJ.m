//
//  CollectionToolsOBJ.m
//  Onstar
//
//  Created by Coir on 16/3/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CollectionToolsOBJ.h"
#import "SOSCheckRoleUtil.h"
#import "SOSSearchResult.h"
#import "LoadingView.h"
#import "CustomerInfo.h"

@implementation CollectionToolsOBJ

+ (void)getCollectionListFromVC:(UIViewController *)vc Success:(void (^)(NSArray *resultArray))completion  {
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:vc andTobePushViewCtr:nil completion:^(BOOL finished) {
        if (finished) {
//            NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_LIST_DESTINATION), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, @"1",@"10"];
            NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_LIST_DESTINATION), BASE_URL, @"1",@"10"];

            [[LoadingView sharedInstance] startIn:vc.view];
            SOSNetworkOperation *listDestReq = [[SOSNetworkOperation alloc]initWithURL:url params:nil  successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                [[LoadingView sharedInstance] stop];
                if (operation.statusCode == 200) {
                    NSArray *arr = [Util arrayWithJsonString:responseStr];
                    completion(arr);
                }
            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                [[LoadingView sharedInstance] stop];
                [Util toastWithMessage:[responseStr getDescriptionString]];
            }];

            [listDestReq setHttpMethod:@"GET"];
            [listDestReq setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
            [listDestReq start];
        }   else    {
            [Util toastWithMessage:@"请先登录查看收藏的兴趣点"];
        }
    }];
}

+ (void)getCollectionStateWithAmapID:(NSString *)amapID Success:(void(^)(bool isCollected, NSString *destinationID))successBlock Failure:(void(^)(void))failureBlock		{
    NSString *url = [BASE_URL stringByAppendingFormat:SOS_Check_Collection_State_URL, amapID];
    
    SOSNetworkOperation *saveDestReq = [[SOSNetworkOperation alloc]initWithURL:url params:nil  successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        if ([responseStr length]) {
            NSDictionary *resDic = [responseStr mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"E0000"]) {
                    NSDictionary *dataDic = resDic[@"data"];
                    if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
                        NSString *desID = dataDic[@"favoriteDestinationID"];
                        if ([desID isKindOfClass:[NSNumber class]]) 	desID = [(NSNumber *)desID stringValue];
                        
                        if (successBlock)    successBlock(YES, desID);
                        return;
                    }
                }
                if (successBlock)    successBlock(NO, nil);
                return;
            }
        }
        if (failureBlock)    failureBlock();
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        if (failureBlock)    failureBlock();
    }];
    
    [saveDestReq setHttpMethod:@"GET"];
    [saveDestReq setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [saveDestReq start];
}

+ (void)addCollectionFromVC:(UIViewController *)vc WithPoi:(SOSPOI *)poi NickName:(NSString *)nickName  Success:(void(^)(NSString *destinationID))successBlock Failure:(void(^)(void))failureBlock     {
    [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:vc andTobePushViewCtr:nil completion:^(BOOL finish){
        if (!finish)     return;
        // check role
//        if (![[SOSCheckRoleUtil shareInstance] checkRoleInPage:vc])     return;
        
        NNFavoritePOI *addDestReq = [[NNFavoritePOI alloc] init];
        addDestReq.fuid = poi.pguid;
        [addDestReq setIdpID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
        [addDestReq setLanguage:NSLocalizedString(@"contentLanguageType", nil)];
        [addDestReq setPoiName:poi.name];
        [addDestReq setPoiNickname:nickName];
        [addDestReq setPoiAddress:poi.address];
        [addDestReq setPoiPhoneNumber:poi.tel];
        [addDestReq setCityCode:poi.city];
        [addDestReq setProvience:poi.province];
        NNGpsLocationCoordinate *poiCoordinate_location = [[NNGpsLocationCoordinate alloc] init];
        [poiCoordinate_location setLongitude:poi.longitude];
        [poiCoordinate_location setLatitude:poi.latitude];
        [addDestReq setPoiCoordinate:poiCoordinate_location];
        
        SOSPOI *userPOI = [CustomerInfo sharedInstance].currentPositionPoi;
        NNGpsLocationCoordinate *mobileCoordinate_location = [[NNGpsLocationCoordinate alloc] init];
        mobileCoordinate_location.longitude = userPOI ? userPOI.longitude : @"";
        mobileCoordinate_location.latitude = userPOI ? userPOI.latitude : @"";
        addDestReq.mobileCoordinate = mobileCoordinate_location;
        
        
        NSString *addDestReq_String = [addDestReq mj_JSONString];
        NSString *url = [BASE_URL stringByAppendingString:NEW_ADD_FAVOURITE_DESTINATION];

        SOSNetworkOperation *saveDestReq = [[SOSNetworkOperation alloc]initWithURL:url params:addDestReq_String  successBlock:^(SOSNetworkOperation *operation, id responseStr) {
            NSDictionary *resDic = [responseStr mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                NSDictionary *dataDic = resDic[@"data"];
                if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"E0000"]) {
                    if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic.count) {
                        NSString *destinationID = dataDic[@"favoriteDestinationID"];
                        dispatch_async_on_main_queue(^{
                            if (successBlock)    successBlock(destinationID);
                            [[NSNotificationCenter defaultCenter] postNotificationName:KCollectionDataChangedNotification object:nil];
                            [Util showSuccessHUDWithStatus:@"已收藏"];
                        });
                    }
                    return;
                }
            }
            
            if (failureBlock)    failureBlock();
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            if (failureBlock)    failureBlock();
            [Util showErrorHUDWithStatus:@"操作异常"];
        }];
        
        [saveDestReq setHttpMethod:@"PUT"];
        [saveDestReq setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [saveDestReq start];
    }];
}
+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID		{
    [CollectionToolsOBJ deleteCollectionWithDestinationID:destinationID Success:nil Failure:nil];
}

+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID Success:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock		{
    [self deleteCollectionWithDestinationID:destinationID NeedToast:YES Success:successBlock Failure:failureBlock];
}

+ (void)deleteCollectionWithDestinationID:(NSString *)destinationID NeedToast:(BOOL)needToast Success:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock     {
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_ADD_FAVOURITE_DESTINATION @"/%@"), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, destinationID];
    NSString *url = [BASE_URL stringByAppendingFormat:DEL_FAVOURITE_DESTINATION,destinationID];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if ([returnData length]) {
            NSDictionary *resDic = [returnData mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"E0000"]) {
                    dispatch_async_on_main_queue(^{
                        if (successBlock)    successBlock();
                        if (needToast) [Util showErrorHUDWithStatus:@"收藏已取消"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KCollectionDataChangedNotification object:nil];
                    });
                    return;
                }
            }
        }
        dispatch_async_on_main_queue(^{
            if (failureBlock)    failureBlock();
            if (needToast) [Util showErrorHUDWithStatus:@"操作异常"];
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failureBlock)    failureBlock();
            if (needToast) [Util showErrorHUDWithStatus:@"操作异常"];
        });
    }];
    [operation setHttpMethod:@"DELETE"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}

+ (void)deleteAllColectionsSuccess:(void(^)(void))successBlock Failure:(void(^)(void))failureBlock     {
    NSString *url = [BASE_URL stringByAppendingFormat:SOS_Delete_All_Colections_URL];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if ([returnData length]) {
            NSDictionary *resDic = [returnData mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *code = resDic[@"code"];
                if ([code isKindOfClass:[NSString class]] && [code isEqualToString:@"E0000"]) {
                    dispatch_async_on_main_queue(^{
                        if (successBlock)    successBlock();
                        [[NSNotificationCenter defaultCenter] postNotificationName:KCollectionDataChangedNotification object:nil];
                    });
                    return;
                }
            }
        }
        dispatch_async_on_main_queue(^{
            if (failureBlock)    failureBlock();
            [Util showErrorHUDWithStatus:@"操作异常"];
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async_on_main_queue(^{
            if (failureBlock)    failureBlock();
            [Util showErrorHUDWithStatus:@"操作异常"];
        });
    }];
    [operation setHttpMethod:@"DELETE"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpHeaders:@{@"client-user-id": [CustomerInfo sharedInstance].userBasicInfo.idpUserId}];
    [operation start];
}

+ (void)getHomeAndCompanyMessage	{
    NSString *url = [BASE_URL stringByAppendingFormat:HOME_POI_GET];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            
            NSArray *dataArray = [Util arrayWithJsonString:responseStr];
            if (dataArray.count) {
                for (NSDictionary *dic in dataArray) {
                    GetDestinationResponse *destinationResponse = [GetDestinationResponse mj_objectWithKeyValues:dic];
                    if (destinationResponse.customCatetory.intValue == 1) {
                        SOSPOI *homePoi = destinationResponse.poi;
                        if (homePoi) 			[CustomerInfo sharedInstance].homePoi = homePoi;
                    } else if (destinationResponse.customCatetory.intValue == 2) {
                        SOSPOI *companyPoi = destinationResponse.poi;
                        if (companyPoi) 		[CustomerInfo sharedInstance].companyPoi = companyPoi;
                    }
                }
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

+ (SOSPOI *)handleCollectionResultDic:(NSDictionary *)collectionDic     {
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.name = collectionDic[@"poiName"];
    poi.address = collectionDic[@"poiAddress"];
    poi.tel = collectionDic[@"poiPhoneNumber"];
    poi.nickName = collectionDic[@"poiNickname"];
    poi.pguid = collectionDic[@"fuid"];
    poi.cityCode = [collectionDic[@"poiCityCode"] length] ? collectionDic[@"poiCityCode"] : collectionDic[@"cityCode"];;
    poi.x = [collectionDic[@"poiCoordinate"][@"longitude"] stringValue];
    poi.y = [collectionDic[@"poiCoordinate"][@"latitude"] stringValue];
    poi.destinationID = [collectionDic[@"favoriteDestinationID"] stringValue];
    return poi;
}

+ (UIView *)getNoDataView   {
    UIView *nodataHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    
    UIImageView *noDataImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NO_favoritePOI"]];
    noDataImgView.contentMode = UIViewContentModeCenter;
    noDataImgView.centerX = nodataHeaderView.centerX;
    noDataImgView.top = 200;
    [nodataHeaderView addSubview:noDataImgView];
    
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, noDataImgView.bottom + 20, SCREEN_WIDTH, 30)];
    noDataLabel.text = NSLocalizedString(@"NO_favoritePOI", nil);
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.font = [UIFont systemFontOfSize:13];
    noDataLabel.textColor = [UIColor blackColor];
    [nodataHeaderView addSubview:noDataLabel];
    
    return nodataHeaderView;
}

@end
