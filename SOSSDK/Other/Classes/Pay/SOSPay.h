//
//  SOSPay.h
//  Pods
//
//  Created by onstar on 2019/8/27.
//

#import <Foundation/Foundation.h>
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayClient.h"

/*AlipayClient*/
#define SOSpaySuccessNotification             @"paySuccessNotification"
#define SOSpayFailNotification                @"payFailNotification"
#define SOSPayFinishNotification              @"PayFinishNotification"
#define SOSpayH5SuccessNotification           @"payH5SuccessNotification"

#define MSGAlipayCancel                        @"用户中途取消"
#define MSGAlipayError                         @"订单支付失败"
#define MSGAlipayConnectError                  @"网络连接出错"

#define SOSPayServicePamara @"&service=alipay.wap.auth.authAndExecute"
#define SOSPayAuthPamara @"alipay.wap.auth.authAndExecute"

NS_ASSUME_NONNULL_BEGIN

@interface SOSPay : NSObject
+ (void)openURL:(NSURL *)url ;
+ (BOOL)fetchInfoFromUrl:(NSString*)urlStr;

//+ (void)payWithUrlOrder:(NSString*)urlOrder;

+ (void)payWithcreateOrderResDic:(NSDictionary *)createOrderResDic target:(id)target;

+ (NSString *)payErrorMsg;

+ (BOOL)gotoStore;

@end

NS_ASSUME_NONNULL_END
