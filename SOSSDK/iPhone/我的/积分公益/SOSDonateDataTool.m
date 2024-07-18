//
//  SOSDonateDataTool.m
//  Onstar
//
//  Created by Coir on 2018/9/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSDonateDataTool.h"
#import "SOSDateFormatter.h"

#define SOSDonateUserDataInfoKey	@"SOSDonateUserDataInfoKey"

@implementation SOSDonateDataObj
@end
@implementation SOSDonateUserInfo
@end

@implementation SOSDonateDataTool


+ (void)getDonateInfoSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure    {
    NSString *url = [NSString stringWithFormat:(@"%@" SOSGetUserDonateInfoURL), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (success) 	success(operation, [returnData mj_JSONObject]);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure)	failure(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

+ (void)getActivityListSuccess:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure        {
    NSString *url = [NSString stringWithFormat:(@"%@" SOSGetDonateActivityListURL), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if (success)     success(operation, [returnData mj_JSONObject]);
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure)    failure(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

+ (void)modifyUserDonateInfoWithActionType:(SOSDonateOperationType)operationType Success:(SOSSuccessBlock)success Failure:(SOSFailureBlock)failure    {
    if (operationType == SOSDonateOperationType_Non)								return;
    if (![[LoginManage sharedInstance] isLoadingUserBasicInfoReady])				return;
    NSMutableDictionary *parameters = [SOSDonateDataTool getParametersWithActionType:operationType];
    // 同一天内,同一种操作最多加分 maxNum 次
    if ([SOSDonateDataTool getSavedNumWithOperationType:operationType] >= [parameters[@"maxNum"] intValue])        return;
    
    NSString *url = [NSString stringWithFormat:(@"%@" SOSGetUserDonateInfoURL), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId];
    [parameters removeObjectForKey:@"maxNum"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:parameters.mj_JSONString successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *resDic = [returnData mj_JSONObject];
        if (success)     success(operation, resDic);
        if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
            NSString *code = resDic[@"code"];
            if ([code isKindOfClass:[NSString class]] && [code.uppercaseString isEqualToString:@"E0000"]) {
                // 保存操作结果
                [SOSDonateDataTool saveResultWithOperationType:operationType];
            }
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (failure)    failure(statusCode, responseStr, error);
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}

+ (int)getSavedNumWithOperationType:(SOSDonateOperationType)operationType	{
    NSString *operationStr = [SOSDonateDataTool getParametersWithActionType:operationType][@"operationalBehavior"];
    NSMutableDictionary *sourceDic = [UserDefaults_Get_Object(SOSDonateUserDataInfoKey) mutableCopy];
    NSString *idpUserID = [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId;
    if (sourceDic.count) {
        NSMutableDictionary *userDic = [sourceDic[idpUserID] mutableCopy];
        if (userDic.count) {
            NSArray *dataArray = userDic[operationStr];
            if (dataArray.count) {
                NSDate *lastActionDate = dataArray[1];
                /// 上一条记录是在今天
                if ([SOSDonateDataTool isActionDateAtToday:lastActionDate]) {
                    int actionCount = [dataArray[0] intValue];
                    return actionCount;
                }
            }
        }
    }
    return 0;
}

+ (void)saveResultWithOperationType:(SOSDonateOperationType)operationType    {
    /*
    { SOSDonateUserDataInfoKey:
          { idpUserid:
              { @"OperationType1": @[ countNum, Date]
                   @"OperationType2": @[ countNum, Date] ...    }}}            */
    
    NSString *operationStr = [SOSDonateDataTool getParametersWithActionType:operationType][@"operationalBehavior"];
    NSMutableDictionary *sourceDic = [UserDefaults_Get_Object(SOSDonateUserDataInfoKey) mutableCopy];
    NSString *idpUserID = [CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId;
    if (idpUserID.isNotBlank) {
        if (sourceDic.count>0 && sourceDic[idpUserID]) {
               NSMutableDictionary *userDic = [sourceDic[idpUserID] mutableCopy];
               if (userDic.count) {
                   NSArray *dataArray = userDic[operationStr];
                   if (dataArray.count) {
                       NSDate *lastActionDate = dataArray[1];
                       /// 上一条记录是在今天
                       if ([SOSDonateDataTool isActionDateAtToday:lastActionDate]) {
                           int actionCount = [dataArray[0] intValue];
                           actionCount ++;
                           dataArray = @[@(actionCount), [NSDate date]];
                       }
                   }    else    {
                       dataArray = @[@(1), [NSDate date]];
                   }
                   userDic[operationStr] = dataArray;         // 更新记录
               }    else    {
                   userDic = @{operationStr: @[@(1), [NSDate date]]}.mutableCopy;    // 新建记录
               }
               sourceDic[idpUserID] = userDic;        //更新记录
           }    else    {    // 新建记录
               sourceDic = @{idpUserID: @{operationStr: @[@(1), [NSDate date]]}}.mutableCopy;
           }
           UserDefaults_Set_Object(sourceDic, SOSDonateUserDataInfoKey);
    }
   
}

+ (BOOL)isActionDateAtToday:(NSDate *)lastActionDate	{
    NSString *lastActionDateStr = [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"yyyy-MM-dd" Date:lastActionDate timeZone:@"GMT+0800"];
    NSString *nowDateStr = [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"yyyy-MM-dd" Date:[NSDate date] timeZone:@"GMT+0800"];
    if ([lastActionDateStr isEqualToString:nowDateStr]) 	 return YES;
    return NO;
}

+ (SOSDonateOperationType)getDonateOperationTypeWithRemoteOperationType:(SOSRemoteOperationType)remoteType	{
    switch (remoteType) {
        case SOSRemoteOperationType_LockCar:
            return SOSDonateOperationType_LockCar;
            
        case SOSRemoteOperationType_UnLockCar:
            return SOSDonateOperationType_UnlockCar;
            
        case SOSRemoteOperationType_RemoteStart:
            return SOSDonateOperationType_Remote_Start;
            
        case SOSRemoteOperationType_RemoteStartCancel:
            return SOSDonateOperationType_Remote_StartCancel;
            
        case SOSRemoteOperationType_Horn:
        case SOSRemoteOperationType_Light:
        case SOSRemoteOperationType_LightAndHorn:
            return SOSDonateOperationType_LightAndHorn;
        case SOSRemoteOperationType_VehicleLocation:
            return SOSDonateOperationType_Car_Location;
        default:
            break;
    }
    return SOSDonateOperationType_Non;
}

+ (NSMutableDictionary *)getParametersWithActionType:(SOSDonateOperationType)actionType	{
    int maxNum = 0;
    NSString *operationString = @"";
    switch (actionType) {
        case SOSDonateOperationType_Login:
            maxNum = 1;
            operationString = @"LOGIN";
            break;
        case SOSDonateOperationType_LockCar:
            maxNum = 5;
            operationString = @"LOCKED";
            break;
        case SOSDonateOperationType_UnlockCar:
            maxNum = 5;
            operationString = @"UNLOCK";
            break;
        case SOSDonateOperationType_Remote_Start:
            maxNum = 5;
            operationString = @"START_UP";
            break;
        case SOSDonateOperationType_Remote_StartCancel:
            maxNum = 5;
            operationString = @"CANCEL_START";
            break;
        case SOSDonateOperationType_Car_Location:
            maxNum = 5;
            operationString = @"POSITIONING";
            break;
        case SOSDonateOperationType_LightAndHorn:
            maxNum = 5;
            operationString = @"FLASHING_WHISTLE";
            break;
        case SOSDonateOperationType_Behavior_Score:
            maxNum = 1;
            operationString = @"BEHAVIORAL_SCORE";
            break;
        case SOSDonateOperationType_Fuel_Rank:
            maxNum = 1;
            operationString = @"FUEL_CONSUMPTION";
            break;
        default:
            break;
    }
    NSString *idpUserId = [[CustomerInfo sharedInstance].userBasicInfo.idmUser.idpUserId copy];
    NSString *phoneNumber = [[CustomerInfo sharedInstance].userBasicInfo.idmUser.mobilePhoneNumber copy];
    NSDictionary *parameters = @{@"channel": @"get",
                                 @"integralNo": @(1),
                                 @"operationalBehavior": operationString,
                                 @"idpUserId": idpUserId.length ? idpUserId : @"",
                                 @"phoneNumber": phoneNumber.length ? phoneNumber : @"",
                                 @"maxNum": @(maxNum) /* 此字段用于统计最大加分值,不上传 */};
    return parameters.mutableCopy;
}

+ (void)addLoginObserver	{
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:SOS_APP_DELEGATE] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户登录, 获取Suit成功
        if ([newValue isKindOfClass:[NSNumber class]] && [newValue intValue] == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
            [SOSDonateDataTool modifyUserDonateInfoWithActionType:SOSDonateOperationType_Login Success:nil Failure:nil];
        }
    }];
}

@end
