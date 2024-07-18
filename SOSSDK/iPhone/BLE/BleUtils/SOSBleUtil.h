//
//  SOSBleUtil.h
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSAuthorInfo.h"
#import <BlePatacSDK/VKeyEntity.h>

@interface SOSBleUtil : NSObject

+ (void)test;
+ (void)test1;


/**
 查询本地所有钥匙
 */
+ (NSArray <VKeyEntity *> *)selectAllKeys;


/**
 根据本地钥匙 获取全名VIN
 */
+ (NSString *)getFullVinWithBleName:(NSString *)BleName ;

/**
 查询与此VIN匹配的所有钥匙
 */
+ (NSArray <VKeyEntity *> *)selectAllKeysWithVin:(NSString *)vin;

+ (void)deleteAllBleKeys;
/**
 根据后台返回字段判断钥匙是否已经失效
 */
+ (BOOL)authorValid:(NSString *)status;


/**
 判断钥匙是否有效
 */
+ (BOOL)keyValid:(SOSVKeys *)key authorInfo:(SOSAuthorDetail *)authorInfo;

/**
 若本地无钥匙,状态需回退到未下载状态
 */
+ (NSString *)realStatusWithAuthorEntity:(SOSAuthorDetail *)authorEntity;

/**
 过滤+排序
 */
+ (NSArray *)disposeDataWithAuthorInfo:(SOSAuthorInfo *)authorInfo;

/**
 下载钥匙保存
 
 */
+ (void)saveKeysWithVKeys:(SOSVKeys *)vKeys authorInfo:(SOSAuthorDetail *)authorInfo;

/**
 根据url获得url中的参数
 */
+ (NSDictionary *)getUrlParamsWithUrl:(NSURL *)url;

/**
 *  生成二维码
 */
+ (UIImage *)creatCIQRCodeImageWithUrl:(NSString *)url centerImage:(UIImage *)centerImage;



/**
 跳转至接受共享页面
 */
+ (void)showReceiveAlertControllerWithUrl:(NSString *)url;


/**
 VIN 前3后6
 */
+ (NSString *) recodesign:(NSString *)str;


/**
    手机号加空格
 */
+ (NSString *)formatPhone:(NSString *)phone;

@end
