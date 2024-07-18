//
//  SOSBleUtil.m
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBleUtil.h"
#import <BlePatacSDK/DBManager.h>
#import <BlePatacSDK/Keyinfo.h>
#import "SOSBleReceiveAlertViewController.h"
#import "NSDate+DateTools.h"
#import "SOSCardUtil.h"
#import "BlueToothManager+SOSBleExtention.h"

@implementation SOSBleUtil

+ (BOOL)authorValid:(NSString *)status{
    return  [status isEqualToString:@"NEW"]||
        [status isEqualToString:@"APPROVED"]||
        [status isEqualToString:@"ACCEPTED"]||
        [status isEqualToString:@"GRANTED"]||
        [status isEqualToString:@"VALID"]||
        [status isEqualToString:@"INUSE"];
}

+ (BOOL)keyValid:(SOSVKeys *)key authorInfo:(SOSAuthorDetail *)authorInfo{
    if ([key.vkeyStatus isEqualToString:@"VALID"]) {
        return true;
    }else {
        if ([authorInfo.authorizationStatus isEqualToString:@"GRANTED"]) {
            if (!key.vkeyModifyTime.isNotBlank) {
                return true;
            }
        }
        
    }
    return false;
}

+ (NSString *)realStatusWithAuthorEntity:(SOSAuthorDetail *)authorEntity {
    NSString *status = authorEntity.authorizationStatus;
    BOOL exsit = NO;
    for (SOSVKeys *vkey in authorEntity.vkeys) {
        
        if ([self keyValid:vkey authorInfo:authorEntity]) {
//        if ([vkey.vkeyStatus isEqualToString:@"VALID"]) {
            exsit = [self selectKeyExsitWithVkId:vkey.vkeyId];
            break;
        }
    }
    if (!exsit) {
        if ([status isEqualToString:@"GRANTED"]) {//已下载未生效
            //若本地没钥匙  APPROVED
            status = @"APPROVED";
        }else if ([status isEqualToString:@"INUSE"]) { //已下载已生效
            //若本地没钥匙 VALID
            status = @"VALID";
        }
    }
    return status;
}

+ (BOOL)selectKeyExsitWithVkId:(NSString *)vkId {
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    NSArray *keys = [[DBManager sharedInstance] GetSomeKeyInDB:INT_MAX];
    for (Keyinfo *info in keys) {
        if ([vkId isEqualToString:info.vkno]) {
            return true;
        }
    }
    return NO;
}


+ (NSArray *)disposeDataWithAuthorInfo:(SOSAuthorInfo *)authorInfo {
    NSMutableArray *tempAry = @[].mutableCopy;
    NSMutableArray *permAry = @[].mutableCopy;
    NSMutableArray *historyTempAry = @[].mutableCopy;
    NSMutableArray *historyPermAry = @[].mutableCopy;
    //过滤
    for (SOSAuthorDetail *author in authorInfo.resultData) {
        if ([SOSBleUtil authorValid:author.authorizationStatus]) {
            if ([author.authorizationType isEqualToString:@"TEMP"]) {
                [tempAry addObject:author];
            }else {
                [permAry addObject:author];
            }
        }else {
            if ([author.authorizationType isEqualToString:@"TEMP"]) {
                [historyTempAry addObject:author];
            }else {
                [historyPermAry addObject:author];
            }
        }
        //删除本地过期的钥匙
        [self deleteInValidKeysWithKeyId:author];
    }
    //排序
//    [tempAry sortUsingComparator:^NSComparisonResult(SOSAuthorDetail*  _Nonnull obj1, SOSAuthorDetail*  _Nonnull obj2) {
//        return obj1.createTime < obj2.createTime;
//    }];
//    [permAry sortUsingComparator:^NSComparisonResult(SOSAuthorDetail*  _Nonnull obj1, SOSAuthorDetail*  _Nonnull obj2) {
//        return obj1.createTime < obj2.createTime;
//    }];
//    [historyTempAry sortUsingComparator:^NSComparisonResult(SOSAuthorDetail*  _Nonnull obj1, SOSAuthorDetail*  _Nonnull obj2) {
//        return obj1.createTime < obj2.createTime;
//    }];
//    [historyPermAry sortUsingComparator:^NSComparisonResult(SOSAuthorDetail*  _Nonnull obj1, SOSAuthorDetail*  _Nonnull obj2) {
//        return obj1.createTime < obj2.createTime;
//    }];
    
    return @[tempAry.copy,
             permAry.copy,
             historyTempAry.copy,
             historyPermAry.copy];
}


+ (NSDictionary *)getUrlParamsWithUrl:(NSURL *)url {
    return [self getParamsWithQuery:url.query];
}

