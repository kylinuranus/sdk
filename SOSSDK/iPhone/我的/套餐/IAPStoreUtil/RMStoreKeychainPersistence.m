//
//  RMStoreKeychainPersistence.m
//  RMStore
//
//  Created by Hermes on 10/19/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
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

#import "RMStoreKeychainPersistence.h"
#import <Security/Security.h>

NSString* const RMStoreTransactionsKeychainKey  = @"RMStoreTransactionKey1";

NSString* const SOSAppleTransactionOrderIdKey   = @"apple_order_no";
NSString* const SOSOnstarTransactionOrderIdKey  = @"out_order_no";
NSString* const SOSAppleReceiptDataKey          = @"apple_voucher";
NSString* const SOSApplePriceKey                = @"actual";
NSString* const SOSDeleteOrderIdKey             = @"delete_order_id";

#pragma mark - Keychain

NSMutableDictionary* RMKeychainGetSearchDictionary(NSString *key)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    dictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    dictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    
    NSString *serviceName = [NSBundle mainBundle].bundleIdentifier;
    dictionary[(__bridge id)kSecAttrService] = serviceName;
    
    return dictionary;
}

void RMKeychainSetValue(NSData *value, NSString *key)
{
    NSMutableDictionary *searchDictionary = RMKeychainGetSearchDictionary(key);
    OSStatus status = errSecSuccess;
    CFTypeRef ignore;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &ignore) == errSecSuccess)
    { // Update
        if (!value)
        {
            status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
        } else {
            NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
            updateDictionary[(__bridge id)kSecValueData] = value;
            status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
        }
    }
    else if (value)
    { // Add
        searchDictionary[(__bridge id)kSecValueData] = value;
        status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
    }
    if (status != errSecSuccess)
    {
        NSLog(@"RMStoreKeychainPersistence: failed to set key %@ with error %ld.", key, (long)status);
    }
}

NSData* RMKeychainGetValue(NSString *key)
{
    NSMutableDictionary *searchDictionary = RMKeychainGetSearchDictionary(key);
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id)kSecReturnData] = (id)kCFBooleanTrue;
    
    CFDataRef value = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&value);
    if (status != errSecSuccess && status != errSecItemNotFound)
    {
        NSLog(@"RMStoreKeychainPersistence: failed to get key %@ with error %ld.", key, (long)status);
    }
    return (__bridge NSData*)value;
}

@interface RMStoreKeychainPersistence ()
@property (strong, nonatomic) NSOperationQueue *uploadQueue;

@end

@implementation RMStoreKeychainPersistence {
    NSDictionary *_transactionsDictionary;
    BOOL _isUploading;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _uploadQueue = [NSOperationQueue new];
        _uploadQueue.maxConcurrentOperationCount = 6;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkFailureReceipt)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkFailureReceipt)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
        [self performSelector:@selector(startMonitoring) withObject:nil afterDelay:5.0];  //5秒之后开始监听

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//开始检测网络
- (void)startMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)checkFailureReceipt {
    NSLog(@"iap:checkFailureReceipt");
    //暂不处理丢包问题
//    [self removeTransactions];
    NSArray *failureReceipt = [self allFailureAppleOrderId];
    NSLog(@"failureReceipt = %@",failureReceipt);
    for (NSString *failureId in failureReceipt) {
        NSDictionary *dic = [self getOnstarOrderWithAppleOrderId:failureId];
        [[RMStore defaultStore].receiptVerifier verifyFailureTransaction:dic success:^{
            NSLog(@"处理掉单成功");
            
        } failure:^(NSError *error) {
            NSLog(@"处理掉单失败");
        }];
    }
    
}


#pragma mark - RMStoreTransactionPersistor
- (void)persistTransaction:(SKPaymentTransaction*)paymentTransaction
{
    NSString *transactionIdentifier = paymentTransaction.transactionIdentifier;//订单id
    [self removeTransactionWithAppleOrderId:transactionIdentifier];
}

#pragma mark - Public

