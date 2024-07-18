//
//  CustomerInfo.m
//  Onstar
//
//  Created by Alfred Jin on 1/26/11.
//  Copyright 2011 plenware. All rights reserved.
//

#import "SOSLoginUserDbService.h"
#import "SOSGreetingManager.h"
#import "ApplePushSaveUtil.h"
#import "SOSLoginDbService.h"
#import "AppPreferences.h"
#import "CustomerInfo.h"
#import "SOSUserLocation.h"
#import "Util.h"

@implementation CustomerInfo

static CustomerInfo * sharedCustomerInfoDelegate = nil;

+ (CustomerInfo *)sharedInstance {
    static CustomerInfo *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] init];
    });
    return sharedOBJ;
}
- (NNOAuthLoginResponse *)tokenBasicInfo
{
    if (_tokenBasicInfo == nil) {
        _tokenBasicInfo = [[NNOAuthLoginResponse alloc] init];
    }
    return _tokenBasicInfo;
}

- (SOSLoginUserDefaultVehicleVO *)userBasicInfo {
    if (_userBasicInfo == nil) {
        _userBasicInfo = [[SOSLoginUserDefaultVehicleVO alloc] init];
    }
    if (_userBasicInfo.idpUserId.length <= 0) {
        _userBasicInfo.idpUserId = _tokenBasicInfo.idpUserId;
    }
    return _userBasicInfo;
}

