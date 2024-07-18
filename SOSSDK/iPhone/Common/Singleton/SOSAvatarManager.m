//
//  SOSAvatarManager.m
//  Onstar
//
//  Created by TaoLiang on 2018/8/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAvatarManager.h"
#import <SDWebImage/SDWebImageManager.h>

//NSString * const kDefault_Account_Avatar = @"avatar";

@interface SOSAvatarManager ()
@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *vehicleAvatarHomeUrl;
@property (copy, nonatomic) NSString *vehicleAvatarOtherUrl;
@end

@implementation SOSAvatarManager

static SOSAvatarManager *avatarManager = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarManager = [SOSAvatarManager new];
    });
    return avatarManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak __typeof(self)weakSelf = self;
        
        weakSelf.avatarUrl = [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl;
        
        [RACObserve([LoginManage sharedInstance], loginState) subscribeNext:^(NSNumber *x) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (x.integerValue == LOGIN_STATE_NON) {
                    weakSelf.avatarUrl = nil;
                }else if (x.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                    weakSelf.avatarUrl = [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl;
                }
            });
        }];
    }
    return self;
}


- (void)fetchAvatar:(void (^)(UIImage * _Nullable, BOOL))avatarBlock {
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        avatarBlock([self getPlaceholderImage], YES);
    }else if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        _avatarUrl = [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl;
        if (_avatarUrl.length <= 0) {
            avatarBlock([self getPlaceholderImage], YES);
            return;
        }
        NSURL *url = [NSURL URLWithString:_avatarUrl];
        if (![[SDWebImageManager sharedManager] cacheKeyForURL:url]) {
            avatarBlock([self getPlaceholderImage], YES);
        }
        [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!error) {
                avatarBlock(image, NO);
            }else {
                avatarBlock([self getPlaceholderImage], YES);
            }
        }];
    }
}

- (void)saveImageToCache:(UIImage *)image forURL:(NSString *)urlString {
    _avatarUrl = urlString;
     //todosdk bucik app内闪退
//    NSURL *url = [NSURL URLWithString:urlString];
//    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
    [self syncToUserBasicInfo:urlString];
}

- (void)fetchVehicleAvatar:(SOSVehicleAvatarType)type avatarBlock:(void (^)(UIImage * _Nullable, BOOL))avatarBlock {
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) {
        avatarBlock([self getVehiclePlaceholderImage:type brand:@"UNSIGNIN"], YES);
    }else if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
        [self requestVehicleAvatarURL:^(BOOL success) {
            if (success) {
                NSString *urlString = (type == SOSVehicleAvatarTypeHomePage) ? _vehicleAvatarHomeUrl : _vehicleAvatarOtherUrl;
                if (![urlString isKindOfClass:NSString.class] ||  urlString.length <= 0) {
                    return;
                }
                NSURL *cacheURL = urlString.mj_url;
                [[SDWebImageManager sharedManager] loadImageWithURL:cacheURL options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!error) {
                        avatarBlock(image, NO);
                    }else {
                        NSString *brand = [self getBrandString];
                        avatarBlock([self getVehiclePlaceholderImage:type brand:brand], YES);
                    }
                }];
            }else {
                NSString *brand = [self getBrandString];
                avatarBlock([self getVehiclePlaceholderImage:type brand:brand], YES);
            }
        }];
        
    }
    
}

#pragma mark - private
- (UIImage *)getPlaceholderImage {
    return _placeholder.length > 0 ? [UIImage imageNamed:_placeholder] : [UIImage imageNamed:kDefault_Account_Avatar];
}

- (UIImage *)getVehiclePlaceholderImage:(SOSVehicleAvatarType)type brand:(NSString *)brand {
    NSArray *types = @[@"HOMEPAGE", @"OTHER"];
    NSString *imageName = [NSString stringWithFormat:@"VehicleAvatar_%@_%@_Placeholder", brand, types[type]];
    return [UIImage imageNamed:imageName];
}

- (NSString *)getBrandString {
    if ([Util vehicleIsBuick]) {
        return @"BUICK";
    }else if ([Util vehicleIsCadillac]) {
        return @"CADILLAC";
    }else if ([Util vehicleIsChevrolet]) {
        return @"CHEVROLET";
    }else {
        return @"UNSIGNIN";
    }
}

//同步到userBasicInfo
- (void)syncToUserBasicInfo:(NSString *)fullUrl {
    [CustomerInfo sharedInstance].userBasicInfo.preference.avatarUrl = fullUrl;
    [[LoginManage sharedInstance] saveUserBasicInfo:[[CustomerInfo sharedInstance].userBasicInfo mj_JSONString]];
}

- (void)requestVehicleAvatarURL:(void (^)(BOOL success))handler {
    __block NSTimeInterval startReqTime = [[NSDate date] timeIntervalSince1970] ;
    __weak __typeof(self)weakSelf = self;
    NSString *url = [BASE_URL stringByAppendingString:SOSFetchVehicleAvatarURL];
    SOSNetworkOperation *ope = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
//        if (![[responseStr class] isKindOfClass:[NSString class]]) {
//            handler ? handler(NO) : nil;
//        }
        [SOSDaapManager sendSysLayout:startReqTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:YES  funcId:VEHICLEPIC_LOAD_TIME];
        if (![responseStr isKindOfClass:NSString.class]) {
            handler ? handler(NO) : nil;
            return;
        }
        NSData *jsonData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData && jsonData.length >0) {
            NSError *error = nil;
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
            if(error) {
                handler ? handler(NO) : nil;
                return;
            }
            weakSelf.vehicleAvatarHomeUrl = data[@"viewA"];
            weakSelf.vehicleAvatarOtherUrl = data[@"viewB"];
            handler ? handler(YES) : nil;
        }
        
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [SOSDaapManager sendSysLayout:startReqTime endTime:[[NSDate date] timeIntervalSince1970] loadStatus:YES  funcId:VEHICLEPIC_LOAD_TIME];
        handler ? handler(NO) : nil;
    }];
    [ope setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [ope setHttpMethod:@"GET"];
    [ope start];
}


@end
