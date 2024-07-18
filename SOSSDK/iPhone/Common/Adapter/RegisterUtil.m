//
//  RegisterUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "RegisterUtil.h"
 
#import "CustomerInfo.h"
@implementation RegisterUtil
+ (void)registAsVisitor:(NSString *)url_ paragramString:(NSString *)params_ successHandler:(void(^)(NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url_ params:params_ successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
        if (success_ && operation.statusCode == 200) {
            success_(response);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
     [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)registAsOwner:(NSString *)url_ paragramString:(NSString *)params_ successHandler:(void(^)(SOSNetworkOperation *operation ,NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    if (!url_) {
        url_ = [BASE_URL stringByAppendingString:INFO3_REGISTER_SUBSCRIBER];
    }
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url_ params:params_ successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        if (success_) {
            success_(operation,responseStr);
        }
        
       } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
           if (failure_) {
               failure_(responseStr,error);
           }
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)sendVerifyCode:(NSString *)para successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString * url_ = [BASE_URL stringByAppendingString:INFO3_REGISTER_CODE_GET];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url_ params:para successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
        [Util toastWithVerifyCode:[NSString stringWithFormat:@"验证码已发送,请注意查收%@",response.secCode]];
        if (success_) {
            success_(response);
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)checkVerifyCode:(NSString *)para successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString * url = [BASE_URL stringByAppendingString:INFO3_REGISTER_CODE_CHECK];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NNError *response = [NNError mj_objectWithKeyValues:[Util dictionaryWithJsonString:responseStr]];
            if (success_) {
                success_(response);
            }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

//+ (void)updateCheckMobileOrEmailSuccessHandler:(void(^)(SOSNetworkOperation *operation,NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
//{
//    NNRegisterRequest *regRequest = [[NNRegisterRequest alloc]init];
//    [regRequest setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
//
//    [regRequest setUserName: [CustomerInfo sharedInstance].userBasicInfo.idpUserId
//     ];
//    [regRequest setSendCodeSenario:@"SUB_TO_VISITOR"];
//    NSString *json = [regRequest mj_JSONString];
//    NSString *url = [BASE_URL stringByAppendingString:INFO3_REGISTER_UPGRADE];
//
//    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSLog(@"response:%@",responseStr);
//        if (success_) {
//            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//            NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
//            success_(operation,response);
//        }
//
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//            if (failure_) {
//            failure_(responseStr,error);
//        }
//    }];
//    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
//    [operation setHttpMethod:@"PUT"];
//    [operation start];
//
//}
//+ (void)updateToOwnerParagramString:(NSString *)params_ successHandler:(void(^)(NNRegisterResponse * regRes))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
//{
//    NSString *url = [BASE_URL stringByAppendingString:INFO3_REGISTER_UPGRADE];
//    __block SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params_ successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        NSLog(@"\n\n\n\n\n 升级车主 operation %@ responseStr:%@  \n\n\n\n",operation,responseStr);
//        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
//        NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
//        if (success_) {
//            success_(response);
//        }
//        
//    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
//        NSLog(@"\n\n\n\n\n 升级车主失败 operation %@ responseStr:%@   \n\n error ------ %@ \n\n\n\n",operation,responseStr,error);
//        if (failure_) {
//            failure_(responseStr,error);
//        }
//    }];
//    [operation setHttpMethod:@"PUT"];
//    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
//    [operation start];
//
//}
+ (void)generateRegisterImageCaptchaGenerate:(NSString *)captchaId_ successHandler:(void(^)(id resp))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:
                     [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_GENERATE,captchaId_]];
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url params:nil needReturnSourceData:YES successBlock:^(SOSNetworkOperation *operation, id response) {
        if (success_) {
            success_(response);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];

}
+ (void)getRegisterImageCodeSuccessHandler:(void(^)(NSDictionary * responseDic))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:NEW_REGISTER_CODE_IMAGE_CAPTCHA];// send verification code
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if (success_) {
            success_(responseDic);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"GET"];
    [operation start];

}
+ (void)checkRegisterImageCode:(NSString *)captchaId_ value:(NSString *)captchaValue_ SuccessHandler:(void(^)(NSDictionary * responseDic))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:
                     [NSString stringWithFormat:NEW_REGISTER_CODE_IMAGE_CAPTCHA_VALIDATE,captchaId_,captchaValue_]];// send verificati
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil
    successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if (success_) {
            success_ (responseDic);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure_) {
            failure_(responseStr,error);
        }
        }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    
    [operation setHttpMethod:@"GET"];
    [operation start];
}

