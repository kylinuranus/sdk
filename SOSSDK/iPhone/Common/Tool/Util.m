//
//  Util.m
//  Onstar
//
//  Created by Alfred Jin on 1/18/11.
//  Copyright 2011 plenware. All rights reserved.
//
#import "Util.h"
#import "OpenUDID.h"
#import "LoadingView.h"
#import "CustomerInfo.h"
#import "NSDataAES256.h"
#import "NetworkErrorVC.h"
#import "SOSSearchResult.h"
#import "SOSCheckRoleUtil.h"
#import "SOSGreetingManager.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSTopNetworkTipView.h"
#import <EventKit/EventKit.h>
#import "SOSDateFormatter.h"
#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import <Toast/UIView+Toast.h>
#import <CommonCrypto/CommonDigest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "SOSFlexibleAlertController.h"
#import "SOSAlertEvluateVC.h"
#import <UserNotifications/UserNotifications.h>

#define IOS_WIFI            @"en0"
#define IP_ADDR_IPv4        @"ipv4"
#define IP_ADDR_IPv6        @"ipv6"
#define IOS_CELLULAR        @"pdp_ip0"

#define KeyMrOOpenFlag          @"Key_MrO_Open_Flag"
#define DATE_FORMAT           	@"yyyy-MM-dd HH:mm:ss.SSS"

//7FchbyjDyMT8kBs3sUi+6Q== 8.3
//3LIspfjKoiQT09wVIGjcaQ== 8.3.1
//I4gv4VowxO6Uv3yaglOL4A== 8.4
//LM7DCK6HuExTAC2RalHOsQ== 8.4.1
//cE9nckmdz/egkLPwgsRuxA== 8.4.2
//1KI8GULvaXzS6Z8GIVgnZg== 8.5
//uEhGrALwxtb90zlcYGHPXw== 8.5.1
//nj719cgX86fZAC6uLpws7Q== 8.6.0


#define kUpdateSecret  [SOSSDKKeyUtils updateSecret] //Info3后台上线后，客户端版本将会强制升级至7.2，用户登录时获取client_info判断版本做强制升级。


static NSString * publicIP =@"0.0.0.0";
@implementation Util
+ (NSString*) checkInputString:(NSString*)str     {
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
	str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];	
	str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	str = [str stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
	str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
	return str;
}

+ (void) writeConfig:(NSString *)keyName setValue:(NSObject *)value     {
	// Documents directory 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); 
	NSString *documentsPath = [paths objectAtIndex:0]; 
	// <Application Home>/Documents/config.plist 
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"DefaultOVDInfo.plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	[dict setObject:value forKey:keyName ];
	[dict writeToFile:configPath atomically:YES ];
}

+ (NSString *) readConfig:(NSString *)keyName     {
	// Documents directory 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); 
	NSString *documentsPath = [paths objectAtIndex:0]; 
	// <Application Home>/Documents/config.plist 
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"DefaultOVDInfo.plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	NSString* object = [dict objectForKey:keyName ];
	return object;
}

+ (void) writeCaclulateWithMulateArray:(NSMutableArray *) arr     {
    // Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    // <Application Home>/Documents/config.plist
    NSString *configPath = [documentsPath stringByAppendingPathComponent:@"CaclulateDate.plist"];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:configPath];
//    [dict setObject:value forKey:keyName ];
    [array writeToFile:configPath atomically:YES ];
}

+ (NSMutableArray *) readCaclulateDate     {
    // Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    // <Application Home>/Documents/config.plist
    NSString *configPath = [documentsPath stringByAppendingPathComponent:@"CaclulateDate.plist"];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:configPath];
    return array;
}

+ (void) writeVisotrConfig:(NSString *)keyName setValue:(NSObject *)value     {
	// Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	// <Application Home>/Documents/config.plist
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"Visitor.plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	[dict setObject:value forKey:keyName ];
	[dict writeToFile:configPath atomically:YES ];
}

+ (NSArray *) readVisitorConfig:(NSString *)keyName     {
	// Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	// <Application Home>/Documents/config.plist
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"Visitor.plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	NSArray* object = [dict objectForKey:keyName ];
	return [object copy];
}

+ (void)writeToVisitorDocuments     {
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"Visitor"ofType:@"plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	
	// Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	// <Application Home>/Documents/ACUConfig.plist
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"Visitor.plist"];
	NSMutableDictionary *dictD = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	
	NSEnumerator* keys = [dict keyEnumerator];
	NSEnumerator* keysWriteTo = [dictD keyEnumerator];
	if ([[keysWriteTo allObjects] count] < 1){
		id key;
		while (key = [keys nextObject]){
			[dictD setObject:key forKey:[dict objectForKey:key]];
			[ dict writeToFile:configPath atomically:YES ];
		}
	}

}

+ (void)writeToDocuments     {
	NSString *path = [[NSBundle SOSBundle] pathForResource:@"DefaultOVDInfo"ofType:@"plist"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	
	// Documents directory 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); 
	NSString *documentsPath = [paths objectAtIndex:0]; 
	// <Application Home>/Documents/ACUConfig.plist 
	NSString *configPath = [documentsPath stringByAppendingPathComponent:@"DefaultOVDInfo.plist"];
	NSMutableDictionary *dictD = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
	
	NSEnumerator* keys = [dict keyEnumerator];
	NSEnumerator* keysWriteTo = [dictD keyEnumerator];
	if ([[keysWriteTo allObjects] count] < 1){
		id key;
		while (key = [keys nextObject]){
			[dictD setObject:key forKey:[dict objectForKey:key]];
			[ dict writeToFile:configPath atomically:YES ];
		}
	}
    //拷贝CaclulateDate.plist 到 Doc文件夹
    NSString * caclulateFromPath = [[NSBundle SOSBundle] pathForResource:@"CaclulateDate"ofType:@"plist"];
    NSString * caclulateToPath = [documentsPath stringByAppendingPathComponent:@"CaclulateDate.plist"];
    
    NSFileManager * fm = [[NSFileManager alloc]init];
    
    BOOL isExit = [fm fileExistsAtPath:caclulateToPath];
    
    if (!isExit && caclulateFromPath) {
           [fm copyItemAtPath:caclulateFromPath toPath:caclulateToPath error:nil];
    }
}



+ (NSString *)addVINPrexWithString:(NSString *)vin     {
    return [NSString stringWithFormat:@"VIN%@", vin];
}

+ (NSString *)removeVINPrexWithString:(NSString *)vin     {
	NSMutableString *tempString = [[NSMutableString alloc] initWithString:vin];
	[tempString replaceCharactersInRange: NSMakeRange(0, 3) withString:@""];
    
	return tempString;
}

+ (NSString *)addChargeModePrexWithString:(NSString *)vin     {
	NSMutableString *tempString = [[NSMutableString alloc] initWithString:@"CM"];
	[tempString appendString:vin];
	
	return tempString;
}

+ (NSString *)removeChargeModePrexWithString:(NSString *)vin     {
	NSMutableString *tempString = [[NSMutableString alloc] initWithString:vin];
	[tempString replaceCharactersInRange: NSMakeRange(0, 2) withString:@""];
    
	return tempString;
}

+ (NSData*) encryptString:(NSString*)plaintext withKey:(NSString*)key     {
	return [[plaintext dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
}

+ (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key     {       
	return [[NSString alloc] initWithData:[ciphertext AES256DecryptWithKey:key]
								  encoding:NSUTF8StringEncoding];
}

+ (void)updateTBTinfoTableWithStatus:(NSString *)newStatus andID:(NSNumber *)keyID atTable:(NSString *)tableNmae     {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"pollingInfos.sqlite3"];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) 
	{
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *update = [NSString stringWithFormat:@"UPDATE %@ SET status='%@' where id = ?", tableNmae,  newStatus];
	
	sqlite3_stmt *update_statement;
	
	if(sqlite3_prepare_v2(database, [update UTF8String], -1, &update_statement, NULL) != SQLITE_OK)
		NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
	
	sqlite3_bind_int(update_statement, 1, [keyID intValue]);
	
	if (SQLITE_DONE != sqlite3_step(update_statement)) {
		NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_reset(update_statement);
	sqlite3_finalize(update_statement);
	sqlite3_close(database);
}

+ (void)insertInto:(NSString *)tableNmae WithSendTBTinfos:(NSDictionary *)poiInfos     {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"pollingInfos.sqlite3"];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	// 修改VIN 创建TBT表
    char *errorMsg;
	NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
						   requestID, time, address, title, status, phoneNumber, latitude, longitude, cityname, province,vin);", tableNmae];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
	
    NSString *query = [NSString stringWithFormat:@"select * FROM %@",tableNmae];
	
	sqlite3_stmt *read_statement;
	
    BOOL isFull = NO;
    NSInteger count = 0;
    
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &read_statement, nil) == SQLITE_OK) 
	{		
        /***************************** start check update **************************/
        NSMutableArray *columns = [[NSMutableArray alloc] init];
        int colummcount = sqlite3_column_count(read_statement);
        for (int i = 0; i < colummcount; i++) {
            NSString *columnname = [NSString stringWithUTF8String:sqlite3_column_name(read_statement, i)];
            [columns addObject:columnname];
            NSLog(@"i  = %d,columnname %@", i, columnname);
        }
        NSMutableString *addColumn = [NSMutableString stringWithString:@"alter table %@ add column %@;"];
        
        if (![columns containsObject:@"cityname"]) {
            NSString *addcolumnSql = [NSString stringWithFormat:addColumn,tableNmae, @"cityname"];
            NSLog(@"add column str %@", addcolumnSql);
            if (sqlite3_exec (database, [addcolumnSql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(database);
                NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
                NSAssert1(0, @"Error creating table: %s", errorMsg);
            }
            
        }
        if (![columns containsObject:@"province"]) {
            NSString *addcolumnSql = [NSString stringWithFormat:addColumn,tableNmae, @"province"];
            NSLog(@"add column str %@", addcolumnSql);
            if (sqlite3_exec (database, [addcolumnSql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(database);
                NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
                NSAssert1(0, @"Error creating table: %s", errorMsg);
            }
        }
        //插入vin列
        if (![columns containsObject:@"vin"]) {
            NSString *addcolumnSql = [NSString stringWithFormat:addColumn,tableNmae, @"vin"];
            NSLog(@"add column str %@", addcolumnSql);
            if (sqlite3_exec (database, [addcolumnSql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                sqlite3_close(database);
                NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
                NSAssert1(0, @"Error creating table: %s", errorMsg);
            }
        }
        NSLog(@"check send to TBT table column end");
        /***************************** start check update **************************/
        
		while (sqlite3_step(read_statement) == SQLITE_ROW) 
		{
            count++;
        }
    }
    
    if (count >= 20)
        isFull = YES;
    
    sqlite3_reset(read_statement);
	sqlite3_finalize(read_statement);
        
	NSString *update = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (requestID, time, address, title, status, phoneNumber, latitude, longitude, cityname, province,vin)\
							VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');", tableNmae,
                        [Util Dic:poiInfos ObjForKey:SEND_TO_TBT_REQUEST_ID],
                        [Util Dic:poiInfos ObjForKey:K_SEND_TO_TBT_TIME],
                        [Util Dic:poiInfos ObjForKey:K_SEARCH_RESULT_ADDRESS],
                        [Util Dic:poiInfos ObjForKey:K_SEARCH_RESULT_NAME],
                        [Util Dic:poiInfos ObjForKey:K_SEND_TO_TBT_STATUS],
                        [Util Dic:poiInfos ObjForKey:K_SEARCH_RESULT_PHONE_NUMBER],
                        [Util Dic:poiInfos ObjForKey:K_LATITUDE],
                        [Util Dic:poiInfos ObjForKey:K_LONGITUDE],
                        [Util Dic:poiInfos ObjForKey:K_SEARCH_RESULT_CITY_NAME],
                        [Util Dic:poiInfos ObjForKey:K_SEARCH_RESULT_PROVINCE_NAME],
                        [Util Dic:poiInfos ObjForKey:K_SEND_TO_TBT_VIN]];
	
	if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error updating tables: %s", errorMsg);	//crash
	}	
	
    
    
    if (isFull) 
    {
        NSString *query = [NSString stringWithFormat:@"select * FROM %@",tableNmae];
        
        sqlite3_stmt *read_statement;
        
        if (sqlite3_prepare_v2( database, [query UTF8String], -1, &read_statement, nil) == SQLITE_OK)      {
            while (sqlite3_step(read_statement) == SQLITE_ROW) 
            {
                NSString *delete = [NSString stringWithFormat:@"delete from %@ where id = ?",tableNmae];
                
                sqlite3_stmt *delete_statement;
                
                if(sqlite3_prepare_v2(database, [delete UTF8String], -1, &delete_statement, NULL) != SQLITE_OK)
                    NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
                
                sqlite3_bind_int(delete_statement, 1, sqlite3_column_int(read_statement, 0));
                
                if (SQLITE_DONE != sqlite3_step(delete_statement)) {
                    NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
                }
                
                sqlite3_reset(delete_statement);
                sqlite3_finalize(delete_statement);
                
                break ;
            }
        }
        
        sqlite3_reset(read_statement);
        sqlite3_finalize(read_statement);
    }
}

+ (NSString *)Dic:(NSDictionary *)dic ObjForKey:(NSString *)key       {
    NSString *tempStr = NONil(dic[key]);
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\'" withString:@"''"];
    return tempStr;
}

+ (void)insertInto:(NSString *)tableNmae WithRequestId:(NSString *)requestID andRequestType:(NSString *)requestType     {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"pollingInfos.sqlite3"];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
    // BEGIN TRANSACTION
    sqlite3_exec(database,"BEGIN TRANSACTION",0,0,0);
    
	char *errorMsg;
    
	NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, \
                           vin, model, make, requestID, requestType);",
                           tableNmae];
	
	if (sqlite3_exec (database, [createSQL  UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
		sqlite3_close(database);
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error creating table: %s", errorMsg);
	}
	
	NSString *query = [NSString stringWithFormat:@"select * FROM %@",tableNmae];
	
	sqlite3_stmt *read_statement;
	
	NSString *tempVIN = [NSString stringWithFormat:@""];
	
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &read_statement, nil) == SQLITE_OK) 
	{		
		while (sqlite3_step(read_statement) == SQLITE_ROW) 
		{	
			char *rowData = (char *)sqlite3_column_text(read_statement, 1);
			if (nil != rowData) 
			{
				tempVIN = [NSString stringWithUTF8String:rowData];
			}

			
			rowData = (char *)sqlite3_column_text(read_statement, 5);
			if (nil != rowData) 
			{
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				if ([tempString isEqualToString:requestType]) 
				{		
					if ([tempVIN isEqualToString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin])
					{
						NSString *delete = [NSString stringWithFormat:@"delete from %@ where id = ?",tableNmae];
						
						sqlite3_stmt *delete_statement;
						
						if(sqlite3_prepare_v2(database, [delete UTF8String], -1, &delete_statement, NULL) != SQLITE_OK)
							NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
						
						sqlite3_bind_int(delete_statement, 1, sqlite3_column_int(read_statement, 0));
						
						if (SQLITE_DONE != sqlite3_step(delete_statement)) {
							NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
						}
						
						sqlite3_reset(delete_statement);
						sqlite3_finalize(delete_statement);
					}
				}
			}
		}
		
	}
	

	
	sqlite3_reset(read_statement);
	sqlite3_finalize(read_statement);

    ///model == modelDesc    make==makeDesc
	NSString *update = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (vin, model, make, requestID, requestType) VALUES ('%@','%@','%@','%@','%@');",
						tableNmae, [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,
						[[CustomerInfo sharedInstance] currentVehicle].modelDesc,
						[[CustomerInfo sharedInstance] currentVehicle].makeDesc,
						requestID, requestType];
	
	if (sqlite3_exec (database, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
        sqlite3_close(database);
		NSLog(@"errorMsg is:%@", [NSString stringWithUTF8String:errorMsg]);
		NSAssert1(0, @"Error updating tables: %s", errorMsg);	
	}
    
    // COMMIT
    int result = sqlite3_exec(database,"COMMIT",0,0,&errorMsg); //COMMIT
    NSLog(@"Commit result = %d",  result);
    sqlite3_close(database);
}


+ (NSMutableArray *)getDestinationItemsFrom:(NSString *)tableNmae     {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"pollingInfos.sqlite3"];
	
	NSMutableArray *destinations = [[NSMutableArray alloc] init];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
// 查询TBT数据库
//	NSString *query = [NSString stringWithFormat:@"select * FROM %@ ORDER BY ID DESC",tableNmae];
    NSString *vin = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin;
	NSString *query = [NSString stringWithFormat:@"select * FROM %@ WHERE  VIN IS NULL OR VIN = '%@'   ORDER BY ID DESC",tableNmae,vin];
	sqlite3_stmt *read_statement;
	
	if (sqlite3_prepare_v2( database, [query UTF8String], -1, &read_statement, nil) == SQLITE_OK) 
	{		
		while (sqlite3_step(read_statement) == SQLITE_ROW) 
		{
			NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
			
			NSInteger vinID = sqlite3_column_int(read_statement, 0);
			[infoDict setObject:@(vinID) forKey:VIN_INFOS_KEY_ID];
			
			char *rowData = (char *)sqlite3_column_text(read_statement, 1);
			if (nil != rowData) 
			{
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:SEND_TO_TBT_REQUEST_ID];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 2);
			if (nil != rowData) 
			{
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEND_TO_TBT_TIME];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 3);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEARCH_RESULT_ADDRESS];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 4);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEARCH_RESULT_NAME];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 5);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEND_TO_TBT_STATUS];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 6);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEARCH_RESULT_PHONE_NUMBER];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 7);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_LATITUDE];
			}
			
			rowData = (char *)sqlite3_column_text(read_statement, 8);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_LONGITUDE];
			}
            
            rowData = (char *)sqlite3_column_text(read_statement, 9);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEARCH_RESULT_CITY_NAME];
			}
            
            rowData = (char *)sqlite3_column_text(read_statement, 10);
			if (nil != rowData) {
				
				NSString *tempString = [NSString stringWithUTF8String:rowData];
				[infoDict setObject:tempString forKey:K_SEARCH_RESULT_PROVINCE_NAME];
			}
            
            rowData = (char *)sqlite3_column_text(read_statement, 11);
            if (nil != rowData) {
                
                NSString *tempString = [NSString stringWithUTF8String:rowData];
                [infoDict setObject:tempString forKey:K_SEND_TO_TBT_VIN];    //读取VIN
            }
            
			[destinations addObject:infoDict];
		}
	}
	
	sqlite3_reset(read_statement);
	sqlite3_finalize(read_statement);
	
	return destinations;
}


