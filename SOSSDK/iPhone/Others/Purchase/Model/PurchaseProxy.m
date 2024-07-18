//
//  PurchaseProxy.m
//  Onstar
//
//  Created by Joshua on 6/5/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PurchaseProxy.h"
#import "AppPreferences.h"
#import "PurchaseModel.h"
#import "Util.h"
#import "CustomerInfo.h"
#import "RequestDataObject.h"
#import "ResponseDataObject.h"

static PurchaseProxy *instance = nil;
@implementation PurchaseProxy

+ (PurchaseProxy *)sharedInstance     {
    static PurchaseProxy *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}

+ (void)purgeSharedInstance     {
    instance = nil;
}

- (id)init     {
    self = [super init];
    listenerArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)addListener:(id<ProxyListener>)listener     {
    if (listener && ![listenerArray containsObject:listener]) {
        [listenerArray addObject:listener];
    }
}

- (void)removeListener:(id<ProxyListener>)listener     {
    if (listener && [listenerArray containsObject:listener]) {
        [listenerArray removeObject:listener];
    }
}

#pragma mark - request
- (void)sendRequestParams:(NSString *)requestParams toURL:(NSString *)url async:(BOOL)isAsync purchaseRequestType:(PurchaseRequestType)requestType netWorkHttpType:(NSString *)httpTypeStr     {
        if (isAsync)
        {
            SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url
                                                    params:requestParams
                                              successBlock:^(SOSNetworkOperation *operation, id returnData) {
                                                  
                                                  [self requestFinished:returnData withRequestType:requestType];
                                                  
                                              } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                  [self requestFailed:responseStr];
                                              }];
            [sosOperation setHttpMethod:httpTypeStr];
            [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];

            [sosOperation start];
        }
        else
        {
            SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url
                                                    params:requestParams
                                              successBlock:^(SOSNetworkOperation *operation, id returnData) {
                                                  
                                                  [self requestFinished:returnData withRequestType:requestType];
                                                  
                                              } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                                                  [self requestFailed:responseStr];
                                              }];
            [sosOperation setHttpMethod:httpTypeStr];
            [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
            [sosOperation startSync];

        }
}


#pragma mark - request    获取后端返回即将使用的支付信息
- (void)payOrderSendRequestParams:(NSString *)requestParams toURL:(NSString *)url async:(BOOL)isAsync purchaseRequestType:(PurchaseRequestType)requestType netWorkHttpType:(NSString *)httpTypeStr     {
    if (isAsync)	{
        SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:requestParams successBlock:^(SOSNetworkOperation *operation, id returnData) {
            
            [self payOrderRequestFinished:returnData withRequestType:requestType];
            
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [self payOrderRequestFailed:responseStr];
        }];
        [sosOperation setHttpMethod:httpTypeStr];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation start];
    }	else	{
        SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:requestParams successBlock:^(SOSNetworkOperation *operation, id returnData) {
            [self payOrderRequestFinished:returnData withRequestType:requestType];
        } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
            [self payOrderRequestFailed:responseStr];
        }];
        [sosOperation setHttpMethod:httpTypeStr];
        [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
        [sosOperation startSync];
        
    }
}

#pragma mark - 获取当前用户车辆可以购买的套餐列表
- (void)getPackageList
{
//    NSString *packageType;
//    NSString *versionCodeStr = [NSString stringWithFormat:@"%@",@([Util getAppVersionCode])];
    NSString *url = @"";
    if ([PurchaseModel sharedInstance].purchaseType == PurchaseTypeData) {
        //packageType = @"DATA";
        url = [BASE_URL stringByAppendingString:NEW_PURCHASE_PACKAGE_DATA];
        
    }else{
        //packageType = @"CORE";
        url = [BASE_URL stringByAppendingString:NEW_PURCHASE_PACKAGE_CORE];
    }
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PURCHASE_PACKAGE), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
//    url = [url stringByAppendingFormat:@"&packageType=%@",packageType];
    url = [url stringByAppendingFormat:@"&vin=%@",[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    [self sendRequestParams:nil toURL:url async:YES purchaseRequestType:RequestGetPackageListByVin netWorkHttpType:@"GET"];
}
#pragma mark - 获取支付信息
- (void)getPayInfoByPayType:(NSString *)payType mspOrderString:(NSString *)orderStr sucessHandler:(void(^)(NSString *payPara))sucess failureHandler:(void(^)(NSString *failStr))failure
{
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_PURCHASE_ORDER_INFO), BASE_URL, payType];
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:orderStr successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSLog(@"======getPayInfoByPayType=========%@",returnData);
        sucess(returnData);
    }	failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error)		{
        failure(responseStr);
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"PUT"];
    [sosOperation start];

}

