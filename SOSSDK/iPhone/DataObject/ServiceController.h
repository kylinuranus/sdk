//
//  ServiceControler.h
//  Onstar
//
//  Created by Onstar on 1/11/13.
//
//

#import <Foundation/Foundation.h>
@class GeoLocation;

typedef void(^ResultBlock)(id result);
typedef NS_ENUM(NSUInteger, SOSVehicleAlertType) {
    ALERT_LIGHT,
    ALERT_HORN,
   ALERT_ALL
};

@interface ServiceController : NSObject     {
    dispatch_queue_t pollingQueue;
    dispatch_source_t pollingTimerSource;
    dispatch_source_t timeoutTimerSource;
}
@property (readwrite, atomic)   BOOL loginFlagForDataRefresh;
@property (readwrite, atomic)   BOOL switcherLock;
@property (strong, atomic)      NSString *requestType;
@property (strong, atomic)      NSMutableArray *requestTypes;
//set hotspot info
@property (strong, nonatomic)   NSString *ssid;
@property (strong, nonatomic)   NSString *passphrase;
@property(strong,nonatomic)     GeoLocation *startLocation;
@property(strong,nonatomic)     NSString *destinationType;
@property(strong,nonatomic)     GeoLocation *destinationLocation;

@property (strong, nonatomic) NSString *desLatitude;
@property (strong, nonatomic) NSString *desLongitude;
@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
//ODD
@property (strong, nonatomic)NSString *destination_name;
@property (strong, nonatomic)NSString *destination_phoneNumber;

@property (strong, nonatomic)NSString *destination_address_streetNo;
@property (strong, nonatomic)NSString *destination_address_street;
@property (strong, nonatomic)NSString *destination_address_city;
@property (strong, nonatomic)NSString *destination_address_state;
@property (strong, nonatomic)NSString *destination_address_country;
@property (strong, nonatomic)NSString *destination_address_zipCode;

@property (strong, nonatomic)NSString *destination_location_longitude;
@property (strong, nonatomic)NSString *destination_location_latitude;

//new
@property(nonatomic,strong) NSString * migSessionKey;
@property(nonatomic,strong) NSString * vin;
@property(nonatomic,strong) NSString * language;
@property(nonatomic,strong) NSMutableArray * dataRefreshList;
@property (nonatomic, strong) NSString *currentRequestID;
@property (nonatomic, strong) NSString *currentRequestType;
//闪灯，鸣笛，闪灯+鸣笛
@property(nonatomic,assign)SOSVehicleAlertType alertType;

//set charge mode
@property(nonatomic,strong) NSString *chargeMode;
@property(nonatomic,strong) NSString *rateType;

//set depart time array
@property(nonatomic, strong) NSDictionary *scheduleDic;

@property(nonatomic, strong)NSString *duration;

+ (ServiceController *)sharedInstance;
- (BOOL)canPerformRequest:(NSString *)requestType;
- (BOOL)tryPerformRequest:(NSString *)inRequestType StartTime:(NSDate *)startTime;
- (BOOL)tryPerformRequest:(NSString *)requestType;
- (void)cleanCurrentRequest:(NSString *)requestType;

/// 获取 ICM 2.0 新增部件 状态接口请求参数,还需进一步封装
+ (NSMutableArray *)getICM2DataRefreshRequestTypes;

- (BOOL)isRuningRequest:(NSString *)requestType;

- (BOOL)canPerformVehicleService;
- (void)cleanUpVehicleSevices;
/// 操作加锁
- (void)updatePerformVehicleService;
//new

/*      检查功能是否可以执行
 *      functionName:功能名字  在Configuration中的宏定义
 */
- (BOOL)checkFuncitonIsValid:(NSString *) functionName;

/*      开始执行XXX功能
 *      functionName:功能名字  在Configuration中的宏定义
 *      startSuccess:执行成功时调用
 *      startFail:执行失败时调用
 *      askSuccess:轮询成功时调用
 *      askFail:轮询失败时调用
 *
 *      block返回参数类型有三种
 *      NSString,ErrorInfo,NSDictionary
 */
- (id)startFunctionWithName:(NSString *) functionName startSuccess:(ResultBlock) startSuccess startFail:(ResultBlock) startFail askSuccess:(ResultBlock) askSuccess askFail:(ResultBlock) askFail;

/*      开始执行XXX功能,并查询结果
 *      functionName:功能名字  在Configuration中的宏定义
 *      startSuccess:执行成功时调用
 *      startFail:执行失败时调用
 *      askSuccess:轮询成功时调用
 *      askFail:轮询失败时调用
 *      resultSuccess:查询到结果成时调用
 *      resultFail:查询到结果失败时调用
 *      block返回参数类型有三种
 *      NSString,ErrorInfo,NSDictionary
 */
- (id) startFunctionWithName:(NSString *) functionName startSuccess:(ResultBlock) startSuccess startFail:(ResultBlock) startFail askSuccess:(ResultBlock) askSuccess askFail:(ResultBlock) askFail resultSuccess:(ResultBlock) resultSuccess resultFail:(ResultBlock) resultFail;


- (id)startFunctionWithName:(NSString *)functionName Parameters:(NSString *)parameters Vin:(NSString *)vin startSuccess:(ResultBlock) startSuccess startFail:(ResultBlock) startFail askSuccess:(ResultBlock) askSuccess askFail:(ResultBlock) askFail resultSuccess:(ResultBlock) resultSuccess resultFail:(ResultBlock) resultFail;

- (void)startPolling;
- (void)stopPolling;
- (void)getAlertTimeFromMSP;
@end
