//
//  SOSLifeThirdFuncsHelper.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/7.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSQuickStartHelper.h"
#import "SOSRemoteTool.h"
#import "SOSCardUtil.h"
#import "NavigateSearchVC.h"
#if __has_include(<BlePatacSDK/BlueToothManager.h>)
#import "BlueToothManager+SOSBleExtention.h"
#endif
#import "SOSLifeJumpHelper.h"
#import "SOSHomeAndCompanyTool.h"
#import "SOSNavigateTool.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSLifeJumpHeader.h"
#import "SOSItemModel.h"
#import "AccountInfoUtil.h"
#define RESOURCE_KEY     @"resource"
#define GENERATION_KEY   @"generation"
#define ROLE_KEY         @"role"
#define UNRELEATED_KEY   @"unReleated"
#define SPECIAL_KEY         @"specialVisiableCondition"


@interface SOSQuickStartHelper ()
@property (copy, nonatomic) NSArray *totalThirdFuncsVisible; //全量数组(权限表)
@property (copy, nonatomic) NSMutableDictionary *thirldFuncsDefault; //string

@end

@implementation SOSQuickStartHelper

static SOSQuickStartHelper *instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SOSQuickStartHelper new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle SOSBundle] pathForResource:@"qsVisible" ofType:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        _totalThirdFuncsVisible = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSString *jsonName = @"qsDefault";
#ifdef SOSSDK_SDK
        jsonName = @"qsDefaultSDK";
#endif
        NSString *defaultPath = [[NSBundle SOSBundle] pathForResource:jsonName ofType:@"json"];
        NSData *defaultData = [[NSData alloc] initWithContentsOfFile:defaultPath];
        _thirldFuncsDefault = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:defaultData options:kNilOptions error:nil]] ;
    }
    return self;
}
//static NSLock* optLock = nil;