+ (void)deleteVinInfoWithID:(NSNumber *)vinID fromTable:(NSString *)tableNmae     {	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *strPaths = [documentsDirectory stringByAppendingPathComponent:@"pollingInfos.sqlite3"];
	
	AppDelegate_iPhone *delegate = (AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate];
	sqlite3	*database = [delegate database];
	
	if (sqlite3_open([strPaths UTF8String], &database) != SQLITE_OK) 
	{
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
	
	NSString *delete = [NSString stringWithFormat:@"delete from %@ where id = ?",tableNmae];

	sqlite3_stmt *delete_statement;
	
	if(sqlite3_prepare_v2(database, [delete UTF8String], -1, &delete_statement, NULL) != SQLITE_OK)
		NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
	
	sqlite3_bind_int(delete_statement, 1, [vinID intValue]);
	
	if (SQLITE_DONE != sqlite3_step(delete_statement)) {
		NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_reset(delete_statement);
	sqlite3_finalize(delete_statement);
	sqlite3_close(database);
	
}

+ (NSMutableDictionary *) getCurrentDeviceID     {
	UIDevice *device = [UIDevice currentDevice];
//	NSString *deviceID = device.uniqueIdentifier;
    NSString *deviceID = [OpenUDID value];
    NSString *systemName = device.systemName;
	NSString *systemVersion = device.systemVersion;
	
	NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
	[deviceInfo setObject:deviceID forKey:CURRENT_DEVICE_ID];
    [deviceInfo setObject:systemName forKey:CURRENT_SYSTEM_NAME];
	[deviceInfo setObject:systemVersion forKey:CURRENT_SYSTEM_VERSION];
	[deviceInfo setObject:CURRENT_IMSI forKey:CURRENT_IMSI];
	
	return deviceInfo;
}

+ (NSMutableDictionary *) getCurrentDeviceInfoDic     {
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceID = [OpenUDID value];
    NSString *systemName = device.systemName;
    NSString *systemVersion = device.systemVersion;
    
    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
    [deviceInfo setObject:deviceID forKey:@"deviceID"];
    [deviceInfo setObject:device.model forKey:@"deviceType"];
    [deviceInfo setObject:[NSString stringWithFormat:@"%@%@",systemName,systemVersion] forKey:@"deviceOS"];
    [deviceInfo setObject:NONil([[CustomerInfo sharedInstance] auth_token]) forKey:@"deviceToken"];
    [deviceInfo setObject:device.name forKey:@"deviceDesc"];

    
    return deviceInfo;
}

+ (NSString *) getMetaLanguage     {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *language = [languages objectAtIndex:0];
	
	NSString *currentLanguage = META_LANGUAGE_ENGLISH;
	if ([language isEqualToString:@"zh_CN"] || [language hasPrefix:@"zh-Hans"] || [language hasPrefix:@"zh-Hant"])
		currentLanguage = META_LANGUAGE_CHINESE;
	
	return currentLanguage;
}

+ (BOOL)vehicleIsEV {
    return [CustomerInfo sharedInstance].currentVehicle.bev;
}

+ (BOOL)vehicleIsBEV {
    return [CustomerInfo sharedInstance].currentVehicle.bev;
}

//PHEV 油电混动
+ (BOOL)vehicleIsPHEV {
    return [CustomerInfo sharedInstance].currentVehicle.phev;
}

//G9,目前2种车型，非g10即g9或之前版本
+ (BOOL)vehicleIsG9 {
//    NSString *vehicleBaseType = [CustomerInfo sharedInstance].currentVehicle.vehicleBaseType;
//    if (vehicleBaseType.length > 0) {
//        return [vehicleBaseType.lowercaseString isEqualToString:@"gen9"];
//    }
    return [CustomerInfo sharedInstance].currentVehicle.gen9;
    
}

+ (BOOL)vehicleIsG10 {
    //info3 也可能是Gen10,此时,vehicleBaseType=info3,isGen10=gen10,根据isGen10字段来判断
    return [CustomerInfo sharedInstance].currentVehicle.gen10;
//    NSString *vehicleBaseType = [CustomerInfo sharedInstance].currentVehicle.vehicleBaseType;
//    if (vehicleBaseType.length > 0) {
//        return [vehicleBaseType.lowercaseString isEqualToString:@"gen10"];
//    }
    
}

+ (BOOL)vehicleIsD2JBI {
    return [CustomerInfo sharedInstance].currentVehicle.d2jbi;
}

+ (BOOL)vehicleIsG8 {
    return [CustomerInfo sharedInstance].currentVehicle.gen8;
}

+ (BOOL)vehicleIsInfo3 {
    return [CustomerInfo sharedInstance].currentVehicle.info3;

}

+ (BOOL)vehicleIsInfo34 {
    return [CustomerInfo sharedInstance].currentVehicle.info34;
}

/**
 是否是icm车

 @return
 */
+ (BOOL) vehicleIsIcm	{
    return [CustomerInfo sharedInstance].currentVehicle.icm;
}

/// 是否为 ICM 2.0 车
+ (BOOL)vehicleIsICM2	{
    SOSVehicle *vehicle = [CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle;
    return (vehicle.HVACSettingSupported || vehicle.closeSunroofSupported || vehicle.openSunroofSupported || vehicle.closeWindowSupported || vehicle.openWindowSupported || vehicle.openTrunkSupported) && !Util.vehicleIsMy21;
}

+ (BOOL)vehicleIsMy21 {
    SOSVehicle *vehicle = CustomerInfo.sharedInstance.userBasicInfo.currentSuite.vehicle;
    return vehicle.brakePadLifeSupported || vehicle.engineAirFilterMonitorStatusSupported;

//    return vehicle.brakePadLifeSupported || vehicle.engineAirFilterMonitorStatusSupported || vehicle.unlockTrunkSupported || vehicle.lockTrunkSupported;
}

//+ (BOOL) vehicleIsBuick     {
//    BOOL checkCapEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"Buick"];
//    BOOL checkLowEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"buick"];
//    BOOL checkChinese = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"别克"];
//    BOOL yingLangVehicle = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"英朗"];
//	if (checkCapEnglish || checkLowEnglish || checkChinese || [self vehicleIsD2JBI] || yingLangVehicle)
//		return YES;
//	return NO;
//}
//
//+ (BOOL) vehicleIsCadillac  {
//    BOOL checkCapEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"Cadillac"];
//    BOOL checkLowEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"cadillac"];
//    BOOL checkChinese = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"凯迪拉克"];
//    if (checkCapEnglish || checkLowEnglish || checkChinese)
//        return YES;
//    return NO;
//}

+ (BOOL) vehicleIsBuick  {
    return [[[[CustomerInfo sharedInstance] currentVehicle].brand uppercaseString] isEqualToString:@"BUICK"];
}

+ (BOOL) vehicleIsCadillac  {
    return [[[[CustomerInfo sharedInstance] currentVehicle].brand uppercaseString] isEqualToString:@"CADILLAC"];
}

+ (BOOL) vehicleIsChevrolet  {
//    BOOL checkCapEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"Chevrolet"];
//    BOOL checkLowEnglish = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"Chevrolet"];
//    BOOL checkChinese = [[[CustomerInfo sharedInstance] currentVehicle].modelDesc hasPrefix:@"雪佛兰"];
//    if (checkCapEnglish || checkLowEnglish || checkChinese)
//        return YES;
//    return NO;
    return [[[[CustomerInfo sharedInstance] currentVehicle].brand uppercaseString] isEqualToString:@"CHEVROLET"];
}

+ (NSString *)getVehicleBrandName	{
    if ([Util vehicleIsBuick]) 				return @"别克";
    else if ([Util vehicleIsCadillac])      return @"凯迪拉克";
    else if ([Util vehicleIsChevrolet])   	return @"雪佛兰";
    return nil;
}


+ (BOOL) isValidNumber:(NSString *)toCheck     {
    if (!toCheck) {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:toCheck]; 
    float  val; 
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL) isNotEmptyString:(NSString *)string     {
    return (string != nil && string.length != 0);
}

+ (UIViewController *)findTopViewControllerOfClass:(Class)classname  fromControllers:(NSArray*)controllers     {
    for(NSInteger i = controllers.count - 1; i >= 0 ; --i){
        
        UIViewController *vc=[controllers objectAtIndex:i];
        if([vc isKindOfClass:classname]){
            return vc;
        }
    }
    return nil;
}

+ (int)indexOfTopViewControllerOfClass:(Class)classname  fromControllers:(NSArray*)controllers {
    for(NSInteger i=controllers.count-1;i>=0;--i){
        UIViewController *vc=[controllers objectAtIndex:i];
        if([vc isKindOfClass:classname]){
            return (int)i;
        }
    }
    return -1;
}

+ (SOSPOI *)convertToSOSpoiFromDict:(NSDictionary *)dict     {
    SOSPOI *poi = [[SOSPOI alloc] init];
    poi.name = dict[K_SEARCH_RESULT_NAME];
    poi.locationName = dict[K_SEARCH_RESULT_LOCATION_NAME];
    poi.x = dict[K_POI_COORDINATE][K_LONGITUDE];
    poi.y = dict[K_POI_COORDINATE][K_LATITUDE];
    poi.tel = dict[K_SEARCH_RESULT_PHONE_NUMBER];
    poi.address = dict[K_SEARCH_RESULT_ADDRESS];
    poi.city = dict[K_SEARCH_RESULT_CITY_NAME];
    poi.province = dict[K_SEARCH_RESULT_PROVINCE_NAME];
    poi.sosPoiType = POI_TYPE_POI;
    poi.destinationID = dict[K_DESTINATION_ID];
    return poi;
}



+ (NSString*)getVerDate     {
    NSDateFormatter *dm = [[NSDateFormatter alloc] init];
    [dm setDateFormat:@"yyyyMMddHHmm"];
    return  [NSString stringWithFormat:@"Build%@",[dm stringFromDate:[NSDate date]] ];
    
}


+ (BOOL)isDeviceiPhone6Plus     {
    return IS_IPHONE_6P;
}

+ (BOOL)isDeviceiPhone6     {
    return IS_IPHONE_6;
}

+ (BOOL)isDeviceiPhone5     {
    return IS_IPHONE_5;
}


+ (BOOL)isDeviceiPhone4     {
    return IS_IPHONE_4_OR_LESS;
}

+ (BOOL)isUpgradeUser     {
    return [Util isNotEmptyString:[Util readConfig:K_PREVIOUS_VERSION]];
}

+ (NSString*)getConfigureURL     {
    NSString *retStr = @"https://api.shanghaionstar.com";
    switch ([SOSEnvConfig config].sos_env) {
        case 0: //IDT1
            retStr = @"https://api-idt1.shanghaionstar.com:1443";
            break;
        case 2: //PRD
            retStr = @"https://api.shanghaionstar.com";
            break;
        case 5: //IDT4
            retStr = @"https://api-idt4.shanghaionstar.com:4443";
            break;
        
        case 3://PP2
            retStr = @"https://api-pp2.shanghaionstar.com:13443";
            break;
        case 4://IDT5
            retStr = @"https://api-idt5.shanghaionstar.com:7443";
            break;
        case 8://VV2
            retStr = @"https://api-vv2.shanghaionstar.com:9443";
            break;
        case 6://pp1
            retStr = @"https://api-pp1.shanghaionstar.com:12443";
            break;
        case 7://VV1
            retStr = @"https://api-vv1.shanghaionstar.com:6443";
            break;
//        case 8://VV3
//            retStr = @"https://api-vv3.shanghaionstar.com:33443";
//            break;
        case 10://IDT7
            retStr = @"https://api-idt7.shanghaionstar.com:443";
            break;
        case 9://PP3
            retStr = @"https://api-pp3.shanghaionstar.com:34443";
            break;
        case 11://PP4
            retStr = @"https://api-pp4.shanghaionstar.com:443";
            break;
        case 12://T
            retStr = @"https://api-t.shanghaionstar.com:443";
            break;
//        case 13://idt6
//            retStr = @"https://api-idt6.shanghaionstar.com:443";
//            break;
//        case 14://NEWEFO
//            retStr = @"https://api-pd.shanghaionstar.com:443";
//            break;
        case 14://IDT10
            retStr = @"https://api-idt10.shanghaionstar.com:443";
            break;
        case 15://IDT7-SIT
            retStr = @"https://api-sit-idt7.shanghaionstar.com:20426";
            break;
        case 16://IDT10-SIT
            retStr = @"https://api-sit-idt10.shanghaionstar.com:20426";
            break;
        case 17://PP5
            retStr = @"https://api-pp5.shanghaionstar.com:443";
            break;
        case 19://Reh
            retStr = @"https://api-reh.shanghaionstar.com:443";
            break;
        case 20://IDT8
            retStr = @"https://api-idt8.shanghaionstar.com:443";
            break;
        case 21://VV4
            retStr = @"https://api-vv4.shanghaionstar.com:443";
            break;
        case 22://VV5
            retStr = @"https://api-vv5.shanghaionstar.com:443";
            break;
        case 23://IDT9
            retStr = @"https://api-idt9.shanghaionstar.com:443";
            break;
        case 24://IDT6SIT
        case 13://idt6保持和idt6sit一致
            retStr = @"https://api-idt6sit.shanghaionstar.com:20426";
            break;
        case 25://idta
            retStr = @"https://api-idta.shanghaionstar.com:443";
            break;
        case 26://VVA
            retStr = @"https://api-vva.shanghaionstar.com:443";
            break;
        case 27://PPA
            retStr = @"https://api-ppa.shanghaionstar.com:443";
            break;
        case 28://DEV api-dev.shagnhaionstar.com:20843
            retStr = @"https://api-dev.shanghaionstar.com:443";
            break;
        case 29://PPD-内网 api.ppd.shanghaionstar.com
            retStr = @"https://api-ppd.shanghaionstar.com:443";
            break;
        case 30://PPD -外网 api.ppd.shanghaionstar.com
            retStr = @"https://api-idt6.shanghaionstar.com:443";
            break;
        default:
            break;
    }
    return retStr;
}

+ (NSString*)getStaticConfigureURL:(NSString *)relativePath     {
    NSString *retStr = @"https://www.onstar.com.cn";
    switch ([SOSEnvConfig config].sos_env) {
        case 0: //IDT1
            retStr = @"https://idt1.onstar.com.cn";
            break;
        case 2: //PRD
            retStr = @"https://www.onstar.com.cn";
            break;
        case 5: //IDT4
            retStr = @"https://idt4.onstar.com.cn";
            break;
        
        case 3://PP2
            retStr = @"https://www.onstar.com.cn";
            break;
        case 4://IDT5
            retStr = @"https://idt5.onstar.com.cn";
            break;
        case 8://VV2
            retStr = @"https://vv2.onstar.com.cn";
            break;
        case 6://pp1
            retStr = @"https://pp1.onstar.com.cn";
            break;
        case 7://VV1
            retStr = @"https://vv1.onstar.com.cn";
            break;
//        case 8://VV3
//            retStr = @"https://vv3.onstar.com.cn";
//            break ;
        case 15://IDT7SIT
            retStr = @"https://idt7sit.onstar.com.cn";
        case 10://IDT7
            retStr = @"https://idt7.onstar.com.cn";
            break;
        case 9://PP3
            retStr = @"https://pp3.onstar.com.cn";
            break;
        case 11://PP4
            retStr = @"https://pp4.onstar.com.cn";
            break;
        case 12://T
            retStr = @"https://gef.onstar.com.cn";
            break;
//        case 13://idt6
//            retStr = @"https://idt6.onstar.com.cn";
//            break;
//        case 14://NEWEFO
//            retStr = @"https://gef.onstar.com.cn";
//            break;
        case 16://IDT10-SIT
        case 14://IDT10
            retStr = @"https://idt10.onstar.com.cn";
            break;
        case 17://PP5
            retStr = @"https://pp5.onstar.com.cn";
            break;
        case 19://Reh
            retStr = @"https://reh.onstar.com.cn";
            break;
        case 20://Reh
            retStr = @"https://idt8.onstar.com.cn";
            break;
        case 21://VV4
            retStr = @"https://vv4.onstar.com.cn";
            break;
        case 22://VV5
            retStr = @"https://vv5.onstar.com.cn";
            break;
        case 23://IDT9
            retStr = @"https://idt9.onstar.com.cn";
            break;
        case 24://IDT6SIT
        case 13://idt6保持和idt6sit一致
            retStr = @"https://idt6sit.onstar.com.cn";
            break;
        case 25:
            retStr = @"https://idta.onstar.com.cn";
            break;
        case 26://VVA
            retStr = @"https://vva.onstar.com.cn";
            break;
        case 27://PPA
            retStr = @"https://ppa.onstar.com.cn";
            break;
        case 28://DEV
            retStr = @"https://idt9.onstar.com.cn";
            break;
        case 29://PPD
            retStr = @"https://idt6.onstar.com.cn";
            break;
        case 30://PPD -外网 api.ppd.shanghaionstar.com
            retStr = @"https://idt6.onstar.com.cn";
            break;
        default:
            break;
        
    }
    return [retStr stringByAppendingString:relativePath];
}

/**
 m.onstar.com.cn域名的静态资源目录
 文件上传相关均使用此域名
 @param relativePath
 @return
 */
+ (NSString*)getmOnstarStaticConfigureURL:(NSString *)relativePath     {
    NSString *retStr = @"https://m.onstar.com.cn";
    switch ([SOSEnvConfig config].sos_env) {
        case 2: //PRD
            retStr = @"https://m.onstar.com.cn";
            break;
        case 15://IDT7SIT
          
        case 10: //IDT7
            retStr = @"https://m-idt7.onstar.com.cn";
            break;
            
        case 12://T
            retStr = @"https://m-gef.onstar.com.cn";
            break;
//        case 13://idt6
//            retStr = @"https://m-idt6.onstar.com.cn";
//            break;
       
//        case 14://NEWEFO
//            retStr = @"https://m-gef.onstar.com.cn";
//            break;
        case 16://IDT10-SIT
        case 14://IDT10
            retStr = @"https://m-idt10.onstar.com.cn";
            break;
        case 17://PP5
            retStr = @"https://m-pp5.onstar.com.cn";
            break;
        case 19://Reh
            retStr = @"https://m-reh.onstar.com.cn";
            break;
        case 20://IDT8
            retStr = @"http://m-idt8.onstar.com.cn";
            break;
        case 21://VV4
            retStr = @"http://m-vv4.onstar.com.cn";
            break;
        case 22://VV5
            retStr = @"http://m-vv5.onstar.com.cn";
            break;
        case 23://IDT9
            retStr = @"http://m-idt9.onstar.com.cn";
            break;
        case 24://IDT6-SIT
            retStr = @"https://m-idt6sit.onstar.com.cn";
            break;
        case 13://idt6保持和idt6sit一致
            retStr = @"https://m-idt6.onstar.com.cn";
            break;
        case 25:
            retStr = @"https://m-idta.onstar.com.cn";
            break;
        case 28://DEV
            retStr = @"https://m-idt9.onstar.com.cn";
            break;
        case 29://PPD
            retStr = @"https://m-idt6.onstar.com.cn";
            break;
        case 30://PPD-外网
            retStr = @"https://m-idt6.onstar.com.cn";
            break;
        default:
            retStr = @"https://m-idt6.onstar.com.cn";
            break;
    }
    return [retStr stringByAppendingString:relativePath];
}
/**
 OM系统下H5地址路径
 @param relativePath
 @return
 */
+ (NSString*)getOMOnstarStaticConfigureURL:(NSString *)relativePath {
    NSString *retStr = @"http://om.onstar.com.cn";
    //om这个是用户手册的地址，统一连到生产的就行。
    return [retStr stringByAppendingString:relativePath];
//    switch ([SOSEnvConfig config].sos_env) {
//        case 0: //PRD
//            retStr = @"http://om.onstar.com.cn";
//            break;
//        case 14://NEWEFO
//        case 12://NEWPRD
//            retStr = @"http://om-gef.onstar.com.cn";
//            break;
//        case 13://R1
//            retStr = @"http://om-r1.onstar.com.cn";
//            break;
//        case 4://idt5
//            retStr = @"http://om-idt5.onstar.com.cn";
//            break;
//        case 16://NEWIDT7
//        case 9://idt7
//            retStr = @"http://om-idt7.onstar.com.cn";
//            break;
//        case 18://PP5
//            retStr = @"http://om-pp5.onstar.com.cn";
//            break;
//        case 20://IDT8
//            retStr = @"http://om-idt8.onstar.com.cn";
//            break;
//        default:
//            retStr = @"http://om-idt7.onstar.com.cn";
//            break;
//    }
//    return [retStr stringByAppendingString:relativePath];
}

+ (UIImage *)zoomImage:(UIImage *)image WithScale:(int)scale     {
    if (image == nil) {
        return nil;
    }
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width/scale, image.size.height/scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect newRect = CGRectMake(0, 0, image.size.width/scale, image.size.height/scale);
    [image drawInRect:newRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    return retImage;
}

/*!
 @brief 将obj1和obj2相同的属性值 copy 到 obj2 里.
 */
+ (BOOL)copySamePropertyFromObj1:(id)obj1 ToObj2:(id)obj2     {
    NSMutableArray *obj1Propertys = [Util propertyNanmeAndPropertyTypeFromObject:obj1];
    NSMutableArray *obj2Propertys = [Util propertyNanmeAndPropertyTypeFromObject:obj2];
    for (NSDictionary *dict1 in obj1Propertys) {
        for (NSDictionary *dict2 in obj2Propertys) {
            if ([dict1[K_PROPERTY_NAME] isEqualToString:dict2[K_PROPERTY_NAME]]&&
                [dict1[K_PROPERTY_TYPE] isEqualToString:dict2[K_PROPERTY_TYPE]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id value = [obj1 performSelector:NSSelectorFromString(dict1[K_PROPERTY_NAME])];
#pragma clang diagnostic pop

                if (value) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [obj2 performSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[dict2[K_PROPERTY_NAME] substringToIndex:1] uppercaseString], [dict2[K_PROPERTY_NAME] substringFromIndex:1]]) withObject:value];
#pragma clang diagnostic pop
                }
                [obj2Propertys removeObject:dict2];
                break;
            }
        }
    }
    return NO;
}

/*!
 @brief 取得对象的 属性名和属性类型
 @param obj 对象
 @return 返回一组 包含
 {
 key:K_PROPERTY_NAME, value:属性名
 K_PROPERTY_TYPE, value:属性类型
 } Dictionary.
 */
+ (NSMutableArray *)propertyNanmeAndPropertyTypeFromObject:(id)obj     {
    u_int count;
    objc_property_t* properties = class_copyPropertyList([obj class], &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyType = getPropertyType(properties[i]);
        NSString *pName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *pType = [NSString  stringWithCString:propertyType encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:pName, K_PROPERTY_NAME, pType, K_PROPERTY_TYPE,nil];
        [propertyArray addObject:dict];
    }
    free(properties);
    
    return propertyArray;
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (strcmp(attribute, "Ti") == 0) {
            return "int";
        } else if (strcmp(attribute, "Td") == 0) {
            return "double";
        }else if (strcmp(attribute, "Tc") == 0) {
            return "char";
        }else if (strcmp(attribute, "Tf") == 0) {
            return "float";
        }else if (strcmp(attribute, "Tl") == 0) {
            return "long";
        }else if (strcmp(attribute, "Ts") == 0) {
            return "short";
        }else if (attribute[0] == 'T') {
            NSString *type = [NSString stringWithUTF8String:attribute];
            if ([@"T@" isEqualToString:[type substringWithRange:NSMakeRange(0, 2)]]) {
                return [[type substringWithRange:NSMakeRange(2, type.length -4)] UTF8String];
            } else {
                const char * ret = NULL;
                if (strlen(attribute) > 4) {
                    ret = (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
                }
                if (!ret) {
                    ret = "@";
                }
                return ret;
            }
        }
    }
    return "@";
}


- (void)reflectMethod:(id)obj1     {
    u_int count;
    Method* methods = class_copyMethodList([obj1 class], &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
        NSLog(@"method name %@", [NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]);
    }
    free(methods);
}

//利用正则表达式验证
//6-20个字符
+ (BOOL)isValidateUserName:(NSString *)userName     {
    NSString * regex =@"^(?![0-9]+$)[0-9A-Za-z]{6,20}$";// @"^[A-Za-z0-9]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userName];
}

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateMobilePhone:(NSString *)phone     {
    if (phone.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:phone];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:phone];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:phone];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}


