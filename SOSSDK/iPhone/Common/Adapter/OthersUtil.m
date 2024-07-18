//
//  OthersUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "OthersUtil.h"
#import "SOSDateFormatter.h"
@implementation OthersUtil
//获取公网ip
+ (void)getIP:(NSString *)url SuccessHandle:(void (^)(IPData *ip))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSString * ipofUrl = @"http://ip.taobao.com/service/getIpInfo.php?ip=myip";
//        NSData * resData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ipofUrl]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (resData) {
//                NSString *ipStr = [[NSString alloc] initWithData:resData encoding:NSASCIIStringEncoding];
//                if (ipStr) {
//                    IPDataWrapper *ipData = [IPDataWrapper mj_objectWithKeyValues:[Util dictionaryWithJsonString:ipStr]];
//                            if (success_) {
//                                success_(ipData);
//                           }
//                }
//            }
//        });
//    });
    NSString * ipofUrl = @"http://ip.360.cn/IPShare/info";
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:ipofUrl params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        IPData *ipData;
        if ([responseStr isKindOfClass:[NSString class]]) {
            ipData = [IPData mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success_) {
                    success_(ipData);
                }
            });
        }

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        IPData *ipData = [IPData mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        dispatch_async(dispatch_get_main_queue(), ^{
        if (ipData && success_) {
            success_(ipData);
        }
        });

    }];
    [operation setHttpMethod:@"GET"];
    [operation start];
}
+ (void)getProvinceInfosuccessHandler:(void(^)(NSArray *responsePro))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:PROVINCE_URL];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray * arr =[NNProvinceInfoObject mj_objectArrayWithKeyValuesArray:[Util arrayWithJsonString:responseStr]];
        if (success_) {
            success_(arr);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        failure_(responseStr,error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}
+ (void)getCityInfoByProvince:(NSString *)province successHandler:(void(^)(NSArray *responseCity))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    
    NSString *url = [NSString stringWithFormat:(@"%@" PROVINCE_CITY_URL), BASE_URL, [NSString stringWithFormat:@"%@",[province stringByURLEncode]]];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray * arr =[NNProvinceInfoObject mj_objectArrayWithKeyValuesArray:[Util arrayWithJsonString:responseStr]];
        if (success_) {
            success_(arr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}
+ (void)getBannerByCategory:(NSString *)category_ CarOwnersLiv:(BOOL)living SuccessHandle:(success_)success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_BANNER];
    NNBannerRequest *request = [[NNBannerRequest alloc]init];
    [request setVin:NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin)];
    [request setMake:NONil([[CustomerInfo sharedInstance] currentVehicle].makeDesc)];
    [request setModel:NONil([[CustomerInfo sharedInstance] currentVehicle].modelDesc)];
    [request setYear:NONil([[CustomerInfo sharedInstance] currentVehicle].year)];
    [request setDeviceType:@"21"];
    [request setDeviceOS:@"iOS"];
    [request setLanguagePreference:[[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH]?@"en":@"zh" ];
    [request setUserID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    
    [request setImgType:[Util bannerosType]];
    [request setVersionCode:[Util getAppVersionCode]];
    if (category_) {
        [request setCategory:category_];
    }
    NSString *json = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (living) {
            NSDictionary *diction = [Util dictionaryWithJsonString:responseStr];
            if (success_) {
                success_(diction);
            }

        }else{
            
            NSArray *contentHearderArray = [NNBanner mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]];
            
            if (success_) {
                success_(contentHearderArray);
            }
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr, error);
        }
    }];
    [operation setHttpMethod:@"POST"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}
+ (void)getBannerWithCategory:(NSString *)category_ SuccessHandle:(success_)success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_BANNER];
    NNBannerRequest *request = [[NNBannerRequest alloc]init];
    [request setVin:NONil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin)];
    [request setMake:NONil([[CustomerInfo sharedInstance] currentVehicle].makeDesc)];
    [request setModel:NONil([[CustomerInfo sharedInstance] currentVehicle].modelDesc)];
    [request setYear:NONil([[CustomerInfo sharedInstance] currentVehicle].year)];
    [request setDeviceType:@"21"];
    [request setDeviceOS:@"iOS"];
    [request setLanguagePreference:[[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH]?@"en":@"zh" ];
    [request setUserID:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId];
    
    [request setImgType:[Util bannerosType]];
    [request setVersionCode:[Util getAppVersionCode]];
    if (category_) {
        [request setCategory:category_];
    }
    NSString *json = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
         
             NSDictionary *resDic = [responseStr mj_JSONObject];
//            NSDictionary *bannerDic = [NNBanner mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]];
            
            if (success_) {
                success_(resDic);
            }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        //[self initBannerWithImage:nil];
        if (failure_) {
            failure_(responseStr, error);
        }
    }];