//+ (void)insertChargeModeInto:(NSString *)tempTableNmae     {
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"DefaultOVDInfo.sqlite3"];
//	
//	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
//	sqlite3	*database = [delegate database];
//	
//	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
//		sqlite3_close(database);
//		NSAssert(0, @"Failed to open database");
//	}
//	
//	char *errorMsg;
//	NSString *tableNmae = [Util addChargeModePrexWithString:tempTableNmae];
//    
//	NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (vin, chargeMode, \
//                                                            timeYear, timeMonth, timeDay, timeAMorPM, \
//                                                            timeHour, timeMinute, timeSecond);", tableNmae];
//	
//	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//		sqlite3_close(database);
//		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
//		NSAssert1(0, @"Error creating table: %s", errorMsg);
//	}
//    //先删除旧记录
//    NSString * deleteOld = [[NSString alloc] initWithFormat:@"delete from %@",tableNmae];
//    if (sqlite3_exec (database, [deleteOld UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)   {
//        NSAssert1(0, @"Error Delete DataRefresh Data tables: %s", errorMsg);
//    }
//    NSString *update = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (vin, chargeMode, \
//                            timeYear, timeMonth, timeDay, timeAMorPM, \
//                            timeHour, timeMinute, timeSecond) VALUES \
//                            ('%@','%@','%@','%@','%@','%@','%@','%@',\
//                            '%@');", tableNmae,
//                            [self sharedInstance].userBasicInfo.currentSuite.vehicle.vin,
//                            [self sharedInstance].chargeMode,
//                            [self sharedInstance].timeYearVolt,
//                            [self sharedInstance].timeMonthVolt,
//                            [self sharedInstance].timeDayVolt,
//                            [self sharedInstance].timeAMorPMVolt,
//                            [self sharedInstance].timeHourVolt,
//                            [self sharedInstance].timeMinuteVolt,
//                            [self sharedInstance].timeSecondVolt];
//        
//    if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)   {
//            NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
//            NSAssert1(0, @"Error updating tables: %s", errorMsg);
//        }
//}
//
//+ (void)selectChargeModeFrom:(NSString *)tempTableNmae     {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"DefaultOVDInfo.sqlite3"];
//    AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
//    sqlite3	*database = [delegate database];
//    
//    if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
//        sqlite3_close(database);
//        NSAssert(0, @"Failed to open database");
//    }
//    
//    NSString *tableNmae = [Util addChargeModePrexWithString:tempTableNmae];
//    
//    //	NSString *query = [NSString stringWithFormat:@"select * FROM %@ WHERE %@ = %@",tableNmae, tempTableNmae, tempTableNmae];
//    NSString *query = [NSString stringWithFormat:@"select * FROM %@",tableNmae];
//    
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)    {
//        
//        while (sqlite3_step(statement) == SQLITE_ROW)   {
//            
//            for (int i = 0; i <= 8; i++) {
//                NSString *rowName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(statement, i)];
//                NSString *rowValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
//                if (!rowName.length)    continue;
//                if (rowValue.length)    [[self sharedInstance] setValue:rowValue forKey:rowName];
//                else                    [[self sharedInstance] setValue:nil forKey:rowName];
//            }
//        }
//    }   else   {
//        //[self sharedInstance].vin = @"";
//        [self sharedInstance].chargeMode = @"";
//        [self sharedInstance].timeYearVolt = @"";
//        [self sharedInstance].timeMonthVolt = @"";
//        [self sharedInstance].timeDayVolt = @"";
//        [self sharedInstance].timeAMorPMVolt = @"";
//        [self sharedInstance].timeHourVolt = @"";
//        [self sharedInstance].timeMinuteVolt = @"";
//        [self sharedInstance].timeSecondVolt = @"";
//    }
//    
//}

+ (void)insertInto:(NSString *)tempTableNmae     {
    if (tempTableNmae == nil) {
        return;
    }
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"DefaultOVDInfo.sqlite3"];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	char *errorMsg;
	NSString *tableNmae = [Util addVINPrexWithString:tempTableNmae];

	NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (vin , \
													carYear, vehicleRange , oDoMeter , lifeTimeFuelEcon , \
													fuelLavel , fuelLavelInGas , oilLife , \
													lastTripDistance , lastTripFuelEcon , \
													tirePressurePlacardFront , tirePressureLF , \
													tirePressureLFStatus , tirePressureLR , \
													tirePressureLRStatus , tirePressureRF , \
													tirePressureRFStatus , tirePressureRR , \
													tirePressureRRStatus , tirePressurePlacardRear, \
													timeYear, timeMonth, timeDay, timeAMorPM, \
                                                    timeHour, timeMinute, timeSecond, \
                                                    batteryLevel, evVoltage, chargeStartTime, chargeEndTime, \
                                                    chargeState, chargeMode, evRange, evTotleRange, plugInState, \
                                                    bevBatteryRange, bevBatteryStatus, airFilterStatus, brakePadLifeFront, brakePadLifeRear, brakePadLifeStatus);", tableNmae];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
    
    /************** START Check Table Column ***************/
    NSArray *voltInfoColumns = [[NSArray alloc] initWithObjects:@"batteryLevel", @"evVoltage", @"chargeStartTime", @"chargeEndTime", @"chargeState", @"chargeMode", @"evRange", @"evTotleRange", @"plugInState", @"bevBatteryRange", @"bevBatteryStatus", @"airFilterStatus", @"brakePadLifeFront", @"brakePadLifeRear", @"brakePadLifeStatus", nil];
    NSString *querySql = [NSString stringWithFormat:@"Select * from %@", tableNmae];
    sqlite3_stmt *queryStmt;
    if (sqlite3_prepare_v2(database, [querySql UTF8String], -1, &queryStmt, nil) == SQLITE_OK) {
        int columnCount = sqlite3_column_count(queryStmt);
        NSMutableArray *columnsArray = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for (int i = 0; i < columnCount; i++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(queryStmt, i)];
            NSLog(@"column Name :%@",columnName);
            [columnsArray addObject:columnName];
        }
        for (int i = 0; i < voltInfoColumns.count; i++) {
            if (![columnsArray containsObject:[voltInfoColumns objectAtIndex:i]]) {
                NSString *addColumnSql = [NSString stringWithFormat:@"alter table %@ add column %@;",tableNmae,[voltInfoColumns objectAtIndex:i]];
                NSLog(@"add column sql %@", addColumnSql);
                if (sqlite3_exec(database, [addColumnSql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                    sqlite3_close(database);
                    NSLog(@"erro msg %@", [NSString stringWithUTF8String:errorMsg]);
                    NSAssert1(0, @"fail to add column: %s", errorMsg);
                }else {
                    NSLog(@"add column exec success");
                }
            }
        }
    }
    /************** End   Check Table Column ***************/
    
    //先删除旧记录
    NSString * deleteOld = [[NSString alloc] initWithFormat:@"delete from %@",tableNmae];
    if (sqlite3_exec (database, [deleteOld UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)   {
        NSAssert1(0, @".......Error Delete DataRefresh Data tables: %s", errorMsg);
    }
    
    NSString *update = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (vin, carYear, vehicleRange, oDoMeter, \
                        lifeTimeFuelEcon, fuelLavel, fuelLavelInGas, \
                        oilLife, lastTripDistance, lastTripFuelEcon, \
                        tirePressurePlacardFront, tirePressureLF, \
                        tirePressureLFStatus, tirePressureLR, \
                        tirePressureLRStatus, tirePressureRF, \
                        tirePressureRFStatus, tirePressureRR, \
                        tirePressureRRStatus, tirePressurePlacardRear, \
                        timeYear, timeMonth, timeDay, timeAMorPM, \
                        timeHour, timeMinute, timeSecond, \
                        batteryLevel, evVoltage, chargeStartTime, chargeEndTime, \
                        chargeState, chargeMode, evRange, evTotleRange, plugInState, bevBatteryRange, bevBatteryStatus, airFilterStatus, brakePadLifeFront, brakePadLifeRear, brakePadLifeStatus) \
                        VALUES ('%@','%@','%@','%@','%@','%@','%@','%@',\
                        '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@', \
                        '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',\
                        '%@','%@','%@','%@','%@','%@','%@', '%@','%@','%@','%@','%@','%@','%@');", tableNmae,
                        [self sharedInstance].userBasicInfo.currentSuite.vehicle.vin, [[CustomerInfo sharedInstance] currentVehicle].year,
                        [self sharedInstance].vehicleRange, [self sharedInstance].oDoMeter,
                        [self sharedInstance].lifeTimeFuelEcon, [self sharedInstance].fuelLavel,
                        [self sharedInstance].fuelLavelInGas, [self sharedInstance].oilLife,
                        [self sharedInstance].lastTripDistance, [self sharedInstance].lastTripFuelEcon,
                        [self sharedInstance].tirePressurePlacardFront, [self sharedInstance].tirePressureLF,
                        [self sharedInstance].tirePressureLFStatus, [self sharedInstance].tirePressureLR,
                        [self sharedInstance].tirePressureLRStatus, [self sharedInstance].tirePressureRF,
                        [self sharedInstance].tirePressureRFStatus, [self sharedInstance].tirePressureRR,
                        [self sharedInstance].tirePressureRRStatus, [self sharedInstance].tirePressurePlacardRear,
                        [self sharedInstance].timeYear, [self sharedInstance].timeMonth, [self sharedInstance].timeDay,
                        [self sharedInstance].timeAMorPM, [self sharedInstance].timeHour,
                        [self sharedInstance].timeMinute, [self sharedInstance].timeSecond,
                        [self sharedInstance].batteryLevel, [self sharedInstance].evVoltage,
                        [self sharedInstance].chargeStartTime, [self sharedInstance].chargeEndTime,
                        [self sharedInstance].chargeState, [self sharedInstance].chargeModeHome,
                        [self sharedInstance].evRange, [self sharedInstance].evTotleRange,
                        [self sharedInstance].plugInState, [self sharedInstance].bevBatteryRange, [self sharedInstance].bevBatteryStatus,
                        [self sharedInstance].airFilterStatus, self.sharedInstance.brakePadLifeFront, self.sharedInstance.brakePadLifeRear, self.sharedInstance.brakePadLifeStatus];
	
    
	if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)   {
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error updating tables: %s", errorMsg);	
	}
}

+ (void)selectVehicleDataFromDB:(NSString *)tempTableNmae     {	
    if (nil == tempTableNmae) {
        return;
    }
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"DefaultOVDInfo.sqlite3"];
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *tableNmae = [Util addVINPrexWithString:tempTableNmae];
		
	NSString *query = [NSString stringWithFormat:@"select * FROM %@",tableNmae];
    
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)    {
		while (sqlite3_step(statement) == SQLITE_ROW)   {
			char *rowData = (char *)sqlite3_column_text(statement, 0);
			if (nil != rowData)     [self sharedInstance].userBasicInfo.currentSuite.vehicle.vin = [NSString stringWithUTF8String:rowData];
            for (int i = 1; i <= 41; i++) {
                char * rowNameChar = (char *)sqlite3_column_name(statement, i);
                if (rowNameChar == NULL) {
                    continue;
                }
                NSString *rowName = [NSString stringWithUTF8String:rowNameChar];
                NSString *rowValue = [NSString stringWithUTF8String:NONNullCChar((char *)sqlite3_column_text(statement, i))];
                if (![rowName isEqualToString:@"carYear"])
                {
                    if (rowValue.length){
                        [[self sharedInstance] setValue:rowValue forKey:rowName];
                    }
                    else{
                        [[self sharedInstance] setValue:nil forKey:rowName];
                    }
                }
            }
		}
        [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_OperateSuccess;
	}   else {
		[self sharedInstance].vehicleRange = nil;
		[self sharedInstance].oDoMeter = nil;
		[self sharedInstance].lifeTimeFuelEcon = nil;
		[self sharedInstance].fuelLavel = nil;
		[self sharedInstance].fuelLavelInGas = nil;
		[self sharedInstance].oilLife = nil;
		[self sharedInstance].lastTripDistance = nil;
		[self sharedInstance].lastTripFuelEcon = nil;
		[self sharedInstance].tirePressurePlacardFront = nil;
		[self sharedInstance].tirePressureLF = nil;
		[self sharedInstance].tirePressureLFStatus = nil;
		[self sharedInstance].tirePressureLR = nil;
		[self sharedInstance].tirePressureLRStatus = nil;
		[self sharedInstance].tirePressureRF = nil;
		[self sharedInstance].tirePressureRFStatus = nil;
		[self sharedInstance].tirePressureRR = nil;
		[self sharedInstance].tirePressureRRStatus = nil;
		[self sharedInstance].tirePressurePlacardRear = nil;
		[self sharedInstance].timeYear = nil;
        [self sharedInstance].timeMonth = nil;
        [self sharedInstance].timeDay = nil;
        [self sharedInstance].timeAMorPM = nil;
        [self sharedInstance].timeHour = nil;
        [self sharedInstance].timeMinute = nil;
        [self sharedInstance].timeSecond = nil;
        [self sharedInstance].batteryLevel = nil;
        [self sharedInstance].evVoltage = nil;
        [self sharedInstance].chargeStartTime = nil;
        [self sharedInstance].chargeEndTime = nil;
        [self sharedInstance].chargeState = nil;
        [self sharedInstance].chargeModeHome = nil;
        [self sharedInstance].evRange = nil;
        [self sharedInstance].plugInState = nil;
        [self sharedInstance].evTotleRange = nil;
        [self sharedInstance].bevBatteryRange = nil;
        self.sharedInstance.bevBatteryStatus = nil;
        self.sharedInstance.airFilterStatus = nil;
        self.sharedInstance.brakePadLifeFront = nil;
        self.sharedInstance.brakePadLifeRear = nil;
        self.sharedInstance.brakePadLifeStatus = nil;

        [SOSGreetingManager shareInstance].vehicleStatus = RemoteControlStatus_Void;
	}
}