+ (BOOL)isValidatePhone:(NSString *)phone{
    NSString *phoneRegex = @"^\\d{11}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
    /*
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                               error:&error];
    NSUInteger numberOfMatches = [detector numberOfMatchesInString:phone
                                                           options:0
                                                             range:NSMakeRange(0, [phone length])];
    if (numberOfMatches>0) {
        return YES;
    }

    return NO;
     */
}

+ (BOOL)isValidatePassword:(NSString *)password{
//    NSString * regex = @"^(?=.*[0-9].*)(?=.*[A-Za-z].*).{6,25}$";//@"^[A-Za-z0-9]{6,20}$";//@"^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{6,20}$";
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,25}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password];
}


/**
 6位纯数字
 */
+ (BOOL)isValidateCarControlPassword:(NSString *)password {
    NSString * regex = @"^[0-9A-Za-z]{6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password];
}
/**
 纯数字
 */
+ (BOOL)isNumeber:(NSString *)str     {
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isValidateVin:(NSString *)vin     {
    NSString * regex = @"^[A-Za-z0-9]{17}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:vin];
}

+ (BOOL)isValidateSSID:(NSString *)ssid{
    NSString * regex = @"^[A-Za-z0-9]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:ssid];//
}

+ (BOOL)isValidateInfo3SSID:(NSString *)ssid{
    NSString * regex = @"^[A-Za-z0-9]{6,14}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:ssid];//
}

+ (BOOL)isvalidateSSIDPassword:(NSString *)password{
    NSString * regex = @"^[A-Za-z0-9]{8,14}$";//可以纯数字或字母//@"^(?=.*[0-9].*)(?=.*[A-Za-z].*).{8,14}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password];
}

+ (BOOL)isValidateGeoFencingName:(NSString *)geoFencingName     {
    NSString * regex = @"^[a-zA-Z0-9\u4e00-\u9fa5 ]{1,16}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isOK = [pred evaluateWithObject:geoFencingName];
    return isOK;
}


+ (BOOL)isCorrectLicenseNum:(NSString* )liscenseNo     {
    NSString *upperStr = liscenseNo.uppercaseString;
    //^[\\u4e00-\\u9fa5]{1}[A-HJ-NP-Za-hj-np-z0-9]{1}[DFdf]?[A-HJ-NP-Za-hj-np-z0-9]{4}[A-HJ-NP-Za-hj-np-z0-9使试超挂学警港澳]{1}$
    NSString *carRegex = @"^[\\u4e00-\\u9fa5]{1}[A-HJ-NP-Za-hj-np-z0-9]{1}[DFdf]?[A-HJ-NP-Za-hj-np-z0-9]{5}[A-HJ-NP-Za-hj-np-z0-9使试超挂学警港澳]{1}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:upperStr];
}

+ (BOOL)isCorrectEngineNum:(NSString* )engineNo     {
    if (!engineNo.length) {
        return YES;
    }
    NSString *carRegex = @"^[A-Za-z0-9]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:engineNo];
}

+ (int)calculateStringLength:(NSString *)string     {
    /**
     *  转码ascll,nsstring换成char *,对转换后的字符串遍历，遇0跳过，遇1 lenght+1
     */
    int stringlenght = 0;
    
    for (int index = 0; index < [string length]; index++) {
        
        NSString *character = [string substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
            //中文
            stringlenght = stringlenght+2;
        } else {
            stringlenght = stringlenght+1;
        }
    }
    return stringlenght;
}


+ (NSString *)calculateTextNumber:(NSString *) textA maxLength:(int)maxLength     {
    int number = 0;
    
    NSString *textString = [NSString stringWithFormat:@""];
    for (int index = 0; index < [textA length]; index++) {
        
        NSString *character = [textA substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
            number = number+2;
        } else {
            number = number+1;
        }
        
        if (number <= maxLength) {
            textString = [textString stringByAppendingString:character];
        }else{
            break;
        }
    }
    return textString;
}

+ (NSString *)trim:(UITextField *)textfield     {
    NSString *trimString = [textfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [trimString copy];
}

+ (NSString *)trimString:(NSString *)str_     {
    NSString *trimString = [str_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return [trimString copy];
}

+ (NSString *)trimWhite:(UITextField *)textfield     {
    NSString *trimString = [textfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimString copy];
}

+ (NSString *)removeWhiteSpaceString:(NSString *)string     {
    NSMutableCharacterSet *characterSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    NSArray *components = [string componentsSeparatedByCharactersInSet:characterSet];
    NSString *resultStr = [components componentsJoinedByString:@""];
    return resultStr;
}

static NSArray *cityInfoArray;
+ (NSArray *)cityInfoArray     {
    if (cityInfoArray == nil || cityInfoArray.count == 0) {
        NSString *path = [[NSBundle SOSBundle] pathForResource:@"Provineces" ofType:@"plist"];
        cityInfoArray = [NSArray arrayWithContentsOfFile:path];
    }
    return [cityInfoArray copy];
}

+ (NSArray *)provinceInfoArray     {
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"ProvinecesAcronym" ofType:@"plist"];
    return  [NSArray arrayWithContentsOfFile:path];
}

+ (NSArray *)insuranceInfoArray     {
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"Insurence" ofType:@"plist"];
    return  [NSArray arrayWithContentsOfFile:path];
}

+ (NSString *)acronymToZhcn:(NSString *)arconym	{
    NSString * provinceName = @"";
    for (NSDictionary * dict in [self provinceInfoArray]) {
        if ([[dict objectForKey:@"serverSubstitute"] isEqualToString:arconym]) {
            provinceName = [dict objectForKey:@"clientShow"];
            break;
        }
    }
    return provinceName;
}

+ (NSString *)acronymToZhcn:(NSString *)arconym compareList:(NSArray *)proList	{
    if (!arconym) {
        return @"请选择";
    }
    NSString * provinceName = arconym;
    for (id  proModule in proList) {
        if ([proModule respondsToSelector:@selector(name)]) {
            if ([[proModule performSelector:@selector(name)] isEqualToString:arconym]) {
                provinceName = [proModule performSelector:@selector(value)];
                break;
            }
        }
    }
    return provinceName;
}
//+ (NSString *)zh_CNToArconym:(NSString *)zh compareList:(NSArray *)proList    {
//    NSString * provinceZH = zh;
//    for (id  proModule in proList) {
//        if ([proModule respondsToSelector:@selector(value)]) {
//            if ([[proModule performSelector:@selector(value)] isEqualToString:zh]) {
//                provinceZH = [proModule performSelector:@selector(name)];
//                break;
//            }
//        }
//    }
//    return provinceZH;
//}
/***性别***/
+ (NSArray *)genderInfoArray		{
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"Gender" ofType:@"plist"];
    return  [NSArray arrayWithContentsOfFile:path];
}

