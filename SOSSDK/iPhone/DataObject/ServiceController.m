//
//  ServiceControler.m
//  Onstar
//
//  Created by Onstar on 1/11/13.
//
//

#import "ServiceController.h"
#import "AppPreferences.h"
#import "UserCarInfoVC.h"
#import "CustomerInfo.h"
 
#import "DataObject.h"
#import "SetHomeAddressVC.h"
#import "SOSFlexibleAlertController.h"

#define NEED_POP_TO_ROOT		0
#define NEED_POP				1
#define NEED_RELOGIN			2
static  NSString *const defaultDuration = @"1";

@interface ServiceController()
@property(strong, nonatomic)NSDate *serviceStartTime;
@property(strong, nonatomic)NSString * ReportID;
@property(strong, nonatomic)NSString *serviceResult;
@end

@implementation ServiceController	{
    ResultBlock _startSuccess;
    ResultBlock _startFail;
    ResultBlock _askSuccess;
    ResultBlock _askFail;
    ResultBlock _resultSuccess;
    ResultBlock _resultFail;
}

- (BOOL)canPerformRequest:(NSString *)inRequestType		{
    NSString *message = [NSString stringWithFormat:@"重复操作 原：%@, 现：%@",self.requestType, inRequestType];
    NSLog(@"canPerformRequest %@", message);
    if (self.switcherLock) {
        NSString *message = NSLocalizedString(@"MultiVehicleOperationAlert", nil);
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon／48x48／feedback_success_operable_48x48"] title:@"操作冲突" message:message customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        
        SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:nil];
        [vc addActions:@[action]];
        [vc show];
        
    }
    return !self.switcherLock;
}
// try perfor this request and record for reporting
- (BOOL)tryPerformRequest:(NSString *)inRequestType StartTime:(NSDate *)startTime	{
    BOOL result = [self tryPerformRequest:inRequestType];
    if (result) {
        self.serviceStartTime = startTime;
    }
    return result;
}

- (BOOL)tryPerformRequest:(NSString *)inRequestType		{
    NSString *message = [NSString stringWithFormat:@"try 重复操作 原：%@, 现：%@",self.requestType, inRequestType];
    NSLog(@"tryPerformRequest %@", message);
    if (self.switcherLock) {
        NSString *message = NSLocalizedString(@"MultiVehicleOperationAlert", nil);
//        [Util showAlertWithTitle:nil message:message completeBlock:nil];
        SOSFlexibleAlertController *vc = [SOSFlexibleAlertController alertControllerWithImage:[UIImage imageNamed:@"Icon／48x48／feedback_success_operable_48x48"] title:@"操作冲突" message:message customView:nil preferredStyle:SOSAlertControllerStyleAlert];
        
        SOSAlertAction *action = [SOSAlertAction actionWithTitle:@"知道了" style:SOSAlertActionStyleDefault handler:nil];
        [vc addActions:@[action]];
        [vc show];
        
        
        
        return NO;
    }
    else {
        self.requestType = inRequestType;
        [self.requestTypes addObject:inRequestType];
        self.switcherLock = YES;
    }
    return YES;
}

- (void)cleanCurrentRequest:(NSString *)inRequestType     {
    NSLog(@"clean request type = %@\n request Type array %@", inRequestType, self.requestTypes);
    if (self.loginFlagForDataRefresh) {
        self.loginFlagForDataRefresh = NO;
    }
    [self.requestTypes removeObject:inRequestType];
    self.switcherLock = NO;
}

- (BOOL)isRuningRequest:(NSString *)requestTypeIn     {
    BOOL flag = NO;
    if (self.requestTypes) {
        flag = [requestTypeIn isEqualToString:[self.requestTypes lastObject]];
    } else {
        flag = NO;
    }
    return flag;
}

