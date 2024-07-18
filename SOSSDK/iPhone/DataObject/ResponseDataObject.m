//
//  ResponseDataObject.m
//  Onstar
//
//  Created by Joshua on 15/8/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseDataObject.h"
#import "SOSSearchResult.h"
#import <MJExtension/MJExtension.h>
#import "NSDate+Modify.h"

@implementation NNErrorDetail
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"msg" : @"description",
             };
}
@end

@implementation Broadcastlist
+ (NSDictionary *)objectClassInArray{
    return @{
             @"broadcastList" : @"BroadcastDetail"
             };
}
@end

@implementation BroadCastDataResponse
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"broadcastListId" : @"id",
             };
}
@end

@implementation ResponseStatus

@end

@implementation ResponseInfo
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
    @end

@implementation BroadcastDetail

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"broadcastDetailId" : @"id",
             };
}

@end

@implementation TCPSResponseItem
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"tcpsItemId" : @"id",
             };
}
    @end
@implementation TCPSResponse
+ (NSDictionary *)objectClassInArray{
    return @{
             @"tcps" : @"TCPSResponseItem"
             };
}
- (NSString *)getTCPSUrlAtIndex:(NSInteger)index
{
        TCPSResponseItem * item =[self.tcps objectAtIndex:index];
        return item.url;
}
@end

@implementation CheckInAppVersionResponse
@end

@implementation SOSCheckAppVersionResponse
-(BOOL)isMustUpgradeVersion{
    return [self.force isEqualToString:@"force"];
}
-(BOOL)needAlertVersion{
    return [self.alert isEqualToString:@"alert"];
}
@end

@implementation NNPreferDealerDataResponse
@end

@implementation NNUpdatePreferDealer
@end

@implementation NNLandingPage

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"lid" : @"id",
             };
}
@end

@implementation CommandResponse
@end
@implementation DiagnosticElement
@end
@implementation DiagnosticResponse

+ (NSDictionary *)objectClassInArray{
    return @{
             @"diagnosticElement" : @"DiagnosticElement"
             };
}
@end

@implementation PackageListResponse
//
//+ (Class)packageArray_class     {
//    return [PackageInfos class];
//}
+ (NSDictionary *)objectClassInArray{
    return @{
             @"packageArray" : @"PackageInfos"
             };
}
@end

@implementation PackageInfos

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}

- (NSString *)packageId		{
    if (_packageId.length)		return _packageId;
    return _productNumber;
}

- (NSString *)actualPrice	{
    if (_actualPrice.length)        return _actualPrice;
    return _finalPrice;
}

@end

@implementation JsonError
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"message" : @"description",
             };
}
@end

@implementation NNPageable
@end

@implementation NNGetOrderHistoryResponse

+ (NSDictionary *)objectClassInArray{
    return @{
             @"orderList" : @"NNOrderInfo"
             };
}
@end

@implementation NNOrderInfo
@end


@implementation NNExtendedSubscriber
@end

@implementation NNAccount

+ (NSDictionary *)objectClassInArray{
    return @{
             @"vehicles" : @"NNVehicle"
             };
}
@end

@implementation NNVehicles
@end

@implementation NNPackageinfo
@end

@implementation NNCreateOrderResponse
@end

@implementation NNPaymentparameters
@end

@implementation NNGetPackageListResponse

+ (NSDictionary *)objectClassInArray{
    return @{
             @"packageList" : @"NNPackagelistarray"
             };
}
@end

@implementation channelList
+ (NSDictionary *)objectClassInArray{
    return @{
             @"channels" : @"channelDTO"
             };
}
@end

@implementation NNPackagelistarray

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end


@implementation NNGetDataListResponse

+ (NSDictionary *)objectClassInArray{
    return @{
             @"packageUsageInfos" : @"NNPackagelistarray"
             };
}
@end


@implementation NNSaveDeviceInfoResponse
@end

@implementation NNSaveSessionResponse
@end

@implementation NNChargingProfileRequest
@end

@implementation NNChargingProfile
@end

@implementation NNSchedule
@end

@implementation NNWeeklyCommuteSchedule
+ (NSDictionary *)objectClassInArray{
    return @{
             @"dailyCommuteSchedule" : @"NNSchedule"
             };
}
@end

