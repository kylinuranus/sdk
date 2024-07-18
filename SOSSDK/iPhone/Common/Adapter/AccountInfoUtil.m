//
//  AccountInfoUtil.m
//  Onstar
//
//  Created by Vicky on 16/6/30.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "AccountInfoUtil.h"
#import "Util.h"
 
#import "ResponseDataObject.h"
#import "CustomerInfo.h"
#import "NSString+JWT.h"
#import "SOSRegisterInformation.h"


@implementation AccountInfoUtil

+ (void)getAccountInfo:(BOOL)popError Success:(void (^)(NNExtendedSubscriber *subscriber))completion Failed:(void (^)(void))failCompletion	{
    NSString * url = [NSString stringWithFormat:@"%@%@",BASE_URL,BBWC_Info];
    SOSRegisterCheckRequestWrapper * reg = [[SOSRegisterCheckRequestWrapper alloc] init];  //basic_info接口替换为/enroll/info/encrypt接口
    reg.enrollInfo = [[SOSRegisterCheckRequest alloc] init];
    reg.enrollInfo.vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    reg.enrollInfo.inputGovid = [CustomerInfo sharedInstance].govid;
    reg.enrollInfo.idpID = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
        
    NSString * body =[NSString stringWithFormat:@"{\"vehicleValidationStr\":%@%@%@}",@"\"",[SOSUtil AES128EncryptString:[reg mj_JSONString]],@"\""];

    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:body successBlock:^(SOSNetworkOperation *operation, NSString *responseStr) {
            @try {
                NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
                NSString *s = [SOSUtil AES128DecryptString:dic[@"enrollInfo"]];
                NSLog(@"encrypt :%@",s);
                NSDictionary *d = [Util dictionaryWithJsonString:s];
                if (operation.statusCode == 200) {
                    NNExtendedSubscriber *accountInfo = [NNExtendedSubscriber mj_objectWithKeyValues:d];
                    [CustomerInfo sharedInstance].changePhoneNo = accountInfo.mobile;
                    [CustomerInfo sharedInstance].changeEmailNo = accountInfo.email;
                    [CustomerInfo sharedInstance].licenseExpireDate = accountInfo.licenseExpireDate;
                    [CustomerInfo sharedInstance].province= accountInfo.province;
                    [CustomerInfo sharedInstance].city= accountInfo.city;
                    [CustomerInfo sharedInstance].address1= accountInfo.address;
                    [CustomerInfo sharedInstance].address2= accountInfo.address;
                    [CustomerInfo sharedInstance].zip= accountInfo.postcode;
                    
                    completion(accountInfo);
                }else{
                    !failCompletion ? : failCompletion();
                }
            }@catch (NSException *exception) {
                NSLog(@"exception jsonFormatError");
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            if (popError) {
                [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
            }
            !failCompletion ? : failCompletion();
        }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

/*
+ (void)getHeadPhoto:(void(^)(NNHeadPhotoResponse * headPhoto))completion Failed:(void (^)(void)) failCompletion	{
    NSString *url = [NSString stringWithFormat:@"%@%@?idpID=%@", BASE_URL, NEW_HEADPHOTO,[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        @try {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if (operation.statusCode == 200) {
                NNHeadPhotoResponse *headPhoto = [NNHeadPhotoResponse mj_objectWithKeyValues:dic];
                completion(headPhoto);
            }else{
                !failCompletion ? : failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {

    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}
*/

+ (void)updateHeadPhoto:(NSString *) headPhotoStr Suffix:(NSString *)suffix Success:(void (^)(NSDictionary *response))completion Failed:(void (^)(void))failCompletion		{
    
    [Util showLoadingView];
    
    NNHeadPhoto *headPhoto = [[NNHeadPhoto alloc] init];
    [headPhoto setIdpID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    [headPhoto setUserFace:headPhotoStr];
    [headPhoto setExtension:suffix];
    
    NSString *url = [BASE_URL stringByAppendingString:UPLOAD_AVATAR];
    NSString *post = [headPhoto mj_JSONString];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url
                                                                  params:post
                                                            successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        
        [Util hideLoadView];
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        dispatch_async_on_main_queue(^{
            completion(dic);
        });

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if([dic[@"description"] length]>0 && [dic[@"code"] length]> 0){
                NSString *errorMessage = [NSString stringWithFormat:@"%@",dic[@"description"]];
                [Util showAlertWithTitle:nil message:errorMessage completeBlock:nil];
            }else{
                [Util showAlertWithTitle:nil message:NSLocalizedString(@"Upload_failed", nil) completeBlock:nil];
            }
        });
    }];
    
    
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

+ (void)updatePassword:(NSString *) newpassword OldPassword:(NSString *)oldPassword  Success:(void(^)(NSString *response))completion Failed:(void(^)(NSString *failResponse))failCompletion	{
    ChangePasswordRequest *request = [[ChangePasswordRequest alloc] init];
    [request setOldPassword:oldPassword];
    [request setTheNewPassword:newpassword];
    

    NSString *url = [BASE_URL stringByAppendingFormat:NEW_CHANGE_PASSWORD, [CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSString *post = [request mj_JSONString];
    [Util showLoadingView];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(returnData);
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            failCompletion(responseStr);
        }); 
    }];
    [operation setHttpMethod:@"PUT"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
}

