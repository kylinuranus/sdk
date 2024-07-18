//
//  RequestDataObject.m
//  Onstar
//
//  Created by Joshua on 15/8/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestDataObject.h"

@implementation VehicleInformation
@end

@implementation AccountInfo

+ (NSDictionary *)objectClassInArray{
    return @{
             @"vehicles" : @"VehicleInformation"
             };
}
@end

@implementation SubscriberInfo

+ (NSDictionary *)objectClassInArray{
    return @{
             @"accounts" : @"AccountInfo"
             };
}
@end


@implementation CorePackageInfo
@end
@implementation channelDTO
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"channelDescription" : @"description",
             @"channelId" : @"id",
             };
}
@end
@implementation PrepayCardInfo
@end

@implementation ReportItemInfo
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"reportId" : @"id",
             };
}
@end

@implementation ChangePasswordRequest
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"theNewPassword" : @"newPassword",
             };
}
@end


@implementation NNGetBroadCastList
@end

@implementation ReportUserAction
+ (NSDictionary *)objectClassInArray{
    return @{
             @"reports" : @"ReportItemInfo"
             };
}
@end



@implementation chargingProfile
@end

@implementation dailyCommuteSchedule
@end

@implementation LockDoorRequest
@end

@implementation RCLockDoorRequest
@end

@implementation UnlockDoorRequest
@end

@implementation RCUnlockDoorRequest
@end

@implementation AlertRequest
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"overriden" : @"override",
             };
}
@end



@implementation RCalertRequest
@end

@implementation DestinationLocation
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"longi" : @"long",
             };
}
@end

@implementation DestinationAddress
@end

@implementation AdditionalDestinationInfo
@end

@implementation TBTDestination
@end

@implementation RCtbtDestination
@end

@implementation NAVDestination
@end

@implementation RCnavDestination
@end

@implementation DiagnosticsRequest
@end

@implementation RCdiagnosticsRequest
@end

@implementation Hotspot
@end

@implementation RCsetHotSpot
@end

@implementation PreferDealer
@end
@implementation NNVehicleAddRequest
@end


@implementation NNAroundDealerRequest
//+ (Class)Currentlocation_class     {
//    return [NNCurrentlocation class];
//}
@end
@implementation NNGAAEmailPhoneRequest

@end

@implementation NNfeedbackRequest

+ (NSDictionary *)objectClassInArray{
    return @{
             @"base64AttachedImageList" : @"NNBase64AttachedList"
             };
}
@end

@implementation NNBase64AttachedList
@end

@implementation VehicleInfoRequest
@end


@implementation NNSaveSessionRequest

+ (NSDictionary *)objectClassInArray{
    return @{
             @"vehicles" : @"VehicleInformation"
             
             };
}
@end

@implementation NNChargeOverrideRequest
@end

@implementation NNSaveDeviceInfoRequest
@end

@implementation NNEVChargeOverRide
@end

@implementation NNEVNav
@end

@implementation NNEVNavDestination
@end

@implementation NNBannerRequest
@end
@implementation NNTestResRequest
@end

@implementation NNOnBoardDays
@end

@implementation NNOAuthRequest
@end

@implementation NNUpgradeRequest
@end

@implementation NNGpsLocationCoordinate

+ (instancetype)locationWithLatitude:(double)latitude Longitude:(double)longitude	{
    NNGpsLocationCoordinate *location = [NNGpsLocationCoordinate new];
    location.longitude = @(longitude).stringValue;
    location.latitude = @(latitude).stringValue;
    return location;
}

@end

@implementation GetFavoriteDestinationListRequest
@end


@implementation NNPurchaseRequest
@end

@implementation NNCurrentlocation
@end

@implementation NNChangeVehicleRequest
@end
@implementation NNChangeAddressRequest
@end
#pragma mark - 8.0 注册
@implementation CaptchaDTO

@end
@implementation RegCodeDTO

@end
@implementation RegisterEnrollDTO

@end
@implementation NNRegisterRequest
//- (NSDictionary *)map     {
//    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[super map]];
//    [map setObject:@"newMobilePhoneNumber" forKey:@"theNewMobilePhoneNumber"];
//    [map setObject:@"newEmailAddress" forKey:@"theNewEmailAddress"];
//    return [NSDictionary dictionaryWithDictionary:map];
//}
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"theNewMobilePhoneNumber" : @"newMobilePhoneNumber",
             @"theNewEmailAddress" : @"newEmailAddress",
             };
}
@end

@implementation NNGetUserProfile
@end

@implementation NNFavoritePOI
@end



@implementation NNDealersReserveRequest
@end

@implementation NNDealersPreOrder
@end

@implementation NNUserVehicleAssetsRequest
@end
@implementation NNVehiclePrivilegeRequest
@end

@implementation NNHeadPhoto
@end

@implementation NNChargeNot
@end

@implementation NNVehicleInfoRequest
@end

@implementation NNserviceName
@end

@implementation NNProfilesModel
@end

@implementation NNControlSmartHome
@end

@implementation NNNewGeoFence
@end

@implementation NNBindGeoFence
@end

@implementation NNThirdParty
@end

@implementation NNExtension
@end

@implementation NNDispatcherReq
@end

@implementation NNURLRequest
@end

@implementation NNNotifyConfigRequest
@end

@implementation NNSendNotify
@end

@implementation NNTVLogin
@end

@implementation NNCarconditionReportReq
@end

//获取综合油耗排名 获取综合能耗排名
@implementation NNRankReq
@end
