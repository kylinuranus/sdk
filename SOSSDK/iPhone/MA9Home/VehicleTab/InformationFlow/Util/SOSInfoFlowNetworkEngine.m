//
//  SOSInfoFlowNetworkEngine.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowNetworkEngine.h"
#import "SOSInfoFlow.h"

@implementation SOSInfoFlowNetworkEngine

+ (SOSNetworkOperation *)requestInfoFlowsWithLat:(double)lat lon:(double)lon completionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
////    加载本地json模拟数据
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 获取文件路径
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"json"];
//            // 将文件数据化
//            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//            // 对数据进行JSON格式化并返回字典形式
//            NSMutableArray <SOSInfoFlow *>*infoFlows = @[].mutableCopy;
//            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                SOSInfoFlow *infoFlow = [SOSInfoFlow mj_objectWithKeyValues:obj];
//                [infoFlows addObject:infoFlow];
//            }];
//            completionBlock ? completionBlock(infoFlows) : nil;
//        });
//    return nil;
    NSString *key = @"";
    if ([SOSCheckRoleUtil isVisitor]) {
        key = @"visitor";
    }else if ([SOSCheckRoleUtil isProxy]) {
        key = @"proxy";
    }else if ([SOSCheckRoleUtil isDriver]) {
        key = @"driver";
    }else if ([SOSCheckRoleUtil isOwner]) {
        key = @"owner";
    }else {
        key = @"unlogged";
    }
    key = key.uppercaseString;
    NSDictionary *para = @{
                           @"role": key,
                           @"longitude": @(lon),
                           @"latitude": @(lat)
                           };
    return [self requestWithHttpMethod:@"POST" interface:@"/sos/mobileaggr/v1/infoFlow" param:para completionBlock:^(id data) {
        NSMutableArray <SOSInfoFlow *>*infoFlows = @[].mutableCopy;
        if ([data isKindOfClass:NSArray.class]) {
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:NSDictionary.class]) {
                    return;
                }
                SOSInfoFlow *infoFlow = [SOSInfoFlow mj_objectWithKeyValues:obj];
                [infoFlows addObject:infoFlow];
            }];
        }
        completionBlock ? completionBlock(infoFlows) : nil;
    } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
    }];
}

+ (SOSNetworkOperation *)deleteInfoFlow:(NSString *)bid idt:(NSString *)idt completionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin ? : @"";
    NSString *uid = [CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"";
    NSMutableString *partURL = @"/sos/vehrtd/v3/setdelinfo/".mutableCopy;
    [partURL appendFormat:@"%@/%@/%@/%@", vin, uid, bid?:@"", idt?:@""];
    return [self requestWithHttpMethod:@"GET" interface:partURL.copy param:nil completionBlock:^(id data) {
        completionBlock ? completionBlock(nil) : nil;
    } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
    }];
}

+ (SOSNetworkOperation *)deleteForumHotInfoFlow:(NSString *)bid completionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
     NSMutableString *partURL = @"/sos/social/v1/bbs/delete/popular".mutableCopy;
//     [partURL appendFormat:@"%@/%@/%@/%@", vin, uid, bid?:@"", idt?:@""];
     return [self requestWithHttpMethod:@"DELETE" interface:partURL.copy param:nil completionBlock:^(id data) {
         completionBlock ? completionBlock(nil) : nil;
     } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
         errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
     }];
}

+ (SOSNetworkOperation *)deleteAdvertisementInfoFlow:(NSString *)bannerId completionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
    NSDictionary *para = @{
        @"idpUserId": CustomerInfo.sharedInstance.userBasicInfo.idpUserId ? : @"",
        @"operationType": bannerId,
    };
    return [self requestWithHttpMethod:@"POST" interface:@"/sos/mobileuser/v1/user/adsense/takeNote" param:para completionBlock:^(id data) {
        completionBlock ? completionBlock(data) : nil;
    } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
    }];


}

+ (SOSNetworkOperation *)requestInfoFlowSettingsWithCompletionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
//    NSString *url = @"http://10.216.146.52:3000/mock/22/v1/infoFlow";
    return [self requestWithHttpMethod:@"GET" interface:@"/sos/mobileuser/v1/infoFlow" param:nil completionBlock:^(id data) {
        NSMutableArray<SOSInfoFlowSetting *> *settings = [SOSInfoFlowSetting mj_objectArrayWithKeyValuesArray:data];
        completionBlock ? completionBlock(settings) : nil;
    } errorBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
    }];
}

+ (SOSNetworkOperation *)triggerInfoFlowSetting:(SOSInfoFlowSetting *)setting completionBlock:(SOSIFCompletionBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
    NSDictionary *para = @{
                           @"belongType": setting.belongType,
                           @"status": setting.status,
                           };
    return [self requestWithHttpMethod:@"POST" interface:@"/sos/mobileuser/v1/infoFlow" param:para completionBlock:^(id data) {
        
        completionBlock ? completionBlock(data) : nil;
    } errorBlock:^(NSInteger statusCode, NSString * _Nonnull responseStr, NSError * _Nonnull error) {
        errorBlock ? errorBlock(statusCode, responseStr, error) : nil;
    }];
}

typedef void (^SOSIFCompletionBaseBlock)(id data);
+ (SOSNetworkOperation *)requestWithHttpMethod:(NSString *)method interface:(NSString *)partUrl param:(NSDictionary *)param completionBlock:(SOSIFCompletionBaseBlock)completionBlock errorBlock:(SOSIFErrorBlock)errorBlock {
    
    NSString *url = nil;
//    NSString *hostUrl = @"http://10.216.146.52:3000/mock/99/sos";
    if ([partUrl hasPrefix:@"http"]) {
        url = partUrl;
    }else {
        url = [[Util getConfigureURL] stringByAppendingString:partUrl];
        if (url.length > 0) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
    }
    NSString *jsonString = [param mj_JSONString];
    SOSNetworkOperation *ope = [SOSNetworkOperation requestWithURL:url params:jsonString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        if (![responseStr isKindOfClass:NSString.class]) {
            completionBlock ? completionBlock(@[]) : nil;
            return;
        }
//        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"'"];
        NSData *jsonData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id data = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&error];
        if(error) {
            NSLog(@"json解析失败：%@",error);
            data = nil;
        }
        completionBlock ? completionBlock(data) : nil;
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        if (errorBlock) {
            errorBlock(statusCode, responseStr, error);
        }
    }];
    [ope setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [ope setHttpMethod:method];
    [ope start];
    return ope;
}

@end