- (void)reloadSelectAndAllQS {
    //    if (serverThirdFuncs.count <= 0) {
    //        return @[];
    //    }
    //#1.先从本地权限表中筛选
//    if (!optLock) {
//        optLock = [[NSLock alloc] init];
//    }
//    [optLock lock];
    
    
// xiang 8 ying chang san cen
    BOOL shouldHideSC = NO;
//    BOOL shouldHideSC = [CustomerInfo.sharedInstance.userBasicInfo.idpUserId.uppercaseString isEqualToString:[Util decodeBase64:SP_ID].uppercaseString];
//    NSString *jsonName = shouldHideSC  ? @"qsDefaultTest" : @"qsDefault";
//
//    NSString *defaultPath = [[NSBundle SOSBundle] pathForResource:jsonName ofType:@"json"];
//    NSData *defaultData = [[NSData alloc] initWithContentsOfFile:defaultPath];
//    _thirldFuncsDefault = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:defaultData options:kNilOptions error:nil]];
    
    
    NSString *key = [self convertRoleToKeyString];
    if ([self fetchLocalStorage] == nil) {
        if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
            //不支持远程启动的过滤一下
            if (![CustomerInfo sharedInstance].currentVehicle.remoteStartSupported) {
                //                static dispatch_once_t onceToken;
                //                dispatch_once(&onceToken, ^{
                if ([_thirldFuncsDefault[key] containsObject:@"1"]) {
                    
                    if ([SOSCheckRoleUtil isOwner]) {
                        NSMutableArray * temp = [NSMutableArray arrayWithArray:_thirldFuncsDefault[key]];
                        [temp replaceObjectAtIndex:0 withObject:@"3"];
                        [_thirldFuncsDefault setValue:temp forKey:key];
                    }
                    if ([SOSCheckRoleUtil isDriverOrProxy]) {
                        NSMutableArray * temp = [NSMutableArray arrayWithArray:_thirldFuncsDefault[key]];
                        [temp replaceObjectAtIndex:0 withObject:@"11"];
                        
                        [_thirldFuncsDefault setValue:temp forKey:key];
                    }
                }
            }
            //                });
        }else{
            if (![_thirldFuncsDefault[key] containsObject:@"1"]) {
                BOOL default3 = [_thirldFuncsDefault[key] containsObject:@"3"];
                BOOL default11 = [_thirldFuncsDefault[key] containsObject:@"11"];
                if ( default3||default11 ) {
                    NSInteger index = 0 ;
                    if (default3) {
                        index = [_thirldFuncsDefault[key] indexOfObject:@"3"];
                    }
                    if (default11) {
                        index = [_thirldFuncsDefault[key] indexOfObject:@"11"];
                    }
                    NSMutableArray * temp = [NSMutableArray arrayWithArray:_thirldFuncsDefault[key]];
                    [temp replaceObjectAtIndex:index withObject:@"1"];
                    [_thirldFuncsDefault setValue:temp forKey:key];
                }
            }
        }
    }
    NSArray<NSString *> *userFuncsID = [self fetchLocalStorage] ? : _thirldFuncsDefault[key];
    
    _selectFuncs = [NSMutableArray arrayWithArray:userFuncsID];
    
    _totalShowFuncs = @[].mutableCopy;
    [_totalThirdFuncsVisible enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray <SOSQSModelProtol>* columnArray = @[].mutableCopy;
        [obj enumerateObjectsUsingBlock:^(NSDictionary* _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            NSDictionary * item = [[obj1 allValues]objectAtIndex:0];
            BOOL visible = [self judgeVisible:item];
            SOSItemModel * modelItem = [SOSItemModel mj_objectWithKeyValues:item];
            NSString * itemID =[[obj1 allKeys] objectAtIndex:0];
            modelItem.ID =itemID;
            if (shouldHideSC && [itemID isEqualToString:@"42"]) {
                visible = NO;
            }
#ifdef SOSSDK_SDK
            if ([itemID isEqualToString:@"34"]) {
                visible = NO;
            }
            if ([itemID isEqualToString:@"37"]) {
                visible = NO;
            }
            if ([itemID isEqualToString:@"26"]) {
                visible = NO;
            }
            if ([itemID isEqualToString:@"42"]) {
                visible = NO;
            }
            if ([itemID isEqualToString:@"27"]) {
                visible = NO;
            }
            if ([itemID isEqualToString:@"23"]&& !SOS_BUICK_PRODUCT) {
                           visible = NO;
                       }
            if ([itemID isEqualToString:@"13"] && !SOS_BUICK_PRODUCT) {
                visible = NO;
            }
        
            if ([itemID isEqualToString:@"12"] && !SOS_BUICK_PRODUCT) {
                visible = NO;
            }
         
#endif
            if (visible) {
                [columnArray addObject:modelItem];
            }
            if ([userFuncsID containsObject:itemID]) {
                NSInteger index = [userFuncsID indexOfObject:itemID];
                [_selectFuncs replaceObjectAtIndex:index withObject:modelItem];
            }
        }];
        [_totalShowFuncs addObject:columnArray];
    }];
    
//   [optLock unlock];
    
}