- (void)logout {
    //往服务器注册deviceToken
    [ApplePushSaveUtil saveDeviceInfoWithIsBind:@"N" userID:[CustomerInfo sharedInstance].userBasicInfo.idpUserId];

    [self clearVehicleCommand];
//    self.servicesInfo = nil;
    //清除卡片缓存数据
    [[SOSGreetingManager shareInstance] clearCardCache:soskCardDataCacheName];
    // 刷新用户定位
//     [[SOSUserLocation sharedInstance] getLocationWithAccuarcy:kCLLocationAccuracyHundredMeters NeedReGeocode:YES isForceRequest:YES NeedShowAuthorizeFailAlert:NO success:nil Failure:nil];
}

- (SOSICM2VehicleStatus *)icmVehicleStatus {
    if (!_icmVehicleStatus) {
        _icmVehicleStatus = [SOSICM2VehicleStatus new];
    }
    return _icmVehicleStatus;
}

- (void)clearVehicleCommand{
    ///loginout delete loginDB
    [[SOSLoginDbService sharedInstance] clearDB];
    [[SOSLoginUserDbService sharedInstance] clearDB];
    if (self.icmVehicleStatus) {
        [self.icmVehicleStatus removeObserverBlocksForKeyPath:@"refreshState"];
    }
    // 清除 CustomerInfo 持有的对象,属性
    [[CustomerInfo sharedInstance] clearSharedInstancePropertys];
    [CustomerInfo sharedInstance].userBasicInfo = nil;
    
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedCustomerInfoDelegate == nil) {
			sharedCustomerInfoDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return sharedCustomerInfoDelegate;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id) init {
	self = [super init];
	if (self) {

		self.mig_appSessionKey			= @"";
		self.auth_token					= nil;
		self.sp_token					= nil;
		self.userBasicInfo					= nil;
		self.masked_user_name			= nil;
		self.remote_control_optin_status = NO;
        self.fmv_optin_status           = NO;
		self.userBasicInfo			    = nil;
		self.additional_account_no		= nil;
		
		self.vehicleRange				= nil;
		self.oDoMeter					= nil;
		self.lifeTimeFuelEcon			= nil;
		self.fuelLavel					= nil;
		self.fuelLavelInGas				= nil;
		self.oilLife					= nil;
		self.lastTripDistance			= nil;
		self.lastTripFuelEcon			= nil;
		self.tirePressurePlacardFront	= nil;
		self.tirePressureLF				= nil;
		self.tirePressureLFStatus		= nil;
		self.tirePressureLR				= nil;
		self.tirePressureLRStatus		= nil;
		self.tirePressureRF				= nil;
		self.tirePressureRFStatus		= nil;
		self.tirePressureRR				= nil;
		self.tirePressureRRStatus		= nil;
		self.tirePressurePlacardRear	= nil;
		self.timeYear					= nil;
		self.timeMonth					= nil;
		self.timeDay					= nil;
		self.timeAMorPM					= nil;
		self.timeHour					= nil;
		self.timeMinute					= nil;
		self.timeSecond					= nil;
        self.timeYearVolt				= nil;
		self.timeMonthVolt				= nil;
		self.timeDayVolt				= nil;
		self.timeAMorPMVolt				= nil;
		self.timeHourVolt				= nil;
		self.timeMinuteVolt				= nil;
		self.timeSecondVolt				= nil;
//        self.chargeMode                 = nil;
		self.batteryLevel               = nil;
        self.evVoltage                  = nil;
        self.chargeStartTime            = nil;
        self.chargeEndTime              = nil;
        self.chargeState                = nil;
        self.chargeModeHome             = nil;
        self.evRange                    = nil;
        self.evTotleRange               = nil;
        self.plugInState                = nil;
        
		self.vehicleList				= nil;
		self.vinList					= nil;
        self.carYearList                = nil;
		self.modelList					= nil;
				
		self.aroundSearchCategory		= nil;
        self.wifi_SSID                  = nil;
        self.wifi_pwd                   = nil;
        self.wifi_status                = nil;
        
//        self.rateType                   = nil;
//        self.chargeMode                 = nil;
//        
        self.scheduleList               = nil;
        _vehicleList                    = [[NSMutableArray alloc] init];
        _vehicleServicePrivilege       = [[SOSVehiclePrivilege alloc] init];
        self.isInDelear                 = NO;
	}
	
	return self;
}