//+ (NSString *)testLocalJson    {
//    NSString *path = [[NSBundle SOSBundle] pathForResource:@"testJson" ofType:@"xml"];
//    return  [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//}

+ (NSString *)testLocalSubscriberJson	{
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"testSubJson" ofType:@"xml"];
    return  [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

/***用车类型***/
+ (NSArray *)vehicleTypeInfoArray	{
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"VehicleType" ofType:@"plist"];
    return  [NSArray arrayWithContentsOfFile:path];
}

/***客户端对照表***/
+ (NSArray *)clientComparisonTable:(NSString *)tbn	{
    NSString *path = [[NSBundle SOSBundle] pathForResource:tbn ofType:@"plist"];
    return  [NSArray arrayWithContentsOfFile:path];
}

/***服务端别名转换客户端可显示内容***/
+ (NSString *)serverSubstituteToZhcn:(NSString *)arconym comparisonTable:(NSString *)tableName	{
    NSString *clientName = arconym;
    for (NSDictionary * dict in [self clientComparisonTable:tableName]) {
        if ([[dict objectForKey:@"serverSubstitute"] isEqualToString:arconym]) {
            clientName = [dict objectForKey:@"clientShow"];
            break;
        }
    }
    return clientName;
}

/***客户端汉字转换服务端别名***/
+ (NSString *)ClientShowToserverSubstitute:(NSString *)arconym comparisonTable:(NSString *)tableName		{
    NSString *clientName = arconym;
    for (NSDictionary * dict in [self clientComparisonTable:tableName]) {
        if ([[dict objectForKey:@"clientShow"] isEqualToString:arconym]) {
            clientName = [dict objectForKey:@"serverSubstitute"];
            break;
        }
    }
    return clientName;
}

+ (NSDate *)convertGTM0ToGTM8WithDate:(NSDate *)date     {
    NSTimeInterval GTM0_1970 = [date timeIntervalSince1970];
    NSTimeInterval GTM8_1970 = GTM0_1970 + 8*60*60;
    NSDate *dateGTM8 = [NSDate dateWithTimeIntervalSince1970:GTM8_1970];
    return dateGTM8;
}


+ (BOOL)isvalidateTempPassword:(NSString *)password     {
    NSString * regex = @"^[A-Za-z0-9]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:password];
    
}

