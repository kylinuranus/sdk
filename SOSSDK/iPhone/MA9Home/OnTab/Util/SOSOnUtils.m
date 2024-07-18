//
//  SOSOnUtils.m
//  Onstar
//
//  Created by onstar on 2018/12/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSOnUtils.h"

@implementation SOSOnUtils


+ (NSArray *)normalFullRemoteItems {
    
    NSArray *items = @[
                      @{@"title":@"远程启动",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60",
                        @"defaultImg":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60-2",
                        @"operationType":@(SOSRemoteOperationType_RemoteStart)
                        },
                      @{@"title":@"车门解锁",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_remote-locking_loading_60x60",
                        @"defaultImg":@"Icon／60x60／operation-area／car_control_icon_remote-locking_loading_60x60-2",
                        @"operationType":@(SOSRemoteOperationType_UnLockCar)
                        },
                      @{@"title":@"闪灯鸣笛",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_flash-whistle_def_60x60",
                        @"defaultImg":@"Icon／60x60／operation-area／car_control_icon_flash-whistle_def_60x60-2",
                        @"operationType":@(SOSRemoteOperationType_LightAndHorn)
                        },
                      @{@"title":@"取消启动",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60(1)",
                        @"defaultImg":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60(1)-2",
                        @"operationType":@(SOSRemoteOperationType_RemoteStartCancel)
                        },
                      @{@"title":@"车门上锁",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_remote-unlocking_def_60x60",
                        @"defaultImg":@"Icon／60x60／operation-area／car_control_icon_remote-unlocking_def_60x60-2",
                        @"operationType":@(SOSRemoteOperationType_LockCar)
                        },
                      @{@"title":@"空调操控",
                        @"img":@"Icon／60x60／operation-area／car_control_icon_air-conditioning_def_60x60",
                        @"defaultImg":@"on_key_car_control_air_conditioning_def_a",
                        @"operationType":@(SOSRemoteOperationType_OpenHVAC)
                        }
                      ];
    return items;
}


+ (NSArray *)defaultRemoteItems {
//    return [self normalFullRemoteItems];
    NSArray *normalItems = [self normalFullRemoteItems];
    NSMutableArray *items = normalItems.mutableCopy;
//    for (NSDictionary *item in normalItems) {
//        if ([item objectForKey:@"defaultImg"]) {
//            NSMutableDictionary *muItem = item.mutableCopy;
//            [muItem setValue:[item objectForKey:@"defaultImg"] forKey:@"img"];
//            [items addObject:muItem.copy];
//        }
//    }
    [items removeLastObject];
    return items.copy;
}


+ (NSArray *)icmFullRemoteItems {
    NSArray *items = @[
                       @{@"title":@"天窗开启",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60(1)-1",
                         @"defaultImg":@"icon_open-skylight_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_OpenRoofWindow)
                         },
                       @{@"title":@"车窗开启",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_remote-unlocking_def_60x60-1",
                         @"defaultImg":@"car_control_icon_open-window_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_OpenWindow)
                         },
                       @{@"title":@"后备箱开启",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_remote-locking_loading_60x60-1",
                         @"defaultImg":@"icon_open-trunk_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_OpenTrunk)
                         },
                       @{@"title":@"天窗关闭",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60-1",
                         @"defaultImg":@"icon_close-skylight_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_CloseRoofWindow)
                         },
                       @{@"title":@"车窗关闭",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_flash-whistle_def_60x60-1",
                         @"defaultImg":@"icon_close-window_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_CloseWindow)
                         }
                       ];
    return items;
}

+ (NSArray *)my21FullRemoteItems {
    NSArray *items = @[
                       @{@"title":@"天窗开启",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60(1)-1",
                         @"defaultImg":@"icon_open-skylight_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_OpenRoofWindow)
                         },
                       @{@"title":@"车窗开启",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_remote-unlocking_def_60x60-1",
                         @"defaultImg":@"car_control_icon_open-window_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_OpenWindow)
                         },
                       @{@"title":@"后备箱解锁",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_remote-locking_loading_60x60-1",
                         @"defaultImg":@"icon_open-trunk_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_UnlockTrunk)
                         },
                       @{@"title":@"天窗关闭",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_cancel-remote_def_60x60-1",
                         @"defaultImg":@"icon_close-skylight_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_CloseRoofWindow)
                         },
                       @{@"title":@"车窗关闭",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_flash-whistle_def_60x60-1",
                         @"defaultImg":@"icon_close-window_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_CloseWindow)
                         },
                       @{@"title":@"后备箱上锁",
                         @"img":@"Icon／60x60／operation-area／car_control_icon_trunk_lock_def_60x60",
                         @"defaultImg":@"icon_open-trunk_disabled_60x60",
                         @"operationType":@(SOSRemoteOperationType_LockTrunk)
                       },
    ];
    return items;
}

+ (NSArray *)supportNormalRemoteItems {
    NSMutableArray *items = [self normalFullRemoteItems].mutableCopy;
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    
    //远程启动
    if(![CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.remoteStartSupported){
        [set addIndex:0];
        [set addIndex:3];
    }
    [items removeObjectsAtIndexes:set];
    //空调
    if (![CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.HVACSettingSupported) {
        [items removeLastObject];
    }
    
    return items.copy;
}


+ (NSArray *)supportIcmRemoteItems {
    if (![Util vehicleIsICM2] && !Util.vehicleIsMy21) {
        return @[];
    }
    NSMutableArray *items = Util.vehicleIsMy21 ? self.my21FullRemoteItems.mutableCopy : [self icmFullRemoteItems].mutableCopy;
    SOSVehicle *vehicle = [CustomerInfo sharedInstance].currentVehicle;
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    if (vehicle.openSunroofSupported == NO) {
        [set addIndex:0];
        [set addIndex:3];
    }
    
    if (vehicle.openWindowSupported == NO) {
        [set addIndex:1];
        [set addIndex:4];
    }
    
    if (Util.vehicleIsMy21) {
        if (vehicle.unlockTrunkSupported == NO) {
            [set addIndex:2];
            [set addIndex:5];
        }
    }else {
        if (vehicle.openTrunkSupported == NO) {
            [set addIndex:2];
            Util.vehicleIsMy21 ? [set addIndex:5] : nil;
        }

    }
    
    [items removeObjectsAtIndexes:set];
    return items.copy;
}

@end