- (BOOL)saveThirdFuncs:(NSArray<id<SOSQSModelProtol>> *)funcs {
    NSMutableArray<NSString *> *storages = @[].mutableCopy;
    if (funcs.count <= 0) {
        return NO;
    }
    NSMutableArray *uploads = @[].mutableCopy;
    
    [funcs enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [storages addObject:obj.modelID ? : @""];
        [uploads addObject:@{obj.modelID:@{@"title":obj.modelTitle}}];
    }];
    if ([[LoginManage sharedInstance] isLoadingTokenReady]) {
         [self uploadSelectQuickStart:[uploads toJson] needRecore:NO];
    }
    NSString *fileName = [[self getFileName] stringByAppendingString:@".plist"];
    NSString *filePath = [[self getThirdFuncsDirectoryPath] stringByAppendingPathComponent:fileName];
    BOOL success = [NSKeyedArchiver archiveRootObject:storages toFile:filePath];
    return success;
}
//首次登入上传快捷键
-(void)uploadSelectQuickIfFirstLogin{
    
    if ([[Util getAppVersionCode] isEqualToString:@"90100"] ) {
        BOOL hasUpload = UserDefaults_Get_Bool([self customizeQSUploadKey]);
        if (!hasUpload) {
            NSMutableArray *uploads = @[].mutableCopy;
            [_selectFuncs enumerateObjectsUsingBlock:^(id<SOSQSModelProtol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [uploads addObject:@{obj.modelID:@{@"title":obj.modelTitle}}];
            }];
            [self uploadSelectQuickStart:[uploads toJson] needRecore:YES];
        }
    }
}
//上传快捷键
-(void)uploadSelectQuickStart:(NSString *)selectQSStr needRecore:(BOOL)record{
    NSLog(@"uploadSelectQuickStart=======%@",selectQSStr);
    [AccountInfoUtil upLoadUserCustomizeQuickStart:selectQSStr successBlock:^(NSString *response) {
        if (record) {
            UserDefaults_Set_Bool(YES, [self customizeQSUploadKey]);
        }
    } failedBlock:nil];
}
-(NSString *)customizeQSUploadKey{
    NSString * key = [NSString stringWithFormat:@"SOSCustomizeQSUpload%@%@",[CustomerInfo sharedInstance].userBasicInfo.idpUserId,[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];
    return key;

}
#pragma mark - Private Method

- (BOOL)judgeVisible:(NSDictionary *)authDic {
    if (!authDic) {
        return NO;
    }
    BOOL resourceVisible = [self judgeResource:authDic];
    BOOL generationVisible = [self judgeGeneration:authDic];
    BOOL roleVisible = [self judgeRole:authDic];
    BOOL specialVisible = [self judgeSpecial:authDic];
    return (resourceVisible && generationVisible && roleVisible && specialVisible);
    
}

//判断车的能源类型
- (BOOL)judgeResource:(NSDictionary *)authDic {
    NSDictionary *resource = authDic[RESOURCE_KEY];
    if ([resource[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key = @"";
    if ([Util vehicleIsBEV]) {
        key = @"BEV";
    }else if ([Util vehicleIsPHEV]) {
        key = @"PHEV";
    }else {
        
        key = @"FV";
        
    }
    return [resource[key] boolValue];
}

- (BOOL)judgeGeneration:(NSDictionary *)authDic {
    NSDictionary *generation = authDic[GENERATION_KEY];
    if ([generation[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key ;
    if ([Util vehicleIsG9]) {
        key = @"G9";
    }
    if ([Util vehicleIsG10]) {
        key = @"G10";
    }
    if ([Util vehicleIsIcm]) {
        key = @"ICM";
    }
    if ([Util vehicleIsICM2]) {
        key = @"ICM2";
    }
    if (key) {
        return [generation[key] boolValue];
    }else{
        return YES;
    }
}

- (BOOL)judgeRole:(NSDictionary *)authDic {
    NSDictionary *role = authDic[ROLE_KEY];
    if ([role[UNRELEATED_KEY] boolValue]) {
        return YES;
    }
    NSString *key = [self convertRoleToKeyString];
    return [role[key] boolValue];
}
- (BOOL)judgeSpecial:(NSDictionary *)authDic {
    NSString *special = authDic[SPECIAL_KEY];
    if (special) {
        //special不带Argument
        return  [self invocationVisiableFrom:special];
    }
    return YES;
}

- (NSString *)convertRoleToKeyString {
    NSString *key = @"";
    if ([SOSCheckRoleUtil isVisitor]) {
        key = @"visitor";
    }else if ([SOSCheckRoleUtil isProxy]) {
        key = @"proxy";
    }else if ([SOSCheckRoleUtil isDriver]) {
        key = @"driver";
    }else if ([SOSCheckRoleUtil isOwner]) {
        key = @"owner";
    }else {
        key = @"unlogged";
    }
    return key;
}


#pragma mark - local storage
- (NSString *)getThirdFuncsDirectoryPath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsPath stringByAppendingPathComponent:@"qs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (NSString *)getFileName {
    NSMutableString *fileName = @"".mutableCopy;
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"unKnowUser"];
    [fileName appendString:@"_"];
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin ? : @"unKnowVin"];
    [fileName appendString:@"_qs"];
    return fileName.copy;
    
}

- (nullable NSArray<NSString *> *)fetchLocalStorage {
    NSString *fileName = [[self getFileName] stringByAppendingString:@".plist"];
    NSString *filePath = [[self getThirdFuncsDirectoryPath] stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSArray<NSString *> *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return array;
    
}
#pragma -- invocation visiable from JSON
-(BOOL)invocationVisiableFrom:(NSString *)selStr{
    
    SEL sel = NSSelectorFromString(selStr);
    NSMethodSignature *signature =[[self class]instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:sel];
    [invocation invoke];
    if (signature.methodReturnLength > 0) {
        BOOL result = YES;
        [invocation getReturnValue:&result];
        return result;
    }
    return YES;
}
-(BOOL)supportRemote{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.remoteStartSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportopenSunroof{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.openSunroofSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportcloseSunroof{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.closeSunroofSupported) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)supportopenWindow{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.openWindowSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportcloseWindow{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.closeWindowSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportopenTrunk{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.openTrunkSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportHVACSetting{
    if ([[LoginManage sharedInstance] isLoadingVehicleCommandsReady]) {
        if (![CustomerInfo sharedInstance].currentVehicle.HVACSettingSupported) {
            return NO;
        }
    }
    return YES;
}
-(BOOL)supportWIFI{
    if ([CustomerInfo sharedInstance].currentVehicle.wifiSupported &&
        ![Util vehicleIsIcm]) {
        return YES;
    }
    return NO;
}
-(BOOL)supportDrivingBehavior{
    if ([SOSCheckRoleUtil isOwner]) {
        if ([HandleDataRefreshDataUtil showDriveScore]){
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}

-(BOOL)supportBLE{
    
    if ([SOSCheckRoleUtil isOwner] && [CustomerInfo sharedInstance].currentVehicle.ble) {
        return YES;
    }
    return NO;
}
//-(BOOL)checkAuthByOwner{
//    
//    if ([SOSCheckRoleUtil isOwner] && [CustomerInfo sharedInstance].currentVehicle.ble) {
//        return YES;
//    }
//    return NO;
//}

//+ (BOOL)supportIcmRemoteItems {
//    if (![Util vehicleIsICM2]) {
//        return @[];
//    }
//    NSMutableArray *items = [self icmFullRemoteItems].mutableCopy;
//    SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
//    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
//    if (vehicle.openSunroofSupported == NO) {
//        [set addIndex:0];
//        [set addIndex:3];
//    }
//
//    if (vehicle.openWindowSupported == NO) {
//        [set addIndex:1];
//        [set addIndex:4];
//    }
//
//    if (vehicle.openTrunkSupported == NO) {
//        [set addIndex:2];
//    }
//    [items removeObjectsAtIndexes:set];
//    return items.copy;
//}
#pragma mark --invocation action from JSON

-(void)invocationActionFromModel:(SOSItemModel *)modelItem{
    NSDictionary *item = modelItem.mj_JSONObject;
    if (modelItem.modelNeedLogin) {
        [LoginManage sharedInstance].loginSuccessAction = ^{
            if ([self judgeVisible:item]) {
                [self invocationActionFromStr:modelItem.modelAction];
            }
        };
    }else {
        [self invocationActionFromStr:modelItem.modelAction];
    }
}

-(void)invocationActionFromStr:(NSString *)selStr{
    SEL sel = NSSelectorFromString(selStr);
    NSMethodSignature *signature =[[self class]instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:sel];
    [invocation invoke];
}

-(void)remoteStartAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_RemoteStart)];
    [SOSDaapManager sendActionInfo:Quickly_RemoteStart];
}
-(void)cancelStartAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_RemoteStartCancel)];
    [SOSDaapManager sendActionInfo:Quickly_CancelStart];
}
-(void)unLockDoorAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_UnLockCar)];
    [SOSDaapManager sendActionInfo:Quickly_DoorUnlock];
//  //todo 940
//    SOSWebViewController *webVC = [[SOSWebViewController alloc] initWithUrl:@"https://idt6sit.onstar.com.cn/mweb/ma80/checkApp.html"];
//    [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:webVC animated:YES];

}
-(void)lockDoorAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_LockCar)];
    [SOSDaapManager sendActionInfo:Quickly_DoorLock];

}
-(void)lightAndHornAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_LightAndHorn)];
    [SOSDaapManager sendActionInfo:Quickly_HornsLights];
}
-(void)HVACSettingAction{
    [SOSRemoteTool startHVACSetting] ;
    
    [SOSDaapManager sendActionInfo:QUICKLY_HVACSETTING];

}
-(void)closeSunroofAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_CloseRoofWindow)];
    [SOSDaapManager sendActionInfo:QUICKLY_CLOSESUNROOF];

}
-(void)openSunroofAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_OpenRoofWindow)];
    [SOSDaapManager sendActionInfo:QUICKLY_OPENSUNROOF];
    
}
-(void)closeWindowAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_CloseWindow)];
    [SOSDaapManager sendActionInfo:QUICKLY_CLOSEWINDOWS];

}
-(void)openWindowAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_OpenWindow)];
    [SOSDaapManager sendActionInfo:QUICKLY_OPENWINDOWS];

}
-(void)openTrunkAction{
    SOSRemoteOperationType opeType = Util.vehicleIsMy21 ? SOSRemoteOperationType_UnlockTrunk : SOSRemoteOperationType_OpenTrunk;
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:opeType];
    [SOSDaapManager sendActionInfo:QUICKLY_OPENTRUNK];

}
-(void)BLEShareAction{
    
    //共享我的车
    [SOSCardUtil routerToOwnerBle];
    [SOSDaapManager sendActionInfo:QUICKLY_BLE_SHAREMYCAR];

}
-(void)BLEPackageAction{
//    [Util toastWithMessage:@"待定"];
    //蓝牙钥匙
//    if ([[BlueToothManager sharedInstance] isConnected]) {
//        [SOSCardUtil gotoBleOperationPage];
//    }else {
    [SOSCardUtil routerToBleKeyPage];
    [SOSDaapManager sendActionInfo:QUICKLY_BLE_RECEIVEDSHARING];

//    }
}
-(void)vehicleLocationAction{
    [[SOSRemoteTool sharedInstance] startOperationWithOperationType:(SOSRemoteOperationType_VehicleLocation)];
    [SOSDaapManager sendActionInfo:Quickly_locator];
}
-(void)oneKeyToHomeAction{
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }

    [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:[SOS_APP_DELEGATE fetchMainNavigationController] WithType:(pageTypeEasyBackHome) needShowWaitingVC:NO needShowToast:YES];
    [SOSDaapManager sendActionInfo:Quickly_ToHome];
}
-(void)oneKeyToComAction{
    if( [Util show23gPackageDialog]){//是2g3g用户弹完提示框,流程就结束了
        return;
    }

    [[SOSHomeAndCompanyTool sharedInstance] EasyGoHomeFromVC:[SOS_APP_DELEGATE fetchMainNavigationController] WithType:(pageTypeEasyBackCompany) needShowWaitingVC:NO needShowToast:YES];
    [SOSDaapManager sendActionInfo:Quickly_ToOffice];

}
-(void)leaveNowAction{
    NavigateSearchVC *vc = [NavigateSearchVC new];
    [[SOS_APP_DELEGATE  fetchMainNavigationController] pushViewController:vc animated:YES];
    [SOSDaapManager sendActionInfo:Quickly_SearchPOI];
}
//电子围栏
-(void)geoFenceAction{
    [SOSNavigateTool showGeoPageFromVC:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController];
    [SOSDaapManager sendActionInfo:Quickly_SecurityZone];

}
//近期行程
-(void)recentTravelAction{
    [SOSCardUtil routerToRecentJourney];
    [SOSDaapManager sendActionInfo:QUICKLY_MYTRIP];

}
-(void)chargeStationAction{
    [SOSCardUtil routerToChargeStation];
    [SOSDaapManager sendActionInfo:Quick_Chargestation];
}
-(void)onstarLocationAction{
    [SOSCardUtil routerToOnstarDeviceLocation];
    [SOSDaapManager sendActionInfo:Quick_LBS];
}
-(void)forumAction{
    if ([LoginManage sharedInstance].loginState == LOGIN_STATE_NON||[SOSCheckRoleUtil isVisitor]) {
        [SOSCardUtil routerToVc:nil checkAuth:YES checkLogin:YES];
    }else{
        __block  BOOL hasForumMessage = NO;
        if ([MsgCenterManager getMessageList].notificationStatusList) {
            [[MsgCenterManager getMessageList].notificationStatusList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MessageModel *m = (MessageModel*)obj;
                if ([m.category isEqualToString:@"FORUM"]) {
                    if (m.totalCount > 0) {
                        [SOSCardUtil routerToMessageWithCategory:m];
                        hasForumMessage = YES;
                        *stop = YES;
                    }
                }
            }];
        }
        if (!hasForumMessage) {
            [Util toastWithMessage:@"暂无星论坛消息"];
        }
    }
   
}
-(void)onstarFriendAction{
#ifndef SOSSDK_SDK
    [[SOSIMLoginManager sharedManager] pushToIMHomePageFrom:[SOS_APP_DELEGATE fetchMainNavigationController].topViewController];
    [SOSDaapManager sendActionInfo:QUICKLY_ONSTARFRIEND];
#endif
}
-(void)vehicleDetectionReportAction{
    [SOSCardUtil routerToVehicleDetectionReport];
    [SOSDaapManager sendActionInfo:Quickly_OVD];
}
-(void)wifiAction{
    [SOSDaapManager sendActionInfo:Quickly_VehicularWiFi];
    [SOSCardUtil routerToWifiSetting];
}
-(void)operationHistoryAction{
//    if ([SOSCheckRoleUtil isOwner]) {
        [SOSCardUtil routerToOperationHistory];
//    }
    [SOSDaapManager sendActionInfo:Quickly_RecentHistory];
}
-(void)chargeModeAction{
    [SOSCardUtil routerToChargeMode];
    [SOSDaapManager sendActionInfo:Quickly_ChargeManagement];
}
-(void)buypackageAction{
    [SOSCardUtil routerToBuyOnstarPackage:(PackageType_Core)];
    [SOSDaapManager sendActionInfo:Quick_ServicePackage];
}
-(void)onstarReflectAction{
    [SOSCardUtil routerToOnstarReflect];
    [SOSDaapManager sendActionInfo:QUICKLY_ONSTARLINK];

}
-(void)flueStationAction{
    [SOSCardUtil routerToFlueStation];
    [SOSDaapManager sendActionInfo:QUICKLY_OILSTATION];

}
//-(void)preferDealerAction{
//
//}
-(void)dealerRevAction{
    [SOSCardUtil routerToDealerRev];
    [SOSDaapManager sendActionInfo:Quickly_DealerReservation];
}
-(void)backMirrorAction{
    [SOSCardUtil routerToBackMirror];
    [SOSDaapManager sendActionInfo:QUICKLY_REARVIEW];

}
-(void)anyueChageAction{
    [SOSAYChargeManager enterAYChargeVCIsFromCarLife:YES];
    [SOSDaapManager sendActionInfo:QUICKLY_ANYUECHARGE];

}
-(void)dateNotifyAction{
    SOSCarSecretaryViewController *vc = [SOSCarSecretaryViewController new];
    [SOSCardUtil routerToVc:vc checkAuth:YES checkLogin:YES];
    [SOSDaapManager sendActionInfo:QUICKLY_CHEDAIXIANREMIND];

}
-(void)vehicleEvaluateAction{
    [SOSCardUtil routerToCarReportH5];
    [SOSDaapManager sendActionInfo:QUICKLY_CARESTIMATE];

}

- (void)carClass	{
    [SOSDaapManager sendActionInfo:Quickly_Training];
    [SOSCardUtil carClass];
}


- (void)onstarShop {
    [SOSCardUtil routerToOnstarShop];
    
    
}
@end