#pragma mark - 创建订单
- (void)createOrder     {
    NSString *packageType;
    if ([PurchaseModel sharedInstance].purchaseType == PurchaseTypeData) {
        packageType = @"DATA";
    } else {
        packageType = @"CORE";
    }
/*
    NSString *url = [NSString stringWithFormat:(@"%@" SOS_Order_Creat_URL), BASE_URL];
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"actualPrice"] = package.actualPrice;
    parameters[@"total"] = package.annualPrice;
    parameters[@"discount"] = package.discountAmount;
    
    parameters[@"discountId"] = package.discountId;
    parameters[@"duration"] = package.duration;
    parameters[@"durationUnit"] = package.durationUnit;
    parameters[@"offeringId"] = package.offerId;
    parameters[@"offeringName"] = package.offerName;
    parameters[@"orderType"] = packageType;
    parameters[@"partyId"] = [PurchaseModel sharedInstance].idpid;
    parameters[@"productNumber"] = package.productNumber;
    parameters[@"vin"] = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
 
    parameters[@"buyChannel"] = @"Mobile";
    parameters[@"operType"] = @"create";
    parameters[@"partyType"] = @"Mobile";
 */
    NSString *url = [NSString stringWithFormat:(@"%@" SOS_Order_Creat_LBS_URL), BASE_URL];
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"buyChannel"] = @"Mobile";
    parameters[@"isLBSPackage"] = package.isLBSPackage;
    parameters[@"offeringId"] = package.offerId;
    parameters[@"offeringName"] = package.offerName;
    parameters[@"orderType"] = packageType;
    parameters[@"productNumber"] = package.productNumber;
    parameters[@"vin"] = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    if ([package.isLBSPackage integerValue] == 1) { // 如果是LBS套餐就走LBS
        parameters[@"deliveryAddr"] = package.deliveryAddr;
        parameters[@"deliveryName"] = package.deliveryName;
        parameters[@"deliveryPhone"] = package.deliveryPhone;
    }
    parameters[@"imei"] = @""; //创建订单时客户端拿不到这个字段，传空
    parameters[@"platform"] = @"ONSTAR_IOS";

    NSString *requestParamStr = [parameters mj_JSONString];
    [self payOrderSendRequestParams:requestParamStr toURL:url async:YES purchaseRequestType:RequestCreateOrder netWorkHttpType:@"POST"];
}
#pragma mark 创建LBS订单
- (void)createLBSOrder {
    NSString *packageType;
    if ([PurchaseModel sharedInstance].purchaseType == PurchaseTypeData) {
        packageType = @"DATA";
    } else {
        packageType = @"CORE";
    }
    NSString *url = [NSString stringWithFormat:(@"%@" SOS_Order_Creat_LBS_URL), BASE_URL];
    PackageInfos *package = [PurchaseModel sharedInstance].selectPackageInfo;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"buyChannel"] = @"Mobile";
    parameters[@"isLBSPackage"] = package.isLBSPackage;
    parameters[@"offeringId"] = package.offerId;
    parameters[@"offeringName"] = package.offerName;
    parameters[@"orderType"] = packageType;
    parameters[@"productNumber"] = package.productNumber;
    parameters[@"vin"] = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
    if ([package.isLBSPackage integerValue] == 1) { // 如果是LBS套餐就走LBS
        parameters[@"deliveryAddr"] = package.deliveryAddr;
        parameters[@"deliveryName"] = package.deliveryName;
        parameters[@"deliveryPhone"] = package.deliveryPhone;
    }
    parameters[@"imei"] = @""; //创建订单时客户端拿不到这个字段，传空
    parameters[@"platform"] = @"ONSTAR_IOS";
    
    NSString *requestParamStr = [parameters mj_JSONString];
    [self payOrderSendRequestParams:requestParamStr toURL:url async:YES purchaseRequestType:RequestCreateOrder netWorkHttpType:@"POST"];
}
- (void)saveInvoice     {
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PURCHASE_SAVE_INVOICE_URL), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,[PurchaseModel sharedInstance].selectedPackageId,[PurchaseModel sharedInstance].orderId];
    [self sendRequestParams:nil toURL:url async:YES purchaseRequestType:RequestSaveInvoice netWorkHttpType:@"GET"];
}