- (void)addTransactionWith:(SKPaymentTransaction*)paymentTransaction
onStarTransactionIdentifier:(NSString *)onStarTransactionIdentifier
{
    
//    NSString *deleteOnStarOrderId = @"";
//    if (localOnstarOrder) {
//        NSLog(@"note:此订单已经付过钱，使用onstar旧的订单id");
//        deleteOnStarOrderId = onStarTransactionIdentifier;
////        return;
//    }
    
    if (onStarTransactionIdentifier == nil) {
//        NSAssert(nil, @"安吉星订单号为nil");
        return;
    }
    NSString *transactionIdentifier = paymentTransaction.transactionIdentifier;
    NSDictionary *localOnstarOrder = [self getOnstarOrderWithAppleOrderId:transactionIdentifier];
    
    NSDictionary *transactions = [self transactionsDictionary];
    NSMutableDictionary *updatedTransactions = [NSMutableDictionary dictionaryWithDictionary:transactions];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:paymentTransaction.payment.productIdentifier];
    
    NSDictionary *prams = @{};
    
    NSData *receiptData = [NSData dataWithContentsOfURL:[RMStore receiptURL]];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (localOnstarOrder) {//已支付过，本地有值，新增delorderId
        NSMutableDictionary *localPrams = localOnstarOrder.mutableCopy;
        [localPrams setValue:onStarTransactionIdentifier forKey:SOSDeleteOrderIdKey];
        prams = localPrams.copy;
         NSLog(@"note:此订单已经付过钱，使用onstar旧的订单id");
    }else {
        prams = @{SOSAppleTransactionOrderIdKey:transactionIdentifier,
                               SOSApplePriceKey:product.price,
                 SOSOnstarTransactionOrderIdKey:onStarTransactionIdentifier,
                         SOSAppleReceiptDataKey:receipt};
    }
    
    [updatedTransactions setObject:prams forKey:transactionIdentifier];
    [self setTransactionsDictionary:updatedTransactions];
    
}

- (void)removeTransactions
{
    [self setTransactionsDictionary:nil];
}

- (void)removeTransactionWithAppleOrderId:(NSString *)key {
    NSDictionary *transactions = [self transactionsDictionary];
    NSMutableDictionary *updatedTransactions = [NSMutableDictionary dictionaryWithDictionary:transactions];
    [updatedTransactions removeObjectForKey:key];
    [self setTransactionsDictionary:updatedTransactions];
    NSLog(@"移除苹果orderId为%@的订单",key);
}

- (NSDictionary *)getOnstarOrderWithAppleOrderId:(NSString *)appleOrderId {
    NSDictionary *transactions = [self transactionsDictionary];
    return [transactions objectForKey:appleOrderId];
}

- (NSArray *)allFailureAppleOrderId {
    return [self transactionsDictionary].allKeys;
}

//- (NSDictionary *)getOnstarPramsWithTransaction:(SKPaymentTransaction*)transaction {
//    NSDictionary *prams = [self getOnstarOrderWithAppleOrderId:transaction.transactionIdentifier];
//    NSMutableDictionary *newPrams = prams.mutableCopy;
//    NSData *receiptData = [NSData dataWithContentsOfURL:[RMStore receiptURL]];
//    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    [newPrams setObject:receipt forKey:SOSAppleReceiptDataKey];
//    return newPrams.copy;
//}


#pragma mark - Private

- (NSDictionary*)transactionsDictionary
{
    if (!_transactionsDictionary)
    { // Reading the keychain is slow so we cache its values in memory
        NSData *data = RMKeychainGetValue(RMStoreTransactionsKeychainKey);
        NSDictionary *transactions = @{};
        if (data)
        {
            NSError *error;
            transactions = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!transactions)
            {
                NSLog(@"RMStoreKeychainPersistence: failed to read JSON data with error %@", error);
            }
        }
        _transactionsDictionary = transactions;
    }
    return _transactionsDictionary;
    
}

- (void)setTransactionsDictionary:(NSDictionary*)dictionary
{
    _transactionsDictionary = dictionary;
    NSData *data = nil;
    if (dictionary)
    {
        NSError *error;
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        if (!data)
        {
            NSLog(@"RMStoreKeychainPersistence: failed to write JSON data with error %@", error);
        }
    }
    RMKeychainSetValue(data, RMStoreTransactionsKeychainKey);
}


@end