+ (NSString *)md5:(NSString *)input     {
    if (input == nil) {
        return 0;
    }
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (NSString *)md5:(NSString *)input WithSalt:(NSString *)salt   {
    return [Util md5:[input stringByAppendingString:salt]];
}

+ (NSString *)sha1:(NSString *)input     {
    const char *ptr = [input UTF8String];
    
    int i =0;
    int len = (int)strlen(ptr);
    Byte byteArray[len];
    while (i!=len)
    {
        unsigned eachChar = *(ptr + i);
        unsigned low8Bits = eachChar & 0xFF;
        
        byteArray[i] = low8Bits;
        i++;
    }
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(byteArray, len, digest);
    
    NSMutableString *hex = [NSMutableString string];
    for (int i=0; i<20; i++)
        [hex appendFormat:@"%02x", digest[i]];
    
    NSString *immutableHex = [NSString stringWithString:hex];
    
    return immutableHex;
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4     {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses     {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    // The dictionary keys have the form "interface" "/" "ipv4 or ipv6"
    return [addresses count] ? addresses : nil;
}

/*!
 * 获取当前设备ip地址
 */
+ (NSString *)deviceIPAdress     {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {  // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            NSLog(@"ifa_name===%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
            // Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                //如果是IPV4地址，直接转化
                if (temp_addr->ifa_addr->sa_family == AF_INET){
                    // Get NSString from C String
                    address = [self formatIPV4Address:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                //如果是IPV6地址
                else if (temp_addr->ifa_addr->sa_family == AF_INET6){
                    address = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) break;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    //以FE80开始的地址是单播地址
    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) {
        return address;
    } else {
        return @"127.0.0.1";
    }
}

//for IPV6
+ (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

//for IPV4
+ (NSString *)formatIPV4Address:(struct in_addr)ipv4Addr{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+ (NSDictionary *)parseURLParam:(NSString *)url {
    NSString *paramString = [url componentsSeparatedByString:@"?"].lastObject;
    if (paramString.length <= 0) {
        return @{};
    }
    NSArray *keyValues = [paramString componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyValue in keyValues) {
        NSArray *arr = [keyValue componentsSeparatedByString:@"="];
        [dic setValue:arr[1] forKey:arr[0]];
    }
    return dic;
}

//如果设备能够连接互联网，返回设备公网ip，如果设备连接网络无法连接互联网，返回设备局域网ip，如果没有ip，返回0.0.0.0
+ (void )setPublicIP     {
    //1、先取局域网ip作为ip 2、局域网ip获取失败,ip使用0.0.0.0
    publicIP = [self getIPAddress:YES];
//    [OthersUtil getIP:nil SuccessHandle:^(IPData *ipData) {
//        //3、获取公网ip成功后设置成ip
//        publicIP = ipData.ip;
//        //8.2daap记录设备信息,只要一次,除非app重装,等拿到公网ip后发送
//        [SOSDaapManager sendClientInfo];
//    } failureHandler:^(NSString *responseStr, NSError *error) {
//        //4、如果获取失败，继续使用局域网ip
//    }];
}

//检查是否是2g3g用户,是的话给出弹框
+(BOOL) show23gPackageDialog{
    
    BOOL isShow23gPackageDialog = false;
    if ([CustomerInfo sharedInstance].userBasicInfo.userSettings.is2G3GUser) {//2g3g退网用户
        
        [Util showAlertWithTitle:@"当前没有适合您车型的安吉星套餐，详情请咨询400-820-1188" message:nil completeBlock:nil];
        isShow23gPackageDialog = true;
    }
    
    return isShow23gPackageDialog;
}

+ (NSString *)getPublicIP {
    return publicIP;
}

+ (NSString *)getMACAddress {
    return [[self class] SSIDMACInfo];
}
static NSDictionary * ssidDic ;
+ (void)reFreshSSIDInfo     {
    ssidDic = nil;
}

+ (NSString *)SSIDMACInfo
     {
    if (!ssidDic) {
        NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
        
        for (NSString *ifnam in ifs) {
            
            ssidDic = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            
            if (ssidDic && [ssidDic count]) {
                
                break;
                
            }
            
        }
    }
    NSString * ssidStr = ssidDic[@"BSSID"];
    return ssidStr?ssidStr:@"";
    
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)visibleErrorMessage:(NSString *)message     {
    NSString *visibleMsg = NSLocalizedString(@"DefaultError", nil);
    if ([message length] > 0) {
        id error = [message toBasicObject];
        // 如果是dictionary，显示description
        // 如果是nil，并且message是字符串，直接显示。
        
        // 1. MSP返回的错误，{"code":"E2000", "description":"xxxx"}
        // 2. Layer7 -- old {"code":"L7_404", "error_description":"Invalid token, Access token is not in xx"}
        // 3. Layer7 -- new {"error":"invalid_user_credentials",   "error_description":" remainingAttemptsCounter:${mathResult}"}
        //4、微服务返回报错格式:[{
        //        "errorCode":"E4005",
        //        "errorMessage":"用户更新失败。(E4005)"
      //    }]
        if ([error isKindOfClass:[NSDictionary class]]) {
            
            if ([error[@"errorCode"] isEqualToString:@"404"]) {   //addByWQ 20180606
                visibleMsg = @"没有更多了";
            }
            if ([error objectForKey:@"errorMessage"]) {
                 visibleMsg = [error objectForKey:@"errorMessage"];
            }
            if ([error objectForKey:@"description"]) {
                visibleMsg = [error objectForKey:@"description"];
            } else if ([error objectForKey:@"code"] && [[error objectForKey:@"code"] isKindOfClass:[NSString class]]) {
                // Layer7 返回的错误
                visibleMsg = NSLocalizedString([error objectForKey:@"code"], nil);
                // Layer7 返回的错误，可能是accesstoken失效
                if ([[LoginManage sharedInstance] isRefreshingAccessToken]) {
                    visibleMsg = NSLocalizedString(@"ConnectingVehicle", nil);
                }
            } else if ([error objectForKey:@"error"] && [[error objectForKey:@"error"] isKindOfClass:[NSString class]]) {
                visibleMsg = NSLocalizedString([error objectForKey:@"error"], nil);
                
                if ([[error objectForKey:@"error"] isEqualToString:@"invalid_user_credentials"]) {
                    NSString *parseMsg = [error objectForKey:@"error_description"];
                    if (parseMsg) {
                        NSArray *array = [parseMsg componentsSeparatedByString:@":"];
                        if ([array count] > 1) {
                            NSInteger timeLeft = [[array objectAtIndex:1] integerValue];
                            visibleMsg = [NSString stringWithFormat:NSLocalizedString(@"invalid_user_credentials_pin", nil), timeLeft];
                            //记录用户名密码错误function
                            [SOSDaapManager sendActionInfo:logininfoerror_Iknow];
                        }
                    }
                }
                
                if ([[LoginManage sharedInstance] isRefreshingAccessToken]) {
                    visibleMsg = NSLocalizedString(@"ConnectingVehicle", nil);
                }
            }
        } else if ([message isKindOfClass:[NSString class]]) {
            visibleMsg = message;
        }
    }
    return visibleMsg;
}


+ (void)showAlertWithTitle:(NSString *)title_ message:(NSString *)message_ completeBlock:(CompleteBlock)complete_	{
    [self showAlertWithTitle:title_ message:message_ confirmBtn:@"确定" completeBlock:complete_];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmBtn:(NSString *)confirmBtnString completeBlock:(CompleteBlock)complete {
   [ self showAlertWithTitle:title message:message completeBlock:complete cancleButtonTitle:nil otherButtonTitles:confirmBtnString, nil];
}

+ (void)showAlertWithTitle:(NSString *)title_ message:(NSString *)message_  completeBlock:(CompleteBlock)complete_  cancleButtonTitle:(NSString *)canceltitle_ otherButtonTitles:(NSString *)othertitles_,...     {
    NSString *visibleMsg ;
    if (message_) {
        visibleMsg = [Util visibleErrorMessage:message_];
    }
//    if (!title_.isNotBlank && visibleMsg.isNotBlank) {
//        title_ = visibleMsg;
//        message_ = nil;
//    }else if (title_.isNotBlank && visibleMsg.isNotBlank) {
//        message_ = visibleMsg;
//    }
    
    SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:nil title:title_ message:visibleMsg customView:nil preferredStyle:SOSAlertControllerStyleAlert];
    int count = 0;
    NSMutableArray <SOSAlertAction *>*actions = @[].mutableCopy;
    if (canceltitle_) {
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:canceltitle_ style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
            complete_ ? complete_(0) : nil;
        }];
        [actions addObject:cancelAction];
        count =1;
    }
    if (othertitles_) {
        SOSAlertAction *otherAction = [SOSAlertAction actionWithTitle:othertitles_ style:SOSAlertActionStyleDefault handler:^(SOSAlertAction *action) {
            complete_ ? complete_(count) : nil;
        }];
        [actions addObject:otherAction];
        va_list list;
        NSString* curStr;
        va_start(list, othertitles_);
        while ((curStr= va_arg(list, NSString*))){
            count ++;
            SOSAlertAction *otherAction = [SOSAlertAction actionWithTitle:curStr style:SOSAlertActionStyleDefault handler:^(SOSAlertAction *action) {
                complete_ ? complete_(count) : nil;
            }];
            [actions addObject:otherAction];
        }
        va_end(list);
    }
    [ac addActions:actions];
    [ac show];
    
}

+ (void)showAlertRVMStytleWithTitle:(NSString *)title_ message:(NSString *)message_  completeBlock:(CompleteBlock)complete_  cancleButtonTitle:(NSString *)canceltitle_ otherButtonTitles:(NSString *)othertitles_,...     {
    NSString *visibleMsg ;
    if (message_) {
        visibleMsg = [Util visibleErrorMessage:message_];
    }
    
    SOSFlexibleAlertController *ac = [SOSFlexibleAlertController alertControllerWithImage:nil title:title_ message:visibleMsg customView:nil preferredStyle:SOSAlertControllerStyleAlert];
    int count = 0;
    NSMutableArray <SOSAlertAction *>*actions = @[].mutableCopy;
    if (canceltitle_) {
        SOSAlertAction *cancelAction = [SOSAlertAction actionWithTitle:canceltitle_ style:SOSAlertActionStyleCancel handler:^(SOSAlertAction * _Nonnull action) {
            complete_ ? complete_(0) : nil;
        }];
        [actions addObject:cancelAction];
        count =1;
    }
    if (othertitles_) {
        SOSAlertAction *otherAction = [SOSAlertAction actionWithTitle:othertitles_ style:SOSAlertActionStyleDefault handler:^(SOSAlertAction *action) {
            complete_ ? complete_(count) : nil;
        }];
        [actions addObject:otherAction];
        va_list list;
        NSString* curStr;
        va_start(list, othertitles_);
        while ((curStr= va_arg(list, NSString*))){
            count ++;
                SOSAlertAction *otherAction = [SOSAlertAction actionWithTitle:curStr style:SOSAlertActionStyleGray handler:^(SOSAlertAction *action) {
                    complete_ ? complete_(count) : nil;
                }];
                [actions addObject:otherAction];
        }
        va_end(list);
    }
    [ac addActions:actions];
    [ac show];
    
}
#pragma mark--------------------------------

+ (NSString *)maskMobilePhone:(NSString *)number {
    if (![Util isValidatePhone:number]) {
        return number;
    }
    NSString *maskedNumber = [number stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    return maskedNumber;
}

/** 手机号显示前三后四，邮箱参照如下：
* 若邮箱中“@”之前的字符数大于3位，则隐藏“@”的前3位。如Aa***@126.com
* 若邮箱中“@”之前的字符数小于等于3位，则隐藏“@”的前1位。如 *@126.com / A*@126.com / Aa*@126.com */
+ (NSString *)maskEmailWithStar:(NSString *)email     {
    NSRange splitRange = [email rangeOfString:@"@"];
    if (splitRange.location > 3) {
        splitRange.location -= 3;
        splitRange.length = 3;
    } else {
        splitRange.length = splitRange.location - 1;
        splitRange.location = 1;
    }
    return [email stringByReplacingCharactersInRange:splitRange withString:@"***"];
}

+ (NSString *)findCityNameWithCityCode:(NSString *)cityCode     {
    NSArray *list = [Util cityInfoArray];
    for (NSDictionary *province in list) {
        NSArray *cities = [province objectForKey:@"cities"];
        for (NSDictionary *city in cities) {
            NSString *code = [city objectForKey:@"CityCode"];
            if ([code isEqualToString:cityCode]) {
                return [city objectForKey:@"CityName"];
            }
        }
    }
    return @"";
}

+ (NSString *)localizeErrorCode:(NSString *)aErrorCode     {
    NSMutableString *errorType = [[NSMutableString alloc] initWithString:aErrorCode];
    [errorType deleteCharactersInRange:NSMakeRange(3, [errorType length] - 3)];
    
    NSMutableString *errorCode = [[NSMutableString alloc] initWithString:aErrorCode];
    [errorCode deleteCharactersInRange:NSMakeRange(0, 4)];
    if ([errorType isEqualToString:@"ONS"])
        [errorCode insertString:@"0" atIndex:0];
    else
        [errorCode replaceCharactersInRange:NSMakeRange(0, 1) withString:@"1"];
    return errorCode;
}

//+ (BOOL)isInHouseVersion     {
//    return [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:INHOUSE_APP_BUNDERID];
//}

+ (NSString *)aMapAPIKey     {
//    if ([Util isInHouseVersion]) {
//        
//        return AMapKeyInHouse;
//    } else {
//        if (ISIPAD) {
//            return AMapKeyIpadAppStore;
//        }
        return AMapKeyAppStore;
//    }
}

+ (NSString *)osType     {
    //区分pad,iphone
    return [Util isDeviceiPhone4] ? IPHONE_SMALL : IPHONE_LARGE;
}

+ (BOOL)isiPhoneXSeries		{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    
    return iPhoneXSeries;
}

+ (NSString *)currentDeviceType		{
    static NSString * deviceType_ = IPHONE_LARGE;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([Util isDeviceiPhone4]) {
            deviceType_ = IPHONE_SMALL;
        }
        if (IS_IPHONE_XSeries) {
            deviceType_ = IPHONE_X;
        }
    });
    return deviceType_;
}

+ (NSString *)bannerosType     {
    //区分pad,iphone
    return [Util isDeviceiPhone4] ? BANNER_IPHONE4 : BANNER_IPHONE5;
}

+ (NSString *)md5HexDigest:(NSString *)inputStr     {
    const char *cStr = [inputStr UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}



+ (NSString *)getStoryBoard{
    if (ISIPAD) {
        return @"iPad_PurchaseStoryboard";
    }else{
        return @"PurchaseStoryboard";
    }
}


+ (NSString *)getPersonalcenterStoryBoard     {
    if (ISIPAD) {
        return @"";
    }else{
        return @"PersonalCenter";
    }
}



+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString     {
    if (jsonString.length <= 0) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        //NSLog(@"Json解析[%@] 失败：[%@]", jsonString, err);
    }
    return dic;
}


#pragma mark json 转 数组
+ (NSArray *)arrayWithJsonString:(NSString *)jsonString     {
    if (jsonString == nil|| [jsonString isEqualToString:@"[]"]) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

+ (void)playAlertSound     {
    //play sound reminder
    SystemSoundID	soundFileObject = 1002;;
    //调用NSBundle类的方法mainBundle返回一个NSBundle对象，该对象对应于当前程序可执行二进制文件所属的目录
    NSString *soundFile = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",@"Voicemail",@"caf"];
    //一个指向文件位置的CFURLRef对象和一个指向要设置的SystemSoundID变量的指针
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:soundFile], &soundFileObject);
    BOOL isRemoteAudio = [[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_AUDIO];
    BOOL isRemoteViberate = [[NSUserDefaults standardUserDefaults] boolForKey:NEED_REMOTE_Viberate];
    if(isRemoteAudio&&isRemoteViberate)
    {
        AudioServicesPlayAlertSound(soundFileObject);
    }
    else if(isRemoteAudio&&!isRemoteViberate)
    {
        AudioServicesPlaySystemSound (soundFileObject);
    }
    else if(!isRemoteAudio&&isRemoteViberate)
    {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    
}
static NSString  * version;
+ (NSString *)getAppVersionCode     {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *array = [APP_VERSION componentsSeparatedByString:@"."];
        NSInteger versionCode = 0;
        if ([array count] > 2) {
            versionCode = [[array objectAtIndex:0] integerValue] * 10000 + [[array objectAtIndex:1] integerValue] * 100 + [[array objectAtIndex:2] integerValue];
        }
        version = [NSString stringWithFormat:@"%@%@", SOSSDK_VERSION_PREFIX,@(versionCode)];
    });
    return version;
}


+ (void)saveMrOOpenFlagByidpid:(NSString *)idpid withFlag:(BOOL)flag    {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = (NSMutableDictionary *)[userDefault objectForKey:KeyMrOOpenFlag];
    dic = dic ? dic : [NSMutableDictionary dictionary];
    NSMutableDictionary *sourceDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [sourceDic setObject:@(flag) forKey:idpid];
    [userDefault setObject:sourceDic forKey:KeyMrOOpenFlag];
    [userDefault synchronize];
}

+ (NSNumber *)readMrOOpenFlagByidpid:(NSString *)idpid     {
    NSDictionary *flagDic = [[NSUserDefaults standardUserDefaults] objectForKey:KeyMrOOpenFlag];
    NSNumber *flag = [flagDic objectForKey:idpid];
    if (flag == nil) {
        if ([SOSCheckRoleUtil isOwner])		flag = @(YES);
        else     											flag = @(NO);
    }
    return flag;
}

// 按钮边框
+ (UIButton *) borderColor_forBtn:(UIButton *)btn color:(UIColor *)color     {
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 3.0;
    [btn.layer setBorderWidth:1];//设置边界的宽度
    //设置按钮的边界颜色
    //    CGColorRef color = [UIColor lightGrayColor].CGColor;
    [btn.layer setBorderColor:color.CGColor];
    
    return btn;
}
// 按钮边框
+ (UIButton *) borderColor_forBtn:(UIButton *)btn     {
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 3.0;
    [btn.layer setBorderWidth:1];//设置边界的宽度
    //设置按钮的边界颜色
    CGColorRef color = [UIColor lightGrayColor].CGColor;
    [btn.layer setBorderColor:color];
    
    return btn;
}

+ (void)toastWithVerifyCode:(NSString *)Message     {
    if([SOSEnvConfig config].showDebugToast){
        [self toastWithMessage:Message];
    }
}

+ (void)toastWithMessage:(NSString *)Message    {
    if (!Message.length)    return;
    dispatch_async_on_main_queue(^{
        [KEY_WINDOW makeToast:Message duration:1 position:CSToastPositionCenter];
    });
}

+ (void)showLoadingView     {
    UIWindow *topWindow = SOS_ONSTAR_WINDOW;
    dispatch_async_on_main_queue(^{
        [[LoadingView sharedInstance] startIn:topWindow];
    });
}

+ (void)hideLoadView        {
    dispatch_async_on_main_queue(^{
        [[LoadingView sharedInstance] stop];
    });
}

+ (UIViewController *)getPresentedViewController     {
    UIViewController *resultVC;
    UIWindow *window =  SOS_ONSTAR_WINDOW;
    resultVC = [self topViewController:[window rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (void)showFootPrintFirstShowNotice    {
    [Util showToastViewIsFootPrintType:YES];
}

+ (void)showNetworkErrorToastView   {
    [SOSTopNetworkTipView show];
    
}

+ (void)showToastViewTitle:(NSString *)title detailTitle:(NSString *)detailTitle backgroundColor:(UIColor *)bgcolor showTime:(NSTimeInterval)timeinterval     {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *bgView;
        UILabel *messageLabel;
        UILabel *detailLabel;
        CGFloat bgViewHeight = STATUSBAR_HEIGHT + 35;
        if (!bgView) {
            bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -bgViewHeight, SCREEN_WIDTH, bgViewHeight)];
            bgView.backgroundColor = bgcolor;
//            bgView.userInteractionEnabled = ;
        }
        
        if (!messageLabel) {
            float titleHeight;
//            float startY;
            if (detailTitle) {
                titleHeight = (bgView.height -20)/2;//20 statusbar高度
//                startY = 20.0;
                if (!detailLabel) {
                    detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleHeight +20, bgView.width - 40, titleHeight)];
                    detailLabel.text = detailTitle;
                    detailLabel.textAlignment = NSTextAlignmentLeft;
                    detailLabel.textColor = [UIColor whiteColor];
                    detailLabel.font = [UIFont systemFontOfSize:11.];
                    [bgView addSubview:detailLabel];
                }
            }
            else
            {
                titleHeight = bgView.height - STATUSBAR_HEIGHT;
//                startY = STATUSBAR_HEIGHT;
            }
            
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, STATUSBAR_HEIGHT, bgView.width - 40, titleHeight)];
            messageLabel.text = title;
            messageLabel.textAlignment = NSTextAlignmentLeft;
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.font = [UIFont systemFontOfSize:14.];
            [bgView addSubview:messageLabel];
        }
//        messageLabel.numberOfLines = 0;
//        [messageLabel sizeToFit];
        
//        if (!isFootPrintType) {
//            UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示点击箭头"]];
//            arrowImgView.right = bgView.width - 20;
//            arrowImgView.centerY = bgView.height / 2;
//            [bgView addSubview:arrowImgView];
//            UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(bgView.width - 80 - 20, 0, 100, bgView.height)];
//            [arrowButton addTarget:[UIApplication sharedApplication].delegate action:@selector(showNetworkErrorDetailPage) forControlEvents:UIControlEventTouchUpInside];
//            [bgView addSubview:arrowButton];
//        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                [window addSubview:bgView];
                bgView.top = 0;
                
            }];
            [UIView animateWithDuration:timeinterval animations:^{
                messageLabel.alpha = .99;
            } completion:^(BOOL finished) {
                if (bgView) {
                    [UIView animateWithDuration:0.3 animations:^{
                        bgView.top = -bgViewHeight;
                    } completion:^(BOOL finished) {
                        [bgView removeFromSuperview];
                    }];
                }
            }];
        });
    });
}