@implementation NNCommuteSchedule
@end

@implementation NNContentHeader
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"contentId" : @"id",
             };
}
@end


@implementation NNContentHeaderCatogry

+ (NSDictionary *)objectClassInArray{
    return @{
             @"contentHeaderList" : @"NNContentHeader",
             
             };
}

@end


@implementation NNContent
@end

@implementation NNContentDeatil
@end


@implementation NNBanner
- (id)copyWithZone:(nullable NSZone *)zone
{
    NNBanner * cop = [[NNBanner allocWithZone:zone] init];
    cop.bannerID = _bannerID;
    cop.bannerNUM = _bannerNUM;
    cop.title = _title;
    cop.contentUrl = _contentUrl;
    cop.imgType = _imgType;
    cop.updateTS = _updateTS;
    cop.expiredStartTS = _expiredStartTS;
    cop.expiredEndTS = _expiredEndTS;
    cop.showType = _showType;
    cop.languagePreference = _languagePreference;
    cop.imgUrl = _imgUrl;
    cop.openStatus = _openStatus;
    cop.url = _url;
    cop.exposureMonitoringUrl = _exposureMonitoringUrl;
    cop.clickMonitoringUrl = _clickMonitoringUrl;
    cop.isScaling = _isScaling;
    cop.isH5Title = _isH5Title;
    cop.content = _content;
    cop.paramData = _paramData;
    cop.partnerId = _partnerId;
    cop.functionId = _functionId;
    return cop;
}
//+ (NSDictionary *)replacedKeyFromPropertyName{
//    return @{
//             @"title" : @"title",
//             };
//}



- (NSString *)modelTitle {
    return self.title;
}

- (NSString *)modelImage {
    return self.imgUrl;
}

- (void)setModelTitle:(NSString *)modelTitle {
    _title = modelTitle;
}
@end

//@implementation NNBannerList
////+ (Class)bannerList_class     {
////    return [NNBanner class];
////}
//
//+ (NSDictionary *)objectClassInArray{
//    return @{
//             @"bannerList" : @"NNBanner"
//             };
//}
//
//@end

@implementation NNCarOwnerLiving

+ (NSDictionary *)objectClassInArray{
    return @{
             @"LIFE_MANAGER": @"NNBanner",
             @"CAR_MANAGER" : @"NNBanner",
             @"HOT_PROMOTION" : @"NNBanner",
             };
}
@end

@implementation NNContentHeaderList
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"cid" : @"id",
             };
}
@end

@implementation NNOVDList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"contentHeaderList" : @"NNContentHeaderList"
             };
}
@end

@implementation NNOVDStatus
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"descrip" : @"description",
             };
}
@end

@implementation NNOvdStatusInfo
@end

@implementation NNvehicleMaintenance
@end

@implementation NNIndividualTirePressure

@end

@implementation NNTirePressure
@end

@implementation NNOvdMaintenanceInfo
@end

@implementation NNVehicleProfile
@end

@implementation NNOVDEmail
@end

@implementation NNOVDEmailDTO
@end



@implementation NNCenterPoiCoordinate
+ (NNCenterPoiCoordinate *)coordinateWithLongitude:(NSString *)lon AndLatitude:(NSString *)lat  {
    NNCenterPoiCoordinate *coor = [NNCenterPoiCoordinate new];
    coor.longi = lon;
    coor.lati = lat;
    return coor;
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"longi" : @"longitude",
             @"lati"  : @"latitude"
             };
}
@end

@implementation NNVehicle
//+ (Class)serviceEntitlement_class     {
//    return [NNServiceEntitlement class];
//}
//
//+ (Class)vehicleUnitFeatures_class     {
//    return [NNVehicleFeature class];
//}
+ (NSDictionary *)objectClassInArray{
    return @{
             @"serviceEntitlement" : @"NNServiceEntitlement",
             @"vehicleUnitFeatures" : @"NNVehicleFeature",
             };
}
- (NSString *)makeModel     {
    return [NSString stringWithFormat:@"%@%@", self.makeDesc, self.modelDesc];
}

@end

@implementation NNServiceEntitlement
@end

@implementation NNVehicleFeature
@end