+ (NSDictionary *)getParamsWithQuery:(NSString *)query {
    NSArray * params = [query componentsSeparatedByString:@"&"];

    NSMutableDictionary * paramDict=[NSMutableDictionary dictionaryWithCapacity:[params count]];
    for(NSString * str in params){
        NSArray * keyAndValueArray=[str componentsSeparatedByString:@"="];
        
        NSString * valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // GBK convert
        if (!valueStr) {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            valueStr=[[keyAndValueArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:gbkEncoding];
        }
        [paramDict setValue:NONil(valueStr) forKey:[keyAndValueArray objectAtIndex:0]];
    }
    return paramDict;
}


/**
 删除过期钥匙
 */
+ (void)deleteInValidKeysWithKeyId:(SOSAuthorDetail *)authorInfo {
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    
    for (SOSVKeys *key in authorInfo.vkeys) {
        if (![self keyValid:key authorInfo:authorInfo]) {
            [[DBManager sharedInstance] DeleteOneCarKeyInDB:key.vkeyId Result:^(BOOL b, NSError *error) {
                
            }];
            if ([BlueToothManager sharedInstance].isConnected) {
                BOOL noValidKey = [SOSBleUtil selectAllKeysWithVin:[BlueToothManager sharedInstance].bleOperationVar.connectingBleModel.BleName].count==0;
                if (noValidKey) {//本地没有当前连接的vin可用的钥匙 断开
                    [[BlueToothManager sharedInstance] cannelWithPeripheral:[BlueToothManager sharedInstance].peripheral block:nil];
                }
            }
        }
    }
    
}


/**
 下载钥匙保存

 */
+ (void)saveKeysWithVKeys:(SOSVKeys *)vKeys authorInfo:(SOSAuthorDetail *)authorInfo {
    
    Keyinfo *info = [Keyinfo new];
    info.vkno = vKeys.vkeyId;
    info.vkkey = vKeys.vkeyContent.secretContent;
    info.csk = vKeys.vkeyContent.csk2;
    info.sha256 = vKeys.vkeyContent.sha256;
    info.idpuserid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId?:@"";
    info.vin = authorInfo.vin;
    info.keyTime = [NSString stringWithFormat:@"%@%@",[self cStringFromTimestamp:authorInfo.startTime.doubleValue],[self cStringFromTimestamp:authorInfo.endTime.doubleValue]];
    info.startTime = authorInfo.startTime;
    info.endTime = authorInfo.endTime;
    DBManager *dbManager = [DBManager sharedInstance];
    NSError *error;
    
    [dbManager AddOneCarKeyIntoDB:info Result:^(BOOL b, NSError *error) {
        if (b) {
            NSLog(@"%@",  @"add ok -");
        }
    }];

    NSLog(@"%@",error);
}

+ (void)test {
    
    Keyinfo *info = [Keyinfo new];
    info.vkno = @"31373234";
    info.vkkey = @"77A8B6EC3294BFB800AD83AF0A2018343081F26CF571EA7F942C176A4EE923FAEE7E5A06629AD1CAF9D04AF2352985E8CF9DA2AB2E85622273863214548460A82ECC44047A538DF1785CE4CC0C15823A0DDC34D0D1A68880AAD331F01F2DCEFBDECF66CA76A0AF3971DA6DCE413FD373C22A1F414689488C34FCF9C9B052AE2022ABF7E332E49526E1A0A1A8058E17539C9519FABC02CB9608E5F81D8E4207565986E6B6D36D69CEF659F8B64E034EF9D831020EFF89A0730B797C2DB721EDBA6BC0D7A2E61259FC3953F2C24B6E5F7C982754F5E1DE2B18BE4331F251D4B40424FC369E469157C91530A207DD613ADFDEF9252E0C3F669138BFE86B9F2B5AD7";
    info.csk = @"8648FA7AF1A1CAFF02C9EF5B561A4E5073D2E6A6B921EBC30B8AB1CB5F47083C";
    info.sha256 = @"502B6469D4C4FF750D887A21E6DC8C0B89DB432DFB7DEA0C1851FC4AAB7B4025";
    info.idpuserid = @"LIDONGXU12345678";
    info.vin = @"LSGKJ8RH3KW000835";
    info.keyTime = @"201808151004201808160000";
    DBManager *dbManager = [DBManager sharedInstance];
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    NSError *error;
    [dbManager AddOneCarKeyIntoDB:info Result:^(BOOL b, NSError *error) {
        if (b) {
            NSLog(@"%@",  @"add ok -");
        }
    }];
    
    NSLog(@"%@",error);
}

+ (void)deleteAllBleKeys {
    DBManager *dbManager = [DBManager sharedInstance];
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    NSArray *keys = [dbManager GetSomeKeyInDB:INT_MAX];
    
    for (Keyinfo *key in keys) {
        [[DBManager sharedInstance] DeleteOneCarKeyInDB:key.vkno Result:^(BOOL b, NSError *error) {
            if (b) {
                NSLog(@"del ok");
            }
        }];
    }
    
}

/**
 查询本地所有钥匙
 */
+ (NSArray *)selectAllKeys {
    DBManager *dbManager = [DBManager sharedInstance];
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    NSArray *keys = [dbManager GetSomeKeyInDB:INT_MAX];
    return keys;
}


/**
 根据本地钥匙 获取全名VIN
 */
+ (NSString *)getFullVinWithBleName:(NSString *)BleName {
    NSArray *keys = [self selectAllKeys];
    for (Keyinfo *key in keys) {
        if ([[key.vin substringFromIndex:(key.vin.length-6)] isEqualToString:[BleName substringFromIndex:(BleName.length-6)]]) {
            return key.vin;
        }
    }
    return BleName;
}


/**
 查询与此VIN匹配的所有钥匙
 */
+ (NSArray *)selectAllKeysWithVin:(NSString *)vin {
    NSArray *keys = [self selectAllKeys];
    NSMutableArray *validKeys = @[].mutableCopy;
    for (VKeyEntity *key in keys) {
        NSString *keyVinLast = [key.vin substringFromIndex:(key.vin.length-6)];
        if ([keyVinLast isEqualToString:[vin substringFromIndex:(vin.length-6)]]) {
            NSString *startTimeStr = [key.keyTime substringToIndex:12];
            NSString *endTimeStr = [key.keyTime substringFromIndex:12];
            NSDate *startDate = [NSDate dateWithString:startTimeStr format:@"yyyyMMddHHmm"];
            NSDate *endDate = [NSDate dateWithString:endTimeStr format:@"yyyyMMddHHmm"];
            
            if ([startDate earlierDate:[NSDate date]] && [endDate laterDate:[NSDate date]]) {
                [validKeys addObject:key];
            }else if ([endDate earlierDate:[NSDate date]]) {
                //已过期的钥匙 删除
                [[DBManager sharedInstance] DeleteOneCarKeyInDB:key.vkno Result:^(BOOL b, NSError *error) {
                    if (b) {
                        NSLog(@"del ok");
                    }
                }];
            }
        }
    }
    return validKeys;
}



+ (void)test1 {
    DBManager *dbManager = [DBManager sharedInstance];
    [[DBManager sharedInstance] managedObjectContext:bledbkey];
    NSArray *keys = [dbManager GetSomeKeyInDB:INT_MAX];
    
    NSLog(@"blekeys = %@",keys);
    NSArray *keys1 = [self selectAllKeys];
    NSArray *keys2 = [self selectAllKeysWithVin:@"LSGKJ8RH3KW000835"];
    NSLog(@"xxx");
//    for (VKeyEntity *key in keys) {
//        [[DBManager sharedInstance] DeleteOneCarKeyInDB:key.vkno Result:^(BOOL b, NSError *error) {
//            if (b) {
//                NSLog(@"xxx");
//            }
//        }];
//    }
//
//    NSArray *keys1 = [dbManager GetSomeKeyInDB:INT_MAX];
//
//    NSLog(@"blekeys = %@",keys1);
    

}


+ (NSString *)cStringFromTimestamp:(NSTimeInterval)timestamp{
    //时间戳转时间的方法
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];

    return [timeDate stringWithFormat:@"yyyyMMddHHmm"];
}