+ (void)showToastViewIsFootPrintType:(BOOL)isFootPrintType {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    float toValue = window.sos_safeAreaInsets.top;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *bgView;
        UILabel *messageLabel;
        
        if (!bgView) {
            bgView = [[UIView alloc] initWithFrame:CGRectMake(0, toValue -55, SCREEN_WIDTH, 75)];
            bgView.backgroundColor = [UIColor colorWithRed:99 / 255. green:199 / 255. blue:254 / 255. alpha:.9];
            bgView.tag = 973276;
            bgView.userInteractionEnabled = !isFootPrintType;
        }
        if (!messageLabel) {
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, bgView.width - 20, bgView.height)];
            messageLabel.text = isFootPrintType ? @"仅记录通过安吉星蓝键下发的全程音控领航和目的地设置协助。" : NSLocalizedString(@"Network_Error_Toast_Message", nil);
            messageLabel.textAlignment = NSTextAlignmentLeft;
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.font = [UIFont systemFontOfSize:14.];
            [bgView addSubview:messageLabel];
        }
        messageLabel.numberOfLines = 0;
        [messageLabel sizeToFit];
        messageLabel.width = bgView.width - 40;
        //bgView.height = messageLabel.height + 16;
        messageLabel.centerY = bgView.height / 2;

        if (!isFootPrintType) {
            UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示点击箭头"]];
            arrowImgView.right = bgView.width - 20;
            arrowImgView.centerY = bgView.height / 2;
            [bgView addSubview:arrowImgView];
            UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(bgView.width - 80 - 20, 0, 100, bgView.height)];
            [[arrowButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                UINavigationController *navVC = [SOS_APP_DELEGATE fetchMainNavigationController];
                if ([navVC.topViewController isKindOfClass:[NetworkErrorVC class]])     return;
                NetworkErrorVC *vc = [[NetworkErrorVC alloc] init];
                [navVC pushViewController:vc animated:YES];
                [[window viewWithTag:973276] removeFromSuperview];
            }];
            [bgView addSubview:arrowButton];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [UIView animateWithDuration:0.3 animations:^{
                [window addSubview:bgView];
                bgView.top = toValue;

            }];
            [UIView animateWithDuration:(5 - isFootPrintType * 2) animations:^{
                messageLabel.alpha = .99;
            } completion:^(BOOL finished) {
                if (bgView) {
                    [UIView animateWithDuration:0.3 animations:^{
                        bgView.top = toValue -55;
                    } completion:^(BOOL finished) {
                        [bgView removeFromSuperview];
                    }];
                }
            }];
        });
    });
}

#pragma mark 空白
+ (BOOL) isBlankString:(NSString *)string {
    if ([string isEqual:[NSNull null]] || [string isEqualToString:@"(null)"]) {
        NSLog(@"字符串为空");
        return YES;
    }
    if (string == nil || string == NULL || string.length == 0 ||[string  isEqual: @" "] ) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
//是否是省市简写
+ (BOOL)isProvinceAcronym:(NSString *)string     {
    NSString * regex = @"^[A-Z]{1}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:string];
}


+ (void)alertUserEvluateApp {
#ifndef SOSSDK_SDK
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger successCount = [userDefault integerForKey:Success_Count];
    NSInteger commentCount = [userDefault integerForKey:Comment_Count];
    NSInteger refuseCount = [userDefault integerForKey:Refuse_Count];
    successCount++;
    [userDefault setInteger:successCount forKey:Success_Count];
    [userDefault synchronize];
    if(successCount>=3)	{
        if(commentCount <1 && refuseCount < 3) 		{	//首次
			SOSAlertEvluateVC *vc = [SOSAlertEvluateVC new];
            [vc show];
        }
    }
#endif
}


+ (void) goodRating{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger commentCount = [userDefault integerForKey:Comment_Count];
    commentCount++;
    [userDefault setInteger:commentCount forKey:Comment_Count];
    [userDefault synchronize];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/an-ji-xing/id437190725?mt=8&uo=4"]];
    [self clearCounting];
}

+ (void) refuseRating{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger refuseCount = [userDefault integerForKey:Refuse_Count];
    refuseCount++;
    [userDefault setInteger:refuseCount forKey:Refuse_Count];
    [userDefault synchronize];
    [self clearCounting];
}

+ (void) clearCounting{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:0 forKey:Success_Count];
    [userDefault synchronize];
}


+ (BOOL)isValidPercentValue:(NSString *)value     {
    NSString *valueEx = @"[0-9.]{1,}";
    NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", valueEx];
    return [valuePredicate evaluateWithObject:value];
}

#pragma mark -判断设备
static NSString  * platform;