+ (void)isCheckEnrollState:(BOOL)isCheckEnroll paragramString:(NSString *)params_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url;
    if (isCheckEnroll) {
      url  = [BASE_URL stringByAppendingString:
           Register_Vehicle_Enroll];
    }
    else
    {
        url  = [BASE_URL stringByAppendingString:Register_Subscriber_Check];
    }
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:params_
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

#pragma mark - 添加车辆
+ (void)checkVisitorWithVINOrGovidState:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:Upgrade_Check_Visitor];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para_
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)checkSubscriberByGovid:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:Register_Govid_Check];  //验证发票信息
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para_
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)checkNewGovidInfo:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:Register_Govid_Change_Check];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para_
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)uploadSubscriberReceiptPhoto:(NSString *)para_ successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:Enroll_Upload_ReceiptPhoto];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para_
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

//<<<<<<< .working
//+ (void)registSubscriberByEnrollInfo:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
//=======
+ (void)uploadSubscriberPhotos:(NSArray *)uploadArray successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
{
    NSString *url = [Util getmOnstarStaticConfigureURL:Enroll_Upload_ReceiptPhoto];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSDictionary * userDic in uploadArray) {
            NSString * fileName = [userDic objectForKey:@"name"];
            [formData appendPartWithFileData:[userDic objectForKey:@"data"] name:fileName fileName:[NSString stringWithFormat:@"%@.png", fileName] mimeType:@"image/png"];
        }
//        [formData appendPartWithFileData:data3 name:@"vehicleInvoiceFile" fileName:fileName3 mimeType:@"image/png"];
    } successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success_) {
                success_(responseStr);
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        if (failure_) {
            failure_(responseStr,error);
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation startUploadTask];
}

+ (void)registSubscriberByEnrollInfo:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_;
//>>>>>>> .merge-right.r79379
{
    NSString *url = [BASE_URL stringByAppendingString:Register_Subscriber_Submit];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)submitBBWCInfoOrOnstarInfo:(BOOL)isBBWC  withEnrollInfo:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url;
    if (!isBBWC) {
       url = [BASE_URL stringByAppendingString:[NSString stringWithFormat:BBWC_Submit,[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin]];
    }
    else
    {
        url = [BASE_URL stringByAppendingString:[NSString stringWithFormat:OnstarUserInfo_Submit]];

    }
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ (responseStr);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_(responseStr,error);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)checkPIN:(NSString *)para successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr))failure_
{
    NSString *url = [BASE_URL stringByAppendingString:Register_Check_Pin];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
                                                                if (success_) {
                                                                    success_ ([SOSUtil checkPINResponseCode:responseStr]);
                                                                }
                                                            } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                                if (failure_) {
                                                                    failure_([SOSUtil checkPINResponseCode:responseStr]);
                                                                }
                                                            }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization,@"DEVICE-ID":[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)queryDealerInfo:(NNAroundDealerRequest *)dealerReq subscriberID:(NSString *)sub accountId:(NSString *)account vinStr:(NSString *)vin successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    [dealerReq setReturnPreferredDealer:@"false"];
    NSString *s = [NSString stringWithFormat:NEW_DEALER_GET_CITYDEALERS,dealerReq.cityCode,dealerReq.currentLocation.longitude,dealerReq.currentLocation.latitude,dealerReq.queryType,dealerReq.dealerBrand];
    NSString *url = [BASE_URL stringByAppendingString:s];

    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success_) {
            success_(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure_(responseStr,error);
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}
+ (void)queryDealerInfo:(NNAroundDealerRequest *)dealerReq subscriberID:(NSString *)sub accountId:(NSString *)account vinStr:(NSString *)vin pageSize:(NSString *)pagesize successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    [dealerReq setReturnPreferredDealer:@"false"];
    NSString *s = [NSString stringWithFormat:NEW_DEALER_GET_CITYDEALERS,dealerReq.cityCode,dealerReq.currentLocation.longitude,dealerReq.currentLocation.latitude,dealerReq.queryType,dealerReq.dealerBrand];
    NSString *url = [BASE_URL stringByAppendingString:s];
    if (pagesize) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&pageNum=0&pageSize=%@",pagesize]];
    }
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success_) {
            success_(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        failure_(responseStr,error);
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}
+ (void)queryIsGAAMobileAndEmail:(NNGAAEmailPhoneRequest *)queryReq successHandler:(void(^)(NSString *responseStr))success_ failureHandler:(void(^)(NSString *responseStr, NSError *error))failure_
{
    NSString *url = [NSString stringWithFormat:(@"%@" Upgrade_Check_IsgaaSub), BASE_URL];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:[queryReq mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (success_) {
            success_(responseStr);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        if (failure_)	failure_(responseStr, error);
    }];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];
}

@end
