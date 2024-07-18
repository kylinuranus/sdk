//
//  RMStoreTransactionReceiptVerifier.m
//  RMStore
//
//  Created by Hermes Pique on 7/31/13.
//  Copyright (c) 2013 Robot Media SL (http://www.robotmedia.net)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RMStoreTransactionReceiptVerifier.h"
#import "RMStoreKeychainPersistence.h"
#import "PackageUtil.h"
#import "LoadingView.h"

#ifdef DEBUG
#define RMStoreLog(...) NSLog(@"RMStore: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#define RMStoreLog(...)
#endif

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

@implementation RMStoreTransactionReceiptVerifier

- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    NSDictionary *prarms = [[RMStore defaultStore].transactionPersistor getOnstarOrderWithAppleOrderId:transaction.transactionIdentifier];
    
    if (!prarms) {
        NSLog(@"丢单了");
        return;
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self verifyFailureTransaction:prarms
                           success:successBlock
                           failure:failureBlock];
}

#pragma mark 处理订单
- (void)verifyFailureTransaction:(NSDictionary*)transactionDic
                         success:(void (^)(void))successBlock
                         failure:(void (^)(NSError *error))failureBlock
{
    NSString *appleOrderId = [transactionDic objectForKey:SOSAppleTransactionOrderIdKey];
    NSLog(@"APPLE订单号%@开始上传",appleOrderId);
    if ([RMStore defaultStore].purchasePayType == RMStorePurchasePayNone) {
        [PackageUtil payParams:transactionDic successHandler:^(id response) {
            if (successBlock) {
                successBlock();
            }
            [[RMStore defaultStore].transactionPersistor removeTransactionWithAppleOrderId:appleOrderId];
            NSLog(@"APPLE订单号%@加包成功",[transactionDic objectForKey:SOSAppleTransactionOrderIdKey]);
        } failureHandler:^(NSString *responseStr, NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
            if (error.code == RMStoreErrorCodeUnableToCompleteVerification) {
                [[RMStore defaultStore].transactionPersistor removeTransactionWithAppleOrderId:appleOrderId];
            }
        }];
    }else if ([RMStore defaultStore].purchasePayType == RMStorePurchasePayRearviewMirror) { // 后视镜
        [PackageUtil payRearviewMirrorServiceParams:transactionDic successHandler:^(id response) {
            if (successBlock) {
                successBlock();
            }
            [[RMStore defaultStore].transactionPersistor removeTransactionWithAppleOrderId:appleOrderId];
            NSLog(@"APPLE后视镜订单号%@加包成功",[transactionDic objectForKey:SOSAppleTransactionOrderIdKey]);
        } failureHandler:^(NSString *responseStr, NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
            if (error.code == RMStoreErrorCodeUnableToCompleteVerification) {
                [[RMStore defaultStore].transactionPersistor removeTransactionWithAppleOrderId:appleOrderId];
            }
        }];
    }
//    [LoadingView sharedInstance]->labelLoading.text = @"验证中，请稍后...";
    

//    [self verifyByClientSuccess:^{
//        [[RMStore defaultStore].transactionPersistor removeTransactionWithAppleOrderIdKey:appleTransactionOrderId];
//        NSLog(@"移除失败的订单Id%@", appleTransactionOrderId);
//        NSLog(@"剩余掉单: %@", [[RMStore defaultStore].transactionPersistor allFailureReceipt]);
//
//    } failure:^(NSError *error) {
//        
//    }];
    
    
}

/*
- (void)verifyByClientSuccess:(void (^)())successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    NSData *receiptData = [NSData dataWithContentsOfURL:[RMStore receiptURL]];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    static NSString *receiptDataKey = @"receipt-data";
    NSDictionary *jsonReceipt = @{receiptDataKey : receipt};
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonReceipt options:0 error:&error];
    if (!requestData)
    {
        if (failureBlock != nil)
        {
            failureBlock(error);
        }
        return;
    }
    
    
    [self verifyRequestData:requestData url:AppStore success:successBlock failure:failureBlock];
}

- (void)verifyRequestData:(NSData*)requestData
                      url:(NSString*)urlString
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = requestData;
    static NSString *requestMethod = @"POST";
    request.HTTPMethod = requestMethod;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!data)
            {
//                NSError *wrapperError = [NSError errorWithDomain:@"sos error verify" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Connection to Apple failed. Check the underlying error for more info."}];
                RMStoreLog(@"Server Connection Failed");
                NSError *wrapperError = [NSError errorWithDomain:RMStoreErrorDomain code:RMStoreErrorCodeUnableToCompleteVerification userInfo:@{NSUnderlyingErrorKey : error, NSLocalizedDescriptionKey : @"Connection to Apple failed. Check the underlying error for more info."}];
                if (failureBlock != nil)
                {
                    failureBlock(wrapperError);
                }
                return;
            }
            NSError *jsonError;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!responseJSON)
            {
                if (failureBlock != nil)
                {
                    failureBlock(jsonError);
                }
            }
            NSLog(@"%@",responseJSON);
            static NSString *statusKey = @"status";
            NSInteger statusCode = [responseJSON[statusKey] integerValue];
            
            static NSInteger successCode = 0;
            static NSInteger sandboxCode = 21007;
            if (statusCode == successCode)
            {
                if (successBlock != nil)
                {
                    successBlock();
                }
            }
            else if (statusCode == sandboxCode)
            {
                [self verifyRequestData:requestData url:SANDBOX success:successBlock failure:failureBlock];
            }
            else
            {
                RMStoreLog(@"Verification Failed With Code %ld", (long)statusCode);
                NSError *serverError = [NSError errorWithDomain:RMStoreErrorDomain code:statusCode userInfo:nil];
                if (failureBlock != nil)
                {
                    failureBlock(serverError);
                }
            }
        });
    }];
    [task resume];
}
*/

@end