#pragma mark singleton
static ServiceController *serviceController = nil;
+ (ServiceController *)sharedInstance     {
    static ServiceController *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (serviceController == nil) {
            serviceController = [super allocWithZone:zone];
            // assignment and return on first allocation
            return serviceController;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id) init {
    self = [super init];
    NSMutableArray *requestTypesTmp = [[NSMutableArray alloc] init];
    self.requestTypes = requestTypesTmp;
    pollingQueue = dispatch_queue_create("PollingTimerQueue", 0);
    [[LoginManage sharedInstance] addObserver:self forKeyPath:@"loginState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:Nil];
    return self;
}

- (BOOL)canPerformVehicleService	{
    return !self.switcherLock;
}

- (void)cleanUpVehicleSevices	{
    self.switcherLock = NO;
    if (self.requestTypes && [self.requestTypes isKindOfClass:[NSMutableArray class]])  [self.requestTypes removeAllObjects];
    _loginFlagForDataRefresh = NO;
}

// 操作加锁
- (void)updatePerformVehicleService	{
    self.switcherLock = YES;
}

//new
- (BOOL) checkFuncitonIsValid:(NSString *)functionName	{
    //如果pollingTimer存在，则说明有任务正在轮询。。。轮询。。。轮询。。。轮询。。。
    if(pollingTimerSource)	{
        if (_startFail) 	_startFail(@"正在执行其他操作，请稍后重试...");
        
        _startFail = nil;
        return NO;
    }
    return YES;
}

- (id)startFunctionWithName:(NSString *)functionName startSuccess:(ResultBlock)startSuccess startFail:(ResultBlock)startFail askSuccess:(ResultBlock)askSuccess askFail:(ResultBlock)askFail resultSuccess:(ResultBlock)resultSuccess resultFail:(ResultBlock)resultFail    {
    return     [self startFunctionWithName:functionName Parameters:nil Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin startSuccess:startSuccess startFail:startFail askSuccess:askSuccess askFail:askFail resultSuccess:resultSuccess resultFail:resultFail];
}

- (id)startFunctionWithName:(NSString *) functionName startSuccess:(ResultBlock) startSuccess startFail:(ResultBlock) startFail askSuccess:(ResultBlock) askSuccess askFail:(ResultBlock) askFail        {
    return     [self startFunctionWithName:functionName Parameters:nil Vin:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin startSuccess:startSuccess startFail:startFail askSuccess:askSuccess askFail:askFail resultSuccess:nil resultFail:nil];
}

- (id)startFunctionWithName:(NSString *) functionName Parameters:(NSString *)parameters Vin:(NSString *)vin startSuccess:(ResultBlock) startSuccess startFail:(ResultBlock) startFail askSuccess:(ResultBlock) askSuccess askFail:(ResultBlock) askFail resultSuccess:(ResultBlock) resultSuccess resultFail:(ResultBlock) resultFail	{
    
    //将对象的地址赋值给成员变量
    _startSuccess = [startSuccess copy];
    _startFail = [startFail copy];
    _askSuccess = [askSuccess copy];
    _askFail = [askFail copy];
    if (resultSuccess)	_resultSuccess = [resultSuccess copy];
    else				_resultSuccess = nil;
    if (resultFail)    _resultFail = [resultFail copy];
    else				_resultFail = nil;
    
    _requestType = functionName;
    
    if ([self checkFuncitonIsValid:functionName]) {
        //开始执行。。。
        [self startInitialRemoteOperationWithType:functionName Parameters:parameters Vin:vin];
    }	else	{
        //不执行。。。
        NSLog(@"function can't use");
    }
    return nil;
}

#pragma mark - onstar API url
- (NSString *)urlWithType:(NSString *)remoteType Vin:(NSString *)vin	{
    NSString *url = nil;
    if ([remoteType isEqualToString:LOCK_DOOR_REQUEST])							{
        url = [NSString stringWithFormat:ONSTAR_API_LOCKDOOR, vin];
    }    else if ([remoteType isEqualToString:UNLOCK_DOOR_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_UNLOCKDOOR, vin];
    }    else if ([remoteType isEqualToString:REMOTE_START_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_REMOTESTART, vin];
    }    else if ([remoteType isEqualToString:REMOTE_STOP_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_CANCELSTART, vin];
    }    else if ([remoteType isEqualToString:VEHICLE_ALERT_REQUEST] || [remoteType isEqualToString:VEHICLE_ALERT_HORN_REQUEST] || [remoteType isEqualToString:VEHICLE_ALERT_FLASHLIGHTS_REQUEST])	{
        url = [NSString stringWithFormat:ONSTAR_API_ALERT, vin];
    }	else if ([remoteType isEqualToString:VEHICLE_CANCEL_ALERT_REQUEST])		{
        url = [NSString stringWithFormat:ONSTAR_API_CANCELALERT, vin];
    }	else if([remoteType isEqualToString:GET_VEHICLE_LOCATION_REQUEST])		{
        url = [NSString stringWithFormat:ONSTAR_API_LOCATION, vin];
    }	else if ([remoteType isEqualToString:SEND_TO_TBT_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_TBT, vin];
    }	else if([remoteType isEqualToString:SEND_TO_NAV_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_ODD, vin];
    }	else if ([remoteType isEqualToString:GET_VEHICLE_DATA_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_DATAREFRESH, vin];
    }	else if ([remoteType isEqualToString:GET_HOTSPOT_INFO_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_GET_INFO, vin];
    }	else if ([remoteType isEqualToString:SET_HOTSPOT_INFO_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_SET_INFO, vin];
    }	else if([remoteType isEqualToString:GET_HOTSPOT_STATUS_REQUEST])		{
        url = [NSString stringWithFormat:ONSTAR_API_GET_STATUS, vin];
    }	else if([remoteType isEqualToString:ENABALE_HOTSPOT_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_ENABLE_STATUS, vin];
    }	else if([remoteType isEqualToString:DISABLE_HOTSPOT_REQUEST])			{
        url = [NSString stringWithFormat:ONSTAR_API_DISABLET_STATUS, vin];
    }	else if([remoteType isEqualToString:GET_CHARGE_PROFILE_REQUEST])		{
        url = [NSString stringWithFormat:ONSTAR_API_GET_PROFILE, vin];
    }	else if([remoteType isEqualToString:SET_CHARGE_PROFILE_REQUEST])		{
        url = [NSString stringWithFormat:ONSTAR_API_SET_PROFILE, vin];
    }	else if([remoteType isEqualToString:GET_SCHEDULE_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_GET_SCHEDULE, vin];
    }	else if([remoteType isEqualToString:SET_SCHEDULE_REQUEST])				{
        url = [NSString stringWithFormat:ONSTAR_API_SET_SCHEDULE, vin];
    }    else    {
        NSString *versionStr = @"v1";
        url = [NSString stringWithFormat:@"%@/api/%@/account/vehicles/%@/commands/%@", BASE_URL, versionStr, vin, remoteType];
        return url;
    }
    return [NSString stringWithFormat:@"%@%@",BASE_URL,url];
}

#pragma mark -- 设置DATA REFRESH --
- (NSMutableArray *) setRequestTypes	{
    NSMutableArray *requestTypes = [[NSMutableArray alloc] init];
    SOSVehicle *vehicle = CustomerInfo.sharedInstance.userBasicInfo.currentSuite.vehicle;
    
    if (vehicle.lastTripDistanceSupport)
        [requestTypes addObject:@"LAST TRIP DISTANCE"];
    
    if (vehicle.oilLifeSupport)
        [requestTypes addObject:@"OIL LIFE"];
    
    if (vehicle.odoMeterSupport)
        [requestTypes addObject:@"ODOMETER"];
    
    if (vehicle.fuelTankInfoSupport)
        [requestTypes addObject:@"FUEL TANK INFO"];
    
    if (vehicle.vehicleRangeSupported)
        [requestTypes addObject:@"VEHICLE RANGE"];
    
    if (vehicle.lifetimeFuelEconSupport)
        [requestTypes addObject:@"LIFETIME FUEL ECON"];
    
    if (vehicle.lastTripFuelEconSupport)
        [requestTypes addObject:@"LAST TRIP FUEL ECONOMY"];
    
    if (vehicle.tirePressureSupport) {
        [requestTypes addObject:@"TIRE PRESSURE"];
    }
    if (vehicle.getChargeModeSupport) {
        [requestTypes addObject:@"GET CHARGE MODE"];
    }
    if (vehicle.evScheduledChargeStartSupport) {
        [requestTypes addObject:@"EV SCHEDULED CHARGE START"];
    }
    if (vehicle.getCommuteScheduleSupport) {
        [requestTypes addObject:@"GET COMMUTE SCHEDULE"];
    }
    if (vehicle.evPlugVoltageSupport) {
        [requestTypes addObject:@"EV PLUG VOLTAGE"];
    }
    if (vehicle.evBatteryLevelSupport) {
        [requestTypes addObject:@"EV BATTERY LEVEL"];
    }
    if (vehicle.evPlugStateSupport) {
        [requestTypes addObject:@"EV PLUG STATE"];
    }
    if (vehicle.evEstimatedChargeEndSupport) {
        [requestTypes addObject:@"EV ESTIMATED CHARGE END"];
    }
    if (vehicle.evChargeStateSupport) {
        [requestTypes addObject:@"EV CHARGE STATE"];
    }
    if (vehicle.lifeTimeEVOdometerSupport) {
        [requestTypes addObject:@"LIFETIME EV ODOMETER"];
    }
    if (vehicle.bevBatteryRangeSupported) {
        [requestTypes addObject:@"BATTERY RANGE"];
    }
    if (vehicle.bevBatteryStatusSupported) {
        [requestTypes addObject:@"BATTERY STATUS"];
    }
    
    ///My21
    vehicle.brakePadLifeSupported ? [requestTypes addObject:@"BRAKE PAD LIFE"] : nil;
    vehicle.engineAirFilterMonitorStatusSupported ? [requestTypes addObject:@"ENGINE AIR FILTER MONITOR STATUS"] : nil;

    
    return requestTypes;
}

+ (NSMutableArray *)getICM2DataRefreshRequestTypes    {
    NSMutableArray *requestTypes = [[NSMutableArray alloc] init];
    SOSVehicle *vehicle = CustomerInfo.sharedInstance.userBasicInfo.currentSuite.vehicle;
    if (vehicle.windowPositionSupport)	 		[requestTypes addObject:@"WINDOW POSITION STATUS"];
    if (vehicle.sunroofPositionSupport)			[requestTypes addObject:@"SUNROOF POSITION STATUS"];
    if (vehicle.doorPositionSupport)         		[requestTypes addObject:@"DOOR AJAR STATUS"];
    if (vehicle.lastDoorCommandSupport)         	[requestTypes addObject:@"DOOR LAST REMOTE LOCK STATUS"];
    if (vehicle.flashStateSupport)         		[requestTypes addObject:@"HAZARDLIGHTS STATUS"];
    if (vehicle.lightStateSupport)         		[requestTypes addObject:@"HEADLIGHTS STATUS"];
    if (vehicle.engineStateSupport)         		[requestTypes addObject:@"REMOTE START STATUS"];
    if (vehicle.trunkPositionSupport)         	[requestTypes addObject:@"REAR CLOSURE AJAR STATUS"];
    return requestTypes;
}

//根据remoteType获得url地址
//发送执行请求
- (void)startInitialRemoteOperationWithType:(NSString *)remoteType  Parameters:(NSString *)parameters Vin:(NSString *)vin	{
    NSString *url = nil;
    NSString *json = parameters;
    url = [self urlWithType:remoteType Vin:vin];
    //lockDoor
    if([remoteType isEqualToString:LOCK_DOOR_REQUEST]){
        LockDoorRequest *lockDoor = [[LockDoorRequest alloc]init];
        [lockDoor setDelay:@"0"];
        RCLockDoorRequest *rc = [[RCLockDoorRequest alloc]init];
        [rc setLockDoorRequest:lockDoor];
        json = [rc mj_JSONString];
    }
    //unlockDoor
    else if([remoteType isEqualToString:UNLOCK_DOOR_REQUEST]){
        UnlockDoorRequest *unLockDoor = [[UnlockDoorRequest alloc]init];
        [unLockDoor setDelay:@"0"];
        RCUnlockDoorRequest *rc = [[RCUnlockDoorRequest alloc]init];
        [rc setUnlockDoorRequest:unLockDoor];
        json = [rc mj_JSONString];
    }
    //车辆位置：闪灯鸣笛
    else if ([remoteType isEqualToString:VEHICLE_ALERT_REQUEST] || [remoteType isEqualToString:VEHICLE_ALERT_HORN_REQUEST] || [remoteType isEqualToString:VEHICLE_ALERT_FLASHLIGHTS_REQUEST]) {
        
        RCalertRequest  *rc = [[RCalertRequest alloc] init];
        AlertRequest *alert = [[AlertRequest alloc] init];
        [alert setDelay:@"0"];
        if ([_duration length]>0) {
            [alert setDuration:_duration];
        }	else	{
            [alert setDuration:defaultDuration]; //闪灯鸣笛30秒
        }
        if (self.alertType == ALERT_ALL) {
            [alert setAction:@[@"Honk",@"Flash"]];
        }	else if (self.alertType == ALERT_HORN){
            [alert setAction:@[@"Honk"]];
        }	else if(self.alertType == ALERT_LIGHT){
            [alert setAction:@[@"Flash"]];
        }
        [alert setOverriden:@[@"DoorOpen",@"IgnitionOn"]];
        [rc setAlertRequest:alert];
        json =  [rc mj_JSONString];
    }
    //TBT
    else if ([remoteType isEqualToString:SEND_TO_TBT_REQUEST]) {
        RCtbtDestination *tbt = [[RCtbtDestination alloc]init];
        DestinationLocation *location = [[DestinationLocation alloc]init];
        [location setLat:self.desLatitude];//31.167986
        [location setLongi:self.desLongitude];//121.398862
        TBTDestination *tbtDesti = [[TBTDestination alloc] init];
        [tbtDesti setDestinationLocation:location];
        [tbt setTbtDestination:tbtDesti];
        json = [tbt mj_JSONString];
        //TODO tbt成功或者失败记载report未区分是map点击tbt还是音控导航tbt,因为不需要关注是何种方式tbt，只需关注tbt成功与否,默认Map tbt
//        self.ReportID = Map_TBT;
    }
    //ODD For 5.5.5 Don't use for MrO 's version.
    else if([remoteType isEqualToString:@"HARD_CODE_R5.5.5"]){
        RCnavDestination *navi = [[RCnavDestination alloc]init];
        DestinationLocation *location = [[DestinationLocation alloc]init];
        location.longi = self.destination_location_longitude;
        location.lat = self.destination_location_latitude;
        AdditionalDestinationInfo *info = [[AdditionalDestinationInfo alloc]init];
        DestinationAddress *address = [[DestinationAddress alloc]init];
        //中文转成英文城市
        [address setState:@"China"];
        [address setCity:self.destination_address_city];
        [address setStreet:self.destination_address_street];
        [info setName:self.destination_name];
        [info setDestinationAddress:address];
        NAVDestination *desti = [[NAVDestination alloc]init];
        [desti setDestinationLocation:location];
        [desti setAdditionalDestinationInfo:info];
        [navi setNavDestination:desti];
        json = [navi mj_JSONString];
    }
    //ODD
    else if([remoteType isEqualToString:SEND_TO_NAV_REQUEST]){
        RCnavDestination *navi = [[RCnavDestination alloc]init];
        DestinationLocation *location = [[DestinationLocation alloc]init];
        location.longi = self.destination_location_longitude;
        location.lat = self.destination_location_latitude;
        AdditionalDestinationInfo *info = [[AdditionalDestinationInfo alloc]init];
        DestinationAddress *address = [[DestinationAddress alloc]init];
        [address setState:@"China"];
        //        [address setStreet:self.destination_address_street];//UAT defect,没有具体地址信息
        [info setDestinationAddress:address];
        NAVDestination *desti = [[NAVDestination alloc]init];
        [desti setDestinationLocation:location];
        [desti  setAdditionalDestinationInfo:info];
        [navi setNavDestination:desti];
        json = [navi mj_JSONString];
    }
    //Data Refresh
    else if ([remoteType isEqualToString:GET_VEHICLE_DATA_REQUEST]) {
        RCdiagnosticsRequest *dataRefresh = [[RCdiagnosticsRequest alloc]init];
        DiagnosticsRequest *diagrequest = [[DiagnosticsRequest alloc]init];
        [diagrequest setDiagnosticItem:[self setRequestTypes]];
        [dataRefresh setDiagnosticsRequest:diagrequest];
        json = [dataRefresh mj_JSONString];
    }
    //set hotspotInfo
    else if ([remoteType isEqualToString:SET_HOTSPOT_INFO_REQUEST]) {
        RCsetHotSpot *setInfo = [[RCsetHotSpot alloc]init];
        Hotspot *spot= [[Hotspot alloc]init];
        [spot setSsid:self.ssid];
        [spot setPassphrase:self.passphrase];
        [setInfo setHotspotInfo:spot];
        json = [setInfo mj_JSONString];
    }
    //start charge
    else if ([remoteType isEqualToString:CHARGE_OVER_RIDE_REQUEST]) {
        NNEVChargeOverRide *override = [[NNEVChargeOverRide alloc]init];
        NNChargeOverrideRequest *request = [[NNChargeOverrideRequest alloc]init];
        [request setMode:@"CHARGE_NOW"];
        [override setChargeOverrideRequest:request];
        json = [override mj_JSONString];
    }
    //set charge profile
    else if ([remoteType isEqualToString:SET_CHARGE_PROFILE_REQUEST]) {
        NNChargingProfile *profile = [[NNChargingProfile alloc]init];
        NNChargingProfileRequest *request = [[NNChargingProfileRequest alloc]init];
        [request setChargeMode:self.chargeMode];
        [request setRateType:self.rateType];
        [profile setChargingProfile:request];
        json = [profile mj_JSONString];
    }
    // set schedule
    else if ([remoteType isEqualToString:SET_SCHEDULE_REQUEST]) {
        NNSchedule *sun = [[NNSchedule alloc]init];
        [sun setDayOfWeek:WEEK_DAY0];
        [sun setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY0]];
        NNSchedule *mon = [[NNSchedule alloc]init];
        [mon setDayOfWeek:WEEK_DAY1];
        [mon setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY1] ];
        NNSchedule *tue = [[NNSchedule alloc]init];
        [tue setDayOfWeek:WEEK_DAY2];
        [tue setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY2]];
        NNSchedule *wed = [[NNSchedule alloc]init];
        [wed setDayOfWeek:WEEK_DAY3];
        [wed setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY3]];
        NNSchedule *thu = [[NNSchedule alloc]init];
        [thu setDayOfWeek:WEEK_DAY4];
        [thu setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY4]];
        NNSchedule *fri = [[NNSchedule alloc]init];
        [fri setDayOfWeek:WEEK_DAY5];
        [fri setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY5]];
        NNSchedule *sat = [[NNSchedule alloc]init];
        [sat setDayOfWeek:WEEK_DAY6];
        [sat setDepartTime:[self.scheduleDic objectForKey:WEEK_DAY6]];
        
        NSArray *scheduleArray =[NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat, nil];
        NNWeeklyCommuteSchedule *weeklySchedule = [[NNWeeklyCommuteSchedule alloc]init];
        [weeklySchedule setDailyCommuteSchedule:scheduleArray];
        NNCommuteSchedule *communicateSchedule = [[NNCommuteSchedule alloc]init];
        [communicateSchedule setWeeklyCommuteSchedule:weeklySchedule];
        json = [communicateSchedule mj_JSONString];
    }
    //set trip
    else if ([remoteType isEqualToString:CREATE_TRIP_PLAN_REQUEST]) {
        DestinationLocation *location = [[DestinationLocation alloc]init];
        [location setLat:@"31.16837"];
        [location setLongi:@"121.397203"];
        NNEVNav *nav = [[NNEVNav alloc]init];
        [nav setDestinationLocation:location];
        [nav setOriginChargeCapable:@"true"];
        NNEVNavDestination *destination = [[NNEVNavDestination alloc]init];
        [destination setEvNavDestination:nav];
        json = [destination mj_JSONString];
    }
    // 打开车窗
    else if ([remoteType isEqualToString:@"openWindows"])		{
        json = @{@"openWindowOptions": @{@"openType": @"FULL"}}.mj_JSONString;
    }
    // 打开天窗
    else if ([remoteType isEqualToString:@"openSunroof"])        {
        json = @{@"openSunroofOptions": @{@"openType": @"FULL"}}.mj_JSONString;
    }
    
    if (parameters && parameters.length)	json = parameters;
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:json successBlock:^(SOSNetworkOperation *operation, id returnData) {
        if ([remoteType isEqualToString:SEND_TO_TBT_REQUEST]||[remoteType isEqualToString:SEND_TO_NAV_REQUEST]) {
            _startSuccess(returnData);
        }	else	{
            _startSuccess(@"Start success");
        }
        [self analysisStartResponse:returnData remoteType:remoteType WithVin:vin];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorCode = BACKEND_ERROR;
        if(statusCode == 0){
            errorCode = NETWORK_TIMEOUT;
        }
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if(dic)	{
            if ([[[[dic objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"]) {
                errorCode = [[[[dic objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"];
                
                if ([[dic objectForKey:@"description"] isEqualToString:@"invalid_token"])	{
                    [[LoginManage sharedInstance] upgradeToken:[LoginManage sharedInstance].pinCode];
                    [self startInitialRemoteOperationWithType:_requestType Parameters:parameters Vin:vin];
                    return ;
                }
            }
        }
        
        if (_startFail) 	_startFail(errorCode);
        
        _startFail = nil;
        [[ServiceController sharedInstance] cleanUpVehicleSevices];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"POST"];
    [sosOperation start];
}

//解析启动功能返回的结果
- (void)analysisStartResponse:(id) operation remoteType:(NSString *)remoteType WithVin:(NSString *)vin	{
   
    NSDictionary *responseDict = [Util dictionaryWithJsonString:operation];
    JsonError *error = [JsonError mj_objectWithKeyValues:[[[responseDict objectForKey:@"commandResponse"]objectForKey:@"body"]objectForKey:@"error"]];
    if (error.code) {
        if (_startFail) 	_startFail(error.code);
        
        _startFail = nil;
        [[ServiceController sharedInstance] cleanUpVehicleSevices];
    }	else {
        NSString *requestURL = [[responseDict objectForKey:@"commandResponse"] objectForKey:@"url"];
        NSString *status = [[responseDict objectForKey:@"commandResponse"] objectForKey:@"status"];
        NSArray  *urlArray = [requestURL componentsSeparatedByString:@"/"];
        NSString *currentrequestID = [urlArray lastObject];
        
        if([status isEqualToString:SERVER_RESPONSE_INPROGRESS]){
            [self startPollingWithVin:vin];
        }
        if ([currentrequestID length] > 0) {
            // 保存当前的request type和request id //询问雨辰说只有刷车况失败重登录后重试
            [[ServiceController sharedInstance] setCurrentRequestID:currentrequestID];
            [self setCurrentRequestType:remoteType];
            [self saveUnfinishedRequestWithVin:vin];
        }
    }
}

#pragma mark
#pragma mark -- 轮询 --
- (void)startPollingWithVin:(NSString *)vin	{
    [self stopPolling];
    [self performSelectorInBackground:@selector(pollingOnChildrenThreadWithVin:) withObject:vin];
}

- (void)pollingOnChildrenThreadWithVin:(NSString *)vin	{
    pollingTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pollingQueue);
    dispatch_source_set_timer(pollingTimerSource, dispatch_time(DISPATCH_TIME_NOW, POLLING_TIMER_INTERVAL * NSEC_PER_SEC), POLLING_TIMER_INTERVAL * NSEC_PER_SEC, 0);
    
    __block __weak ServiceController *weakSelf = self;
    dispatch_source_set_event_handler(pollingTimerSource, ^{
        [weakSelf pollingRemoteResultWithVin:vin];
    });
    dispatch_resume(pollingTimerSource);
    
    timeoutTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pollingQueue);
    dispatch_source_set_timer(timeoutTimerSource, dispatch_time(DISPATCH_TIME_NOW, REMOTE_CONTROL_TIME_OUT_TIMER * NSEC_PER_SEC), REMOTE_CONTROL_TIME_OUT_TIMER * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timeoutTimerSource, ^{
        [weakSelf stopPolling];
        
        dispatch_async_on_main_queue(^{
            if (_askFail) {
                _askFail(NETWORK_TIMEOUT);
            }
            _askFail = nil;
        });
        [[ServiceController sharedInstance] cleanUpVehicleSevices];
    });
    dispatch_resume(timeoutTimerSource);
    
}

- (void)stopPolling		{
    // timer停止的时候，表示请求已经完成，或者超时了。
    _currentRequestID = nil;
    _currentRequestType = nil;
    [self clearUnfinishedRequest];
    
    if (pollingTimerSource) {
        dispatch_source_cancel(pollingTimerSource);
        pollingTimerSource = nil;
    }
    
    if (timeoutTimerSource) {
        dispatch_source_cancel(timeoutTimerSource);
        timeoutTimerSource = nil;
    }
}

- (void)pollingLastTimeCommandResult:(NSString *)lastRequestID forRequest:(NSString *)requestName Vin:(NSString *)vin	{
    NSString *urlStr = [NSString stringWithFormat:ONSTAR_API_POLLING, vin, lastRequestID];
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, urlStr];
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        NSDictionary *responseDict = [Util dictionaryWithJsonString:returnData];
        NSString *operationStatus = [[responseDict objectForKey:@"commandResponse"] objectForKey:@"status"];
        if (responseDict == nil || operationStatus == nil || requestName == nil) {
            return;
        }
        if ([operationStatus isEqualToString:@"success"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LAST_VEHICLE_COMMAND_RESULT object:@[requestName, operationStatus, responseDict]];
            });
            
            [self clearUnfinishedRequest];
        } else if ([operationStatus isEqualToString:@"inProgress"]) {
            // 如果还没有完成，10秒后继续查询
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self pollingLastTimeCommandResult:lastRequestID forRequest:requestName Vin:vin];
            });
        } else {
            [self clearUnfinishedRequest];
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {	}];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