- (void)queryOrderStatusWithOrderID:(NSString *)orderID     {
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PURCHASE_QUERY_ORDER_STATUS_URL), BASE_URL, orderID];
    [self sendRequestParams:nil toURL:url async:NO purchaseRequestType:RequestQueryOrderStatusById netWorkHttpType:@"GET"];
}

- (void)getOrderHistoryInPage:(NSInteger)pageNum Size:(NSInteger)size     {
    NSString *packageType;
    if ([PurchaseModel sharedInstance].purchaseType == PurchaseTypeData) {
        packageType = @"DATA";
    } else {
        packageType = @"CORE";
    }
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PURCHASE_GET_ORDER_HISTORY), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,packageType,[NSString stringWithFormat:@"%ld",(long)pageNum],[NSString stringWithFormat:@"%ld",(long)size]];
    [self sendRequestParams:nil toURL:url async:YES purchaseRequestType:RequestGetOrderHistory netWorkHttpType:@"GET"];
}

#pragma mark - PPC request
- (void)getAccountInfoByVin:(NSString *)vin     {
    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PPC_GET_ACCOUNT_BY_VIN), BASE_URL, vin];
    [self sendRequestParams:nil toURL:url async:YES purchaseRequestType:RequestGetAccountByVin netWorkHttpType:@"GET"];
}

- (void)validatePPC:(BOOL)isFromVinConfirm     {
    NNPurchaseRequest *request = [[NNPurchaseRequest alloc] init];
    [request setCardNo:[SOSUtil AES128EncryptString:[[PurchaseModel sharedInstance] ppcCardNo]]];
    [request setPassWord:[SOSUtil AES128EncryptString:[[PurchaseModel sharedInstance] ppcCardPasswd]]];
    [request setOsType:[Util osType]];
    [request setOperation:@"VALIDATE"];
 
    NSString *url = [BASE_URL stringByAppendingString:NEW_PPC_ACTIVATE_CARD_BY_ID];
    if (isFromVinConfirm) {
//        NNExtendedSubscriber *subscriber = [PurchaseModel sharedInstance].getAccountInfoResponse;
//        url = [NSString stringWithFormat:(@"%@" NEW_PPC_ACTIVATE_CARD_BY_ID), BASE_URL, subscriber.idpID, subscriber.defaultAccountID, [PurchaseModel sharedInstance].ppcVehicle.vin];
        [request setVehicleId:[PurchaseModel sharedInstance].ppcVehicle.vin];
    } else {
//        url = [NSString stringWithFormat:(@"%@" NEW_PPC_ACTIVATE_CARD_BY_ID), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [request setVehicleId:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }
    NSString *requestStr = [request mj_JSONString];
    [self sendRequestParams:requestStr toURL:url async:YES purchaseRequestType:RequestValidateCardById netWorkHttpType:@"POST"];
}

- (void)activatePPCById:(NSString *)type     {
    NNPurchaseRequest *request = [[NNPurchaseRequest alloc] init];
    [request setCardNo:[SOSUtil AES128EncryptString:[[PurchaseModel sharedInstance] ppcCardNo]]];
    [request setPassWord:[SOSUtil AES128EncryptString:[[PurchaseModel sharedInstance] ppcCardPasswd]]];
    [request setOsType:[Util osType]];
    [request setOperation:@"ACTIVATE"];
    
    NSString *url = [BASE_URL stringByAppendingString:NEW_PPC_ACTIVATE_CARD_BY_ID];
    if ([type isEqualToString:@"Other"]) {
//         NNExtendedSubscriber *subscriber = [PurchaseModel sharedInstance].getAccountInfoResponse;
//        url = [NSString stringWithFormat:(@"%@" NEW_PPC_ACTIVATE_CARD_BY_ID), BASE_URL, subscriber.idpID, subscriber.defaultAccountID, [PurchaseModel sharedInstance].ppcVehicle.vin];
        [request setVehicleId:[PurchaseModel sharedInstance].ppcVehicle.vin];
    } else {
//        url = [NSString stringWithFormat:(@"%@" NEW_PPC_ACTIVATE_CARD_BY_ID), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
        [request setVehicleId:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    }
    NSString *requestStr = [request mj_JSONString];
    [self sendRequestParams:requestStr toURL:url async:YES purchaseRequestType:RequestActivateCardById netWorkHttpType:@"POST"];
}

- (void)getActivateHistoryInPage:(NSInteger)pageNum Size:(NSInteger)size     {
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_PPC_GET_ACTIVATE_HISTORY), BASE_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.account.accountId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,[Util osType]];
    NSString *url = [BASE_URL stringByAppendingFormat:NEW_PPC_GET_ACTIVATE_HISTORY,[Util osType]];

    [self sendRequestParams:nil toURL:url async:YES purchaseRequestType:RequestGetActivateHistory netWorkHttpType:@"GET"];
}



