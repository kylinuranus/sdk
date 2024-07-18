//
//  SOSPay.m
//  Pods
//
//  Created by onstar on 2019/8/27.
//

#import "SOSPay.h"
#import "LoadingView.h"
@implementation SOSPay
+ (void)openURL:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic) {
             NSLog(@"result = %@", resultDic);
             [[AlipayClient sharedInstance] handleAlipayDictResult:resultDic];
         }];
    }
}
+ (BOOL)fetchInfoFromUrl:(NSString*)urlStr {
//    NSString *orderInfo = [[AlipaySDK defaultService] fetchOrderInfoFromH5PayUrl:urlStr];
//    return orderInfo;
    
//payInterceptorWithUrl:(NSString *)urlStr
//                   fromScheme:(NSString *)schemeStr
//                     callback:(CompletionBlock)completionBlock;
    return  [[AlipaySDK defaultService] payInterceptorWithUrl:urlStr fromScheme:[SOSSDKKeyUtils paySchemeUrl] callback:^(NSDictionary *resultDic) {
        [[AlipayClient sharedInstance] handleAlipayDictResult:resultDic];
    }];
}

//+ (void)payWithUrlOrder:(NSString*)urlOrder
//{
//    if (urlOrder.length > 0) {
//        [[AlipaySDK defaultService] payUrlOrder:urlOrder fromScheme:[SOSSDKKeyUtils paySchemeUrl] callback:^(NSDictionary* result) {
//            NSLog(@"%@",result);
//            [[AlipayClient sharedInstance] handleAlipayDictResult:result];
//        }];
//    }
//}

+ (void)payWithcreateOrderResDic:(NSDictionary *)createOrderResDic target:(id)target{
    NSString * payType ;
    [[NSNotificationCenter defaultCenter] addObserver:target selector:@selector(observePayResponse:) name:SOSpaySuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:target selector:@selector(observePayResponse:) name:SOSpayFailNotification object:nil];
    payType = @"alipay";
    
    id actualPrice = createOrderResDic[@"actualPrice"];
    if ([actualPrice isKindOfClass:[NSNumber class]]) {
        actualPrice = [actualPrice stringValue];
    }
    id orderId = createOrderResDic[@"orderId"];
    if ([orderId isKindOfClass:[NSNumber class]]) {
        orderId = [orderId stringValue];
    }
    
    SOSLoginUserDefaultVehicleVO *userInfo = [CustomerInfo sharedInstance].userBasicInfo;
    NSDictionary *dic = @{@"actualPrice": actualPrice?:@"",
                          @"defaultAccountID": userInfo.currentSuite.account.accountId,
                          @"email": NONil(userInfo.subscriber.emailAddress),
                          @"orderId": orderId?:@"",
                          @"packageName": createOrderResDic[@"offeringName"]?:@"",
                          @"phoneNumber": NONil(userInfo.idmUser.mobilePhoneNumber)};
    
    [[PurchaseProxy sharedInstance] getPayInfoByPayType:payType mspOrderString:dic.mj_JSONString sucessHandler:^(NSString *payPara){
        [[LoadingView sharedInstance] stop];
//        PayReq * payReqFromMSP = [PayReq mj_objectWithKeyValues:payPara];
        NSDictionary *payReqFromMSP = payPara.mj_JSONObject;
        
        if (payReqFromMSP) {
            [[AlipayClient sharedInstance] payWithOrderString:payReqFromMSP[@"sign"]];
        }    else     {
            [Util showAlertWithTitle:nil message:payPara completeBlock:nil];
        }
        
        
    } failureHandler:^(NSString *failStr){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[LoadingView sharedInstance] stop];
            [Util showAlertWithTitle:nil message:failStr completeBlock:nil];
        });
        
    }];
    
}

+ (NSString *)payErrorMsg {
    return [[AlipayClient sharedInstance] errorMsg];
}

+ (BOOL)gotoStore {
    return ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]];
}

@end