+ (NSString *)getDevicePlatform     {
    if (platform == nil) {
        int mib[2];
        size_t len;
        char *machine;
        
        mib[0] = CTL_HW;
        mib[1] = HW_MACHINE;
        sysctl(mib, 2, NULL, &len, NULL, 0);
        machine = malloc(len);
        sysctl(mib, 2, machine, &len, NULL, 0);
        
        platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
        free(machine);
        // iPhone
        if ([platform  isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
        if ([platform  isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
        if ([platform  isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
        if ([platform  isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
        if ([platform  isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
        if ([platform  isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
        if ([platform  isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
        
        if ([platform  isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
        if ([platform  isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
        if ([platform  isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
        if ([platform  isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
        
        if ([platform  isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
        if ([platform  isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
        
        if ([platform  isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
        if ([platform  isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
        
        if ([platform  isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
        if ([platform  isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
        if ([platform  isEqualToString:@"iPhone8,4"])  return @"iPhone SE";

        if ([platform  isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
        if ([platform  isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";

        if ([platform  isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
        if ([platform  isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
        if ([platform  isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
        if ([platform  isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
        if ([platform  isEqualToString:@"iPhone10,3"]) return @"iPhone X";
        if ([platform  isEqualToString:@"iPhone10,6"]) return @"iPhone X";
        
        if ([platform  isEqualToString:@"iPhone11,8"]) return @"iPhone Xr";
        if ([platform  isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
        if ([platform  isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
        if ([platform  isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
        
        if ([platform isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
        if ([platform isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
        if ([platform isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    }
    
    return platform;
}

+ (UINavigationController *)currentNavigationController     {
//    AppDelegate_iPhone *appdelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [SOS_APP_DELEGATE hideMainLeftMenu];
    return (UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController];
//     [(UINavigationController *)[appdelegate.mainVC fetchContentViewController] presentViewController:bbwcNav animated:YES completion:^{  }];

//    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
//    UITabBarController *tabBarVc = appDelegate.rootTabBarVC;
//    return (UINavigationController *)tabBarVc.selectedViewController;
}


+ (NSString *)clientInfo     {
    
    //平台_系统版本号_应用版本号_客户端语言_手机类型
    //平台取值：android/iphone/ipad
    //客户端语言取值：zh-CN/en-US
    //手机类型:android具体手机model等信息，ios具体型号
    //例如：
    //android_4.0_31_zh-CN_Galaxy/iphone_9.1_7.0.0_en-US_iphone4/ipad_9.1_5.1.0_zh-CN
    NSString *CLIENT_INFO = [NSString stringWithFormat:@"%@_%f_%@_%@_%@_%@",[Util osType],[[[UIDevice currentDevice]systemVersion]floatValue], [self getAppVersionCode],[self language],[Util getDevicePlatform],kUpdateSecret];
    return CLIENT_INFO;
}

+ (NSString *)language     {
    NSString *requestLanguage = @"en-US";
    NSString *currentLanguage = [SOSLanguage getCurrentLanguage];
    if ([currentLanguage isEqualToString:LANGUAGE_CHINESE]) {
        requestLanguage = @"zh-CN";
    }
    return requestLanguage;
}


+ (NSString *)SOS_stringDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}



+ (void) getVehicleReportCallback:(void(^)(NSString *VehicleOptStatus))opt     {
    
    NSString *url = [BASE_URL stringByAppendingFormat:get_local_services_URL, [CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin,@"CarAssessment"];
    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:nil successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        NSLog(@"车辆鉴定报告开关状态response:%@",responseStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *arr = [Util arrayWithJsonString:responseStr];
            opt(arr[0][@"optStatus"]);
        });
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        NSLog(@"error: %@", error);
        [Util showAlertWithTitle:nil message:responseStr completeBlock:nil];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:@"GET"];
    [operation start];
}


+ (void)openVehicleService:(void(^)(void))compCallback httpMethod:(NSString *)httpMethod     {
    [Util showLoadingView];
    NSString *url = [BASE_URL stringByAppendingFormat:open_local_service_URL,[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    
    NSDictionary *d = @{@"subscriberID":[CustomerInfo sharedInstance].userBasicInfo.subscriber.subscriberId,
                        @"serviceName":@"CarAssessment"};
    NSString *para = [Util jsonFromDict:d];

    SOSNetworkOperation *operation = [SOSNetworkOperation requestWithURL:url params:para successBlock:^(SOSNetworkOperation *operation, id responseStr) {
        [Util hideLoadView];
        NSLog(@"response:%@",responseStr);
        NSDictionary *responseDic = [Util dictionaryWithJsonString:responseStr];
        if ([responseDic[@"code"] isEqualToString:@"E0000"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                compCallback();
            });
        }
    } failureBlock:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        [Util hideLoadView];
    }];
    [operation setHttpHeaders:@{@"Authorization":[LoginManage sharedInstance].authorization}];
    [operation setHttpMethod:httpMethod];
    [operation start];
}

/**
 get value form IOS system setting at app lanuch
 */
+ (void)ServerIPFromSettings     {
    NSString *bundlePath = [[NSBundle SOSBundle] bundlePath];
    NSString *settingsPath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *settingRootListPath = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary *settingDict = [NSDictionary dictionaryWithContentsOfFile:settingRootListPath];
//    NSLog(@"settings Dict : %@", settingDict);
    NSNumber *serverIP = 0;
    NSNumber *portalURLValue = 0;
    if (settingDict) {
        NSArray *settingPreArray = [settingDict objectForKey:@"PreferenceSpecifiers"];
        for (NSDictionary *preDict in settingPreArray) {
            
            if ([SERVER_IP_INT_KEY isEqualToString:[preDict objectForKey:@"Key"]]) {
                serverIP = [preDict objectForKey:@"DefaultValue"];
            } else if ([PORTAL_URL_KEY isEqualToString:[preDict objectForKey:@"Key"]]) {
                portalURLValue = [preDict objectForKey:@"DefaultValue"];
            }
        }
    }
    NSDictionary *eviromentDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   serverIP,SERVER_IP_INT_KEY,
                                   nil];
    NSDictionary *portalURLDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   portalURLValue,PORTAL_URL_KEY,
                                   nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:eviromentDict];
    [[NSUserDefaults standardUserDefaults] registerDefaults:portalURLDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeShortcutEditFile     {
    //8.2.0因为登录改造,重置一次快捷键
    
    // 版本升级且快捷键逻辑发生很大变化，就应该删除快捷键本地归档文件
    // app版本的key值
    NSString *key = @"CFBundleShortVersionString";
    // 1.取得当前的app版本
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    // 2.取得之前的app版本
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    // 3.如果两个版本不同，且快捷键逻辑发生很大变化
    // lastVersion可能为nil
    if (!(lastVersion && [lastVersion isEqualToString:currentVersion]) && [currentVersion isEqualToString:@"8.4.0"]) {
        UserDefaults_Set_Object(currentVersion, key);
        UserDefaults_Set_Bool(NO, @"HomeShortcutFirstOpenApp");
        
        NSString *extension = @"swh";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            if ([[filename pathExtension] isEqualToString:extension]) {
                NSLog(@"remove filename: %@", filename);
                [fileManager removeItemAtPath:[documentDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
}

+ (BOOL)isAllowNotification{
//    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    }else{
        return NO;
    }
//    }else{
//        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//        if(UIRemoteNotificationTypeNone != type){
//            return YES;
//        }else{
//            return NO;
//        }
//    }
}

+ (NSString *)getTimeStampFromDate:(NSDate *)date  {
    return  [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]*1000];
}

+ (NSString *)getFormatterDate:(NSDate *)date  {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    return NONil([formatter stringFromDate:date]);
}

+ (void)assginVehicleCommansData:(NSString *)str {
    NSDictionary *dic = [Util dictionaryWithJsonString:str];
    NNSupportedCommands *supportedCommands = [NNSupportedCommands mj_objectWithKeyValues:dic];
    NNCommands *commands = supportedCommands.commands;
//    [CustomerInfo sharedInstance].currentVehicle.remoteStopSupported =YES;
    SOSVehicle *vehicle = CustomerInfo.sharedInstance.userBasicInfo.currentSuite.vehicle;
    for (NNCommand *command in commands.command) {
        if ([[command name] isEqualToString:@"lockDoor"]) {
            vehicle.lockDoorSupported = YES;
        }else if([[command name] isEqualToString:@"unlockDoor"]){
            vehicle.unlockDoorSupported = YES;
        }else if([[command name] isEqualToString:@"alert"]){
            vehicle.vehicleAlertSupported =YES;
        }else if([[command name] isEqualToString:@"diagnostics"])	{
            vehicle.dataRefreshSupported =YES;
            NNCommandData *commandData = [command commandData];
            NSArray *data = commandData.supportedDiagnostics.supportedDiagnostic;
            for (NSString *supportData in data) {
                if ([supportData isEqualToString:@"ODOMETER"]) {
                    vehicle.odoMeterSupport = YES;
                }else if([supportData isEqualToString:@"TIRE PRESSURE"]) {
                    vehicle.tirePressureSupport = YES;
                }else if([supportData isEqualToString:@"OIL LIFE"]) {
                    vehicle.oilLifeSupport = YES;
                } else if([supportData isEqualToString:@"FUEL TANK INFO"]) {
                    vehicle.fuelTankInfoSupport = YES;
                }  else if([supportData isEqualToString:@"VEHICLE RANGE"]) {
                    vehicle.vehicleRangeSupported = YES;
                }  else if([supportData isEqualToString:@"LAST TRIP DISTANCE"]) {
                    vehicle.lastTripDistanceSupport = YES;
                }    else if([supportData isEqualToString:@"GET CHARGE MODE"]) {
                    vehicle.getChargeModeSupport = YES;
                }    else if([supportData isEqualToString:@"EV SCHEDULED CHARGE START"]) {
                    vehicle.evScheduledChargeStartSupport = YES;
                }    else if([supportData isEqualToString:@"GET COMMUTE SCHEDULE"]) {
                    vehicle.getCommuteScheduleSupport = YES;
                }    else if([supportData isEqualToString:@"EV PLUG VOLTAGE"]) {
                    vehicle.evPlugVoltageSupport = YES;
                }    else if([supportData isEqualToString:@"EV BATTERY LEVEL"]) {
                    vehicle.evBatteryLevelSupport = YES;
                }    else if([supportData isEqualToString:@"EV PLUG STATE"]) {
                    vehicle.evPlugStateSupport = YES;
                }    else if([supportData isEqualToString:@"EV ESTIMATED CHARGE END"]) {
                    vehicle.evEstimatedChargeEndSupport = YES;
                }   else if([supportData isEqualToString:@"EV CHARGE STATE"]) {
                    vehicle.evChargeStateSupport = YES;
                }   else if([supportData isEqualToString:@"LIFETIME EV ODOMETER"]) {
                    vehicle.lifeTimeEVOdometerSupport = YES;
                }   else if([supportData isEqualToString:@"LIFETIME FUEL ECON"]){
                    vehicle.lifetimeFuelEconSupport = YES;
                } 	else if([supportData isEqualToString:@"LAST TRIP FUEL ECONOMY"]){
                    vehicle.lastTripFuelEconSupport = YES;
                }
                
                // ICM 2.0 新增						  "WINDOW POSITION STATUS"
                else if([supportData isEqualToString:@"WINDOW POSITION STATUS"]){
                    vehicle.windowPositionSupport = YES;
                }     else if([supportData isEqualToString:@"SUNROOF POSITION STATUS"]){
                    vehicle.sunroofPositionSupport = YES;
                }     else if([supportData isEqualToString:@"DOOR AJAR STATUS"]){
                    vehicle.doorPositionSupport = YES;
                }     else if([supportData isEqualToString:@"DOOR LAST REMOTE LOCK STATUS"]){
                    vehicle.lastDoorCommandSupport = YES;
                }     else if([supportData isEqualToString:@"HAZARDLIGHTS STATUS"]){
                    vehicle.flashStateSupport = YES;
                }     else if([supportData isEqualToString:@"HEADLIGHTS STATUS"]){
                    vehicle.lightStateSupport = YES;
                }     else if([supportData isEqualToString:@"REMOTE START STATUS"]){
                    vehicle.engineStateSupport = YES;
                }     else if([supportData isEqualToString:@"REAR CLOSURE AJAR STATUS"]){
                    vehicle.trunkPositionSupport = YES;
                }
                
                //K228纯电车新增
                else if ([supportData isEqualToString:@"BATTERY RANGE"]) {
                    vehicle.bevBatteryRangeSupported = YES;
                }else if ([supportData isEqualToString:@"BATTERY STATUS"]) {
                    vehicle.bevBatteryStatusSupported = YES;
                }
                
                //My21新增
                else if ([supportData isEqualToString:@"BRAKE PAD LIFE"]) {
                    vehicle.brakePadLifeSupported = YES;
                }else if ([supportData isEqualToString:@"ENGINE AIR FILTER MONITOR STATUS"]) {
                    vehicle.engineAirFilterMonitorStatusSupported = YES;
                }
            }
            
        }else if([[command name] isEqualToString:@"start"]){
            vehicle.remoteStartSupported =YES;
        }else if([[command name] isEqualToString:@"cancelStart"]){
            vehicle.remoteStopSupported =YES;
        }else if([[command name] isEqualToString:@"sendTBTRoute"]){
            vehicle.sendToTBTSupported =YES;
        }
        else if([[command name] isEqualToString:@"location"]){
            vehicle.myVehicleLocationSupported =YES;
        }else if([[command name]isEqualToString:@"sendNavDestination"]){
            vehicle.sendToNAVSupport = YES;
        }else if([[command name]isEqualToString:@"chargeOverride"]){
            vehicle.getChargeModeSupport = YES;
        }else if([[command name]isEqualToString:@"getChargingProfile"]){
            vehicle.getChargingProfileSupport = YES;
        }else if([[command name]isEqualToString:@"setChargingProfile"]){
            vehicle.setChargingProfileSupport = YES;
        }else if([[command name]isEqualToString:@"getCommuteSchedule"]){
            vehicle.getCommuteScheduleSupported = YES;
        }else if([[command name]isEqualToString:@"setCommuteSchedule"]){
            vehicle.setCommuteScheduleSupport = YES;
        }
        
        // ICM 2.0 新增
        else if ([[command name] isEqualToString: @"openTrunk"])	{
            vehicle.openTrunkSupported = YES;
        }	else if ([[command name] isEqualToString: @"openWindows"])    {
            vehicle.openWindowSupported = YES;
        }    else if ([[command name] isEqualToString: @"closeWindows"])    {
            vehicle.closeWindowSupported = YES;
        }    else if ([[command name] isEqualToString: @"openSunroof"])    {
            vehicle.openSunroofSupported = YES;
        }    else if ([[command name] isEqualToString: @"closeSunroof"])    {
            vehicle.closeSunroofSupported = YES;
        }    else if ([[command name] isEqualToString: @"setHvacSettings"])    {
            vehicle.HVACSettingSupported = YES;
        }
        
        // My21新增
        else if ([command.name isEqualToString:@"unlockTrunk"]) {
            vehicle.unlockTrunkSupported = YES;
        }else if ([command.name isEqualToString:@"lockTrunk"]) {
            vehicle.lockTrunkSupported = YES;
        }
    }
    // 根据loginstate状态判断就行
//    [CustomerInfo sharedInstance].getCommandsComplete = YES;
}

+ (NSString *)generateTimeStamp     {
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *timestempString = [dateFormatter stringFromDate: currentTime];
    return timestempString;
}

+ (NSString *)generateNonce     {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    return (__bridge NSString *)string;
}

+ (void)LoginFrist_SuccessWithIdpid:(NSString *)idpid withVin:(NSString *)vin     {
    //判断当前用户是否在数组中，如果在的话，就不是第一次在当前设备登录
    NSData *saveMenulistDate = UserDefaults_Get_Object(NN_TEMP_USERLOGIN_IDPID);
    NSData *saveMenuVinlistDate = UserDefaults_Get_Object(NN_TEMP_USERLOGIN_vin);
    NSArray* idpidArray;
    NSArray* vinArray;
    if (saveMenulistDate) {
     idpidArray  = [NSKeyedUnarchiver unarchiveObjectWithData:saveMenulistDate];
    }
    if (saveMenuVinlistDate) {
     vinArray  = [NSKeyedUnarchiver unarchiveObjectWithData:saveMenuVinlistDate];
    }
    
    if(![idpidArray containsObject:idpid]){
        UserDefaults_Set_Object([NSNumber numberWithBool:YES],USER_FIRST_LOGIN);
        if (![vinArray containsObject:vin]) {
            UserDefaults_Set_Object([NSNumber numberWithBool:YES],USER_FIRST_LOGIN_vin);
        }else{
            UserDefaults_Set_Object([NSNumber numberWithBool:NO],USER_FIRST_LOGIN_vin);
        }
    }else{
        UserDefaults_Set_Object([NSNumber numberWithBool:NO],USER_FIRST_LOGIN);
        UserDefaults_Set_Object([NSNumber numberWithBool:NO],USER_FIRST_LOGIN_vin);
    }
}

+ (BOOL)isToastLoadUserProfileFailure     {
//    if ([LoginManage sharedInstance].loadingUserProfile == LOGIN_LOADING_USER_PROFILE_INPROGRESS){
//        [Util toastWithMessage:@"您的信息正在更新，请稍后重试。"];
//        return YES;
//    }
//
//    if ([LoginManage sharedInstance].loadingUserProfile == LOGIN_LOADING_USER_PROFILE_FAILURE){
//        [Util toastWithMessage:@"您的信息获取失败，请重新登录或联系安吉星客服。"];
//        return YES;
//    }
    return NO;
}

+ (BOOL)isLoadUserProfileFailure     {
    if ([LoginManage sharedInstance].loadingUserProfile == LOGIN_LOADING_USER_PROFILE_INPROGRESS ||
        [LoginManage sharedInstance].loadingUserProfile == LOGIN_LOADING_USER_PROFILE_FAILURE){
        return YES;
    }
    return NO;
}

+ (NSData *)zipImageDataLessthan10MB:(NSData *)imageData     {
    CGFloat maxFileSize = 10*1024*1024;
    NSData *compressedData;
    if (imageData.length > maxFileSize) {
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        UIImage *image = [UIImage imageWithData:imageData];
        compressedData = UIImageJPEGRepresentation(image, compression);
        while ([compressedData length] > maxFileSize && compression > maxCompression) {
            compression -= 0.1;
            compressedData = UIImageJPEGRepresentation(image, compression);
        }
    }
    else
    {
        compressedData = imageData;
    }
    
    return compressedData;
}

+ (NSData *)zipImageDataLessthan1MB:(UIImage *)image     {
    if (image) {
        CGFloat maxFileSize = 0.8*1024*1024;
        NSData *compressedData;
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
        if (imageData.length >= maxFileSize) {
            CGFloat compression = 0.1f;
            compressedData = UIImageJPEGRepresentation(image, compression);
        }
        else     {
            CGFloat compression = 0.5f;
            compressedData = UIImageJPEGRepresentation(image, compression);
        }
        return compressedData;
    }else{
        return [NSData data];
    }
}

+ (NSData *)compressedImageFiles:(UIImage *)image imageKB:(CGFloat)fImageKBytes  {
    //二分法压缩图片
    CGFloat compression = 1;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    NSUInteger fImageBytes = fImageKBytes * 1000;//需要压缩的字节Byte，iOS系统内部的进制1000
    if (imageData.length <= fImageBytes){
        return (imageData);
    }
    CGFloat max = 1;
    CGFloat min = 0;
    //指数二分处理，s首先计算最小值
    compression = pow(2, -6);
    imageData = UIImageJPEGRepresentation(image, compression);
    if (imageData.length < fImageBytes) {
        //二分最大10次，区间范围精度最大可达0.00097657；最大6次，精度可达0.015625
        for (int i = 0; i < 6; ++i) {
            compression = (max + min) / 2;
            imageData = UIImageJPEGRepresentation(image, compression);
            //容错区间范围0.9～1.0
            if (imageData.length < fImageBytes * 0.9) {
                min = compression;
            } else if (imageData.length > fImageBytes) {
                max = compression;
            } else {
                break;
            }
        }
        
        return(imageData);
        
    }
    
    // 对于图片太大上面的压缩比即使很小压缩出来的图片也是很大，不满足使用。
    //然后再一步绘制压缩处理
    UIImage *resultImage = [UIImage imageWithData:imageData];
    while (imageData.length > fImageBytes) {
        @autoreleasepool {
            CGFloat ratio = (CGFloat)fImageBytes / imageData.length;
            //使用NSUInteger不然由于精度问题，某些图片会有白边
       NSLog(@">>>>>>>>>>>>>>>>>%f>>>>>>>>>>>>%f>>>>>>>>>>>%f",resultImage.size.width,sqrtf(ratio),resultImage.size.height);
            CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                     (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
            resultImage = [self createImageForData:imageData maxPixelSize:MAX(size.width, size.height)];
            imageData = UIImageJPEGRepresentation(resultImage, compression);
        }
    }
    
    //   整理后的图片尽量不要用UIImageJPEGRepresentation方法转换，后面参数1.0并不表示的是原质量转换。
    return(imageData);
}

+ (UIImage *)createImageForData:(NSData *)data maxPixelSize:(NSUInteger)size {
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0,
                (__bridge CFDictionaryRef)@{ (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                             (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
                                             (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES, });
    CFRelease(source);
    CFRelease(provider);
    if (!imageRef) {
        return nil;
    }
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    return toReturn;
}

+ (NSString *) recodesign:(NSString *)str     {
    NSString *maskedPhone;
    if (str.length > 4) {
        NSString *preStr = [str substringWithRange:NSMakeRange(0, 3)];
        NSString *rearStr = [str substringFromIndex:[str length]-4];
        maskedPhone = [NSString stringWithFormat:@"%@****%@",preStr,rearStr];
    }
    return maskedPhone;
}

+ (SOSVehicleStatus)updateVehicleStatus {
    // Rate for vehicle
    VehicleStatus oilStatus = [SOSVehicleVariousStatus oilStatus]; //机油
    VehicleStatus tirePressureStatus = [SOSVehicleVariousStatus tirePressureStatus]; //胎压
    VehicleStatus gasStatus = [SOSVehicleVariousStatus gasStatus]; //燃油
    VehicleStatus batteryStatus = [SOSVehicleVariousStatus batteryStatusCharge];//电池
    VehicleStatus brakeStatus = SOSVehicleVariousStatus.brakeStatus; //刹车片
    
    NSInteger totalValue;
    if ([Util vehicleIsBEV]) {
        totalValue = tirePressureStatus | batteryStatus;
    }else if (Util.vehicleIsMy21) {
        totalValue = gasStatus | oilStatus | tirePressureStatus | batteryStatus | brakeStatus;
    }else {
        totalValue = gasStatus | oilStatus | tirePressureStatus | batteryStatus;
    }
    if (totalValue >= 0x100) { //256
        return SOSVehicleStatusBad;
    } else if (totalValue > 0x010) {//16
        return SOSVehicleStatusBetter;
    } else if (totalValue > 0x000) {//0
        return SOSVehicleStatusBest;
    }

    return SOSVehicleStatusUnknow;
    
}

+ (SOSChargeStatus)updateChargeStatus {
    if ([Util vehicleIsPHEV] || [Util vehicleIsBEV]) {
        NSString *chargeState = [CustomerInfo sharedInstance].chargeState;
        if ([chargeState isEqualToString:SOSVehicleChargeStateCharging]) {
            return SOSChargeStatus_charging;
        }else if ([chargeState isEqualToString:SOSVehicleChargeStateNotCharging]) {
            return SOSChargeStatus_not_charging;
        }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingComplete]) {
            
            return SOSChargeStatus_charging_complete;
            
        }else if ([chargeState isEqualToString:SOSVehicleChargeStateChargingAborted]) {
            return SOSChargeStatus_charging_aborted;
            
        }
    }
    return SOSChargeStatus_Unknow;
}

+ (SOSVehicleConditionCategory)updateVehicleConditionCategory {
    SOSVehicleConditionCategory category = NoVehicleConditionData;
    RemoteControlStatus vehicleRefreshStatus = [SOSGreetingManager shareInstance].vehicleStatus;
    if (vehicleRefreshStatus == RemoteControlStatus_OperateSuccess) {
        SOSVehicleStatus vehicleStatus = [Util updateVehicleStatus];
        SOSChargeStatus chargeStatus = [Util updateChargeStatus];
        if (vehicleStatus == SOSVehicleStatusBest) {
            if (chargeStatus == SOSChargeStatus_charging) {
                category = CHARGING;
            }else if (chargeStatus == SOSChargeStatus_charging_complete) {
                category = STATECHARGINGCOMPLETE;
            }else {
                category = VehicleConditionFine;
            }
            
        }else if (vehicleStatus == SOSVehicleStatusBad || vehicleStatus == SOSVehicleStatusBetter) {
            VehicleStatus oilStatus = [SOSVehicleVariousStatus oilStatus]; //机油
            VehicleStatus tirePressureStatus = [SOSVehicleVariousStatus tirePressureStatus]; //胎压
            VehicleStatus gasStatus = [SOSVehicleVariousStatus gasStatus]; //燃油
            VehicleStatus batteryStatus = [SOSVehicleVariousStatus batteryStatusCharge];//电池
            VehicleStatus brakeStatus = SOSVehicleVariousStatus.brakeStatus;//刹车片
            
            int badCount = 0;
            if (oilStatus > OIL_GREEN) {
                badCount ++;
            }
            
            if (gasStatus > GAS_GREEN_GOOD) {
                badCount ++;
            }
            
            if (tirePressureStatus > PRESSURE_GREEN) {
                badCount ++;
            }
            
            if (batteryStatus > BATTERY_GREEN) {
                badCount ++;
            }
            if (brakeStatus > BRAKE_GREEN) {
                badCount ++;
            }
            if (badCount >=2) {
                category = MoreThanOneBad;
            }else if (oilStatus == OIL_RED) {
                category = OilNotEnough;
            }else if (oilStatus == OIL_YELLOW) {
                category = OilLow;
            }else if (tirePressureStatus == PRESSURE_RED) {
                category = TirePressureBad;
            }else if (tirePressureStatus == PRESSURE_YELLOW) {
                category = TirePressureLow;
            }else if (gasStatus == GAS_RED) {
                category = FuelNotEnough;
            }else if (gasStatus == GAS_YELLOW) {
                category = FuelLow;
            }else if (chargeStatus == SOSChargeStatus_charging_aborted) {
                category = CHARGINGABORTED;
            }else if (batteryStatus == BATTERY_RED) {
                category = BatteryNotEnough;
            }else if (batteryStatus == BATTERY_YELLOW) {
                category = BatteryLow;
            }else if (brakeStatus == BRAKE_YELLOW) {
                category = BRAKEPADSNOTENOUGH;
            }else if (brakeStatus == BRAKE_RED) {
                category = BRAKEPADSLOW;
            }
        }    else {
            category = NoVehicleConditionData;
        }
        
    }
    return category;
}


+ (NSArray <NSString *>*)getAllPropertyKeys:(Class)theClass {
    NSMutableArray<NSString *> *keys = @[].mutableCopy;
    unsigned int methodCount = 0;
    objc_property_t * properties = class_copyPropertyList(theClass, &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        objc_property_t property = properties[i];
        //通过property_getName函数获得属性的名字
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    return keys.copy;
}

+ (NSArray<NSString *> *)getAllPropertyValues:(__kindof NSObject *)object ignoreKeys:(NSArray<NSString *> *)ignoreKeys{
    NSMutableArray<NSString *> *keys = [Util getAllPropertyKeys:[object class]].mutableCopy;
    if (ignoreKeys) {
        [keys removeObjectsInArray:ignoreKeys];
    }
    NSMutableArray<NSString *> *values = @[].mutableCopy;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [object valueForKey:key];
        if (value.length > 0) {
            [values addObject:[object valueForKey:key]];
        }else {
            [values addObject:@""];
        }
    }];
    return values.copy;
}

+ (BOOL)checkCodesign {
    //apple文档地址https://developer.apple.com/library/content/technotes/tn2311/_index.html
    //这个是自动化测试用的teamId,个人99$账号
    NSString *kAutoTestPrefixId = @"VW62KRYY4N";
    //这个是99$账号的teamId。
    NSString *kPrefixId = @"S6UQPQ9V64";
    //这个是99$账号的onstar工程的prefixId，因为项目非常早期时候创建，当时prefixId还不是teamId，后来所有创建的项目prefixId都是teamId
    NSString *kPrefixOldId = @"2TNUB3VRCY";
    //这个是299$账号的teamId。这个账号里onstar工程的prefixId已经是teamId了。
    NSString *kPrefixIdInhouse = @"2UB35A3DKB";
    
    // 描述文件路径
    NSString *embeddedPath = [[NSBundle SOSBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:embeddedPath]) {
        
        // 读取application-identifier
        NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
        NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (int i = 0; i < [embeddedProvisioningLines count]; i++) {
            if ([[embeddedProvisioningLines objectAtIndex:i] rangeOfString:@"application-identifier"].location != NSNotFound) {
                
                NSInteger fromPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"<string>"].location+8;
                
                NSInteger toPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"</string>"].location;
                
                NSRange range;
                range.location = fromPosition;
                range.length = toPosition - fromPosition;
                
                NSString *fullIdentifier = [[embeddedProvisioningLines objectAtIndex:i+1] substringWithRange:range];
                
                //                NSLog(@"%@", fullIdentifier);
                
                NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
                NSString *appIdentifier = [identifierComponents firstObject];
                
                // 对比签名ID
                if (![appIdentifier isEqual:kPrefixId] && ![appIdentifier isEqualToString:kPrefixOldId] && ![appIdentifier isEqualToString:kPrefixIdInhouse] && ![appIdentifier isEqualToString:kAutoTestPrefixId]) {
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"codesign verification failed." preferredStyle:UIAlertControllerStyleAlert];
                    [ac show];
                    return NO;
                }
                break;
            }
        }
    }
    return YES;
    

}


+ (UIColor *)randomColor {
    int R = arc4random_uniform(256);
    int G = arc4random_uniform(256);
    int B = arc4random_uniform(256);
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
}


+ (NSString *)getChineseForBrand:(NSString *)brand {
    if ([brand isEqualToString:@"BUICK"]) {
        return @"别克";
    }else if ([brand isEqualToString:@"CHEVROLET"]) {
        return @"雪佛兰";
    }else if ([brand isEqualToString:@"CADILLAC"]) {
        return @"凯迪拉克";
    }else {
        return @"";
    }
}

+ (NSString *)jsonFromDict:(NSDictionary *)dict     {
    NSString *jsonStr;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        return nil;
    } else {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonStr;
}

//后视镜用户名限制
+ (BOOL)isValidMirrorUserName:(NSString *)userName     {
    NSString * regex =@"^[0-9A-Za-z\u4e00-\u9fa5]{1,20}$";// @"^[A-Za-z0-9]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userName];
    
    
}

//正则验证身份证
+ (BOOL)isValidateIDCard:(NSString *)cardNum     {
    NSString * regex =@"^[0-9A-Za-z]{18}$";// @"^[A-Za-z0-9]{6,18}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:cardNum];
}


#pragma mark - MA9.0 通用HUD控件
+ (void)showHUD {
    if (SOS_ONSTAR_WINDOW.hidden) {
        return;
    }
    [SVProgressHUD show];
}

+ (void)showHUDWithStatus:(NSString *)status {
    [self showHUDWithStatus:status subStatus:nil];
}

+ (void)showHUDWithStatus:(NSString *)status subStatus:(NSString *)subStatus {
    if (SOS_ONSTAR_WINDOW.hidden) {
        return;
    }
    [SVProgressHUD showWithStatus:status];

}

+ (void)showSuccessHUDWithStatus:(NSString *)status {
    [self showSuccessHUDWithStatus:status subStatus:nil];
}

+ (void)showSuccessHUDWithStatus:(NSString *)status subStatus:(NSString *)subStatus {
    if (SOS_ONSTAR_WINDOW.hidden) {
        return;
    }
    [SVProgressHUD showSuccessWithStatus:status];
}

+ (void)showErrorHUDWithStatus:(NSString *)status {
    [self showErrorHUDWithStatus:status subStatus:nil];
}

+ (NSString *)timeformatFromSeconds:(NSInteger)seconds {
    //format of hour
    seconds = seconds/1000;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld", (long) seconds / 3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds % 3600) / 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    //format of time
    NSString *format_time = nil;
    if (seconds / 3600 <= 0) {
        format_time = [NSString stringWithFormat:@"00:%@:%@", str_minute, str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@:%@", str_hour, str_minute, str_second];
    }
    return format_time;
}

+ (void)showErrorHUDWithStatus:(NSString *)status subStatus:(NSString *)subStatus {
    if (SOS_ONSTAR_WINDOW.hidden) {
        return;
    }
    [Util hideLoadView];
    [SVProgressHUD showErrorWithStatus:status];
}

+ (void)showInfoHUDWithStatus:(NSString *)status {
    [self showInfoHUDWithStatus:status subStatus:nil];
}

+ (void)showInfoHUDWithStatus:(NSString *)status subStatus:(NSString *)subStatus {
    if (SOS_ONSTAR_WINDOW.hidden) {
        return;
    }
    [SVProgressHUD showInfoWithStatus:status];
}

+ (void)dismissHUD {
    if (SOS_ONSTAR_WINDOW.hidden) {
           return;
       }
    [SVProgressHUD dismiss];
}

+ (void)saveEventStartDate:(NSDate*)startData endDate:(NSDate*)endDate alarm:(float)alarm eventTitle:(NSString*)eventTitle location:(NSString*)location notes:(NSString*)notes{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                }
                else
                {
                    //事件保存到日历
                    
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title  = eventTitle;
                    event.location = location;
                    //设定事件开始时间
                    event.startDate = startData;
                    //设定事件结束时间
                    event.endDate   = endDate;
                    
                    //添加提醒 可以添加多个
                    //第一次提醒  (几分钟q前-)
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:alarm]];
                    //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -1.0f]];
                    //第二次提醒  ()
                    //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -10.0f * 24]];
                    
                    event.notes = notes;
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    
                    [eventStore saveEvent:event span:EKSpanThisEvent commit:NO  error:&err];
                    
                    NSLog(@"保存日程成功");
                    
                }
            });
        }];
    }
}

+ (void)saveEvents:(NSArray <SOSUserScheduleItem *>*)events successHandler:(void(^)(void))handler{    if (events && events.count >0) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])     {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)	{
                    }	else if (!granted)	{
                        //被用户拒绝，不允许访问日历
                        BOOL hasDeny = UserDefaults_Get_Bool(@"denyCalendar");
                        if (hasDeny) {
                            [[LoginManage sharedInstance] addPopViewAction:^{
                                [Util showAlertWithTitle:@"提示" message:@"安吉星需要您的同意,才能访问日历。" completeBlock:^(NSInteger buttonIndex) {
                                    [[LoginManage sharedInstance] nextPopViewAction];
                                    if (buttonIndex == 1) {
                                        
                                        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];

                                        }	else	{
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

                                        }
                                    }
                                } cancleButtonTitle:@"取消" otherButtonTitles:@"打开权限",nil];
                                
                            }];
                        }else{
                            UserDefaults_Set_Bool(YES, @"denyCalendar");

                        }
                        
                    }
                    else
                    {
                        //事件保存到日历
                        for (SOSUserScheduleItem * item in events) {
                            EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                            event.title  = item.remindContent;
                            //                        event.location = location;
                         
                            NSDate *triaggerTime = [NSDate dateWithTimeIntervalSince1970:item.remindDate.longValue/1000];
                            NSLog(@"triaggerTime%@",triaggerTime);
                            event.startDate = triaggerTime;
                            //设定事件结束时间
                            event.endDate   = triaggerTime;
                            //添加提醒 可以添加多个
                            //第一次提醒  (几分钟q前-)
                            //                        [event addAlarm:[EKAlarm alarmWithRelativeOffset:alarm]];
                            //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -1.0f]];
                            //第二次提醒  ()
                            //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -10.0f * 24]];
                            event.notes = item.remindContent;
                            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                            NSError *err;
                            [eventStore saveEvent:event span:EKSpanThisEvent commit:NO error:&err];
                            item.calendarId = event.eventIdentifier;
                            NSLog(@"保存%@日程成功",item.serviceId);
                        }
                        // 一次提交所有操作到事件库
                        NSError*error11 =nil;
                        BOOL commitSuccess= [eventStore commit:&error11];
                        if(!commitSuccess) {
                            NSLog(@"一次性提交删除事件是失败%@",error11);
                        }else{
                            NSLog(@"一次性写入日程成功");
                            if (handler) {
                                handler();
                            }
#if DEBUG
                            [Util toastWithMessage:@"写入系统日程成功"];
#endif
                            
                        }
                        
                    }
                });
            }];
        }
    }
}

+ (void)deleteEvents:(NSArray <SOSUserScheduleItem *>*)events{
    if (events && events.count>0) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])     {
            
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)
                    {
                        
                    }
                    else if (!granted)
                    {
                        //被用户拒绝，不允许访问日历
                    }
                    else
                    {
                        NSError *error = nil;
                        for (SOSUserScheduleItem *eventItem in events) {
                            EKEvent *event = [eventStore eventWithIdentifier:eventItem.calendarId ];
                            BOOL  successDelete=[eventStore removeEvent:event span:EKSpanFutureEvents commit:NO error:&error];
                            if(!successDelete){
                                NSLog(@"删除本条事件失败");
                                
                            }else{
                                NSLog(@"删除本条事件成功，%@",error);
                            }
                            
                        }
                       // 一次提交所有操作到事件库
                        BOOL commitSuccess= [eventStore commit:&error];
                        if(!commitSuccess) {
                            NSLog(@"一次性提交删除事件是失败==%@",error);

                    }else{
                        NSLog(@"删除事件OK");
#ifdef DEBUG
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [Util toastWithMessage:@"删除事件成功"];
                        });
#endif
                    }

                    }
                });
            }];
        }
    }
}
//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)ToHex:(long long int)tmpid     {
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i =0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)     {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}
// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString {
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}


+ (void)fireLocalNotification:(NSString *)title body:(NSString *)body identifier:(NSString *)identifier {
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.alertSetting == UNNotificationSettingEnabled) {
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = title ? : @"安吉星";
            content.sound = UNNotificationSound.defaultSound;
            content.body = body ? : @"";
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
            UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }else {
                    NSLog(@"本地推送陈宫");
                }
            }];
        }
    }];
}

+ (NSString *)decodeBase64:(NSString *)base64 {
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodedStr = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedStr;
}
@end
