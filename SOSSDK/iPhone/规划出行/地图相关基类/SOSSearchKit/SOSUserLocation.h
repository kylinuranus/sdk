
#import <CoreLocation/CoreLocation.h>

@interface SOSUserLocation : NSObject

///定位状态
typedef NS_ENUM(NSUInteger, LocationState) {
    ///正在定位
    LocationStateInProcess = 1,
    ///定位成功
    LocationStateSucceed,
    ///定位失败
    LocationStateFailed,
};

///定位状态
@property (nonatomic, assign) LocationState locationState;

+ (SOSUserLocation *)sharedInstance;

/// 处理定位 POI 点
+ (void)handleLocationPOIInfoDone:(SOSPOI *)poi Success:(void (^)(BOOL done, SOSPOI *resultPOI))successBlock;

/// 获取用户定位,优先返回 60s 以内的结果	(默认使用 kCLLocationAccuracyHundredMeters 百米以内偏差精度)
- (void)getLocationSuccess:(void (^)(SOSPOI *userLocationPoi))success Failure:(void(^)(NSError *error))failureBlock;

/// 获取用户定位, 不使用缓存 (默认使用 kCLLocationAccuracyBest 最佳位置精度)
- (void)getLocationForcedSuccess:(void (^)(SOSPOI *userLocationPoi))success Failure:(void(^)(NSError *error))failureBlock;


/// 获取用户定位, 不使用逆地理编码 (默认使用 kCLLocationAccuracyHundredMeters 百米以内偏差精度, 不强制请求)
- (void)getLocationWithoutReGeoSuccess:(void (^)(CLLocationCoordinate2D coordinate))success Failure:(void(^)(NSError *error))failureBlock;


/// 获取经纬度(添加精度参数),逆地理编码   NeedReGeocode: 是否需要逆地理编码    isForceRequest:是否强制刷新定位	needShowAlert:是否显示定位权限失败弹框
- (void)getLocationWithAccuarcy:(CLLocationAccuracy)accuarcy NeedReGeocode:(BOOL)needReGeo isForceRequest:(BOOL)isForce NeedShowAuthorizeFailAlert:(BOOL)needShowAlert success:(void (^)(SOSPOI *poi))success Failure:(void (^)(NSError *error))failure;

/// 检测系统定位权限设置, 默认显示 Alert
- (BOOL)checkAuthorize;

/// 检测系统定位权限设置
- (BOOL)checkAuthorizeAndShowAlert:(BOOL)show;

@end

