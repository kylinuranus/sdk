//
//  SOSLifeNetworkEngine.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/3.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSLifeNetworkEngine.h"

@implementation SOSLifeNetworkEngine


typedef void (^SOSLifeCompletionBaseBlock)(id data);
+ (SOSNetworkOperation *)requestWithHttpMethod:(NSString *)method interface:(NSString *)partUrl param:(NSDictionary *)param completionBlock:(SOSLifeCompletionBaseBlock)completionBlock errorBlock:(SOSLifeErrorBlock)errorBlock {
    NSString *url = nil;
    //    if ([partUrl containsString:@"http"]) {
    //        url = partUrl;
    //    }else {
    NSString *hostUrl = BASE_URL;
    url = [hostUrl stringByAppendingString:partUrl];
    //    }
    if (url.length > 0) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSString *jsonString = [param mj_JSONString];
    SOSNetworkOperation *ope = [SOSNetworkOperation requestWithURL:url params:jsonString successBlock:^(SOSNetworkOperation *operation, id responseStr) {
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