@implementation NNSupportedDiagnostics
//+ (Class)supportedDiagnostic_class     {
//    return [NSString class];
//}
//+ (NSDictionary *)objectClassInArray{
//    return @{
//             @"supportedDiagnostic" : @"NSString"
//             };
//}
@end

@implementation NNCommandData
@end

@implementation NNCommand
+ (NSDictionary *)replacedKeyFromPropertyName	{
    return @{ @"desc" : @"description" };
}
@end

@implementation NNCommands
+ (NSDictionary *)objectClassInArray	{
    return @{ @"command" : @"NNCommand" };
}
@end

@implementation NNSupportedCommands
@end

@implementation NNGeoFence

- (id)copyWithZone:(NSZone *)zone	{
    NNGeoFence *copy = [NNGeoFence new];
    [copy mj_setKeyValues:self.mj_keyValues];
    copy.isEditStatus = self.isEditStatus;
    copy.isNewToAdd = self.isNewToAdd;
    copy.isLBSMode = self.isLBSMode;
//    copy.centerPoiCoordinate = self.centerPoiCoordinate;
    copy.vehicle = self.vehicle;
    return copy;
}

- (BOOL)isLBSMode	{
    return [self isKindOfClass:[NNLBSGeoFence class]];
}

- (void)setCenterPoiName:(NSString *)centerPoiName	{
    if (centerPoiName && [centerPoiName isKindOfClass:[NSString class]]) {
        _centerPoiName = centerPoiName;
    }	else	{
        _centerPoiName = @"";
    }
}

- (void)setIsNewToAdd:(BOOL)isNewToAdd	{
    _isNewToAdd = isNewToAdd;
    self.operationType = isNewToAdd ? @"ADD" : @"UPDATE";
}

+ (NSArray *)mj_ignoredPropertyNames    {
    return @[@"isEditStatus", @"isLBSMode", @"isNewToAdd", @"vehicle"];
}

- (BOOL)isOpen	{
    NSString *status = nil;
    if (self.isLBSMode) 	status = ((NNLBSGeoFence *)self).fenceStatus;
    else					status = self.geoFencingStatus;
    return [status isEqualToString:@"ON"];
}

- (NSString *)getGeoMobile	{
    NSString *mobile = nil;
    if (self.isLBSMode)     mobile = ((NNLBSGeoFence *)self).mobile;
    else                    mobile = self.mobilePhone;
    return mobile;
}

@end

@implementation NNLBSGeoFence

@synthesize centerPoiName;

+ (instancetype)mj_objectWithKeyValues:(id)keyValues	{
    NNLBSGeoFence *lbsGeo = [super mj_objectWithKeyValues:keyValues];
    lbsGeo.geoFencingName = lbsGeo.name;
    lbsGeo.centerPoiCoordinate = [NNCenterPoiCoordinate coordinateWithLongitude:lbsGeo.longitude AndLatitude:lbsGeo.latitude];
    lbsGeo.geoFencingStatus = lbsGeo.fenceStatus;
    lbsGeo.mobilePhone = lbsGeo.mobile;
    return lbsGeo;
}

+ (NSDictionary *)replacedKeyFromPropertyName	{
    return @{ @"centerPoiAddress" : @"description",
              @"Id": @"id" };
}

+ (NSArray *)mj_ignoredPropertyNames    {
    return @[@"isEditStatus", @"isLBSMode", @"isNewToAdd"];
}

- (id)copyWithZone:(NSZone *)zone    {
    NNLBSGeoFence *copy = [NNLBSGeoFence new];
    [copy mj_setKeyValues:self.mj_keyValues];
    copy.isEditStatus = self.isEditStatus;
    copy.isNewToAdd = self.isNewToAdd;
    copy.isLBSMode = self.isLBSMode;
    return copy;
}

- (NSString *)centerPoiName	{
    if (centerPoiName.length) 	return centerPoiName;
    else if (_name.length)		return _name;
    else						return @"";
}

//- (void)setGeoFencingName:(NSString *)geoFencingName    {
//    [super setGeoFencingName:geoFencingName];
//    self.name = geoFencingName;
//}