#pragma mark - response
//非支付
- (void)requestFinished:(NSString *)request withRequestType:(PurchaseRequestType)type     {
    NSDictionary *rootStr = [Util dictionaryWithJsonString:request];
    switch (type) {
        case RequestGetPackageListByVin:
            [self parseGetPackageListResponse:rootStr];
            break;
        case RequestCreateOrder:
            [PurchaseModel sharedInstance].createOrderResDic = rootStr;
            [PurchaseModel sharedInstance].createOrderResponse = [NNCreateOrderResponse mj_objectWithKeyValues:rootStr];
            break;
        case RequestSaveInvoice:
            [self parseSaveInvoiceResponse:rootStr];
            break;
        case RequestQueryOrderStatusById:
            [self parseQueryOrderStatusResponse:rootStr];
            break;
        case RequestGetOrderHistory:
            [self parseGetOrderHistoryResponse:rootStr];
            break;
        case RequestGetAccountByVin:
            [self parseGetAccountInfoByVinResponse:rootStr];
            break;
        case RequestValidateCardById:
            [self parseValidatePPCByIdResponse:rootStr];
            break;
        case RequestActivateCardById:
            [self parseActivatePPCByIdResponse:rootStr];
            break;
        case RequestGetActivateHistory:
            [self parseGetActivateHistory:rootStr];
            break;
        case RequestGetWapPayURL:
            [self parseGetWapPayUrl:rootStr];
            break;
        default:
            break;
    }
    
    if ([listenerArray count] > 0) {
        for (id<ProxyListener> listener in listenerArray) {
            [listener proxyDidFinishRequest:YES withObject:nil];
        }
    }
}


// 支付
- (void)payOrderRequestFinished:(NSString *)request withRequestType:(PurchaseRequestType)type     {
    NSDictionary *rootStr = [Util dictionaryWithJsonString:request];
    switch (type) {
        case RequestGetPackageListByVin:
            [self parseGetPackageListResponse:rootStr];
            break;
        case RequestCreateOrder:
        {
            [PurchaseModel sharedInstance].createOrderResponse = [NNCreateOrderResponse mj_objectWithKeyValues:rootStr];
            [PurchaseModel sharedInstance].createOrderResDic = rootStr;
        }
            break;
        case RequestSaveInvoice:
            [self parseSaveInvoiceResponse:rootStr];
            break;
        case RequestQueryOrderStatusById:
            [self parseQueryOrderStatusResponse:rootStr];
            break;
        case RequestGetOrderHistory:
            [self parseGetOrderHistoryResponse:rootStr];
            break;
        case RequestGetAccountByVin:
            [self parseGetAccountInfoByVinResponse:rootStr];
            break;
        case RequestValidateCardById:
            [self parseValidatePPCByIdResponse:rootStr];
            break;
        case RequestActivateCardById:
            [self parseActivatePPCByIdResponse:rootStr];
            break;
        case RequestGetActivateHistory:
            [self parseGetActivateHistory:rootStr];
            break;
        case RequestGetWapPayURL:
            [self parseGetWapPayUrl:rootStr];
            break;
        default:
            break;
    }
    
    if ([listenerArray count] > 0) {
        for (id<ProxyListener> listener in listenerArray) {
            [listener payOrderProxyDidFinishRequest:YES withObject:nil];
        }
    }
}

