

#import "CustomerInfo.h"
#import "BaseSearchOBJ.h"
#import "SOSUserLocation.h"
#import "SOSSearchResult.h"
#import "SOSMapHeader.h"

typedef void(^LocationSuccessBlock)(SOSPOI * poi);
typedef void(^FailureBlock)(NSError *);

@interface SOSUserLocation()    <CLLocationManagerDelegate, GeoDelegate, ErrorDelegate>  {
    CLLocationManager *CLManager;
    AMapLocationManager *manager;
    BaseSearchOBJ *searchOBJ;
}

@property (copy, nonatomic, nullable) LocationSuccessBlock successBlock;
@property (copy, nonatomic, nullable) FailureBlock failureBlock;

@end

@implementation SOSUserLocation

+ (id)sharedInstance     {
    static SOSUserLocation *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [self new];
    });
    return sharedOBJ;
}

+ (void)handleLocationPOIInfoDone:(SOSPOI *)poi Success:(void (^)(BOOL done, SOSPOI *resultPOI))successBlock{
    if (poi == nil) {
        [Util showHUD];
        [[SOSUserLocation sharedInstance] getLocationWithoutReGeoSuccess:^(CLLocationCoordinate2D coordinate) {
            [Util dismissHUD];
            SOSPOI *resultPOI = [SOSPOI new];
            resultPOI.longitude = @(coordinate.longitude).stringValue;
            resultPOI.latitude = @(coordinate.latitude).stringValue;
            if (successBlock)    successBlock(YES, resultPOI);
        } Failure:^(NSError *error) {
            [Util dismissHUD];
            [Util toastWithMessage:@"获取定位信息失败"];
            if (successBlock)    successBlock(NO, nil);
        }];
    }    else    {
        if (successBlock)    successBlock(YES, poi);
    }
}

#pragma mark - Public Method
static int fail_times = 0;
- (void)getLocationSuccess:(void (^)(SOSPOI *userLocationPoi))success Failure:(void(^)(NSError *error))failure	{
    [self getLocationWithAccuarcy:kCLLocationAccuracyHundredMeters success:success Failure:failure];
}

- (void)getLocationForcedSuccess:(void (^)(SOSPOI *))success Failure:(void (^)(NSError *))failureBlock		{
    [self getLocationWithAccuarcy:kCLLocationAccuracyNearestTenMeters NeedReGeocode:YES isForceRequest:YES NeedShowAuthorizeFailAlert:YES success:success Failure:failureBlock];
}

- (void)getLocationWithAccuarcy:(CLLocationAccuracy)accuarcy success:(void (^)(SOSPOI *))success Failure:(void (^)(NSError *))failureBlock		{
    [self getLocationWithAccuarcy:accuarcy NeedReGeocode:YES isForceRequest:NO NeedShowAuthorizeFailAlert:YES success:success Failure:failureBlock];
}

- (void)getLocationWithoutReGeoSuccess:(void (^)(CLLocationCoordinate2D))success Failure:(void (^)(NSError *))failureBlock		{
    [self getLocationWithAccuarcy:kCLLocationAccuracyHundredMeters NeedReGeocode:NO isForceRequest:NO NeedShowAuthorizeFailAlert:YES success:^(SOSPOI *poi) {
        if (success)  success(CLLocationCoordinate2DMake(poi.latitude.doubleValue, poi.longitude.doubleValue));
    } Failure:failureBlock];
}