//- (void)setCenterPoiAddress:(NSString *)centerPoiAddress    {
//    if (!centerPoiAddress.length)    return;
//    [super setCenterPoiAddress:centerPoiAddress];
////    self.description = centerPoiAddress;
//}

- (void)setCenterPoiCoordinate:(NNCenterPoiCoordinate *)centerPoiCoordinate		{
    [super setCenterPoiCoordinate:centerPoiCoordinate];
    self.longitude = centerPoiCoordinate.longi;
    self.latitude = centerPoiCoordinate.lati;
}

- (void)setMobilePhone:(NSString *)mobilePhone	{
    [super setMobilePhone:mobilePhone];
    self.mobile = mobilePhone;
}

- (void)setGeoFencingStatus:(NSString *)geoFencingStatus	{
    [super setGeoFencingStatus:geoFencingStatus];
    self.fenceStatus = geoFencingStatus;
}

@end


@implementation NNGeoFenceList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"geoFenceList" : @"NNGeoFence"
             };
}
@end

@implementation NNErrorInfo
+ (Class)NNError_class     {
    return [NNError class];
}
@end

@implementation NNError
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end


@implementation NNFeedbackInfo
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end


@implementation NNGetWapPayUrlResponse
@end

@implementation NNQueryOrderStatusResponse
@end

@implementation NNGetVehicleListResponse

+ (NSDictionary *)objectClassInArray{
    return @{
             @"vehicles" : @"NNVehicle"
             };
}
@end

@implementation NNAroundDealerResponse
+ (Class) dealers_class     {
    return [NNDealers class];
}
+ (NSDictionary *)objectClassInArray{
    return @{
             @"dealers" : @"NNDealers"
             };
}
@end

@implementation NNDealers
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"dealersid" : @"id",
             };
}

+ (NSArray *)mj_ignoredPropertyNames	{
    return @[@"poi"];
}

- (NSString *)telephone	{
    if (_telephone.length) {
        if ([_telephone containsString:@";"]) {
            NSArray *strArr = [_telephone componentsSeparatedByString:@";"];
            if (strArr.count) {
                return strArr[0];
            }
        }
        return _telephone;
    }
    return @"";
}

- (SOSPOI *)poi{
    SOSPOI *poi = [SOSPOI new];
    poi.sosPoiType = POI_TYPE_Dealer;
    poi.name = _dealerName;
    poi.longitude = _locationCoordinate.longi;
    poi.latitude = _locationCoordinate.lati;
    poi.address = _address;
    poi.tel = _telephone;
    poi.distance = @(_distance * 1000).stringValue;
    return poi;
}

@end

@implementation NNRegisterResponse
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end




@implementation NNActivatePPCResponse
@end

@implementation SOSUserTokenInfo
@end

@implementation NNOAuthLoginResponse
@end

@implementation NNGetActivateHistoryResponse
+ (NSDictionary *)objectClassInArray{
    return @{
             @"orderList" : @"NNOrderList"
             };
}
@end

@implementation NNOrderList
@end

@implementation NNSubscriber
+ (NSDictionary *)objectClassInArray{
    return @{
             @"accounts" : @"NNAccount",
             @"corePackages" : @"PackageInfos"
             };
}
@end

@implementation NNDealersList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"dealers" : @"NNDealers"
             };
}
@end

@implementation NNOrdersList
+ (NSDictionary *)objectClassInArray{
    return @{
             @"orders" : @"NNOrders"
             };
}
@end

@implementation NNOrders
@end

@implementation NNHeadPhotoResponse
@end

@implementation GetDestinationResponse

- (SOSPOI *)poi {
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.name = self.poiName;
    poi.address = self.poiAddress;
    poi.type = self.poiCatetory;
    poi.city = self.cityCode;
    poi.province = self.provience;
    poi.tel = self.poiPhoneNumber;
    poi.nickName = self.poiNickname;
    poi.x = self.poiCoordinate.longi;
    poi.y = self.poiCoordinate.lati;
    poi.destinationID = self.favoriteDestinationID;
    return poi;
}

@end


@implementation NNGetSmartHomedeviceList
//+ (Class) devices_class{
//    return [NNMachinelistArray class];
//}
+ (NSDictionary *)objectClassInArray{
    return @{
             @"devices" : @"NNMachinelistArray"
             };
}
@end