- (void)requestFailed:(NSString *)responseError     {
    if ([listenerArray count] > 0) {
        for (id<ProxyListener> listener in listenerArray) {
            [listener proxyDidFinishRequest:NO withObject:responseError];
        }
    }
}

// 支付失败
- (void)payOrderRequestFailed:(NSString *)responseError     {
    if ([listenerArray count] > 0) {
        for (id<ProxyListener> listener in listenerArray) {
            [listener payOrderProxyDidFinishRequest:NO withObject:responseError];
        }
    }
}

- (void)parseGetPackageListResponse:(NSDictionary *)responseDict     {
    PackageListResponse *response;

    if (responseDict && [responseDict isKindOfClass:[NSArray class]])
    {
       response = [[PackageListResponse alloc] init];
       [response setPackageArray:[PackageInfos mj_objectArrayWithKeyValuesArray:(NSArray *)responseDict]];
    }
    else
    {
        //to be delete
        //[[PackageListResponse alloc] initWithDictionary:responseDict];
        response = [PackageListResponse mj_objectWithKeyValues:responseDict];
    }
    [[PurchaseModel sharedInstance] setPackageListResponse:response];
}

- (void)parseQueryOrderStatusResponse:(NSDictionary *)responseDict     {
//    QueryOrderStatusResponse *response = [[QueryOrderStatusResponse alloc] initWithElement:responseXML];
//    [[PurchaseModel sharedInstance] setQueryOrderStatusResponse:response];
//    [response release];
    NNQueryOrderStatusResponse *response = [NNQueryOrderStatusResponse mj_objectWithKeyValues:responseDict];
//    [[NNQueryOrderStatusResponse alloc] initWithDictionary:responseDict];
    [[PurchaseModel sharedInstance] setQueryOrderStatusResponse:response];
}

- (void)parseGetOrderHistoryResponse:(NSDictionary *)responseDict     {
    NNGetOrderHistoryResponse *response = [NNGetOrderHistoryResponse mj_objectWithKeyValues:responseDict];
    [[PurchaseModel sharedInstance] setGetOrderHistoryResponse:response];
}

- (void)parseSaveInvoiceResponse:(NSDictionary *)responseDict     {
//    SaveInvoiceResponse *response = [[SaveInvoiceResponse alloc] initWithElement:responseXML];
//    [[PurchaseModel sharedInstance] setSaveInvoieResponse:response];
//    [response release];
}

#pragma mark - PPC response parse
- (void)parseGetAccountInfoByVinResponse:(NSDictionary *)responseDict     {
    NNExtendedSubscriber *subscriber = [NNExtendedSubscriber mj_objectWithKeyValues:responseDict];//[[NNExtendedSubscriber alloc] initWithDictionary:responseDict];
    [[PurchaseModel sharedInstance] setGetAccountInfoResponse:subscriber];
}

- (void)parseValidatePPCByIdResponse:(NSDictionary *)responseDict     {
    NNActivatePPCResponse *response = [NNActivatePPCResponse mj_objectWithKeyValues:responseDict];
    [[PurchaseModel sharedInstance] setValidateResponse:response];
}

- (void)parseActivatePPCByIdResponse:(NSDictionary *)responseDict     {
    NNActivatePPCResponse *response = [NNActivatePPCResponse mj_objectWithKeyValues:responseDict];
    [[PurchaseModel sharedInstance] setActivatePPCResponse:response];
}

- (void)parseGetActivateHistory:(NSDictionary *)responseDict     {
    NNGetActivateHistoryResponse *response = [NNGetActivateHistoryResponse mj_objectWithKeyValues:responseDict];
    [[PurchaseModel sharedInstance] setGetActivateHistoryResponse:response];
}

- (void)parseGetWapPayUrl:(NSDictionary *)responseDict     {
    NNGetWapPayUrlResponse *response = [NNGetWapPayUrlResponse mj_objectWithKeyValues:responseDict];
    [[PurchaseModel sharedInstance] setGetWapPayUrlResponse:response];
}

- (void)dealloc     {
    [listenerArray removeAllObjects];
}

@end