- (void)getLocationWithAccuarcy:(CLLocationAccuracy)accuarcy NeedReGeocode:(BOOL)needReGeo isForceRequest:(BOOL)isForce NeedShowAuthorizeFailAlert:(BOOL)needShowAlert success:(void (^)(SOSPOI *))success Failure:(void (^)(NSError *error))failure	{
    SOSPOI *poi = [CustomerInfo sharedInstance].currentPositionPoi;
    if (poi && !isForce) {
        NSTimeInterval timeInterval = - [[NSDate dateWithISOFormatString:poi.operationDateStrValue] timeIntervalSinceNow];
        if (timeInterval < 60)    {
//            self.locationState = LocationStateSucceed;
            if (success) success(poi);
            return;
        }
    }
    if (self.locationState == LocationStateInProcess) {
        NSError *error = [NSError errorWithDomain:@"LocationInProcess" code:-888 userInfo:@{@"message": @"LocationInProcess"}];
        if (failure)	failure(error);
        return;
    }
    self.locationState = LocationStateInProcess;
    if (!manager)   manager = [[AMapLocationManager alloc] init];
    manager.desiredAccuracy = accuarcy;
    manager.locationTimeout = 5;
    manager.reGeocodeLanguage = AMapLocationReGeocodeLanguageChinse;
    if ([self checkAuthorizeAndShowAlert:needShowAlert]) {
        [manager stopUpdatingLocation];
        [manager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            //解决某些机型第一次定位到太平洋的问题
            if (!location.coordinate.longitude && !location.coordinate.latitude) {
                fail_times ++;
                if (fail_times < 4) {
                    [self getLocationWithAccuarcy:accuarcy success:success Failure:failure];
                    return ;
                } else {
                    fail_times = 0;
                }
            }
            if (error) {
                // 排除 取消
                if (error.code != 5) {
                    self.locationState = LocationStateFailed;
                    if (failure) failure(error);
                }
                return;
            }
            if (needReGeo == NO) {
                SOSPOI *poi = [SOSPOI new];
                poi.sosPoiType = POI_TYPE_CURRENT_LOCATION;
                poi.latitude = @(location.coordinate.latitude).stringValue;
                poi.longitude = @(location.coordinate.longitude).stringValue;
                poi.operationDateStrValue = [[NSDate date] stringWithISOFormat];
                self.locationState = LocationStateSucceed;
                if (success) success(poi);
                return;
            }	else	{
                if (!searchOBJ)    {
                    searchOBJ = [BaseSearchOBJ new];
                    searchOBJ.geoDelegate = self;
                    searchOBJ.errorDelegate = self;
                }
                [searchOBJ reGeoCodeSearchWithLocation:[AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude]];
                self.successBlock = success;
                self.failureBlock = failure;
            }
        }];
    }	else	{
        NSError *error = [NSError errorWithDomain:@"AuthorizeFail" code:-999 userInfo:@{@"message": @"AuthorizeFail"}];
        self.locationState = LocationStateFailed;
        if (failure) failure(error);
    }

}

#pragma mark - Search Delegate
- (void)reverseGeocodingResults:(NSArray *)results	{
    if (results.count) {
        SOSPOI *poi = [results[0] copy];
        poi.sosPoiType = POI_TYPE_CURRENT_LOCATION;
        [CustomerInfo sharedInstance].currentPositionPoi = poi;
        self.locationState = LocationStateSucceed;
        if (self.successBlock) 	self.successBlock(poi);
        self.successBlock = nil;
    }	else	{
        NSError *error = [NSError errorWithDomain:@"ReGeoFail" code: -888 userInfo:@{@"message": @"ReGeoFail"}];
        self.locationState = LocationStateFailed;
        if (self.failureBlock) 	self.failureBlock(error);
        self.failureBlock = nil;
    }
}

- (void)baseSearch:(id)searchOption Error:(NSString *)errCode	{
    NSError *error = [NSError errorWithDomain:@"ReGeoFail" code: -777 userInfo:@{@"message": errCode}];
    self.locationState = LocationStateFailed;
    if (self.failureBlock)     self.failureBlock(error);
    self.failureBlock = nil;
}

#pragma mark - Author Check
- (BOOL)checkAuthorizeAndShowAlert:(BOOL)show	{
    CLManager = [CLLocationManager new];
    CLManager.delegate = self;
    [CLManager requestWhenInUseAuthorization];
    //判断定位服务有没有打开
    NSInteger authStatus = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && authStatus == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    
    if (![CLLocationManager locationServicesEnabled] && authStatus == kCLAuthorizationStatusDenied) {
        return NO;
    }
    
    if (![CLLocationManager locationServicesEnabled] || (authStatus == kCLAuthorizationStatusRestricted) || (authStatus == kCLAuthorizationStatusDenied))   {
        if (show)    [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
        return NO;
    }
    return YES;
    
}

- (BOOL)checkAuthorize  {
    return [self checkAuthorizeAndShowAlert:YES];
}

- (void)showAlert   {
    dispatch_async_on_main_queue(^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [Util showAlertWithTitle:@"安吉星暂未获得您的权限" message:nil completeBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            } cancleButtonTitle:@"取消" otherButtonTitles:@"去设置",nil];
        }
    });
}

@end