@implementation NNProfiles
@end

@implementation NNMachinelistArray
@end

@implementation NNMyPreferentialModel
@end

@implementation NNgeofencing
+ (NSDictionary *)objectClassInArray{
    return @{
             @"geofencings" : @"NNGeoFence"
             };
}
@end

@implementation NNVehicleInfoModel
@end

@implementation NNSmartHomeStatus
+ (NSDictionary *)objectClassInArray{
    return @{
             @"esArray" : @"NNEsarray"
             };
}
@end

@implementation NNEsarray
@end

@implementation NNToken
@end

@implementation NNDispatcherRep
@end

@implementation NNNotifyConfig

@end

@implementation NNwechainLogin

@end

@implementation NNserviceObject
@end
/***/

@implementation NNUerBasicInfo
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end
/***/
/***/
@implementation SOSVehiclePrivilege
- (BOOL)hasVehicleServiceAviliable;
{
    BOOL aviliable  = _lock | _unLock | _remoteStart |_vehicleAlert ;
//    [SOSVehiclePrivilege mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
//        if ([property.type isNumberType]) {
//            aviliable = (aviliable | (BOOL)[property valueForObject:self]);
//        }
//    }];
    return aviliable;
}
- (id)valueForUndefinedKey:(NSString *)key  {
    //如果是取消启动，则和远程启动是否可用一致
    if ([key isEqualToString:REMOTE_STOP_REQUEST]) {
        return @(_remoteStart);
    }
    return @(1);
}
@end
@implementation SOSVehicleAndPackageEntitlement
@end

/***/

@implementation NNProvinceInfoObject
@end

@implementation NNProvincesObject
+ (NSDictionary *)objectClassInArray{
    return @{
             @"provinceList" : @"NNProvinceInfoObject"
             };
}
@end

@implementation NNCheckAccountObject
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
@end
@implementation NNBBWCQuestion

@end

@implementation NNservicesOpt
+ (NSDictionary *)objectClassInArray{
    return @{
             @"servicesList" : @"NNserviceObject"
             };
}
@end
@implementation NNBBWCResponse

@end

@implementation NNBBWCQuestionList

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"desc" : @"description",
             };
}
+ (NSDictionary *)objectClassInArray{
    return @{
             @"questions" : @"NNBBWCQuestion"
             };
}
@end

@implementation NNCarReportResp
@end

@implementation NNOilRankResp
@end

@implementation NNEngrgyRankResp
@end

@implementation NNDrivingScoreResp
@end

@implementation SOSTrailResp
@end

@implementation NNStarTravelStageInfo
@end

@implementation NNVehicleCashResp
-(instancetype)initWithMonthStatistics:(NSString *)ms yearStatistics:(NSString *)ys{
    if (self = [super init]) {
        self.multiMonthStatistics = ms;
        self.monthStatistics = ys;
        self.demo = YES;
    }
    return self;
}
@end

@implementation NNStarTravelResp
@end

@implementation NNLBSDadaInfo

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{ @"ID" : @"id"};
}

- (void)setCreatesWithDate:(NSDate *)date   {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _createts = [formatter stringFromDate:date];
}

@end


@implementation NNLBSLocationPOI

@end


@implementation MessageCenterModel

+ (NSDictionary *)objectClassInArray{
    return @{
             @"notificationStatusList" : @"MessageModel"
             };
}
@end

@implementation MessageModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"lastMsgTime" : @"lastMsg.date",
             @"lastMsgTitle" : @"lastMsg.title",
             };
}

@end


@implementation MessageCenterListModel

+ (NSDictionary *)objectClassInArray{
    return @{
             @"notifications" : @"NotifyOrActModel"
             };
}
@end

@implementation NotifyOrActModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"msgId" : @"id"
             };
}


@end



@implementation NearByDealerList

+ (NSDictionary *)objectClassInArray{
    return @{
             @"nearbyDealer" : @"NearByDealerModel",
             @"recommendDealer" : @"NearByDealerModel"
             };
}
@end


@implementation NearByDealerModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"dealerId" : @"id",
             @"longitude" : @"locationCoordinate.longitude",
             @"latitude" : @"locationCoordinate.latitude",
             };
}