- (void)pollingRemoteResultWithVin:(NSString *)vin		{
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON) 	return;
    
    //轮询开始
    NSString *urlStr = [NSString stringWithFormat:ONSTAR_API_POLLING, vin, [ServiceController sharedInstance].currentRequestID];
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, urlStr];
    
    SOSNetworkOperation *sosOperation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id returnData) {
        [self analysisPollingResult:returnData];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSString *errorCode = BACKEND_ERROR;
        NSString *code = nil;
        if (responseStr.length) {
            NSDictionary *resDic = [responseStr mj_JSONObject];
            if ([resDic isKindOfClass:[NSDictionary class]] && resDic.count) {
                NSString *temCode = resDic[@"code"];
                if ([temCode isKindOfClass:[NSString class]] && temCode.length) {
                    code = temCode;
                }
            }
        }
        if(statusCode == 0 && ![code isEqualToString:@"-1009"]){
            errorCode = NETWORK_TIMEOUT;
        }
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        if ([[[[dic objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"]) {
            errorCode = [[[[dic objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"];
        }
        [self stopPolling];
        
        if (_askFail) {
            _askFail(errorCode);
        }
        _askFail = nil;
        [[ServiceController sharedInstance] cleanUpVehicleSevices];
    }];
    [sosOperation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [sosOperation setHttpMethod:@"GET"];
    [sosOperation start];
}

- (void)analysisPollingResult:(id) operation	{
    NSDictionary *responseDict = [Util dictionaryWithJsonString:operation];
    NSString *operationStatus = [[responseDict objectForKey:@"commandResponse"] objectForKey:@"status"];
    if ([operationStatus isEqualToString:@"success"]) {
        DebugLog(@">>>> Polling success!");
        [self stopPolling];
       
        if (_askSuccess) 	_askSuccess(responseDict);
        
        _askSuccess = nil;
        _askFail = nil;
        [[ServiceController sharedInstance] cleanUpVehicleSevices];

    } else if ([operationStatus isEqualToString:@"inProgress"]){
        DebugLog(@">>>> Polling In progress...");
    } else {
        DebugLog(@">>>> Polling failure!");
        [self stopPolling];
        
        NSString *errorCode = BACKEND_ERROR;
        if ([[[[responseDict objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"]) {
            errorCode = [[[[responseDict objectForKey:@"commandResponse"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"];
        }
        if (_askFail) {
            _askFail(errorCode);
        }
        _askFail = nil;
        [[ServiceController sharedInstance] cleanUpVehicleSevices];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context		{
    if ([change objectForKey:NSKeyValueChangeNewKey]==[change objectForKey:NSKeyValueChangeOldKey])		return;
    
    if ([keyPath isEqual:@"loginState"]) {
        if ([LoginManage sharedInstance].loginState == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
            ///获取车牌号，发动机号
            [UserCarInfoVC getVehicleBasicInfoSuccess:nil];
            ///获取家和公司Poi信息
            [[SetHomeAddressVC new] getHomeAndCompanyPoiInfo];
        }
    }
}

- (NSDictionary *)loadUnfinishedRequest	{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"UNFINISHED_VEHICLE_REQUEST"];
}

- (void)saveUnfinishedRequestWithVin:(NSString *)vin	{
    if (_currentRequestID && _currentRequestType) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *tmpDict = @{@"RequestID":_currentRequestID, @"RequestName":_currentRequestType, @"VIN":NONil(vin)};
        // 只保存一个
        [defaults setObject:tmpDict forKey:@"UNFINISHED_VEHICLE_REQUEST"];
        [defaults synchronize];
    }
}

- (void)clearUnfinishedRequest	{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"UNFINISHED_VEHICLE_REQUEST"];
    [defaults synchronize];
}

- (void)getAlertTimeFromMSP	{
    // send verification code
    NSString *url = [BASE_URL stringByAppendingString:REMOTE_ALERT_TIME_URL];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"response:%@",responseStr);
        NSDictionary *dic = [Util dictionaryWithJsonString:responseStr];
        [ServiceController sharedInstance].duration = [dic objectForKey:@"duration"];
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [ServiceController sharedInstance].duration = nil;
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}

- (void)dealloc	{
    [[LoginManage sharedInstance] removeObserver:self forKeyPath:@"loginState" context:nil];
}
@end
