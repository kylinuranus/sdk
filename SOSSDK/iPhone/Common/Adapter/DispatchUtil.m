//
//  DispatchUtil.m
//  Onstar
//
//  Created by Vicky on 17/1/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "DispatchUtil.h"

@implementation DispatchUtil

+ (void)getDispatcher:(NNDispatcherReq *)req Success:(void (^)(NNURLRequest *urlRequest))completion Failed:(void (^)(void))failCompletion{
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, MSP_Dispatch_3rd_Sec];
    NSString *post = [req mj_JSONString];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:post successBlock:^(SOSNetworkOperation *operation, NSString *responseStr) {
        [Util hideLoadView];
        @try {
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            NSString *error = [dic objectForKey:@"code"];
            if (operation.statusCode == 200) {
                NNDispatcherRep *rep = [NNDispatcherRep mj_objectWithKeyValues:dic];
                NNURLRequest *request = [[NNURLRequest alloc]init];
                request.url = rep.url;
                request.jsonStr = rep.jsonStr;
                request.method = req.method;
                request.contenType = req.contentType;
                completion(request);
            }else{
                [Util showAlertWithTitle:nil message:NSLocalizedString(error, nil) completeBlock:nil];
                !failCompletion ? : failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
        !failCompletion ? : failCompletion();
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"POST"];
    [operation start];
}
@end
