//
//  PurchaseProxy.h
//  Onstar
//
//  Created by Joshua on 6/5/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProxyListener <NSObject>
@optional
- (void)proxyDidFinishRequest:(BOOL)success withObject:(id)object;

- (void)payOrderProxyDidFinishRequest:(BOOL)success withObject:(id)object;

@end
// 获取onstar服务端订单部分接口类
@interface PurchaseProxy : NSObject     {
    NSMutableArray *listenerArray;
}
+ (PurchaseProxy *)sharedInstance;
+ (void)purgeSharedInstance;

- (void)addListener:(id<ProxyListener>)listener;
- (void)removeListener:(id<ProxyListener>)listener;

- (void)getPackageList;
- (void)createOrder;
- (void)createLBSOrder;
- (void)saveInvoice;
- (void)queryOrderStatusWithOrderID:(NSString *)orderID;
- (void)getOrderHistoryInPage:(NSInteger)pageNum Size:(NSInteger)size;

- (void)getAccountInfoByVin:(NSString *)vin;
- (void)validatePPC:(BOOL)isFromVinConfirm;
- (void)activatePPCById:(NSString *)type;
- (void)getActivateHistoryInPage:(NSInteger)pageNum Size:(NSInteger)size;


//add v7.2
//根据选择支付类型以及服务端订单号获取服务端生成的订单支付使用信息,该信息用于设置wechat等支付参数,orderStr是服务端返回订单信息，为兼容老版本才传递该参数
- (void)getPayInfoByPayType:(NSString *)payType mspOrderString:(NSString *)orderStr sucessHandler:(void(^)(NSString *payPara))sucess failureHandler:(void(^)(NSString *failStr))failure;
@end
