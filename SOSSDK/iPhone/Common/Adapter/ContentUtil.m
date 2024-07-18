//
//  ContentUtil.m
//  Onstar
//
//  Created by Vicky on 16/7/20.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ContentUtil.h"
 

@implementation ContentUtil


+ (void)getContentByCategory:(NSString *)category Success:(void (^)(NNContentHeaderCatogry *content))completion Failed:(void (^)(void))failCompletion{
    [Util showLoadingView];
    //NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_CONTENT),BASE_URL,[Util getAppVersionCode],category];
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_CONTENT];
    NSDictionary *d = @{@"versionCode":[Util getAppVersionCode],@"category":category};
    NSString *s = [Util jsonFromDict:d];

    SOSNetworkOperation * sosOperation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id returnData) {
        @try {
            [Util hideLoadView];
            NSDictionary *dic = [Util dictionaryWithJsonString:returnData];
            if (operation.statusCode == 200) {
                //to be delete
               //NNContentHeaderCatogry *response = [[NNContentHeaderCatogry alloc] initWithDictionary:dic];
                NNContentHeaderCatogry *response = [NNContentHeaderCatogry mj_objectWithKeyValues:dic];
                completion(response);
            }else{
                failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
       
    }];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation start];

}

+ (void)getContentDetailByCategory:(NSString *)category num:(NSString *)number Success:(void (^)(NNContentDeatil * contentDeatil))completion Failed:(void (^)(void))failCompletion{
   [Util showLoadingView];
//    NSString *url = [NSString stringWithFormat:(@"%@" NEW_GET_CONTENT_DETAIL), BASE_URL, number,[Util getAppVersionCode],category];
    NSString *url = [BASE_URL stringByAppendingString:NEW_GET_CONTENT_DETAIL];
    NSDictionary *d = @{@"contentNUM":number,@"versionCode":[Util getAppVersionCode],@"category":category};
    NSString *s = [Util jsonFromDict:d];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:s successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        @try {
            [Util hideLoadView];
            NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
            if (operation.statusCode == 200) {
                //to be delete
                //NNContentDeatil *response = [[NNContentDeatil alloc] initWithDictionary:dic];
                NNContentDeatil *response =[NNContentDeatil mj_objectWithKeyValues:dic];
                completion(response);
            }else{
                failCompletion();
            }
        }@catch (NSException *exception) {
            NSLog(@"exception jsonFormatError");
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [operation setHttpMethod:@"POST"];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation start];
    
}
@end