+ (void)updateMobileEmail:(NSString *) mobileEmail ValidateCode:(NSString *) validateCode Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion		{
    [Util showLoadingView];
    NNRegisterRequest *request = [[NNRegisterRequest alloc] init];
    [request setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [request setUserName:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    if([mobileEmail myContainsString:@"@"]){
        [request setTheNewEmailAddress:mobileEmail];
    }else{
        [request setTheNewMobilePhoneNumber:mobileEmail];
    }
    [request setSendCodeSenario:@"CHANGE_MOBILE_EMAIL"];
    [request setSecCode:validateCode];

    NSString *url = [BASE_URL stringByAppendingString:NEW_CHANGE_MOBILE_EMAIL];
    NSString *post = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
           dispatch_async(dispatch_get_main_queue(), ^{
                [Util hideLoadView];
               @try {
                   NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
                   NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
                   if (operation.statusCode == 200) {
                       completion(response);
                   }
               }
               @catch (NSException *exception) {
                   NSLog(@"exception jsonFormatError");
               }
           });
       } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [Util hideLoadView];
               [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
               failCompletion();
           });
       }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)getmobileEmailVerifyCode:(NSString *)mobileEmail Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion		{
    [Util showLoadingView];
    NNRegisterRequest *request = [[NNRegisterRequest alloc] init];
    [request setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [request setUserName:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    if([mobileEmail myContainsString:@"@"]){
        [request setTheNewEmailAddress:mobileEmail];
    }else{
        [request setTheNewMobilePhoneNumber:mobileEmail];
    }

    [request setSendCodeSenario:@"CHANGE_MOBILE_EMAIL"];

    NSString *url = [NSString stringWithFormat:(@"%@" NEW_CHANGE_GETCODE), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId?[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSString *post = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
           [Util hideLoadView];
           dispatch_async(dispatch_get_main_queue(), ^{
               @try {
                   NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
                   NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
                   if (operation.statusCode == 200) {
                       completion(response);
                   }
               }
               @catch (NSException *exception) {
                   NSLog(@"exception jsonFormatError");
               }
           });
       } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
           [Util hideLoadView];
           [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
       }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)updateContactAddress:(NNChangeAddressRequest *)address  Success:(void(^)(NSString *response))completion Failed:(void (^)(void))failCompletion	{
    [Util showLoadingView];
    NSString *url = [BASE_URL stringByAppendingString:NEW_CHANGE_MOBILE_EMAIL];
    NSString *post = [address mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
            @try {
                NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
                if (dic) {
                    completion(returnData);
                }
                else
                {
                    
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception jsonFormatError");
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
            [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
            failCompletion();
        });
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)updateUserNickName:(NSString *)nickName successBlock:(void(^)(NNRegisterResponse *response))completion failedBlock:(void (^)(void))failCompletion {
    NSString *url = [BASE_URL stringByAppendingString:Upgrade_User_Info];
    NSString *userId = [CustomerInfo sharedInstance].userBasicInfo.idpUserId;
    if (!userId) {
        [Util toastWithMessage:@"idpuserId不能为空"];
        failCompletion();
        return;
    }
    url = [url stringByAppendingString:userId];
    NSDictionary *dic = @{
                          @"nickName": nickName ? : @""
                          };
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:[dic mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
        if (dic) {
            completion(returnData);
        }

    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        !failCompletion ? : failCompletion();
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

#pragma mark--- 强制补充手机号使用,增加idpid参数
+ (void)getmobileEmailVerifyCode:(NSString *)mobileEmail withIDpid:(NSString *)idpid Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion        {
    [self getmobileEmailVerifyCode:mobileEmail withIDpid:idpid ShopuldReturnSourceData:YES Success:^(NSDictionary *dic) {
        NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
        completion(response);
    } Failed:^{
        if (failCompletion)		failCompletion();
    }];
}

+ (void)getmobileEmailVerifyCode:(NSString *)mobileEmail withIDpid:(NSString *)idpid ShopuldReturnSourceData:(BOOL)shouldReturnSource Success:(void(^)(NSDictionary *response))completion Failed:(void (^)(void))failCompletion		{
    [Util showLoadingView];
    NNRegisterRequest *request = [[NNRegisterRequest alloc] init];
    [request setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [request setUserName:idpid];
    if([mobileEmail myContainsString:@"@"]){
        [request setTheNewEmailAddress:mobileEmail];
    }else{
        [request setTheNewMobilePhoneNumber:mobileEmail];
    }
    
    [request setSendCodeSenario:@"CHANGE_MOBILE_EMAIL"];
    
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_CHANGE_GETCODE), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId?[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];
    NSString *post = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [Util hideLoadView];
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
                if (operation.statusCode == 200) {
                    if (completion) completion(dic);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception jsonFormatError");
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        if (failCompletion)	failCompletion();
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)updateMobileEmailWithoutLoadingView:(NSString *) mobileEmail withIDpid:(NSString *)idpid ValidateCode:(NSString *) validateCode Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(void))failCompletion		{
    [self updateMobileEmailWithoutLoadingView:mobileEmail withIDpid:idpid ValidateCode:validateCode needAlertError:YES Success:completion Failed:^(NSString *errorStr) {
        if (failCompletion) failCompletion();
    }];
}

+ (void)updateMobileEmailWithoutLoadingView:(NSString *) mobileEmail withIDpid:(NSString *)idpid ValidateCode:(NSString *) validateCode needAlertError:(BOOL)needAlert Success:(void(^)(NNRegisterResponse *response))completion Failed:(void (^)(NSString *errorStr))failCompletion	{
    NNRegisterRequest *request = [[NNRegisterRequest alloc] init];
    [request setSourceId:[[Util getCurrentDeviceID] objectForKey:CURRENT_DEVICE_ID]];
    [request setUserName:idpid];
    if ([mobileEmail myContainsString:@"@"]){
        [request setTheNewEmailAddress:mobileEmail];
    }	else	{
        [request setTheNewMobilePhoneNumber:mobileEmail];
    }
    [request setSendCodeSenario:@"CHANGE_MOBILE_EMAIL"];
    [request setSecCode:validateCode];
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_CHANGE_MOBILE_EMAIL];
    NSString *post = [request mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, id returnData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
                NNRegisterResponse *response = [NNRegisterResponse mj_objectWithKeyValues:dic];
                if (operation.statusCode == 200) {
                    completion(response);
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception jsonFormatError");
            }
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (needAlert) 	[Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        !failCompletion ? : failCompletion(responseStr);
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

#pragma mark---


+ (void)upLoadUserCustomizeQuickStart:(NSString *)qsStr  successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion{
    NSString *url = [BASE_URL stringByAppendingString:SOSUpload_User_Hotkey];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params: qsStr successBlock:^(SOSNetworkOperation *operation, id returnData) {
       
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}
+ (void)getUserOnstarSchedulesWithIdpid:(NSString *)mobile andDate:(NSString *)date  successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion{
    
    NSString *url = [BASE_URL stringByAppendingString:SOSUser_Schedules];
    
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params: [@{@"cusIdpuserId":mobile,@"remindDate":date} mj_JSONString] successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (completion) {
            completion(returnData);
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failCompletion) {
            failCompletion();
        }
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}
+ (void)bindClientScheduleIds:(NSArray *)schArr successBlock:(void(^)(NSString *response))completion failedBlock:(void(^)(void))failCompletion{
    
    if (schArr.count >0) {
        NSString *url = [BASE_URL stringByAppendingString:SOSUser_Schedules_Bind];
        NSString *paraString = [[SOSUserScheduleItem mj_keyValuesArrayWithObjectArray:schArr] mj_JSONString];
        
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:paraString successBlock:^(SOSNetworkOperation *operation, id returnData) {
            if (completion) {
                completion(returnData);
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            if (failCompletion) {
                failCompletion();
            }
        }];
        [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [operation setHttpMethod:@"POST"];
        [operation start];
    }
    
}
+ (void)updateInfoReadStatusWithNotifyId:(NSString *)nId isDelete:(BOOL)isDel{
    NSString * method;
    NSString *url;
    if (isDel) {
        //删除
        method = @"DELETE";
        url = [NSString stringWithFormat:(@"%@" SOS_UpdateMessage_Delete), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId,nId];

    }else{
        //更新已读
         method = @"PUT";
       url = [BASE_URL stringByAppendingString:SOS_UpdateMessage_Read];
    }

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:@{@"notificationId":nId}.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id returnData) {
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:method];
    [operation start];
}

+ (void)queryUserWechatBindStatusHandler:(void(^)(BOOL hasBind))complete{
   
    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,SOSOnstarUserBindWechatQueryURL];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil   successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
        if (dic) {
            
            if ([[dic objectForKey:@"isBind"] boolValue]) {
                complete(YES);
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}
+ (void)unBindUserWechatHandler:(void(^)(BOOL unBindResult))complete{

    NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,SOSOnstarUserUnBindWechatURL];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
        if (dic) {
            if ([[dic objectForKey:@"unBindResult"] boolValue]) {
                complete(YES);
                return ;
            }
        }
         complete(NO);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        complete(NO);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"PUT"];
    [operation start];
}

+ (void)cheeckNeedVerifyPersionInfoBlock:(void (^)(bool needVerify,NSString * verUrl, NSString *verifyTip))complete{
    if ([SOSCheckRoleUtil isOwner]) {
        NSString *url = [NSString stringWithFormat:@"%@%@",BASE_URL,SOSOnstarUserRealNameVerifyURL];
        
//        SOSNetWorkCacheConfig * config = [[SOSNetWorkCacheConfig alloc] init];
//        config.cacheKey = [NSString stringWithFormat:@"%@%@%@",[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@"nameVerify"];
        SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil cacheConfig:nil  successBlock:^(SOSNetworkOperation *operation, id returnData) {
            NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
            if (dic) {
                if ([[dic objectForKey:@"verifyFlag"] boolValue]) {
                    complete(YES,[dic objectForKey:@"verifyUrl"],[dic objectForKey:@"verifyTip"]);
                }
            }
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            
        }];
           [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
           [operation setHttpMethod:@"GET"];
           [operation start];
    }
}
@end