- (SOSPOI *)poi		{
    SOSPOI *poi = [SOSPOI new];
    poi.name = self.dealerName;
    poi.longitude = self.longitude;
    poi.latitude = self.latitude;
    poi.address = self.address;
    poi.tel = self.telephone;
    poi.distance = self.distanceWithUnit;
    
    return poi;
}


@end

@implementation MirrorModel

- (instancetype)init
{
    if (self = [super init]) {
        self.userInfo = [[MirrorUserInfo alloc] init];
        self.vehScreens = [NSMutableArray array];
    }
    return self;
}

@end

@implementation MirrorUserInfo

@end

@implementation MirrorVehicleInfo

@end

@implementation MirrorCollectInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"longitude" : @"poiCoordinate.longitude",
             @"latitude" : @"poiCoordinate.latitude",
             };
}

@end


@implementation MirrorSettingModel

@end
////////////////
@implementation SOSInfoFlowSetting

@end

@implementation MirrorLocationModel

@end


@implementation MirrorPackageDetail

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if ([property.name isEqualToString:@"startTime"]) {
        return [self toTimeStringOldValue:oldValue];
    }else if ([property.name isEqualToString:@"expirationTime"]) {
        return [self toTimeStringOldValue:oldValue];
    }
    return oldValue;
}
#pragma mark 时间戳转时间
- (id)toTimeStringOldValue:(id)oldValue {
    if (oldValue) {
        NSTimeInterval timestamp = [oldValue doubleValue] / 1000;
        NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:timestamp];
        return [timeData toStringWithFormat:@"yyyy年MM月dd日"];
    }
    return oldValue;
}
@end

@implementation MirrorActivePackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"offerings" : @"MirrorPackageDetail"
             };
}

@end

@implementation MirrorUnactivePackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"offerings" : @"MirrorPackageDetail"
             };
}

@end

@implementation MirrorPackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"activePackages" : @"MirrorActivePackage",
             @"inActivePackages" : @"MirrorUnactivePackage",
             };
}

@end


@implementation MirrorCanBuyPackageDetail

@end


@implementation MirrorDataPackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"offerings" : @"MirrorCanBuyPackageDetail"
             };
}

@end

@implementation MirrorCorePackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"offerings" : @"MirrorCanBuyPackageDetail"
             };
}

@end


@implementation MirrorCanBuyPackage

+ (NSDictionary *)objectClassInArray{
    return @{
             @"dataPackages" : @"MirrorDataPackage",
             @"corePackages" : @"MirrorCorePackage",
             };
}

@end

@implementation MirrorRearviewOrdersModel

@end

@implementation MirrorRearviewOrdersList
+ (NSDictionary *)objectClassInArray{
    return @{
             @"orderList" : @"MirrorRearviewOrdersModel"
             };
}
@end





//@implementation SOSInfoFlowSettingResp
//@end

@implementation SOSOrderHistoryModel
@end

@implementation SOSOrderHistoryListModel
+ (NSDictionary *)objectClassInArray{
    return @{ @"result" : @"SOSOrderHistoryModel" };
}
@end
@implementation SOSMSRespModel
@end

@implementation SOSGetPackageServiceResponse
@end

@implementation SOSUserScheduleItem
@end

@implementation SOSUserScheldulesResp
+ (NSDictionary *)objectClassInArray{
    return @{
             @"userScheldules" : @"SOSUserScheduleItem"
             };
}
@end

@implementation SOSSocialOrderInfoResp
@end

@implementation SOSSocialOrderShareInfoResp
@end


@implementation SOSOilStation
+ (NSDictionary *)replacedKeyFromPropertyName	{
    return @{ @"stationID" : @"id" };
}

- (SOSPOI *)transToPOI	{
    SOSPOI *poi = [SOSPOI new];
    poi.name = self.gasName;
    poi.longitude = @(self.gasAddressLongitude).stringValue;
    poi.latitude = @(self.gasAddressLatitude).stringValue;
    poi.address = self.gasAddress;
    poi.province = self.provinceName;
    poi.city = self.cityName;
    poi.distance = @(self.distance).stringValue;
    return poi;
}

@end

@implementation SOSOilOrder
@end

@implementation SOSOilInfoObj
@end