- (SOSServicesInfo *)servicesInfo {
    if (!_servicesInfo) {
        _servicesInfo = [[SOSServicesInfo alloc] init];
    }
    return _servicesInfo;
}

/**
 更新customerinfo中车相关信息,针对某些特别车型（ICM、Info34等）更改genid，否则会产生功能缺失.ps:此部分先沿用之前customerInfo内属性表示
 */
- (void)updateVehicleAttribute     {
    if ([[CustomerInfo sharedInstance] currentVehicle].icm || [[CustomerInfo sharedInstance] currentVehicle].superCruise || [[CustomerInfo sharedInstance] currentVehicle].info34) {
        [[CustomerInfo sharedInstance] currentVehicle].gen10 = YES;
    }
    self.phev = [self.currentVehicle phev];
    
    self.remote_control_optin_status = [_userBasicInfo.preference.vehiclePreference remoteControlOpt];
    self.fmv_optin_status = [_userBasicInfo.preference.vehiclePreference fmvOpt];
}
- (void)updateServiceEntitlement:(SOSVehicleAndPackageEntitlement *)entitlement
{
    self.isExpired = !entitlement.hasAvaliablePackage;
    self.vehicleServicePrivilege = entitlement.map;
    //判断如果是司机／代理，判断是否被授权
    if ( [SOSCheckRoleUtil isDriverOrProxy] ) {
        if ([entitlement.map hasVehicleServiceAviliable]) {
            //只要有一个服务可用，就是已经授权
            self.carSharingFlag = YES;
        }else{
            self.carSharingFlag = NO;
        }
    }
    
}
- (NSString *)getIdpidVinStr
{
    return [NSString stringWithFormat:@"%@%@",self.userBasicInfo.idpUserId ,self.userBasicInfo.currentSuite.vehicle.vin]; 
}
- (BOOL)sendToTBTSupported
{
    if ([Util vehicleIsIcm])
    {
        //icm车不支持tbt
        return NO;
    }
    return self.userBasicInfo.currentSuite.vehicle.sendToTBTSupported;
}

/**
 是否是车机平台注册用户
 @return
 */
- (BOOL)isCMSRegisterUser;
{
    if (![[self.userBasicInfo.idmUser.firstName uppercaseString] isEqualToString:@"FNAME"] || ![[self.userBasicInfo.idmUser.lastName uppercaseString] isEqualToString:@"LNAME"]) {
        return YES;
    }
    return NO;
}

/**
 获取当前车辆

 @return 当前车辆
 */
- (SOSVehicle *)currentVehicle
{
     return  self.userBasicInfo.currentSuite.vehicle;
}

- (NSString *)evRange{
    if([Util isValidNumber:_evRange]){
        return _evRange;
    } else {
        return @"--";
    }
}
- (NSString *)batteryLevel{
    if([Util isValidNumber:_batteryLevel]){
        return _batteryLevel;
    } else {
        return @"--";
    }
}
- (NSString *)evTotleRange{
    if([Util isValidNumber:_evTotleRange]){
        return _evTotleRange;
    } else {
        return @"--";
    }
}

@end