//    [operation setHttpMethod:@"PUT"];
    [operation setHttpMethod:@"POST"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}

+ (void)getBannerByCategory:(NSString *)category_ SuccessHandle:(void (^)(NSArray *banners))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    [self getBannerByCategory:category_ CarOwnersLiv:NO SuccessHandle:success_ failureHandler:failure_];
}

#pragma mark---Report
+ (void)sendReportToDAAP:(NSString *)reportUrl_ postParaJsonString:(NSString *)para_ successHandle:(void (^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
//    SOSNetworkOperation *httpOperation = [SOSNetworkOperation requestWithURL:reportUrl_
//                                                                      params:para_
//                                                                successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//                                                            if (success_) {
//                                                            success_(responseStr);
//                                                                    }
//                                                                } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//                                                            if (failure_) {
//                                                        failure_(responseStr,error);
//                                                                    }
//
//                                                                }];
    SOSNetworkOperation* httpOperation = [[SOSNetworkOperation alloc] initWithURL:reportUrl_ params:para_ enableLog:NO needReturnSourceData:NO needSSLPolicyWithCer:YES cacheConfig:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success_) {
            success_(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    

    [httpOperation setHttpMethod:@"POST"];
    [httpOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [httpOperation start];
}

#pragma mark---天气
//+ (void)asyncRequestForWeather:(NSString *)URL successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_
//{
//    __block SOSNetworkOperation *sosOperation = [[SOSNetworkOperation alloc]initWithNOSSLURL:URL params:nil needReturnSourceData:NO successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        
//        Weather *weather = nil;
//        NSDictionary *weatherDic = [Util dictionaryWithJsonString:responseStr];
//            if(weatherDic!=nil ){
//                weather = [[Weather alloc]initWithDictionary:weatherDic];
//                NSDictionary *dictionary = [NSDictionary dictionaryWithObject:weather forKey:@"weatherInfo"];
//                if (successBlock_) {
//                   successBlock_(sosOperation,dictionary);//返回天气dict
//                }
//            }
//        
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        if (failureBlock_) {
//            if (responseStr) {
//                NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
//                if (nerror) {
//                    failureBlock_(sosOperation ,nerror ,responseStr);
//                }
//                else
//                {
//                    failureBlock_(sosOperation,nil,responseStr);
//                }
//            }
//            
//        }
//    }];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation start];
//}
#pragma mark---限行
//+ (void)asyncRequestForRestrict:(NSString *)restrictURL successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_  {
//    __block SOSNetworkOperation *sosOperation = [[SOSNetworkOperation alloc] initWithURL:restrictURL params:nil needReturnSourceData:NO successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSDictionary *restrictDic =[Util dictionaryWithJsonString:responseStr];
//        if(restrictDic!=nil)
//        {
//            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:restrictDic forKey:@"RestrictInfo"];
//            if ( successBlock_) {
//                successBlock_(sosOperation,dictionary);
//            }
//        }
//    }failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        if (failureBlock_) {
//            if (responseStr) {
//                NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
//                if (nerror) {
//                    failureBlock_(sosOperation ,nerror ,responseStr);
//                }
//                else
//                {
//                    failureBlock_(sosOperation,nil,responseStr);
//                }
//            }
//        }
//        
//    }];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation start];
//}

+ (void)asyncRequestForRestrictCitysWithSuccessBlock:(SOSMroResultSuccessBlock)successBlock failureBlock:(SOSMroResultFailureBlock)failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, @"/msp/api/v3/thirdparty/traffic/vcyber/getLimitLineCitys"];
    __block SOSNetworkOperation *sosOperation = [[SOSNetworkOperation alloc] initWithURL:url params:nil needReturnSourceData:NO successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray *array = [Util arrayWithJsonString:responseStr];
        if (successBlock && array) {
            NSDictionary *dic = @{@"cities": array};
            successBlock(operation, dic);
        }

    }failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (responseStr) {
            NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            if (nerror) {
                failureBlock(sosOperation ,nerror ,responseStr);
            }
            else {
                failureBlock(sosOperation,nil,responseStr);
            }
        }
        
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

+ (void)asyncRequestForRestrictionWithCityCode:(NSString *)cityCode time:(NSString *)time successBlock:(SOSMroResultSuccessBlock)successBlock failureBlock:(SOSMroResultFailureBlock)failureBlock {
    NSDate *searchDate = [[SOSDateFormatter sharedInstance] dateFromString:time];
    NSString *searchString = [[SOSDateFormatter sharedInstance] style1_stringFromDate:searchDate];
    NSString *today = [[SOSDateFormatter sharedInstance] style1_stringFromDate:[NSDate date]];
    NSString *param = [NSString stringWithFormat:@"cityCode=%@&queryDate=%@&today=%@", cityCode, searchString, today];
    NSString *url = [NSString stringWithFormat:@"%@%@%@", BASE_URL, @"/msp/api/v3/thirdparty/traffic/vcyber/restrictionQuery?", param];

    __block SOSNetworkOperation *sosOperation = [[SOSNetworkOperation alloc] initWithURL:url params:nil needReturnSourceData:NO successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSArray *array = [Util arrayWithJsonString:responseStr];
        if (successBlock && array) {
            NSDictionary *dic = @{@"sevenDayDatas": array};
            successBlock(operation, dic);
        }
    }failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (responseStr) {
            NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            if (nerror) {
                failureBlock(sosOperation ,nerror ,responseStr);
            }
            else {
                failureBlock(sosOperation,nil,responseStr);
            }
        }
        
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

#pragma mark --- 违章
+ (void)asyncRequestForVolation:(NSString *)URL_ successBlock:(SOSMroResultSuccessBlock)successBlock_ failureBlock:(SOSMroResultFailureBlock)failureBlock_  {
    __block SOSNetworkOperation *sosOperation =
     [[SOSNetworkOperation alloc]initWithURL:URL_ params:nil needReturnSourceData:NO  successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        
        NSDictionary *violationDic =[Util dictionaryWithJsonString:responseStr];
        if(violationDic!=nil)
        {
//            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:violationDic forKey:@"list"];
            if ( successBlock_) {
                successBlock_(sosOperation,violationDic);
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failureBlock_) {
            if (responseStr) {
                NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
                if (nerror) {
                    failureBlock_(sosOperation ,nerror ,responseStr);
                }
                else
                {
                    failureBlock_(sosOperation,nil,responseStr);
                }
            }
        }        //违章查询失败record
        //[[SOSReportService shareInstance] recordActionWithFunctionID:Violationcheckfailedreport];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}
////info3获取最新tcps协议内容
//+ (void)getTCPSProtolSuccessHandler:(void(^)(TCPSResponse * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
//{
//    NSString * url ;
//    url = [NSString stringWithFormat:@"%@%@",[Util getConfigureURL],INFO3_LATEST_TCPS_LEGAL];
//    SOSNetworkOperation *sosOperation =
//    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        TCPSResponse *res =[[TCPSResponse alloc] init];
//        [res setTcps:[TCPSResponseItem mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]]];
//        if (success) {
//            success(res);
//        }
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NNError * nerror = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
//        if (failure) {
//            failure(responseStr,nerror);
//        }
//    }];
//    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [sosOperation setHttpMethod:@"GET"];
//    [sosOperation start];
//}

+ (void)getTCPSProtolItem:(NSString *)url SuccessHandler:(void(^)(NSString * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        success(responseStr);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation startSync];
}

+ (void)getCarsharingSuccessHandler:(void(^)(SOSRemoteControlShareUserList * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
//    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_LIST), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_LIST), BASE_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];

    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        SOSRemoteControlShareUserList *res = [[SOSRemoteControlShareUserList alloc] init];
        [res setShareList:[SOSRemoteControlShareUser mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]]];
        success(res);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}
+ (void)setCarsharingAuthorzation:(RemoteControlSharePostUser *)authUser SuccessHandler:(void(^)(NSString * responseStr,NNError * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
//    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_SETTING_AUTH), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_SETTING_AUTH), BASE_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];

    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:[authUser mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NNError * response = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        if (response) {
            success(responseStr,response);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];
}

+ (void)queryCarsharingStatusSuccessHandler:(void(^)(SOSRemoteControlShareUser * res))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
    //登陆时会调用
//    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_STATUS), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    NSString *url = [NSString stringWithFormat:(@"%@" CARSHARING_STATUS), BASE_URL,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId];

    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        SOSRemoteControlShareUser *res = [SOSRemoteControlShareUser mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
//        SOSRemoteControlShareUserList *res = [[SOSRemoteControlShareUserList alloc] init];
//        [res setShareList:[SOSRemoteControlShareUser mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]]];
        success([[SOSRemoteControlShareUser mj_objectArrayWithKeyValuesArray:[Util dictionaryWithJsonString:responseStr]] objectAtIndex:0]);
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}


+ (void)queryBBWCQuestionByGovid:(NSString *)govid successHandler:(void(^)(NSArray * questions))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
    NSString * url = [NSString stringWithFormat:@"%@%@%@",BASE_URL,BBWC_Security_Question,@"123"];  //随意参数，后台不做验证
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NNBBWCQuestionList * list = [NNBBWCQuestionList mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        success(list.questions);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

+ (void)queryBBWCInfoByEnrollInfo:(NSString *)para successHandler:(void(^)(NSDictionary * response))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure
{
    NSString * url = [NSString stringWithFormat:@"%@%@",BASE_URL,BBWC_Info];
    //接口body部分使用AES128加密
    NSString * body =[NSString stringWithFormat:@"{\"vehicleValidationStr\":%@%@%@}",@"\"",[SOSUtil AES128EncryptString:para],@"\""];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:body successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        
        NSString * reStr =(NSString *) responseStr;
        NSDictionary * dic = [Util dictionaryWithJsonString:reStr];
        reStr = [dic valueForKey:@"enrollInfo"];
        NSString *contentStr = [SOSUtil AES128DecryptString:reStr];
        NSLog(@"enroll/info/encrypt:%@",contentStr);
        if (contentStr) {
            [dic setValue:contentStr forKey:@"enrollInfo"];
            success(dic);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure(responseStr,nil);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];
}
#pragma mark - 登录

/**
 加载用户基本信息
 @param idpUserId
 @param success
 @param failure
 */
+ (void)loadUserBasicInfoByidpuserID:(NSString *)idpUserId successHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NNError *error))failure
{
    NSString *url = [BASE_URL stringByAppendingFormat:ONSTAR_API_LOGIN_USERBASICINFO, idpUserId];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            success(operation, responseStr);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            failure(statusCode,responseStr,nil);
        }
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}
//
+ (void)loadUserVehicleCommandsByVin:(NSString *)vin_ successHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NSError *error))failure;
{
    NSString *url =[NSString stringWithFormat:(@"%@" ONSTAR_API_COMMANDS), BASE_URL,vin_];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
           success(operation,responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            failure(statusCode,responseStr,error);
        }
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

+ (void)loadVehiclePrivilegeSuccessHandler:(void(^)(SOSNetworkOperation *operation,NSString * response))success failureHandler:(void(^)(NSInteger statusCode,NSString *responseStr, NNError *error))failure
{

    NSString *vin = NNil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin);
    NSString *role = NNil([CustomerInfo sharedInstance].userBasicInfo.currentSuite.role);
    NSString *url = [BASE_URL stringByAppendingFormat:ONSTAR_API_LOGIN_USERVEHICLEPRIVILEGE,vin,role];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            success(operation,responseStr);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if ([LoginManage sharedInstance].loginState != LOGIN_STATE_NON) {
            failure(statusCode,responseStr,nil);
        }
        
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}
+ (void)loadSecretTicket:(NSString *)para successHandler:(void(^)(NSString * ticket))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure;
{
    NSString * url = [NSString stringWithFormat:@"%@%@",BASE_URL,Modify_Pin_Check];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:para successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success) {
            success(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure) {
            failure(responseStr,nil);
        }
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];
}
+ (void)loadAppAllowNotify:(NSString *)status successHandler:(void(^)(NSString * ticket))success failureHandler:(void(^)(NSString *responseStr, NNError *error))failure{
    NSString * url = [NSString stringWithFormat:@"%@%@",BASE_URL,SOSUploadNotificationStatus];
    SOSNetworkOperation *sosOperation =
    [SOSNetworkOperation requestWithURL:url params:[NSString stringWithFormat:@"{\"switchStatus\":\"%@\"}",status]  successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success) {
            success(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure) {
            failure(responseStr,nil);
        }
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];
}
@end