/**
 *  生成二维码
 */
+ (UIImage *)creatCIQRCodeImageWithUrl:(NSString *)url centerImage:(UIImage *)centerImage
{
    //二维码过滤器
    CIFilter *qrImageFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //设置过滤器默认属性 (老油条)
    [qrImageFilter setDefaults];
    
    //将字符串转换成 NSdata (虽然二维码本质上是 字符串,但是这里需要转换,不转换就崩溃)
    NSData *qrImageData = [url dataUsingEncoding:NSUTF8StringEncoding];
    
    //我们可以打印,看过滤器的 输入属性.这样我们才知道给谁赋值
    NSLog(@"%@",qrImageFilter.inputKeys);
    /*
     inputMessage,        //二维码输入信息
     inputCorrectionLevel //二维码错误的等级,就是容错率
     */
    
    
    //设置过滤器的 输入值  ,KVC赋值
    [qrImageFilter setValue:qrImageData forKey:@"inputMessage"];
    
    //取出图片
    CIImage *qrImage = [qrImageFilter outputImage];
    
    //但是图片 发现有的小 (27,27),我们需要放大..我们进去CIImage 内部看属性
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    //转成 UI的 类型
    UIImage *qrUIImage = [UIImage imageWithCIImage:qrImage];
    
    if (centerImage) {
        //----------------给 二维码 中间增加一个 自定义图片----------------
        //开启绘图,获取图形上下文  (上下文的大小,就是二维码的大小)
        UIGraphicsBeginImageContext(qrUIImage.size);
        
        //把二维码图片画上去. (这里是以,图形上下文,左上角为 (0,0)点)
        [qrUIImage drawInRect:CGRectMake(0, 0, qrUIImage.size.width, qrUIImage.size.height)];
        
        
        //再把小图片画上去
        UIImage *sImage = centerImage;
        //    [UIImage imageNamed:@"brand_onstar_200x120"];
        
        CGFloat sImageW = (centerImage.size.width) * ([UIScreen mainScreen].scale);
        CGFloat sImageH= sImageW;
        CGFloat sImageX = (qrUIImage.size.width - sImageW) * 0.5;
        CGFloat sImgaeY = (qrUIImage.size.height - sImageH) * 0.5;
        
        [sImage drawInRect:CGRectMake(sImageX, sImgaeY, sImageW, sImageH)];
        
        //获取当前画得的这张图片
        UIImage *finalyImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭图形上下文
        UIGraphicsEndImageContext();
        
        return finalyImage;
    }
    
    
    // 5. 显示image
    return qrUIImage;
}


/**
 跳转至接受共享页面
 */
+ (void)showReceiveAlertControllerWithUrl:(NSString *)url {
//    NSString *hide = @"";
//    NSString *uuid = @"";
//    NSString *orginUrl = @"";
    NSDictionary *params ;

    if ([url.lowercaseString hasPrefix:@"com.onstar"]) {
        params = [self getUrlParamsWithUrl:[NSURL URLWithString:url]];
    }else {
        params = [self getParamsWithQuery:url];
    }
    NSString *time = [params objectForKey:@"time"];
    if (time.isNotBlank) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000];
        NSDate *now = [NSDate date];
        NSDate *d5 = [date dateByAddingMinutes:5];
        if ([d5 isEarlierThan:now]) {
            //不满足
            [Util toastWithMessage:@"二维码已失效,请联系车主重新分享"];
            return;
        }
    }
    
   
    
    
    
//    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:bleAlert];
    
    
    if (time.isNotBlank) {
        [[LoginManage sharedInstance] checkAndShowLoginViewWithFromViewCtr:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController andTobePushViewCtr:nil completion:^(BOOL finished) {
            if (finished) {
                SOSBleReceiveAlertViewController *bleAlert = [[SOSBleReceiveAlertViewController alloc] initWithNibName:@"SOSBleReceiveAlertViewController" bundle:nil];
                bleAlert.hide = [params objectForKey:@"hide"]?:@"";
                bleAlert.uuid = [params objectForKey:@"uuid"]?:@"";
                bleAlert.orginUrl = url;
                bleAlert.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
                bleAlert.isPer = time.isNotBlank;
                [[SOS_APP_DELEGATE fetchMainNavigationController] presentViewController:bleAlert animated:NO completion:nil];
                
            }
        }];
        return;
    }
     [[SOS_APP_DELEGATE fetchMainNavigationController] popToRootViewControllerAnimated:NO];
    [SOSCardUtil routerToUserReceiveBlePageBlock:^{
        SOSBleReceiveAlertViewController *bleAlert = [[SOSBleReceiveAlertViewController alloc] initWithNibName:@"SOSBleReceiveAlertViewController" bundle:nil];
        bleAlert.hide = [params objectForKey:@"hide"]?:@"";
        bleAlert.uuid = [params objectForKey:@"uuid"]?:@"";
        bleAlert.orginUrl = url;
        bleAlert.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
        bleAlert.isPer = time.isNotBlank;
        [[SOS_APP_DELEGATE fetchMainNavigationController] presentViewController:bleAlert animated:NO completion:nil];
    }];
    
}


+ (NSString *) recodesign:(NSString *)str
{
    NSString *maskedPhone = @"";
    if (str.length >= 6) {
        NSString *preStr = [str substringWithRange:NSMakeRange(0, 3)];
        NSString *rearStr = [str substringFromIndex:([str length]-6)];
        maskedPhone = [NSString stringWithFormat:@"VIN %@******%@",preStr,rearStr];
    }
    return maskedPhone;
}

/**
 手机号加空格
 */
+ (NSString *)formatPhone:(NSString *)phone {
    if (phone.length == 11) {
        NSString *replaceStr = [phone substringWithRange:NSMakeRange(3, 4)];
        phone = [phone stringByReplacingOccurrencesOfString:replaceStr withString:[NSString stringWithFormat:@" %@ ",replaceStr]];
    }
    return phone;
}

@end
